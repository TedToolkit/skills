#!/usr/bin/env python3
"""Run skill evals for a selected marketplace plugin with Codex CLI.

For each scenario in every ``eval.yaml`` under ``tests/`` this:
  1. builds a throwaway work dir,
  2. runs the scenario's setup fixture (offline),
  3. invokes the skill via headless ``codex exec`` from that dir,
  4. checks the scenario's deterministic assertions against the produced files
     and the model's printed output,
  5. prints a pass/fail report and writes results.json / results.md.

Only the standard library + PyYAML are required. A local ``codex`` CLI (or ``CODEX_BIN`` pointing
to one), ``git``, and a ``bash`` (Git Bash on Windows is fine) must be available; the runner locates
bash itself if it isn't on PATH. The runner never downloads Codex through npm.

Usage:
    py -3.10 tests/run_evals.py [skill ...] [--plugin PLUGIN] [--filter SUBSTR] [--keep] [--judge]

With no plugin it groups evals by ``tests/<plugin>/`` and loads each matching plugin in turn.
Skill names match the directory holding the eval.yaml (e.g. ``generate-commit-message``).
Scenarios marked ``mode: static`` run their fixture commands without invoking Codex.
"""
from __future__ import annotations

import argparse
import ctypes
from ctypes import wintypes
from datetime import datetime
import hashlib
import json
import os
import re
import signal
import shutil
import stat
import subprocess
import sys
import tempfile
import time
import uuid
from pathlib import Path

import yaml

TESTS_DIR = Path(__file__).resolve().parent
REPO_ROOT = TESTS_DIR.parent
RESULTS_DIR = TESTS_DIR / ".results"

# ---------------------------------------------------------------------------
# Tool discovery
# ---------------------------------------------------------------------------

def find_bash() -> str | None:
    windows_candidates = (
        r"C:\Program Files\Git\bin\bash.exe",
        r"C:\Program Files\Git\usr\bin\bash.exe",
        r"C:\Program Files (x86)\Git\bin\bash.exe",
    )
    # Prefer Git Bash on Windows. ``bash`` on PATH may be the WSL launcher,
    # which cannot consume the Windows cwd/PATH values this runner supplies.
    candidates = windows_candidates if os.name == "nt" else ()
    for c in candidates:
        if Path(c).exists():
            return c
    return shutil.which("bash")


def git_bin_dirs(bash_path: str) -> list[str]:
    """Dirs to add to PATH so bash, grep -P and the real curl resolve."""
    p = Path(bash_path)
    # .../Git/bin/bash.exe or .../Git/usr/bin/bash.exe -> find the Git root
    for parent in p.parents:
        if parent.name.lower() == "git":
            return [str(parent / "usr" / "bin"), str(parent / "bin")]
    return [str(p.parent)]


BASH = find_bash()
CODEX = os.environ.get("CODEX_BIN") or shutil.which("codex")


if os.name == "nt":
    class _IoCounters(ctypes.Structure):
        _fields_ = [(name, ctypes.c_uint64) for name in (
            "ReadOperationCount", "WriteOperationCount", "OtherOperationCount",
            "ReadTransferCount", "WriteTransferCount", "OtherTransferCount")]

    class _BasicLimitInformation(ctypes.Structure):
        _fields_ = [
            ("PerProcessUserTimeLimit", ctypes.c_int64),
            ("PerJobUserTimeLimit", ctypes.c_int64),
            ("LimitFlags", wintypes.DWORD),
            ("MinimumWorkingSetSize", ctypes.c_size_t),
            ("MaximumWorkingSetSize", ctypes.c_size_t),
            ("ActiveProcessLimit", wintypes.DWORD),
            ("Affinity", ctypes.c_size_t),
            ("PriorityClass", wintypes.DWORD),
            ("SchedulingClass", wintypes.DWORD),
        ]

    class _ExtendedLimitInformation(ctypes.Structure):
        _fields_ = [
            ("BasicLimitInformation", _BasicLimitInformation),
            ("IoInfo", _IoCounters),
            ("ProcessMemoryLimit", ctypes.c_size_t),
            ("JobMemoryLimit", ctypes.c_size_t),
            ("PeakProcessMemoryUsed", ctypes.c_size_t),
            ("PeakJobMemoryUsed", ctypes.c_size_t),
        ]


def _windows_kill_job(proc: subprocess.Popen):
    """Put a Windows subprocess in a job that kills its complete tree on close."""
    if os.name != "nt":
        return None
    kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel32.CreateJobObjectW.restype = wintypes.HANDLE
    kernel32.SetInformationJobObject.argtypes = [wintypes.HANDLE, ctypes.c_int,
                                                  ctypes.c_void_p, wintypes.DWORD]
    kernel32.AssignProcessToJobObject.argtypes = [wintypes.HANDLE, wintypes.HANDLE]
    kernel32.CloseHandle.argtypes = [wintypes.HANDLE]
    job = kernel32.CreateJobObjectW(None, None)
    if not job:
        return None
    info = _ExtendedLimitInformation()
    info.BasicLimitInformation.LimitFlags = 0x00002000  # JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
    if not kernel32.SetInformationJobObject(job, 9, ctypes.byref(info), ctypes.sizeof(info)):
        kernel32.CloseHandle(job)
        return None
    if not kernel32.AssignProcessToJobObject(job, wintypes.HANDLE(proc._handle)):
        kernel32.CloseHandle(job)
        return None
    return job


def _close_windows_handle(handle) -> None:
    if handle is not None:
        kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
        kernel32.CloseHandle.argtypes = [wintypes.HANDLE]
        kernel32.CloseHandle(handle)


def run_bounded(command: list[str], *, timeout: float, capture_output: bool = False,
                **kwargs) -> subprocess.CompletedProcess:
    """Run a command with a wall-clock bound that also terminates child processes."""
    if capture_output:
        if "stdout" in kwargs or "stderr" in kwargs:
            raise ValueError("capture_output cannot be combined with stdout/stderr")
        kwargs["stdout"] = subprocess.PIPE
        kwargs["stderr"] = subprocess.PIPE
    text_mode = bool(kwargs.get("text") or kwargs.get("universal_newlines"))
    encoding = kwargs.get("encoding") or "utf-8"
    errors = kwargs.get("errors") or "strict"
    stdout_target = kwargs.get("stdout")
    stderr_target = kwargs.get("stderr")
    stdout_file = tempfile.TemporaryFile() if stdout_target == subprocess.PIPE else None
    stderr_file = tempfile.TemporaryFile() if stderr_target == subprocess.PIPE else None
    if stdout_file is not None:
        kwargs["stdout"] = stdout_file
    if stderr_file is not None:
        kwargs["stderr"] = stderr_file
    if os.name == "nt":
        kwargs["creationflags"] = kwargs.get("creationflags", 0) | subprocess.CREATE_NEW_PROCESS_GROUP
    else:
        kwargs["start_new_session"] = True
    try:
        proc = subprocess.Popen(command, **kwargs)
    except Exception:
        for output_file in (stdout_file, stderr_file):
            if output_file is not None:
                output_file.close()
        raise
    kill_job = _windows_kill_job(proc)
    timed_out = False
    try:
        proc.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        if os.name == "nt":
            # Closing the job terminates bash/codex and every descendant,
            # including MSYS children that otherwise retain output handles.
            _close_windows_handle(kill_job)
            kill_job = None
            if proc.poll() is None:
                proc.kill()
            try:
                proc.wait(timeout=1)
            except subprocess.TimeoutExpired:
                proc.kill()
        else:
            try:
                os.killpg(proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            if proc.poll() is None:
                proc.kill()
            try:
                proc.wait(timeout=0.2)
            except subprocess.TimeoutExpired:
                pass
    _close_windows_handle(kill_job)
    stdout = stderr = None
    if stdout_file is not None:
        stdout_file.seek(0)
        stdout = stdout_file.read()
        stdout_file.close()
    if stderr_file is not None:
        stderr_file.seek(0)
        stderr = stderr_file.read()
        stderr_file.close()
    if text_mode:
        if isinstance(stdout, bytes):
            stdout = stdout.decode(encoding, errors)
        if isinstance(stderr, bytes):
            stderr = stderr.decode(encoding, errors)
    if timed_out:
        raise subprocess.TimeoutExpired(command, timeout, output=stdout, stderr=stderr)
    return subprocess.CompletedProcess(command, proc.returncode, stdout, stderr)


def preflight(plugin_dir: Path, *, require_codex: bool) -> None:
    problems = []
    if require_codex and not CODEX:
        problems.append("`codex` not found on PATH; install Codex CLI or set CODEX_BIN to its executable.")
    elif require_codex:
        try:
            probe = run_bounded(codex_command("--version"), capture_output=True, text=True,
                                encoding="utf-8", errors="replace", timeout=10)
            if probe.returncode != 0:
                detail = (probe.stderr or probe.stdout or "unknown error").strip()[:200]
                problems.append(f"`codex --version` failed: {detail}. Set CODEX_BIN to a working executable.")
        except (OSError, subprocess.SubprocessError) as exc:
            problems.append(f"`codex` was found but could not start: {exc}. Set CODEX_BIN to a working executable.")
    if not shutil.which("git"):
        problems.append("`git` not found on PATH.")
    if not BASH:
        problems.append("`bash` not found (install Git for Windows, or add bash to PATH).")
    if not plugin_dir.is_dir():
        problems.append(f"plugin dir not found: {plugin_dir}")
    if problems:
        print("Preflight failed:", file=sys.stderr)
        for p in problems:
            print("  - " + p, file=sys.stderr)
        sys.exit(2)


def codex_command(*args: str) -> list[str]:
    return [CODEX, *args]


def codex_shell_environment_args(setup: dict, env: dict[str, str],
                                 *, extra_names: tuple[str, ...] = ()) -> list[str]:
    """Return config overrides for explicitly approved eval-only variables."""
    names = list(setup.get("codex_shell_environment", []) or []) + list(extra_names)
    args = ["-c", 'shell_environment_policy.inherit="core"',
            "-c", "shell_environment_policy.ignore_default_excludes=false"]
    for name in names:
        if not isinstance(name, str) or not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
            raise ValueError(f"invalid codex shell environment name: {name!r}")
        if name not in env:
            raise ValueError(f"codex shell environment variable is not set: {name}")
        args.extend(["-c", f"shell_environment_policy.set.{name}={json.dumps(env[name])}"])
    return args


def scenario_execution_path(workdir: Path, path_prefix: list[str], inherited: str) -> str:
    """Build the deterministic post-setup PATH used by Codex and assertions."""
    binstub = workdir / ".binstub"
    parts = ([str(binstub)] if binstub.is_dir() else []) + path_prefix + [inherited]
    return os.pathsep.join(parts)


class ToolCommandCapture(list[str]):
    """Recognized command inputs plus a completeness verdict for the JSON event schema."""

    def __init__(self, commands=(), *, complete: bool = True, issues=()):
        super().__init__(commands)
        self.complete = complete
        self.issues = tuple(issues)


def extract_tool_commands(event_text: str) -> ToolCommandCapture | None:
    """Extract shell command inputs from ``codex exec --json`` events.

    Tool outputs are deliberately ignored: an inventory command may emit a sensitive path as
    metadata without that path appearing in the command that Codex chose to execute.
    """
    commands: list[str] = []
    incomplete_types: set[str] = set()
    parsed_events = 0
    for line in event_text.splitlines():
        if not line.strip():
            continue
        try:
            event = json.loads(line)
        except json.JSONDecodeError:
            continue
        parsed_events += 1
        item = event.get("item") if isinstance(event, dict) else None
        candidates = [event, item]
        for candidate in candidates:
            if not isinstance(candidate, dict):
                continue
            candidate_type = candidate.get("type")
            if candidate_type not in {"command_execution", "shell_command", "exec_command"}:
                looks_command_like = (
                    "command" in candidate or "cmd" in candidate or
                    isinstance(candidate_type, str) and
                    re.search(r"(?:command|shell|exec)", candidate_type, re.IGNORECASE)
                )
                if looks_command_like:
                    incomplete_types.add(str(candidate_type or "<missing type>"))
                continue
            command = candidate.get("command") or candidate.get("cmd")
            if isinstance(command, str):
                commands.append(command)
            elif isinstance(command, list) and all(isinstance(part, str) for part in command):
                commands.append(" ".join(command))
            else:
                incomplete_types.add(str(candidate_type))
    if not parsed_events:
        return None
    return ToolCommandCapture(
        commands,
        complete=not incomplete_types,
        issues=sorted(incomplete_types),
    )


def _identity_path(path: Path) -> str:
    resolved = path.resolve()
    try:
        return resolved.relative_to(REPO_ROOT).as_posix()
    except ValueError:
        return resolved.as_posix()


def build_input_identity(roots: list[Path]) -> dict:
    """Hash the exact plugin, eval, and runner inputs selected for a run."""
    normalized_roots = sorted({root.resolve() for root in roots}, key=lambda p: p.as_posix())
    files: set[Path] = set()
    for root in normalized_roots:
        if root.is_file():
            files.add(root)
            continue
        if root.is_dir():
            files.update(path for path in root.rglob("*")
                         if path.is_file() and "__pycache__" not in path.parts
                         and path.suffix != ".pyc")

    digest = hashlib.sha256()
    for path in sorted(files, key=_identity_path):
        content = path.read_bytes()
        digest.update(_identity_path(path).encode("utf-8"))
        digest.update(b"\0")
        digest.update(len(content).to_bytes(8, "big"))
        digest.update(content)

    head = None
    try:
        proc = subprocess.run(
            ["git", "-C", str(REPO_ROOT), "rev-parse", "HEAD"],
            capture_output=True, text=True, encoding="utf-8", errors="replace", check=True)
        head = proc.stdout.strip()
    except (OSError, subprocess.SubprocessError):
        pass

    return {
        "algorithm": "sha256(path-utf8 + nul + uint64be-size + bytes)",
        "source_head": head,
        "roots": [_identity_path(root) for root in normalized_roots],
        "file_count": len(files),
        "sha256": digest.hexdigest(),
    }


def input_identity_is_current(expected: dict, roots: list[Path]) -> bool:
    """Return whether selected input bytes still match their pre-run identity."""
    current = build_input_identity(roots)
    return (current["file_count"] == expected["file_count"]
            and current["sha256"] == expected["sha256"])


def require_current_input_identities(
        identities: dict[str, dict], roots_by_plugin: dict[str, list[Path]]) -> None:
    """Reject any selected plugin whose inputs changed since its recorded identity."""
    stale = [plugin for plugin, identity in identities.items()
             if not input_identity_is_current(identity, roots_by_plugin[plugin])]
    if stale:
        raise RuntimeError(
            f"{', '.join(sorted(stale))}: selected plugin, eval, or runner inputs changed during execution")


def install_eval_plugin(plugin_dir: Path) -> tuple[Path, str, str]:
    """Install a copied plugin from a unique local marketplace for this run."""
    root = Path(tempfile.mkdtemp(prefix="codex-eval-marketplace-"))
    marketplace = f"eval-{uuid.uuid4().hex}"
    plugin = f"{plugin_dir.name}-eval-{uuid.uuid4().hex[:8]}"
    destination = root / "plugins" / plugin
    destination.parent.mkdir(parents=True)
    shutil.copytree(plugin_dir, destination)
    for rel in ("plugin.json", ".codex-plugin/plugin.json", ".claude-plugin/plugin.json"):
        manifest_path = destination / rel
        if manifest_path.is_file():
            manifest_data = json.loads(manifest_path.read_text(encoding="utf-8"))
            manifest_data["name"] = plugin
            manifest_path.write_text(json.dumps(manifest_data), encoding="utf-8")
    # Codex CLI accepts Claude-compatible marketplace manifests for local
    # sources; this avoids relying on Windows' case-insensitive .codex path.
    manifest_dir = root / ".claude-plugin"
    manifest_dir.mkdir()
    manifest = {"name": marketplace, "interface": {"displayName": "Codex eval"}, "plugins": [{
        "name": plugin, "source": {"source": "local", "path": f"./plugins/{plugin}"},
        "policy": {"installation": "AVAILABLE", "authentication": "ON_INSTALL"}, "category": "Productivity"}]}
    (manifest_dir / "marketplace.json").write_text(json.dumps(manifest), encoding="utf-8")
    try:
        for command in (codex_command("plugin", "marketplace", "add", str(root)),
                        codex_command("plugin", "add", f"{plugin}@{marketplace}")):
            result = run_bounded(command, timeout=60, capture_output=True, text=True,
                                 encoding="utf-8", errors="replace")
            if result.returncode:
                raise RuntimeError((result.stderr or result.stdout).strip())
    except Exception:
        cleanup_eval_plugin(plugin, marketplace, root)
        raise
    return root, marketplace, plugin


def cleanup_eval_plugin(plugin: str, marketplace: str, root: Path) -> None:
    if CODEX:
        for command in (codex_command("plugin", "remove", f"{plugin}@{marketplace}"),
                        codex_command("plugin", "marketplace", "remove", marketplace)):
            try:
                run_bounded(command, timeout=30, capture_output=True, text=True,
                            encoding="utf-8", errors="replace")
            except (OSError, subprocess.SubprocessError):
                pass
    _rmtree_best_effort(root)


# ---------------------------------------------------------------------------
# Discovery
# ---------------------------------------------------------------------------

def eval_plugins() -> list[str]:
    return sorted(
        path.name
        for path in TESTS_DIR.iterdir()
        if path.is_dir() and not path.name.startswith(".") and any(path.rglob("eval.yaml"))
    )


def discover(plugin: str, skill_filters: list[str]):
    plugin_tests = TESTS_DIR / plugin
    if not plugin_tests.is_dir():
        return
    for path in sorted(plugin_tests.rglob("eval.yaml")):
        skill = path.parent.name
        if skill_filters and skill not in skill_filters:
            continue
        with open(path, encoding="utf-8") as fh:
            spec = yaml.safe_load(fh)
        yield skill, path.parent, spec


def select_scenarios(spec: dict, *, tier: str,
                     name_filter: str | None = None) -> list[dict]:
    """Apply cost-tier and name selectors as a strict intersection."""
    if tier not in {"static", "smoke", "full"}:
        raise ValueError(f"unsupported eval tier: {tier!r}")
    if not isinstance(spec, dict):
        raise ValueError("eval specification must be a mapping")

    scenarios = spec.get("scenarios", [])
    if not isinstance(scenarios, list) or any(not isinstance(item, dict) for item in scenarios):
        raise ValueError("eval 'scenarios' must be a list of mappings")
    names = [scenario.get("name") for scenario in scenarios]
    if any(not isinstance(name, str) or not name.strip() for name in names):
        raise ValueError("every eval scenario must have a non-empty string name")
    if len(names) != len(set(names)):
        raise ValueError("eval scenario names must be unique within one eval.yaml")

    smoke_names = spec.get("smoke_scenarios", [])
    if not isinstance(smoke_names, list) or any(
            not isinstance(name, str) or not name.strip() for name in smoke_names):
        raise ValueError("eval 'smoke_scenarios' must be a list of non-empty scenario names")
    if len(smoke_names) != len(set(smoke_names)):
        raise ValueError("eval 'smoke_scenarios' must not contain duplicates")
    unknown = sorted(set(smoke_names) - set(names))
    if unknown:
        raise ValueError(f"smoke_scenarios references unknown scenario(s): {', '.join(unknown)}")

    smoke_set = set(smoke_names)
    selected = scenarios
    if tier == "static":
        selected = [scenario for scenario in selected if scenario.get("mode", "codex") == "static"]
    elif tier == "smoke":
        selected = [scenario for scenario in selected
                    if scenario.get("mode", "codex") == "static"
                    or scenario["name"] in smoke_set]
    if name_filter:
        needle = name_filter.lower()
        selected = [scenario for scenario in selected if needle in scenario["name"].lower()]
    return selected


def selection_requires_codex(selected: list[tuple[str, Path, list[dict]]]) -> bool:
    """Return whether any selected scenario can invoke Codex."""
    return any(
        scenario.get("mode", "codex") != "static"
        for _, _, scenarios in selected
        for scenario in scenarios
    )


# ---------------------------------------------------------------------------
# Assertions
# ---------------------------------------------------------------------------

def _glob(workdir: Path, pattern: str) -> list[Path]:
    # All patterns are rooted at the fixture; recursion must be explicit with
    # ``**``. This prevents a missing root artifact from being satisfied by a
    # nested file with the same name.
    return [p for p in workdir.glob(pattern) if p.is_file()]


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def _unlink_best_effort(path: Path, *, attempts: int = 3, delay_s: float = 0.05) -> None:
    """Remove a transient file without letting a short Windows sharing lock fail the eval run."""
    for attempt in range(attempts):
        try:
            path.unlink(missing_ok=True)
            return
        except OSError:
            if attempt + 1 < attempts:
                time.sleep(delay_s)


def _rmtree_best_effort(path: Path, *, attempts: int = 5, delay_s: float = 0.05) -> None:
    """Remove a transient tree after short-lived Windows descendant handles are released."""
    def remove_readonly(function, target, _exc_info):
        os.chmod(target, stat.S_IWRITE)
        function(target)

    for attempt in range(attempts):
        try:
            shutil.rmtree(path, onerror=remove_readonly)
            return
        except FileNotFoundError:
            return
        except OSError:
            if attempt + 1 < attempts:
                time.sleep(delay_s * (2 ** attempt))


def check_assertion(a: dict, workdir: Path, env: dict, result_text: str, exit_code: int,
                    *, real_home: Path, deadline: float,
                    tool_commands: list[str] | None = None) -> dict:
    """Return {label, passed, evidence}."""
    t = a.get("type")
    label = t
    passed = False
    evidence = ""

    if t == "file_exists":
        pattern = a["path"]
        label = f"file_exists: {pattern}"
        matches = _glob(workdir, pattern)
        passed = bool(matches)
        evidence = (", ".join(m.name for m in matches) if matches else "no match")

    elif t == "file_contains":
        pattern, value = a["path"], a["value"]
        label = f"file_contains: {pattern} ~ {value!r}"
        matches = _glob(workdir, pattern)
        hit = next((m for m in matches if value in _read(m)), None)
        passed = hit is not None
        evidence = (f"found in {hit.name}" if hit else
                    (f"{len(matches)} file(s), none contained it" if matches else "no matching file"))

    elif t == "file_not_contains":
        pattern, value = a["path"], a["value"]
        label = f"file_not_contains: {pattern} !~ {value!r}"
        matches = _glob(workdir, pattern)
        hit = next((m for m in matches if value in _read(m)), None)
        allow_no_match = bool(a.get("allow_no_match", False))
        passed = hit is None and (bool(matches) or allow_no_match)
        evidence = (f"present in {hit.name}" if hit else
                    ("absent" if matches else
                     ("no matching file (allowed)" if allow_no_match else "no matching file")))

    elif t == "exit_success":
        label = "exit_success"
        passed = exit_code == 0
        evidence = f"exit={exit_code}"

    elif t == "output_contains":
        value = a["value"]
        label = f"output_contains: {value!r}"
        passed = value in result_text
        evidence = "present" if passed else "absent in model output"

    elif t == "output_not_contains":
        value = a["value"]
        label = f"output_not_contains: {value!r}"
        passed = value not in result_text
        evidence = "absent" if passed else "present in model output"

    elif t == "output_count":
        value, expected = a["value"], a["count"]
        label = f"output_count: {value!r} == {expected}"
        actual = sum(line == value for line in result_text.splitlines())
        passed = isinstance(expected, int) and expected >= 0 and actual == expected
        evidence = f"exact-line-count={actual}"

    elif t == "output_regex":
        pattern = a["pattern"]
        label = f"output_regex: {pattern!r}"
        try:
            passed = re.search(pattern, result_text) is not None
            evidence = "matched" if passed else "no match in model output"
        except re.error as exc:
            passed = False
            evidence = f"invalid regex: {exc}"

    elif t == "output_contains_file":
        pattern = a["path"]
        label = f"output_contains_file: {pattern}"
        matches = _glob(workdir, pattern)
        values = [_read(match).strip() for match in matches]
        hit = next((value for value in values if value and value in result_text), None)
        passed = hit is not None
        evidence = "file content present" if passed else (
            f"content from {len(matches)} file(s) absent" if matches else "no matching file")

    elif t == "tool_command_not_contains":
        value = a["value"]
        label = f"tool_command_not_contains: {value!r}"
        if tool_commands and not getattr(tool_commands, "complete", True):
            evidence = ("command-event audit incomplete for type(s): " +
                        ", ".join(tool_commands.issues))
        elif not tool_commands:
            evidence = ("Codex JSON event capture unavailable" if tool_commands is None else
                        "no recognized command inputs; audit fails closed")
        else:
            hit = next((index for index, command in enumerate(tool_commands, 1)
                        if value in command), None)
            passed = hit is None
            evidence = (f"absent from {len(tool_commands)} command input(s)" if passed else
                        f"present in command input #{hit}")

    elif t == "tool_command_not_regex":
        pattern = a["pattern"]
        label = f"tool_command_not_regex: {pattern!r}"
        if tool_commands and not getattr(tool_commands, "complete", True):
            evidence = ("command-event audit incomplete for type(s): " +
                        ", ".join(tool_commands.issues))
        elif not tool_commands:
            evidence = ("Codex JSON event capture unavailable" if tool_commands is None else
                        "no recognized command inputs; audit fails closed")
        else:
            try:
                hit = next((index for index, command in enumerate(tool_commands, 1)
                            if re.search(pattern, command)), None)
                passed = hit is None
                evidence = (f"absent from {len(tool_commands)} command input(s)" if passed else
                            f"matched command input #{hit}")
            except re.error as exc:
                evidence = f"invalid regex: {exc}"

    elif t == "command":
        run = expand(a["run"], workdir, real_home)
        label = f"command: {run if len(run) <= 60 else run[:57] + '...'}"
        remaining = deadline - time.monotonic()
        requested_timeout = float(a.get("timeout", 60))
        command_timeout = min(requested_timeout, remaining)
        if command_timeout <= 0:
            return {"label": label, "passed": False,
                    "evidence": "scenario deadline expired before command assertion"}
        try:
            proc = run_bounded([BASH, "-c", run], cwd=workdir, env=env,
                               capture_output=True, text=True, encoding="utf-8",
                               errors="replace", timeout=command_timeout)
        except subprocess.TimeoutExpired:
            return {"label": label, "passed": False,
                    "evidence": f"timed out after {command_timeout:.1f}s"}
        out = proc.stdout or ""
        checks = []
        if proc.returncode != a.get("expect_exit", 0):
            checks.append(f"exit {proc.returncode} != {a.get('expect_exit', 0)}")
        if "stdout_contains" in a and a["stdout_contains"] not in out:
            checks.append(f"stdout missing {a['stdout_contains']!r}")
        if "stdout_not_contains" in a and a["stdout_not_contains"] in out:
            checks.append(f"stdout unexpectedly has {a['stdout_not_contains']!r}")
        if a.get("stdout_empty") and out.strip():
            checks.append("stdout not empty")
        passed = not checks
        evidence = "ok" if passed else "; ".join(checks)
        if not passed and (proc.stderr or "").strip():
            evidence += f" | stderr: {proc.stderr.strip()[:200]}"

    else:
        label = f"unknown:{t}"
        evidence = "unknown assertion type"

    return {"label": label, "passed": passed, "evidence": evidence}


def check_assertion_safe(a: dict, workdir: Path, env: dict, result_text: str, exit_code: int,
                         *, real_home: Path, deadline: float,
                         tool_commands: list[str] | None = None) -> dict:
    """Turn malformed assertion definitions into one failed assertion, not a crashed eval run."""
    try:
        return check_assertion(a, workdir, env, result_text, exit_code,
                               real_home=real_home, deadline=deadline,
                               tool_commands=tool_commands)
    except (KeyError, TypeError, ValueError) as exc:
        assertion_type = a.get("type") if isinstance(a, dict) else None
        return {"label": f"invalid:{assertion_type}", "passed": False,
                "evidence": f"malformed assertion: {exc}"}


# ---------------------------------------------------------------------------
# Running a scenario
# ---------------------------------------------------------------------------

def expand(value: str, workdir: Path, real_home: Path) -> str:
    return (value.replace("${WORKDIR}", str(workdir))
            .replace("${REAL_HOME}", str(real_home))
            .replace("${REPO_ROOT}", REPO_ROOT.as_posix()))


def skill_execution_prompt(plugin: str, skill: str, prompt: str) -> str:
    return f"Use ${plugin}:{skill} and follow it exactly.\n\nUser request:\n{prompt}"


def scenario_codex_command(setup: dict, env: dict[str, str], result_path: Path,
                           *, eval_plugin_root: Path | None) -> list[str]:
    """Build a hermetic non-interactive command with the least writable roots."""
    extra_env_names: tuple[str, ...] = ()
    if eval_plugin_root is not None:
        env["TEDTOOLKIT_PLUGIN_ROOT"] = str(eval_plugin_root)
        extra_env_names = ("TEDTOOLKIT_PLUGIN_ROOT",)
    command = codex_command(
        *codex_shell_environment_args(setup, env, extra_names=extra_env_names),
        "-a", "on-request", "-c", 'approvals_reviewer="auto_review"',
        "exec", "--ephemeral", "--skip-git-repo-check",
        "--ignore-rules", "--sandbox", "workspace-write", "--json",
        "--output-last-message", str(result_path))
    if eval_plugin_root is not None:
        command.extend(["--add-dir", str(eval_plugin_root)])
    return command


def run_scenario(skill: str, eval_dir: Path, scen: dict, args,
                 *, eval_plugin: str | None = None,
                 eval_plugin_root: Path | None = None) -> dict:
    name = scen.get("name", "<unnamed>")
    mode = scen.get("mode", "codex")
    scenario_timeout = float(scen.get("timeout", 300))
    scenario_started = time.monotonic()
    deadline = scenario_started + scenario_timeout
    workdir = Path(tempfile.mkdtemp(prefix=f"eval-{skill}-"))
    result_path: Path | None = None
    event_path: Path | None = None
    setup = scen.get("setup", {}) or {}
    real_home = Path(os.environ.get("USERPROFILE") or os.path.expanduser("~"))

    record = {"skill": skill, "scenario": name, "prompt": scen.get("prompt", ""),
              "rubric": [] if mode == "static" else scen.get("rubric", []),
              "assertions": [], "workdir": str(workdir)}

    try:
        if mode not in {"codex", "static"}:
            record["error"] = f"unsupported scenario mode: {mode}"
            record["assertions"] = [{"label": "mode", "passed": False,
                                     "evidence": record["error"]}]
            return record

        # 1. copy sibling test files into the work dir
        if setup.get("copy_test_files"):
            for item in eval_dir.iterdir():
                if item.name == "eval.yaml":
                    continue
                dest = workdir / item.name
                if item.is_dir():
                    shutil.copytree(item, dest)
                else:
                    shutil.copy2(item, dest)

        # 2. build the subprocess env (shared by setup, Codex, and command asserts)
        env = os.environ.copy()
        path_prefix = git_bin_dirs(BASH)
        for key, val in (setup.get("env") or {}).items():
            env[key] = expand(str(val), workdir, real_home)

        # 3. run setup commands. Static scenarios use these commands as their
        # complete execution and therefore share the scenario's hard timeout.
        setup_outputs = []
        for raw_cmd in setup.get("commands", []):
            cmd = expand(raw_cmd, workdir, real_home)
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                record["error"] = f"scenario timed out after {scenario_timeout:g}s during setup ({cmd})"
                record["assertions"] = [{"label": "setup", "passed": False,
                                         "evidence": record["error"]}]
                return record
            try:
                proc = run_bounded(
                    [BASH, "-c", cmd], cwd=workdir,
                    env={**env, "PATH": os.pathsep.join(path_prefix + [env["PATH"]])},
                    capture_output=True, text=True, encoding="utf-8", errors="replace",
                    timeout=remaining)
            except subprocess.TimeoutExpired:
                record["error"] = f"scenario timed out after {scenario_timeout:g}s during setup ({cmd})"
                record["assertions"] = [{"label": "setup", "passed": False,
                                         "evidence": record["error"]}]
                return record
            setup_outputs.extend(part for part in (proc.stdout, proc.stderr) if part)
            if proc.returncode != 0:
                record["error"] = f"setup failed ({cmd}): {proc.stderr.strip()[:400]}"
                record["assertions"] = [{"label": "setup", "passed": False, "evidence": record["error"]}]
                return record

        env["PATH"] = scenario_execution_path(workdir, path_prefix, env["PATH"])

        if mode == "static":
            result_text = "\n".join(setup_outputs)
            record["cost_usd"] = None
            record["result_text"] = result_text
            for a in scen.get("assertions", []):
                record["assertions"].append(check_assertion_safe(
                    a, workdir, env, result_text, 0, real_home=real_home, deadline=deadline))
            record["duration_s"] = round(time.monotonic() - scenario_started, 1)
            return record

        # A setup that needs a dynamic prompt (e.g. a freshly created issue iid)
        # writes the final prompt to prompt.txt; it overrides the static yaml prompt.
        prompt_text = scen["prompt"]
        prompt_file = workdir / "prompt.txt"
        if prompt_file.is_file():
            prompt_text = prompt_file.read_text(encoding="utf-8", errors="replace").strip()
            record["prompt"] = prompt_text
            scen["prompt"] = prompt_text   # keep the rubric judge in sync

        # 4. Invoke the selected marketplace plugin through Codex. Capture the
        # final response in a file so assertions do not depend on event schema.
        result_path = workdir.parent / f"{workdir.name}-codex-{uuid.uuid4().hex}.last-message.txt"
        event_path = workdir.parent / f"{workdir.name}-codex-{uuid.uuid4().hex}.events.jsonl"
        cmd = scenario_codex_command(
            setup, env, result_path, eval_plugin_root=eval_plugin_root)
        if getattr(args, "model", None):
            cmd += ["--model", args.model]
        execution_prompt = (skill_execution_prompt(eval_plugin, skill, prompt_text)
                            if eval_plugin else prompt_text)
        cmd.append(execution_prompt)
        timed_out = False
        stderr_text = ""
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            record["error"] = f"scenario timed out after {scenario_timeout:g}s before Codex execution"
            record["assertions"] = [{"label": "run", "passed": False,
                                     "evidence": record["error"]}]
            return record
        try:
            with event_path.open("w", encoding="utf-8", newline="\n") as event_file:
                proc = run_bounded(cmd, cwd=workdir, env=env, stdout=event_file,
                                   stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace",
                                   stdin=subprocess.DEVNULL, timeout=remaining)
            exit_code = proc.returncode
            stderr_text = proc.stderr or ""
        except subprocess.TimeoutExpired as exc:
            timed_out = True
            exit_code = -1
            stderr_text = exc.stderr if isinstance(exc.stderr, str) else ""
        result_text = _read(result_path) if result_path.is_file() else ""
        event_text = _read(event_path) if event_path.is_file() else ""
        tool_commands = extract_tool_commands(event_text)
        cost = None
        if not result_text.strip() and stderr_text.strip():
            result_text = stderr_text

        record["duration_s"] = round(time.monotonic() - scenario_started, 1)
        record["cost_usd"] = cost
        record["result_text"] = result_text
        record["tool_command_count"] = len(tool_commands) if tool_commands is not None else None
        record["tool_command_audit_complete"] = (
            tool_commands.complete if tool_commands is not None else False)
        if tool_commands is not None and tool_commands.issues:
            record["tool_command_audit_issues"] = list(tool_commands.issues)
        if setup.get("retain_tool_commands") and tool_commands is not None:
            record["tool_commands"] = tool_commands

        if timed_out:
            record["error"] = f"scenario timed out after {scenario_timeout:g}s during Codex execution"
            record["assertions"] = [{"label": "run", "passed": False,
                                     "evidence": record["error"]}]
            return record

        # 5. assertions
        for a in scen.get("assertions", []):
            record["assertions"].append(check_assertion_safe(
                a, workdir, env, result_text, exit_code,
                real_home=real_home, deadline=deadline, tool_commands=tool_commands))

        # 6. optional rubric judge
        if args.judge and scen.get("rubric"):
            record["rubric_grades"] = judge_rubric(
                scen, result_text, workdir, env, args, deadline=deadline)

        record["duration_s"] = round(time.monotonic() - scenario_started, 1)
        return record
    finally:
        # Tear down anything the run created outside the work dir. Runs on every
        # exit path
        # — success, assertion failure, setup failure, or timeout — while the
        # work dir still exists, so cleanup scripts can read files setup left
        # behind (e.g. issue.iid). Best-effort: failures are recorded, never
        # raised. The env mirrors the Codex run (real $GITLAB_TOKEN from the
        # parent env, Git's bin dirs and any .binstub on PATH).
        cleanup_cmds = setup.get("cleanup_commands", [])
        if cleanup_cmds and BASH:
            tenv = os.environ.copy()
            for key, val in (setup.get("env") or {}).items():
                tenv[key] = expand(str(val), workdir, real_home)
            path_prefix = git_bin_dirs(BASH)
            binstub = workdir / ".binstub"
            parts = ([str(binstub)] if binstub.is_dir() else []) + path_prefix + [tenv["PATH"]]
            tenv["PATH"] = os.pathsep.join(parts)
            warnings = []
            for raw_cmd in cleanup_cmds:
                cmd = expand(raw_cmd, workdir, real_home)
                try:
                    proc = run_bounded([BASH, "-c", cmd], cwd=workdir, env=tenv,
                                       capture_output=True, text=True,
                                       encoding="utf-8", errors="replace", timeout=120)
                    if proc.returncode != 0:
                        msg = (proc.stderr or proc.stdout or "").strip()[:200]
                        warnings.append(f"{cmd!r} exit {proc.returncode}: {msg}")
                except Exception as exc:  # teardown must never mask the real result
                    warnings.append(f"{cmd!r} raised {exc}")
            if warnings:
                record["teardown_warnings"] = warnings

        # Remove anything the fixture created outside the work dir (e.g. a
        # fictional package it had to drop into the real NuGet cache).
        for rel in setup.get("cleanup_globs", []):
            for target in real_home.glob(rel):
                if target.is_dir():
                    _rmtree_best_effort(target)
                else:
                    target.unlink(missing_ok=True)
        if result_path is not None:
            _unlink_best_effort(result_path)
        if event_path is not None:
            _unlink_best_effort(event_path)
        if args.keep:
            record["kept"] = str(workdir)
        else:
            _rmtree_best_effort(workdir)


def judge_rubric(scen: dict, result_text: str, workdir: Path, env: dict, args,
                 *, deadline: float) -> list[dict]:
    rubric_lines = "\n".join(f"{i+1}. {pt}" for i, pt in enumerate(scen["rubric"]))
    prompt = (
        "You are grading whether a transcript satisfies each rubric point. "
        "Return ONLY a JSON array, one object per point, in order, shaped "
        '{"text": <point>, "passed": <bool>, "evidence": <short reason>}.\n\n'
        f"TASK GIVEN TO THE MODEL:\n{scen.get('prompt','')}\n\n"
        f"MODEL OUTPUT / TRANSCRIPT:\n{result_text}\n\n"
        f"RUBRIC POINTS:\n{rubric_lines}\n"
    )
    result_path = workdir.parent / f"{workdir.name}-judge-{uuid.uuid4().hex}.last-message.txt"
    try:
        remaining = min(180.0, deadline - time.monotonic())
        if remaining <= 0:
            raise TimeoutError("scenario deadline expired before rubric judging")
        cmd = codex_command("exec", "--ephemeral", "--skip-git-repo-check",
                            "--sandbox", "read-only", "--output-last-message",
                            str(result_path))
        if getattr(args, "model", None):
            cmd += ["--model", args.model]
        cmd.append(prompt)
        proc = run_bounded(cmd, cwd=workdir, env=env, stdout=subprocess.DEVNULL,
                           stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace",
                           stdin=subprocess.DEVNULL, timeout=remaining)
        if proc.returncode != 0:
            detail = (proc.stderr or "Codex judge exited unsuccessfully").strip()[:200]
            raise RuntimeError(detail)
        judge_text = _read(result_path) if result_path.is_file() else ""
        start, end = judge_text.find("["), judge_text.rfind("]")
        if start < 0 or end <= start:
            raise ValueError("Codex judge did not return a JSON array")
        grades = json.loads(judge_text[start:end + 1])
        if not isinstance(grades, list) or len(grades) != len(scen["rubric"]):
            raise ValueError("Codex judge returned the wrong number of rubric grades")
        if any(not isinstance(grade, dict) or not isinstance(grade.get("passed"), bool)
               for grade in grades):
            raise ValueError("Codex judge returned an invalid rubric grade")
        return grades
    except Exception as exc:
        return [{"text": "judge error", "passed": False, "evidence": str(exc)[:200]}]
    finally:
        result_path.unlink(missing_ok=True)


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

GREEN, RED, DIM, BOLD, RESET = "\033[32m", "\033[31m", "\033[2m", "\033[1m", "\033[0m"


def record_passes(rec: dict) -> bool:
    asserts = rec.get("assertions", [])
    if not (asserts and all(a["passed"] for a in asserts) and "error" not in rec):
        return False
    grades = rec.get("rubric_grades")
    return grades is None or (bool(grades) and all(g.get("passed") for g in grades))


def print_scenario(rec: dict) -> bool:
    asserts = rec.get("assertions", [])
    ok = record_passes(rec)
    head = f"{GREEN}PASS{RESET}" if ok else f"{RED}FAIL{RESET}"
    meta = []
    if rec.get("duration_s") is not None:
        meta.append(f"{rec['duration_s']}s")
    if rec.get("cost_usd") is not None:
        meta.append(f"${rec['cost_usd']:.4f}")
    meta_s = f" {DIM}({', '.join(meta)}){RESET}" if meta else ""
    print(f"  [{head}] {rec['scenario']}{meta_s}")
    if rec.get("error"):
        print(f"        {RED}{rec['error']}{RESET}")
    for a in asserts:
        mark = f"{GREEN}✓{RESET}" if a["passed"] else f"{RED}✗{RESET}"
        print(f"        {mark} {a['label']}  {DIM}{a['evidence']}{RESET}")
    for g in rec.get("rubric_grades", []):
        mark = f"{GREEN}✓{RESET}" if g.get("passed") else f"{RED}✗{RESET}"
        print(f"        {DIM}rubric{RESET} {mark} {g.get('text','')}  {DIM}{g.get('evidence','')}{RESET}")
    for w in rec.get("teardown_warnings", []):
        print(f"        {RED}⚠ teardown{RESET} {DIM}{w}{RESET}")
    if rec.get("kept"):
        print(f"        {DIM}kept: {rec['kept']}{RESET}")
    return ok


def write_results(all_recs: list[dict], passed: int, total: int,
                  input_identities: dict[str, dict]) -> Path:
    stamp = f"{datetime.now().strftime('%Y%m%d-%H%M%S-%f')}-{uuid.uuid4().hex[:8]}"
    out = RESULTS_DIR / stamp
    out.mkdir(parents=True)
    (out / "results.json").write_text(
        json.dumps({"passed": passed, "total": total, "inputs": input_identities,
                    "scenarios": all_recs},
                   ensure_ascii=False, indent=2), encoding="utf-8")
    lines = [f"# Eval results — {stamp}", "", f"**{passed}/{total} scenarios passed**", ""]
    for plugin, identity in input_identities.items():
        lines.extend([f"- `{plugin}` input: `{identity['sha256']}` "
                      f"({identity['file_count']} files at `{identity['source_head']}`)"])
    lines.append("")
    for r in all_recs:
        ok = record_passes(r)
        lines.append(f"## {'✅' if ok else '❌'} {r['skill']} — {r['scenario']}")
        meta = []
        if r.get("duration_s") is not None:
            meta.append(f"{r['duration_s']}s")
        if r.get("cost_usd") is not None:
            meta.append(f"${r['cost_usd']:.4f}")
        if meta:
            lines.append(f"_{', '.join(meta)}_")
        for a in r.get("assertions", []):
            lines.append(f"- {'✅' if a['passed'] else '❌'} {a['label']} — {a['evidence']}")
        for g in r.get("rubric_grades", []):
            lines.append(f"- {'✅' if g.get('passed') else '❌'} rubric: {g.get('text','')} — "
                         f"{g.get('evidence','')}")
        lines.append("")
    (out / "results.md").write_text("\n".join(lines), encoding="utf-8")
    return out


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description="Run TedToolkit plugin skill evals.")
    ap.add_argument("skills", nargs="*", help="skill names to run (default: all)")
    ap.add_argument("--filter", help="only run scenarios whose name contains this substring")
    ap.add_argument("--tier", choices=("static", "smoke", "full"), default="full",
                    help="eval cost tier (default: full)")
    ap.add_argument("--keep", action="store_true", help="keep work dirs for debugging")
    ap.add_argument("--judge", action="store_true",
                    help="grade rubric points with Codex and fail scenarios on any failed grade")
    ap.add_argument("--model", help="pass the model through to Codex for scenarios and rubric judging")
    ap.add_argument("--plugin",
                    help="run only tests/<plugin>/ with the matching plugin (default: all plugins)")
    args = ap.parse_args()

    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8")
        except Exception:
            pass

    all_recs: list[dict] = []
    input_identities: dict[str, dict] = {}
    input_roots: dict[str, list[Path]] = {}
    passed = total = 0
    plugins = [args.plugin] if args.plugin else eval_plugins()

    try:
        for plugin in plugins:
            plugin_dir = REPO_ROOT / "plugins" / plugin
            selected = []
            for skill, eval_dir, spec in discover(plugin, args.skills):
                scenarios = select_scenarios(spec, tier=args.tier, name_filter=args.filter)
                if scenarios:
                    selected.append((skill, eval_dir, scenarios))

            if not selected:
                continue

            roots = [Path(__file__).resolve(), plugin_dir,
                     *(eval_dir for _, eval_dir, _ in selected)]
            input_roots[plugin] = roots
            input_identities[plugin] = build_input_identity(roots)

            load_plugin = selection_requires_codex(selected)
            require_codex = load_plugin
            preflight(plugin_dir, require_codex=require_codex)

            marketplace_root = marketplace_name = eval_plugin_name = None
            try:
                if load_plugin:
                    marketplace_root, marketplace_name, eval_plugin_name = install_eval_plugin(plugin_dir)
                print(f"\n{BOLD}{plugin}{RESET}")
                for skill, eval_dir, scenarios in selected:
                    print(f"\n{BOLD}{skill}{RESET}  ({len(scenarios)} scenario(s))")
                    for scen in scenarios:
                        candidate_root = (marketplace_root / "plugins" / eval_plugin_name
                                          if marketplace_root is not None
                                          and eval_plugin_name is not None else None)
                        rec = run_scenario(
                            skill, eval_dir, scen, args, eval_plugin=eval_plugin_name,
                            eval_plugin_root=candidate_root)
                        all_recs.append(rec)
                        total += 1
                        if print_scenario(rec):
                            passed += 1
            finally:
                if (marketplace_root is not None and marketplace_name is not None
                        and eval_plugin_name is not None):
                    cleanup_eval_plugin(eval_plugin_name, marketplace_name, marketplace_root)
            require_current_input_identities(
                {plugin: input_identities[plugin]}, {plugin: input_roots[plugin]})
    except Exception as exc:
        print(f"Eval setup failed: {exc}", file=sys.stderr)
        return 2

    if total == 0:
        target = f"plugin {args.plugin!r}" if args.plugin else "the requested filters"
        print(f"No eval scenarios matched {target}.", file=sys.stderr)
        return 2

    try:
        require_current_input_identities(input_identities, input_roots)
    except RuntimeError as exc:
        print(f"Eval setup failed: {exc}", file=sys.stderr)
        return 2

    out = write_results(all_recs, passed, total, input_identities)
    color = GREEN if passed == total else RED
    print(f"\n{BOLD}{color}{passed}/{total} scenarios passed{RESET}")
    print(f"{DIM}results: {out}{RESET}")
    return 0 if passed == total else 1


if __name__ == "__main__":
    sys.exit(main())
