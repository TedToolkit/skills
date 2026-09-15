from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import shutil
import tempfile
import unittest

from check import ContractError, check_repo


class SkillContractReleaseGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        source = Path(os.environ["TEDTOOLKIT_REPO_ROOT"])
        shutil.copytree(source / ".codex-plugin", self.root / ".codex-plugin")
        shutil.copytree(source / ".claude-plugin", self.root / ".claude-plugin")
        shutil.copytree(source / "plugins", self.root / "plugins")
        shutil.copy2(source / "CLAUDE.md", self.root / "CLAUDE.md")
        shutil.copy2(source / "README.md", self.root / "README.md")
        (self.root / "tests").mkdir()
        shutil.copy2(source / "tests/run_evals.py", self.root / "tests/run_evals.py")
        for eval_path in source.glob("tests/**/eval.yaml"):
            target = self.root / eval_path.relative_to(source)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(eval_path, target)
        self.alias_contract = self.root / "tests/skill-contract-release-gate/aliases.yaml"
        self.alias_contract.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(Path(__file__).with_name("aliases.yaml"), self.alias_contract)
        self.tracked = {path.relative_to(self.root).as_posix()
                        for path in self.root.rglob("*") if path.is_file()}

    def track_tree(self, path: Path) -> None:
        self.tracked.update(
            item.relative_to(self.root).as_posix()
            for item in path.rglob("*") if item.is_file())

    def tearDown(self) -> None:
        self.temp.cleanup()

    def digest(self) -> str:
        digest = hashlib.sha256()
        for path in sorted(item for item in self.root.rglob("*") if item.is_file()):
            digest.update(path.relative_to(self.root).as_posix().encode())
            digest.update(path.read_bytes())
        return digest.hexdigest()

    def assert_contract_fails(self, expected: str) -> None:
        with self.assertRaisesRegex(ContractError, expected):
            check_repo(self.root, self.alias_contract, tracked_paths=self.tracked)

    def test_valid_repository_passes_without_writes(self) -> None:
        before = self.digest()
        check_repo(self.root, self.alias_contract, tracked_paths=self.tracked)
        self.assertEqual(before, self.digest())

    def test_untracked_skill_cannot_create_failures(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/skills/scratch/SKILL.md"
        path.parent.mkdir(parents=True)
        path.write_text("not frontmatter", encoding="utf-8")
        check_repo(self.root, self.alias_contract, tracked_paths=self.tracked)

    def test_untracked_link_target_cannot_satisfy_a_tracked_link(self) -> None:
        skill = self.root / "plugins/tedtoolkit-shared/skills/tunit-unit-testing/SKILL.md"
        skill.write_text(skill.read_text(encoding="utf-8").replace(
            "../tunit-testing/SKILL.md", "../untracked-target/SKILL.md"), encoding="utf-8")
        target = skill.parent.parent / "untracked-target/SKILL.md"
        target.parent.mkdir(parents=True)
        target.write_text("untracked", encoding="utf-8")
        self.assert_contract_fails("relative link target is missing")

    def test_skill_name_mismatch_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/skills/run-fix/SKILL.md"
        path.write_text(path.read_text(encoding="utf-8").replace("name: run-fix", "name: wrong", 1), encoding="utf-8")
        self.assert_contract_fails("frontmatter name must equal directory name")

    def test_broken_relative_link_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/skills/tunit-unit-testing/SKILL.md"
        path.write_text(path.read_text(encoding="utf-8").replace("../tunit-testing/SKILL.md", "../missing/SKILL.md"), encoding="utf-8")
        self.assert_contract_fails("relative link target is missing")

    def test_broken_reference_resource_link_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/references/commit-style.md"
        path.write_text(path.read_text(encoding="utf-8").replace(
            "../scripts/commit_group.sh", "../scripts/missing.sh"), encoding="utf-8")
        self.assert_contract_fails("relative link target is missing")

    def test_plugin_install_root_dependency_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/skills/run-fix/SKILL.md"
        path.write_text(path.read_text(encoding="utf-8") +
                        "\nUse TEDTOOLKIT_PLUGIN_ROOT to locate helpers.\n", encoding="utf-8")
        self.assert_contract_fails("forbidden plugin-install-root dependency")

    def test_marketplace_plugin_set_drift_fails(self) -> None:
        path = self.root / ".claude-plugin/marketplace.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["plugins"].pop()
        path.write_text(json.dumps(data), encoding="utf-8")
        self.assert_contract_fails("plugin set differs")

    def test_expected_marketplace_plugin_missing_from_both_fails(self) -> None:
        for relative in (".codex-plugin/marketplace.json", ".claude-plugin/marketplace.json"):
            path = self.root / relative
            data = json.loads(path.read_text(encoding="utf-8"))
            data["plugins"] = [entry for entry in data["plugins"]
                               if entry["name"] != "tedtoolkit-hiring"]
            path.write_text(json.dumps(data), encoding="utf-8")
        self.assert_contract_fails("marketplace plugin set must be")

    def test_manifest_version_drift_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/plugin.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["version"] = "99.0.0"
        path.write_text(json.dumps(data), encoding="utf-8")
        self.assert_contract_fails("paired manifest versions differ")

    def test_manifest_description_drift_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-hiring/plugin.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["description"] = "Wrong persona description."
        path.write_text(json.dumps(data), encoding="utf-8")
        self.assert_contract_fails("paired manifest descriptions differ")

    def test_manifest_skill_root_drift_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-hiring/plugin.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["skills"] = ["./other-skills/"]
        path.write_text(json.dumps(data), encoding="utf-8")
        self.assert_contract_fails("paired manifest Skill roots differ")

    def test_duplicate_skill_name_across_plugins_fails(self) -> None:
        duplicate = self.root / "plugins/tedtoolkit-career/skills/run-fix"
        (duplicate / "agents").mkdir(parents=True)
        (duplicate / "SKILL.md").write_text(
            "---\nname: run-fix\ndescription: Duplicate test Skill.\n---\n\n# Duplicate\n",
            encoding="utf-8")
        (duplicate / "agents/openai.yaml").write_text(
            "interface:\n  display_name: Duplicate\n  short_description: Duplicate test Skill\n",
            encoding="utf-8")
        self.track_tree(duplicate)
        self.assert_contract_fails("Skill name run-fix has multiple plugin owners")

    def test_obsolete_career_entrypoint_fails(self) -> None:
        obsolete = self.root / "plugins/tedtoolkit-career/skills/design-interview"
        obsolete.mkdir(parents=True)
        (obsolete / "SKILL.md").write_text(
            "---\nname: design-interview\ndescription: Obsolete.\n---\n", encoding="utf-8")
        self.track_tree(obsolete)
        self.assert_contract_fails("obsolete Skill path remains")

    def test_missing_breaking_replacement_guidance_fails(self) -> None:
        path = self.root / "README.md"
        path.write_text(path.read_text(encoding="utf-8").replace(
            "`tedtoolkit-hiring/design-interview`", "`missing-interviewer-replacement`", 1),
            encoding="utf-8")
        self.assert_contract_fails("missing replacement guidance")

    def test_missing_agent_metadata_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/skills/run-fix/agents/openai.yaml"
        path.unlink()
        self.assert_contract_fails("required YAML file is missing")

    def test_alias_implicit_policy_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/skills/tunit-unit-testing/agents/openai.yaml"
        path.write_text(path.read_text(encoding="utf-8").replace("allow_implicit_invocation: false", "allow_implicit_invocation: true"), encoding="utf-8")
        self.assert_contract_fails("alias must be explicit-only")

    def test_invalid_agent_yaml_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/skills/run-fix/agents/openai.yaml"
        path.write_text("interface: [", encoding="utf-8")
        self.assert_contract_fails("invalid YAML")

    def test_invalid_manifest_json_fails(self) -> None:
        path = self.root / "plugins/tedtoolkit-shared/plugin.json"
        path.write_text("{", encoding="utf-8")
        self.assert_contract_fails("invalid JSON")


if __name__ == "__main__":
    unittest.main()
