import unittest
from pathlib import Path

SITE = Path(__file__).resolve().parents[1] / "site" / "index.html"


class TestSite(unittest.TestCase):
    def test_homepage_has_title(self):
        html = SITE.read_text(encoding="utf-8")
        self.assertIn("<h1>DevOps Fast Track</h1>", html)

    def test_homepage_has_version(self):
        html = SITE.read_text(encoding="utf-8")
        self.assertIn("Version", html)


if __name__ == "__main__":
    unittest.main()
