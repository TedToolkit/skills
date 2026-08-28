from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from urllib.parse import unquote

import yaml


class ContractError(RuntimeError):
    pass


FORBIDDEN_INSTALL_ROOT_NAMES = (
    "CLAUDE_PLUGIN_ROOT",
    "TEDTOOLKIT_PLUGIN_ROOT",
)


def relative(root: Path, path: Path) -> str:
    return path.resolve().relative_to(root.resolve()).as_posix()


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def load_json(root: Path, path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise ContractError(f"{relative(root, path)}: required JSON file is missing") from error
    except json.JSONDecodeError as error:
        raise ContractError(
            f"{relative(root, path)}: invalid JSON at line {error.lineno}, column {error.colno}") from error


def load_yaml(root: Path, path: Path):
    try:
        return yaml.safe_load(path.read_text(encoding="utf-8"))
    except FileNotFoundError as error:
        raise ContractError(f"{relative(root, path)}: required YAML file is missing") from error
    except yaml.YAMLError as error:
        mark = getattr(error, "problem_mark", None)
        where = f" at line {mark.line + 1}, column {mark.column + 1}" if mark else ""
        raise ContractError(f"{relative(root, path)}: invalid YAML{where}") from error


def load_skill(root: Path, path: Path) -> tuple[str, dict]:
    try:
        text = path.read_text(encoding="utf-8")
    except FileNotFoundError as error:
        raise ContractError(f"{relative(root, path)}: required Skill entrypoint is missing") from error
    lines = text.splitlines()
    label = relative(root, path)
    require(bool(lines) and lines[0] == "---", f"{label}: missing opening YAML frontmatter")
    try:
        closing = lines.index("---", 1)
    except ValueError as error:
        raise ContractError(f"{label}: unterminated YAML frontmatter") from error
    try:
        metadata = yaml.safe_load("\n".join(lines[1:closing]))
    except yaml.YAMLError as error:
        raise ContractError(f"{label}: invalid YAML frontmatter") from error
    require(isinstance(metadata, dict), f"{label}: YAML frontmatter must be a mapping")
    return text, metadata


def markdown_links(text: str) -> list[str]:
    return re.findall(r"\[[^\]]+\]\(([^)]+)\)", text)


def check_markdown_resource_links(root: Path, path: Path, text: str | None = None) -> None:
    text = path.read_text(encoding="utf-8") if text is None else text
    label = relative(root, path)
    repo = root.resolve()
    for raw_link in markdown_links(text):
        link = raw_link.strip().strip("<>")
        if not link or link.startswith("#") or re.match(r"^[A-Za-z][A-Za-z0-9+.-]*:", link):
            continue
        path_text = unquote(link.split("#", 1)[0].split("?", 1)[0])
        target = (path.parent / path_text).resolve()
        require(target.is_relative_to(repo), f"{label}: relative link escapes repository: {raw_link}")
        require(target.exists(), f"{label}: relative link target is missing: {raw_link}")


def check_no_install_root_contract(root: Path) -> None:
    text_suffixes = {".json", ".md", ".ps1", ".py", ".sh", ".yaml", ".yml"}
    paths = [
        root / "CLAUDE.md",
        root / "tests" / "run_evals.py",
        *(path for path in sorted((root / "plugins").glob("**/*"))
          if path.is_file() and path.suffix.lower() in text_suffixes),
    ]
    for path in paths:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        for name in FORBIDDEN_INSTALL_ROOT_NAMES:
            require(name not in text,
                    f"{relative(root, path)}: forbidden plugin-install-root dependency: {name}")


def marketplace_plugins(root: Path, path: Path, *, codex: bool) -> dict[str, str]:
    document = load_json(root, path)
    require(isinstance(document, dict), f"{relative(root, path)}: marketplace must be an object")
    entries = document.get("plugins")
    require(isinstance(entries, list), f"{relative(root, path)}: plugins must be a list")
    result: dict[str, str] = {}
    for entry in entries:
        require(isinstance(entry, dict), f"{relative(root, path)}: plugin entry must be an object")
        name = entry.get("name")
        source = entry.get("source")
        if codex and isinstance(source, dict):
            source = source.get("path")
        require(isinstance(name, str) and name, f"{relative(root, path)}: plugin name is required")
        require(isinstance(source, str) and source, f"{relative(root, path)}: source for {name} is required")
        require(name not in result, f"{relative(root, path)}: duplicate plugin {name}")
        result[name] = source
    return result


def check_marketplaces(root: Path) -> list[str]:
    codex_path = root / ".codex-plugin" / "marketplace.json"
    claude_path = root / ".claude-plugin" / "marketplace.json"
    codex = marketplace_plugins(root, codex_path, codex=True)
    claude = marketplace_plugins(root, claude_path, codex=False)
    require(set(codex) == set(claude),
            ".codex-plugin/marketplace.json: plugin set differs from .claude-plugin/marketplace.json")
    for name in sorted(codex):
        expected = f"./plugins/{name}"
        require(codex[name] == expected,
                f".codex-plugin/marketplace.json: source for {name} must be {expected}")
        require(claude[name] == expected,
                f".claude-plugin/marketplace.json: source for {name} must be {expected}")
        require((root / "plugins" / name).is_dir(),
                f"plugins/{name}: marketplace plugin directory is missing")
    return sorted(codex)


def check_manifests(root: Path, plugins: list[str]) -> None:
    for plugin_name in plugins:
        plugin = root / "plugins" / plugin_name
        codex_path = plugin / ".codex-plugin" / "plugin.json"
        claude_path = plugin / "plugin.json"
        codex = load_json(root, codex_path)
        claude = load_json(root, claude_path)
        for path, manifest in ((codex_path, codex), (claude_path, claude)):
            require(isinstance(manifest, dict), f"{relative(root, path)}: manifest must be an object")
            require(manifest.get("name") == plugin_name,
                    f"{relative(root, path)}: manifest name must be {plugin_name}")
            require(isinstance(manifest.get("version"), str) and manifest["version"],
                    f"{relative(root, path)}: manifest version is required")
        require(codex["version"] == claude["version"],
                f"plugins/{plugin_name}: paired manifest versions differ")


def check_skill(root: Path, skill_path: Path) -> None:
    text, frontmatter = load_skill(root, skill_path)
    skill_dir = skill_path.parent
    label = relative(root, skill_path)
    require(frontmatter.get("name") == skill_dir.name,
            f"{label}: frontmatter name must equal directory name {skill_dir.name}")
    check_markdown_resource_links(root, skill_path, text)

    agent_path = skill_dir / "agents" / "openai.yaml"
    agent = load_yaml(root, agent_path)
    require(isinstance(agent, dict), f"{relative(root, agent_path)}: agent metadata must be a mapping")
    interface = agent.get("interface")
    require(isinstance(interface, dict), f"{relative(root, agent_path)}: interface mapping is required")
    for field in ("display_name", "short_description"):
        require(isinstance(interface.get(field), str) and interface[field].strip(),
                f"{relative(root, agent_path)}: interface.{field} is required")
    if "default_prompt" in interface:
        require(isinstance(interface["default_prompt"], str) and interface["default_prompt"].strip(),
                f"{relative(root, agent_path)}: interface.default_prompt must be non-empty when present")


def check_aliases(root: Path, alias_contract: Path) -> None:
    document = load_yaml(root, alias_contract)
    entries = document.get("aliases") if isinstance(document, dict) else None
    require(isinstance(entries, list), f"{relative(root, alias_contract)}: aliases must be a list")
    for entry in entries:
        require(isinstance(entry, dict), f"{relative(root, alias_contract)}: alias entry must be a mapping")
        plugin_name, alias, canonical = (entry.get(key) for key in ("plugin", "alias", "canonical"))
        require(all(isinstance(value, str) and value for value in (plugin_name, alias, canonical)),
                f"{relative(root, alias_contract)}: plugin, alias, and canonical are required")
        plugin = root / "plugins" / plugin_name / "skills"
        alias_path = plugin / alias / "SKILL.md"
        canonical_path = plugin / canonical / "SKILL.md"
        text, _ = load_skill(root, alias_path)
        require(canonical_path.is_file(),
                f"{relative(root, canonical_path)}: canonical Skill for alias {alias} is missing")
        expected_link = f"../{canonical}/SKILL.md"
        require(expected_link in markdown_links(text),
                f"{relative(root, alias_path)}: alias must link to {expected_link}")
        agent_path = alias_path.parent / "agents" / "openai.yaml"
        agent = load_yaml(root, agent_path)
        require(agent.get("policy", {}).get("allow_implicit_invocation") is False,
                f"{relative(root, agent_path)}: alias must be explicit-only")


def check_parseable_configs(root: Path) -> None:
    json_paths = {
        root / ".codex-plugin" / "marketplace.json",
        root / ".claude-plugin" / "marketplace.json",
        *(root / "plugins").glob("*/plugin.json"),
        *(root / "plugins").glob("*/.codex-plugin/plugin.json"),
    }
    yaml_paths = {
        *(root / "plugins").glob("*/skills/*/agents/openai.yaml"),
        *(path for path in (root / "tests").glob("**/eval.yaml")
          if ".results" not in path.relative_to(root / "tests").parts),
    }
    for path in sorted(json_paths):
        load_json(root, path)
    for path in sorted(yaml_paths):
        load_yaml(root, path)


def _check_repo_tree(root: Path, alias_contract: Path | None = None) -> None:
    root = root.resolve()
    repository_alias_contract = (
        root / "tests" / "tedtoolkit-project-development"
        / "skill-contract-release-gate" / "aliases.yaml")
    alias_contract = alias_contract or repository_alias_contract
    plugins = check_marketplaces(root)
    check_manifests(root, plugins)
    skill_paths = sorted((root / "plugins").glob("*/skills/*/SKILL.md"))
    require(bool(skill_paths), "plugins: no Skill entrypoints found")
    for skill_path in skill_paths:
        check_skill(root, skill_path)
    for reference_path in sorted((root / "plugins").glob("*/references/**/*.md")):
        check_markdown_resource_links(root, reference_path)
    check_no_install_root_contract(root)
    check_aliases(root, alias_contract)
    check_parseable_configs(root)


def git_tracked_paths(root: Path) -> set[str]:
    try:
        result = subprocess.run(
            ["git", "-C", str(root), "ls-files", "-z"],
            check=True, capture_output=True)
    except (OSError, subprocess.SubprocessError) as error:
        raise ContractError("repository tracked-file inventory is unavailable") from error
    return {entry.decode("utf-8").replace("\\", "/")
            for entry in result.stdout.split(b"\0") if entry}


def check_repo(root: Path, alias_contract: Path | None = None,
               *, tracked_paths: set[str] | None = None) -> None:
    """Validate a frozen view containing only Git-tracked repository inputs."""
    root = root.resolve()
    tracked = tracked_paths if tracked_paths is not None else git_tracked_paths(root)
    alias_contract = alias_contract or (
        root / "tests" / "tedtoolkit-project-development"
        / "skill-contract-release-gate" / "aliases.yaml")
    try:
        alias_relative = alias_contract.resolve().relative_to(root).as_posix()
    except ValueError as error:
        raise ContractError("alias contract must be inside the repository") from error

    with tempfile.TemporaryDirectory(prefix="skill-contract-release-") as temporary:
        frozen = Path(temporary)
        for relative_path in sorted(tracked):
            source = root / relative_path
            if not source.is_file():
                continue
            destination = frozen / relative_path
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, destination)
        _check_repo_tree(frozen, frozen / alias_relative)


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate repository Skill release contracts offline.")
    parser.add_argument("--repo-root", type=Path,
                        default=Path(os.environ.get("TEDTOOLKIT_REPO_ROOT", ".")))
    args = parser.parse_args()
    try:
        check_repo(args.repo_root)
    except ContractError as error:
        print(f"ERROR: {error}")
        return 1
    print("OK: repository Skill release contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
