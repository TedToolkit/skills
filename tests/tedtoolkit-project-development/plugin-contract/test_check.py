from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import tempfile
import unittest

from check import ContractError, check_repo


class PluginContractTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        source = Path(os.environ["TEDTOOLKIT_REPO_ROOT"]) / "plugins" / "tedtoolkit-project-development"
        shutil.copytree(source, self.root / "plugins" / "tedtoolkit-project-development")

    def tearDown(self) -> None:
        self.temp.cleanup()

    def assert_contract_fails(self, expected: str) -> None:
        with self.assertRaisesRegex(ContractError, expected):
            check_repo(self.root)

    def test_real_candidate_contract_passes(self) -> None:
        check_repo(self.root)

    def test_manifest_version_drift_fails(self) -> None:
        path = self.root / "plugins" / "tedtoolkit-project-development" / "plugin.json"
        data = json.loads(path.read_text(encoding="utf-8"))
        data["version"] = "0.3.0"
        path.write_text(json.dumps(data), encoding="utf-8")
        self.assert_contract_fails("manifest versions")

    def test_alias_implicit_policy_drift_fails(self) -> None:
        path = self.root / "plugins" / "tedtoolkit-project-development" / "skills" / "prepare-change" / "agents" / "openai.yaml"
        path.write_text(path.read_text(encoding="utf-8").replace("allow_implicit_invocation: false", "allow_implicit_invocation: true"), encoding="utf-8")
        self.assert_contract_fails("prepare-change must be explicit-only")

    def test_alias_name_outside_frontmatter_does_not_pass(self) -> None:
        path = self.root / "plugins" / "tedtoolkit-project-development" / "skills" / "prepare-change" / "SKILL.md"
        text = path.read_text(encoding="utf-8").replace("name: prepare-change", "name: wrong-name", 1)
        path.write_text(text + "\nname: prepare-change\n", encoding="utf-8")
        self.assert_contract_fails("prepare-change frontmatter name")

    def test_missing_canonical_link_target_fails(self) -> None:
        path = self.root / "plugins" / "tedtoolkit-project-development" / "skills" / "scope-changes" / "SKILL.md"
        path.unlink()
        self.assert_contract_fails("prepare-change canonical target does not exist")

    def test_orchestration_owner_drift_fails(self) -> None:
        path = self.root / "plugins" / "tedtoolkit-project-development" / "skills" / "orchestrate-work-items" / "agents" / "openai.yaml"
        path.write_text(path.read_text(encoding="utf-8").replace("only one item is currently ready", "two items are ready"), encoding="utf-8")
        self.assert_contract_fails("one-ready-wave ownership")

    def test_specialist_implicit_policy_drift_fails(self) -> None:
        path = self.root / "plugins" / "tedtoolkit-project-development" / "skills" / "review-code" / "agents" / "openai.yaml"
        path.write_text(path.read_text(encoding="utf-8").replace("allow_implicit_invocation: false", "allow_implicit_invocation: true"), encoding="utf-8")
        self.assert_contract_fails("review-code must be explicit-only")


if __name__ == "__main__":
    unittest.main()
