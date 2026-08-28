import os
import tempfile
import time
import unittest
from pathlib import Path
from types import SimpleNamespace

import run_evals


class AssertionHarnessTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.workdir = Path(self.temp_dir.name)

    def tearDown(self):
        self.temp_dir.cleanup()

    def check(self, assertion, *, deadline=None):
        return run_evals.check_assertion_safe(
            assertion,
            self.workdir,
            os.environ.copy(),
            "result text",
            0,
            real_home=self.workdir,
            deadline=deadline if deadline is not None else time.monotonic() + 10,
        )

    def test_glob_is_rooted_and_recursion_is_explicit(self):
        (self.workdir / "root.txt").write_text("root", encoding="utf-8")
        (self.workdir / "nested").mkdir()
        (self.workdir / "nested" / "child.txt").write_text("child", encoding="utf-8")

        self.assertEqual([self.workdir / "root.txt"], run_evals._glob(self.workdir, "*.txt"))
        self.assertEqual(2, len(run_evals._glob(self.workdir, "**/*.txt")))

    def test_file_not_contains_requires_a_match_unless_opted_out(self):
        failed = self.check({"type": "file_not_contains", "path": "missing.txt", "value": "x"})
        allowed = self.check({"type": "file_not_contains", "path": "missing.txt", "value": "x",
                              "allow_no_match": True})

        self.assertFalse(failed["passed"])
        self.assertTrue(allowed["passed"])

    def test_invalid_regex_is_a_failed_assertion(self):
        result = self.check({"type": "output_regex", "pattern": "["})

        self.assertFalse(result["passed"])
        self.assertIn("invalid regex", result["evidence"])

    def test_expired_command_assertion_does_not_start(self):
        result = self.check({"type": "command", "run": "exit 0"}, deadline=time.monotonic() - 1)

        self.assertFalse(result["passed"])
        self.assertIn("deadline expired before command", result["evidence"])

    def test_malformed_assertion_does_not_raise(self):
        result = self.check({"type": "file_contains", "path": "missing.txt"})

        self.assertFalse(result["passed"])
        self.assertIn("malformed assertion", result["evidence"])

    def test_rubric_failures_gate_the_record(self):
        base = {"assertions": [{"passed": True}]}

        self.assertTrue(run_evals.record_passes(base))
        self.assertFalse(run_evals.record_passes({**base, "rubric_grades": []}))
        self.assertFalse(run_evals.record_passes(
            {**base, "rubric_grades": [{"passed": True}, {"passed": False}]}
        ))

    def test_codex_shell_environment_is_explicit_and_secret_safe(self):
        args = run_evals.codex_shell_environment_args(
            {"codex_shell_environment": ["GIT_DIR", "GIT_WORK_TREE"]},
            {"GIT_DIR": r"C:\fixture\.repo-state", "GIT_WORK_TREE": r"C:\fixture",
             "TEDTOOLKIT_PLUGIN_ROOT": r"C:\candidate", "API_TOKEN": "must-not-leak"},
            extra_names=("TEDTOOLKIT_PLUGIN_ROOT",),
        )

        rendered = " ".join(args)
        self.assertIn('shell_environment_policy.inherit="core"', rendered)
        self.assertIn("shell_environment_policy.set.GIT_DIR", rendered)
        self.assertIn("shell_environment_policy.set.GIT_WORK_TREE", rendered)
        self.assertIn("shell_environment_policy.set.TEDTOOLKIT_PLUGIN_ROOT", rendered)
        self.assertNotIn("API_TOKEN", rendered)
        self.assertNotIn("must-not-leak", rendered)

    def test_skill_execution_prompt_targets_unique_candidate(self):
        prompt = run_evals.skill_execution_prompt(
            "tedtoolkit-shared-eval-a1b2c3d4", "merge-default-branch", "Sync my branch.")

        self.assertTrue(prompt.startswith(
            "Use $tedtoolkit-shared-eval-a1b2c3d4:merge-default-branch"))
        self.assertIn("User request:\nSync my branch.", prompt)

    def test_scenario_codex_command_is_hermetic_and_noninteractive(self):
        plugin_root = self.workdir / "candidate-plugin"
        result_path = self.workdir / "last-message.txt"
        env = {"TEDTOOLKIT_PLUGIN_ROOT": "stale"}

        command = run_evals.scenario_codex_command(
            {}, env, result_path, eval_plugin_root=plugin_root)
        rendered = " ".join(str(part) for part in command)

        self.assertIn('-a on-request -c approvals_reviewer="auto_review" exec', rendered)
        self.assertIn("--ignore-rules", command)
        self.assertIn("--sandbox workspace-write", rendered)
        self.assertIn(f"--add-dir {plugin_root}", rendered)
        self.assertEqual(str(plugin_root), env["TEDTOOLKIT_PLUGIN_ROOT"])

    def test_scenario_execution_path_prepends_fixture_binstub(self):
        (self.workdir / ".binstub").mkdir()

        rendered = run_evals.scenario_execution_path(
            self.workdir, [r"C:\Git\usr\bin", r"C:\Git\bin"], r"C:\Windows")

        self.assertEqual(str(self.workdir / ".binstub"), rendered.split(os.pathsep)[0])
        self.assertIn(r"C:\Git\usr\bin", rendered)

    def test_static_scenario_executes_assertions_through_fixture_binstub(self):
        eval_dir = self.workdir / "eval"
        eval_dir.mkdir()
        scenario = {
            "name": "fixture binstub",
            "mode": "static",
            "setup": {"commands": [
                "mkdir -p .binstub && printf '#!/usr/bin/env bash\\ntouch stub-used\\n' "
                "> .binstub/dotnet && chmod +x .binstub/dotnet"
            ]},
            "assertions": [{"type": "command", "run": "dotnet && test -e stub-used"}],
            "timeout": 30,
        }

        record = run_evals.run_scenario(
            "stub-path", eval_dir, scenario, SimpleNamespace(judge=False, keep=False))

        self.assertTrue(run_evals.record_passes(record), record)

    def test_tool_command_audit_ignores_output_but_detects_command_input(self):
        events = "\n".join([
            '{"type":"item.completed","item":{"type":"command_execution",'
            '"command":"git status --porcelain=v2 -z -uall",'
            '"aggregated_output":"? untracked/private-canary.txt"}}',
            '{"type":"item.completed","item":{"type":"command_execution",'
            '"command":"Get-Content untracked/private-canary.txt"}}',
        ])

        commands = run_evals.extract_tool_commands(events)
        safe = run_evals.check_assertion_safe(
            {"type": "tool_command_not_contains", "value": "SYNTHETIC-CANARY"},
            self.workdir, os.environ.copy(), "result text", 0,
            real_home=self.workdir, deadline=time.monotonic() + 10,
            tool_commands=commands)
        targeted = run_evals.check_assertion_safe(
            {"type": "tool_command_not_contains", "value": "private-canary.txt"},
            self.workdir, os.environ.copy(), "result text", 0,
            real_home=self.workdir, deadline=time.monotonic() + 10,
            tool_commands=commands)

        self.assertEqual(2, len(commands))
        self.assertTrue(safe["passed"])
        self.assertFalse(targeted["passed"])

    def test_tool_command_audit_fails_closed_without_recognized_commands(self):
        commands = run_evals.extract_tool_commands(
            '{"type":"item.completed","item":{"type":"future_command_event"}}')

        result = run_evals.check_assertion_safe(
            {"type": "tool_command_not_contains", "value": "private-canary.txt"},
            self.workdir, os.environ.copy(), "result text", 0,
            real_home=self.workdir, deadline=time.monotonic() + 10,
            tool_commands=commands)

        self.assertEqual([], commands)
        self.assertFalse(result["passed"])
        self.assertIn("no recognized", result["evidence"])

    def test_tool_command_audit_fails_closed_on_partial_schema_drift(self):
        commands = run_evals.extract_tool_commands("\n".join([
            '{"type":"item.completed","item":{"type":"command_execution",'
            '"command":"git status --porcelain=v2"}}',
            '{"type":"item.completed","item":{"type":"future_command_event",'
            '"command":"Get-Content private-canary.txt"}}',
        ]))

        result = run_evals.check_assertion_safe(
            {"type": "tool_command_not_contains", "value": "private-canary.txt"},
            self.workdir, os.environ.copy(), "result text", 0,
            real_home=self.workdir, deadline=time.monotonic() + 10,
            tool_commands=commands)

        self.assertEqual(["git status --porcelain=v2"], commands)
        self.assertFalse(commands.complete)
        self.assertFalse(result["passed"])
        self.assertIn("future_command_event", result["evidence"])

    def test_input_identity_changes_with_source_bytes(self):
        source = self.workdir / "source"
        source.mkdir()
        tracked = source / "input.txt"
        tracked.write_text("before", encoding="utf-8")

        before = run_evals.build_input_identity([source])
        tracked.write_text("after", encoding="utf-8")
        after = run_evals.build_input_identity([source])

        self.assertEqual(1, before["file_count"])
        self.assertEqual([source.resolve().as_posix()], before["roots"])
        self.assertNotEqual(before["sha256"], after["sha256"])


if __name__ == "__main__":
    unittest.main()
