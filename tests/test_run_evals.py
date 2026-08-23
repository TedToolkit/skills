import os
import tempfile
import time
import unittest
from pathlib import Path

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


if __name__ == "__main__":
    unittest.main()
