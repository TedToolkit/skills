import importlib.util
import unittest
from pathlib import Path


SPEC = importlib.util.spec_from_file_location("measure", Path(__file__).with_name("measure.py"))
measure = importlib.util.module_from_spec(SPEC)
assert SPEC.loader
SPEC.loader.exec_module(measure)


class NormalizedSizeTests(unittest.TestCase):
    def test_normalizes_all_line_endings(self):
        self.assertEqual(measure.normalized_size(b"a\r\nb\rc\n"), len("a\nb\nc\n"))

    def test_counts_utf8_bytes_not_characters(self):
        self.assertEqual(measure.normalized_size("中\r\n".encode()), len("中\n".encode()))


if __name__ == "__main__":
    unittest.main()
