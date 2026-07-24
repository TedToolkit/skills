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
    py -3.13 tests/run_evals.py [skill ...] [--plugin PLUGIN] [--filter SUBSTR] [--keep] [--judge]

With no skill names it discovers and runs every eval.yaml. Skill names match the
directory holding the eval.yaml (e.g. ``generate-commit-message``).
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
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
    found = shutil.which("bash")
    if found:
        return found
    for c in (
        r"C:\Program Files\Git\bin\bash.exe",
        r"C:\Program Files\Git\usr\bin\bash.exe",
        r"C:\Program Files (x86)\Git\bin\bash.exe",
    ):
        if Path(c).exists():
            return c
    return None


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


def preflight(plugin_dir: Path) -> None:
    problems = []
    if not CODEX:
        problems.append("`codex` not found on PATH; install Codex CLI or set CODEX_BIN to its executable.")
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


def install_eval_plugin(plugin_dir: Path) -> tuple[Path, str]:
    """Install a copied plugin from a unique local marketplace for this run."""
    root = Path(tempfile.mkdtemp(prefix="codex-eval-marketplace-"))
    marketplace = f"eval-{uuid.uuid4().hex}"
    plugin = plugin_dir.name
    destination = root / "plugins" / plugin
    destination.parent.mkdir(parents=True)
    shutil.copytree(plugin_dir, destination)
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
            result = subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace")
            if result.returncode:
                raise RuntimeError((result.stderr or result.stdout).strip())
    except Exception:
        cleanup_eval_plugin(plugin, marketplace, root)
        raise
    return root, marketplace


def cleanup_eval_plugin(plugin: str, marketplace: str, root: Path) -> None:
    if CODEX:
        for command in (codex_command("plugin", "remove", f"{plugin}@{marketplace}"),
                        codex_command("plugin", "marketplace", "remove", marketplace)):
            subprocess.run(command, capture_output=True, text=True, encoding="utf-8", errors="replace")
    shutil.rmtree(root, ignore_errors=True)


# ---------------------------------------------------------------------------
# Discovery
# ---------------------------------------------------------------------------

def discover(skill_filters: list[str]):
    for path in sorted(TESTS_DIR.rglob("eval.yaml")):
        skill = path.parent.name
        if skill_filters and skill not in skill_filters:
            continue
        with open(path, encoding="utf-8") as fh:
            spec = yaml.safe_load(fh)
        yield skill, path.parent, spec


# ---------------------------------------------------------------------------
# Assertions
# ---------------------------------------------------------------------------

def _glob(workdir: Path, pattern: str) -> list[Path]:
    matches = [p for p in workdir.glob(pattern) if p.is_file()]
    if not matches and "/" not in pattern and "\\" not in pattern:
        matches = [p for p in workdir.rglob(pattern) if p.is_file()]
    return matches


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def check_assertion(a: dict, workdir: Path, env: dict, result_text: str, exit_code: int) -> dict:
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
        passed = hit is None
        evidence = (f"present in {hit.name}" if hit else "absent")

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

    elif t == "command":
        run = a["run"]
        label = f"command: {run if len(run) <= 60 else run[:57] + '...'}"
        proc = subprocess.run([BASH, "-c", run], cwd=workdir, env=env,
                              capture_output=True, text=True,
                              encoding="utf-8", errors="replace")
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


# ---------------------------------------------------------------------------
# Running a scenario
# ---------------------------------------------------------------------------

def expand(value: str, workdir: Path, real_home: Path) -> str:
    return value.replace("${WORKDIR}", str(workdir)).replace("${REAL_HOME}", str(real_home))


def parse_claude_json(stdout: str) -> tuple[str, float | None]:
    """Return (result_text, cost_usd). Falls back to raw stdout on parse error."""
    stdout = stdout.strip()
    try:
        obj = json.loads(stdout)
    except json.JSONDecodeError:
        # stream of objects or junk: take the last JSON line we can parse
        for line in reversed(stdout.splitlines()):
            try:
                obj = json.loads(line)
                break
            except json.JSONDecodeError:
                continue
        else:
            return stdout, None
    result = obj.get("result", "") if isinstance(obj, dict) else ""
    cost = obj.get("total_cost_usd") if isinstance(obj, dict) else None
    return result or stdout, cost


def parse_stream_file(path: Path) -> tuple[str, float | None]:
    """From a stream-json transcript return (result_text, cost_usd).

    Prefer the final ``{"type":"result"}`` event. If it's absent — e.g. the run
    timed out before finishing — fall back to the concatenated assistant text so
    a partial transcript is still inspectable.
    """
    if not path.is_file():
        return "", None
    result_text, cost, chunks = "", None, []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        if not isinstance(obj, dict):
            continue
        if obj.get("type") == "result":
            result_text = obj.get("result") or result_text
            if obj.get("total_cost_usd") is not None:
                cost = obj.get("total_cost_usd")
        elif obj.get("type") == "assistant":
            for block in (obj.get("message", {}).get("content") or []):
                if isinstance(block, dict) and block.get("type") == "text":
                    chunks.append(block.get("text", ""))
    if not result_text and chunks:
        result_text = "\n".join(chunks)
    return result_text, cost


def run_scenario(skill: str, eval_dir: Path, scen: dict, args, plugin_dir: Path) -> dict:
    name = scen.get("name", "<unnamed>")
    workdir = Path(tempfile.mkdtemp(prefix=f"eval-{skill}-"))
    setup = scen.get("setup", {}) or {}
    real_home = Path(os.environ.get("USERPROFILE") or os.path.expanduser("~"))

    record = {"skill": skill, "scenario": name, "prompt": scen.get("prompt", ""),
              "rubric": scen.get("rubric", []), "assertions": [], "workdir": str(workdir)}

    try:
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

        # 2. build the subprocess env (shared by setup, claude, and command asserts)
        env = os.environ.copy()
        path_prefix = git_bin_dirs(BASH)
        binstub = workdir / ".binstub"
        for key, val in (setup.get("env") or {}).items():
            env[key] = expand(str(val), workdir, real_home)

        # 3. run setup commands
        for cmd in setup.get("commands", []):
            proc = subprocess.run([BASH, "-c", cmd], cwd=workdir,
                                  env={**env, "PATH": os.pathsep.join(path_prefix + [env["PATH"]])},
                                  capture_output=True, text=True,
                                  encoding="utf-8", errors="replace", timeout=300)
            if proc.returncode != 0:
                record["error"] = f"setup failed ({cmd}): {proc.stderr.strip()[:400]}"
                record["assertions"] = [{"label": "setup", "passed": False, "evidence": record["error"]}]
                return record

        # .binstub may have been created by setup; it must shadow real tools.
        path_parts = ([str(binstub)] if binstub.is_dir() else []) + path_prefix + [env["PATH"]]
        env["PATH"] = os.pathsep.join(path_parts)

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
        result_path = workdir / "codex.last-message.txt"
        cmd = codex_command("exec", "--ephemeral", "--skip-git-repo-check",
                            "--sandbox", "workspace-write", "--output-last-message",
                            str(result_path), prompt_text)
        if getattr(args, "model", None):
            cmd += ["--model", args.model]
        t0 = time.monotonic()
        timed_out = False
        stderr_text = ""
        try:
            proc = subprocess.run(cmd, cwd=workdir, env=env, stdout=subprocess.DEVNULL,
                                  stderr=subprocess.PIPE, text=True, encoding="utf-8", errors="replace",
                                  stdin=subprocess.DEVNULL, timeout=scen.get("timeout", 300))
            exit_code = proc.returncode
            stderr_text = proc.stderr or ""
        except subprocess.TimeoutExpired as exc:
            timed_out = True
            exit_code = -1
            stderr_text = exc.stderr if isinstance(exc.stderr, str) else ""
        duration = time.monotonic() - t0

        result_text = _read(result_path) if result_path.is_file() else ""
        cost = None
        if not result_text.strip() and stderr_text.strip():
            result_text = stderr_text

        record["duration_s"] = round(duration, 1)
        record["cost_usd"] = cost
        record["result_text"] = result_text

        if timed_out:
            record["error"] = f"claude timed out after {scen.get('timeout', 300)}s"
            record["assertions"] = [{"label": "run", "passed": False,
                                     "evidence": record["error"]}]
            return record

        # 5. assertions
        for a in scen.get("assertions", []):
            record["assertions"].append(check_assertion(a, workdir, env, result_text, exit_code))

        # 6. optional rubric judge
        if args.judge and scen.get("rubric"):
            record["rubric_grades"] = judge_rubric(scen, result_text)

        return record
    finally:
        # Tear down anything the run created outside the work dir. Runs on every
        # exit path
        # — success, assertion failure, setup failure, or timeout — while the
        # work dir still exists, so cleanup scripts can read files setup left
        # behind (e.g. issue.iid). Best-effort: failures are recorded, never
        # raised. The env mirrors the claude run (real $GITLAB_TOKEN from the
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
            for cmd in cleanup_cmds:
                try:
                    proc = subprocess.run([BASH, "-c", cmd], cwd=workdir, env=tenv,
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
                    shutil.rmtree(target, ignore_errors=True)
                else:
                    target.unlink(missing_ok=True)
        if args.keep:
            record["kept"] = str(workdir)
        else:
            shutil.rmtree(workdir, ignore_errors=True)


def judge_rubric(scen: dict, result_text: str) -> list[dict]:
    rubric_lines = "\n".join(f"{i+1}. {pt}" for i, pt in enumerate(scen["rubric"]))
    prompt = (
        "You are grading whether a transcript satisfies each rubric point. "
        "Return ONLY a JSON array, one object per point, in order, shaped "
        '{"text": <point>, "passed": <bool>, "evidence": <short reason>}.\n\n'
        f"TASK GIVEN TO THE MODEL:\n{scen.get('prompt','')}\n\n"
        f"MODEL OUTPUT / TRANSCRIPT:\n{result_text}\n\n"
        f"RUBRIC POINTS:\n{rubric_lines}\n"
    )
    try:
        proc = subprocess.run(
            ["claude", "-p", prompt, "--output-format", "json"],
            capture_output=True, text=True, encoding="utf-8", errors="replace",
            stdin=subprocess.DEVNULL, timeout=180)
        text, _ = parse_claude_json(proc.stdout)
        start, end = text.find("["), text.rfind("]")
        return json.loads(text[start:end + 1]) if start >= 0 and end > start else []
    except Exception as exc:  # judge is best-effort
        return [{"text": "judge error", "passed": False, "evidence": str(exc)[:200]}]


# ---------------------------------------------------------------------------
# Reporting
# ---------------------------------------------------------------------------

GREEN, RED, DIM, BOLD, RESET = "\033[32m", "\033[31m", "\033[2m", "\033[1m", "\033[0m"


def print_scenario(rec: dict) -> bool:
    asserts = rec.get("assertions", [])
    ok = bool(asserts) and all(a["passed"] for a in asserts) and "error" not in rec
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


def write_results(all_recs: list[dict], passed: int, total: int) -> Path:
    stamp = time.strftime("%Y%m%d-%H%M%S")
    out = RESULTS_DIR / stamp
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").write_text(
        json.dumps({"passed": passed, "total": total, "scenarios": all_recs},
                   ensure_ascii=False, indent=2), encoding="utf-8")
    lines = [f"# Eval results — {stamp}", "", f"**{passed}/{total} scenarios passed**", ""]
    for r in all_recs:
        ok = bool(r.get("assertions")) and all(a["passed"] for a in r["assertions"]) and "error" not in r
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
        lines.append("")
    (out / "results.md").write_text("\n".join(lines), encoding="utf-8")
    return out


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    ap = argparse.ArgumentParser(description="Run tedtoolkit-shared skill evals.")
    ap.add_argument("skills", nargs="*", help="skill names to run (default: all)")
    ap.add_argument("--filter", help="only run scenarios whose name contains this substring")
    ap.add_argument("--keep", action="store_true", help="keep work dirs for debugging")
    ap.add_argument("--judge", action="store_true", help="also LLM-judge the rubric points")
    ap.add_argument("--model", help="pass through to `claude -p --model` (e.g. 'sonnet' to "
                        "run on standard context when 1M-context credits are unavailable)")
    ap.add_argument("--plugin", default="tedtoolkit-shared",
                    help="plugin directory under plugins/ to load (default: tedtoolkit-shared)")
    args = ap.parse_args()

    plugin_dir = REPO_ROOT / "plugins" / args.plugin

    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8")
        except Exception:
            pass

    preflight(plugin_dir)

    all_recs: list[dict] = []
    passed = total = 0
    marketplace_root = None
    marketplace_name = None
    try:
        marketplace_root, marketplace_name = install_eval_plugin(plugin_dir)
        for skill, eval_dir, spec in discover(args.skills):
            scenarios = spec.get("scenarios", [])
            if args.filter:
                scenarios = [s for s in scenarios if args.filter.lower() in s.get("name", "").lower()]
            if not scenarios:
                continue
            print(f"\n{BOLD}{skill}{RESET}  ({len(scenarios)} scenario(s))")
            for scen in scenarios:
                rec = run_scenario(skill, eval_dir, scen, args, plugin_dir)
                all_recs.append(rec)
                total += 1
                if print_scenario(rec):
                    passed += 1
    except Exception as exc:
        print(f"Eval setup failed: {exc}", file=sys.stderr)
        return 2
    finally:
        if marketplace_root is not None and marketplace_name is not None:
            cleanup_eval_plugin(plugin_dir.name, marketplace_name, marketplace_root)

    out = write_results(all_recs, passed, total)
    color = GREEN if passed == total else RED
    print(f"\n{BOLD}{color}{passed}/{total} scenarios passed{RESET}")
    print(f"{DIM}results: {out}{RESET}")
    return 0 if passed == total else 1


if __name__ == "__main__":
    sys.exit(main())
