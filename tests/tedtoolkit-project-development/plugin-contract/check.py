from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re

import yaml


class ContractError(RuntimeError):
    pass


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def load_yaml(path: Path) -> dict:
    return yaml.safe_load(path.read_text(encoding="utf-8"))


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ContractError(message)


def load_skill(path: Path) -> tuple[str, dict]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    require(bool(lines) and lines[0] == "---", f"{path}: missing opening YAML frontmatter")
    try:
        closing = lines.index("---", 1)
    except ValueError as error:
        raise ContractError(f"{path}: unterminated YAML frontmatter") from error
    metadata = yaml.safe_load("\n".join(lines[1:closing]))
    require(isinstance(metadata, dict), f"{path}: YAML frontmatter must be a mapping")
    return text, metadata


def markdown_links(text: str) -> set[str]:
    return set(re.findall(r"\[[^\]]+\]\(([^)]+)\)", text))


def check_repo(root: Path) -> None:
    plugin = root / "plugins" / "tedtoolkit-project-development"
    codex_manifest = load_json(plugin / ".codex-plugin" / "plugin.json")
    claude_manifest = load_json(plugin / "plugin.json")
    require(codex_manifest["name"] == claude_manifest["name"] == "tedtoolkit-project-development", "manifest names differ")
    require(codex_manifest["version"] == claude_manifest["version"] == "0.4.0", "manifest versions must both be 0.4.0")

    aliases = {
        "change-design": "design-change",
        "implement-change-tdd": "implement-change",
        "prepare-change": "scope-changes",
        "implement-change-work-items": "orchestrate-work-items",
    }
    for alias, canonical in aliases.items():
        skill_dir = plugin / "skills" / alias
        skill_path = skill_dir / "SKILL.md"
        skill_text, frontmatter = load_skill(skill_path)
        metadata = load_yaml(skill_dir / "agents" / "openai.yaml")
        require(frontmatter.get("name") == alias, f"{alias} frontmatter name must be {alias}")
        canonical_link = f"../{canonical}/SKILL.md"
        require(canonical_link in markdown_links(skill_text), f"{alias} does not link to {canonical}")
        canonical_target = (skill_dir / canonical_link).resolve()
        expected_target = (plugin / "skills" / canonical / "SKILL.md").resolve()
        require(canonical_target == expected_target and canonical_target.is_file(),
                f"{alias} canonical target does not exist: {canonical_link}")
        require(metadata.get("policy", {}).get("allow_implicit_invocation") is False, f"{alias} must be explicit-only")

    continue_metadata = load_yaml(plugin / "skills" / "continue-change" / "agents" / "openai.yaml")
    require(continue_metadata["interface"]["display_name"] == "Continue Change", "continue-change UI is missing")
    require("derive" in continue_metadata["interface"]["default_prompt"].lower(), "continue-change prompt must derive the phase")

    orchestration_prompt = load_yaml(plugin / "skills" / "orchestrate-work-items" / "agents" / "openai.yaml")["interface"]["default_prompt"]
    require("only one item is currently ready" in orchestration_prompt, "orchestration must retain one-ready-wave ownership")

    aggregate_prompt = load_yaml(plugin / "skills" / "review-implementation" / "agents" / "openai.yaml")["interface"]["default_prompt"]
    require("aggregate merge-readiness conclusion" in aggregate_prompt, "review-implementation must own the aggregate conclusion")

    for specialist in ("review-code", "review-tests", "verify-implementation"):
        metadata = load_yaml(plugin / "skills" / specialist / "agents" / "openai.yaml")
        require(metadata.get("policy", {}).get("allow_implicit_invocation") is False, f"{specialist} must be explicit-only")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=Path(os.environ["TEDTOOLKIT_REPO_ROOT"]))
    args = parser.parse_args()
    try:
        check_repo(args.repo_root)
    except (ContractError, FileNotFoundError, json.JSONDecodeError, yaml.YAMLError) as error:
        print(f"ERROR: {error}")
        return 1
    print("OK: project-development plugin contract")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
