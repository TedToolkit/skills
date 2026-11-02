"""Synthetic resume fixtures and checks of generated artifacts; no live services."""
from __future__ import annotations

import argparse
import csv
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


PRIVATE_NAMES = ("ForgePrivateApp", "ForgePrivateModel", "ForgePrivateNative",
                 "ForgePrivateImport", "ForgePrivateWorkflow", "CutPrivateApp",
                 "CutPrivateGeometry", "DevicePrivateHistory")
ROLE = """# Acme Robotics — 软件工程师

Synthetic supplied job posting, retrieved 2026-01-15; no live research needed.
Required: C# desktop workflows, native-library integration, testing and reusable tooling.
Responsibilities: deliver operator workflows and maintain integration reliability.
"""
NOTES = {
    "capabilities": """# Lin Chen

Employment: Northwind Engineering, 软件工程师, 2023.01—2025.12.
All following statements are candidate-confirmed facts, not target-company history.
- 检测工作台: 2023.01 start, 2023.12 acceptance. Built a C# WPF measurement/report
  workflow so inspection staff could review measurements and export pass/fail reports.
  Connected an existing C++ analysis library; regression tests cover report output.
- 型钢切割工作台: 2024.01 start, 2024.12 acceptance. Implemented cutting-plan and
  leftover-material review in C# so operators could approve cutting plans before execution.
  Used typed geometry inputs and comparison tests. Did not invent the cutting algorithm.
- 焊接工作台: 2025.01 start, 2025.12 acceptance. Built operator control and recovery
  workflows, using connection-state tracking and automatic reconnection. Disconnect tests
  verified recovery. No measured revenue, cost, efficiency or downtime improvement supplied.
""",
    "boundaries": """# Lin Chen

Employment: Northwind Engineering, 软件工程师, 2023.01—Present.
All records below belong to Lin's personal implementation, with the scope shown.
These are evidence records; their private repository identifiers are not public product names.

| Private record | Business product | Purpose and contribution | State and dates |
| --- | --- | --- | --- |
| ForgePrivateApp | 焊接生产工作台 | C# operator workflow for choosing weld paths | 2023.01 start, 2023.12 acceptance; running at customer site |
| ForgePrivateModel | 焊接生产工作台 | BREP model wrapper consumed by that application, not a separately accepted product | part of the same delivery |
| ForgePrivateNative | 焊接规划重构 | C++ native adaptation for the redesigned planning product | 2025.01 start; ongoing; internal validation only |
| ForgePrivateImport | 焊接规划重构 | model-import implementation submitted for review | same initiative; review pending; no field deployment or acceptance |
| ForgePrivateWorkflow | 焊接规划重构 | business components consuming the native adapter and importer | same initiative; prototype |
| CutPrivateApp | 型钢切割工作台 | operator review of cutting plans and leftover materials | 2024.01 start, 2024.08 acceptance; independently accepted delivery |
| CutPrivateGeometry | 型钢切割工作台 | shared geometry component used by cutting and welding | component reuse, not another accepted product |

All three products serve the same customer and share C# and geometry code, but the cutting
product has a separate goal, users' workflow and acceptance. The redesign is not an accepted
version of the older welding product. Preserve the supplied business-facing product names.
""",
    "registry": """# Lin Chen

Candidate-confirmed personal project: TestKit, a public .NET component family, maintained
2025.01—Present. Public portfolio name and https://github.com/example/TestKit are authorized.
Core, Text and Paths packages belong to the same maintained ecosystem, not three products.
Core supplies typed results, Text generates localization accessors, Paths supplies typed paths.
Published these packages; no downstream adoption, unique-user or organization evidence supplied.
Use registry-snapshot.json, a frozen synthetic export in the official NuGet search-response
shape. Its ownership fields and retrieval timestamp are supplied evidence for this test.
The requested statistic covers only TestKit.* owned by fixture-owner, including prereleases.
Other prefixes and other owners are outside this family. Read every supplied response page.
""",
    "dates": """# Lin Chen

Employment: Northwind Engineering, 软件工程师, 2020—2026.
Two work projects are supported; full lifecycle and acceptance dates were not supplied.
- 设备采集工作台: implemented C# device acquisition and disconnect recovery. See the
  authorized local repository evidence/DevicePrivateHistory. Lin Chen <lin@example.test>
  is the candidate. Vendor imports, bots and colleagues' changes are not personal work.
  The email is an authorship key, not an authorized resume contact.
  Lin's work on this component has ended; the product's current status is unknown.
- 报表导出支持: an annual work record confirms implementation and verification of CSV report
  export during 2023. It supplies neither months nor broader project lifecycle boundaries.
Recover dates from the supplied records and Git history. Do not ask me to recall dates.
Do not equate an observed development/maintenance interval with full lifecycle or acceptance.
Keep private identifiers in the evidence ledger, outside final resume copy.
""",
}


def git(root: Path, *args: str, env: dict | None = None) -> str:
    return subprocess.run(["git", *args], cwd=root, env=env, check=True,
                          capture_output=True, text=True, encoding="utf-8").stdout.strip()


def init_repo(root: Path) -> None:
    root.mkdir(parents=True, exist_ok=True)
    git(root, "init", "-b", "main")
    git(root, "config", "user.name", "Fixture")
    git(root, "config", "user.email", "fixture@example.test")
    git(root, "config", "commit.gpgsign", "false")


def setup(case: str, root: Path) -> None:
    root = root.resolve()
    require(root.is_dir() and not any(root.iterdir()),
            "Fixture setup requires an empty temporary directory")
    if os.name == "nt":
        # Sandbox-created files can have a different owner. OWNER RIGHTS inheritance alone
        # then prevents the parent eval process from reading its own generated artifacts.
        # Add only the current fixture reader, without changing any global sandbox setting.
        identity = subprocess.run(["whoami", "/user", "/fo", "csv", "/nh"], check=True,
                                  capture_output=True, text=True, encoding="utf-8").stdout
        sid = next(csv.reader(identity.splitlines()))[1]
        require(re.fullmatch(r"S-1-(?:\d+-)+\d+", sid) is not None, "Invalid fixture reader SID")
        subprocess.run(["icacls", str(root), "/grant", f"*{sid}:(OI)(CI)M"], check=True,
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    (root / "candidate.md").write_text(NOTES[case], encoding="utf-8")
    (root / "role.md").write_text(ROLE, encoding="utf-8")
    (root / ".gitignore").write_text("evidence/\n", encoding="utf-8")
    if case == "registry":
        def package(name, downloads, owners=("fixture-owner",), versions=()):
            return {"id": name, "totalDownloads": downloads, "owners": list(owners),
                    "authors": ["fixture-owner"], "versions": [
                        {"version": version, "downloads": count} for version, count in versions]}
        snapshot = {
            "retrievedAt": "2026-01-15T00:00:00Z",
            "source": "Frozen synthetic NuGet search responses; no live endpoint",
            "pages": [
                {"totalHits": 6, "data": [
                    package("TestKit.Core", 100, versions=(("1.0.0", 60), ("1.1.0", 40))),
                    package("TestKit.Text", 50, versions=(("1.0.0", 50),)),
                    package("LegacyTestKit.Core", 1000),
                    package("TestKit.Fork", 400, owners=("another-owner",)),
                ]},
                {"totalHits": 6, "data": [
                    package("testkit.core", 100, versions=(("1.0.0", 60), ("1.1.0", 40))),
                    package("TestKit.Paths", 75, versions=(("0.2.0-beta.1", 75),)),
                    package("Other.Package", 900),
                ]},
            ],
        }
        (root / "registry-snapshot.json").write_text(
            json.dumps(snapshot, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if case == "dates":
        history = root / "evidence" / "DevicePrivateHistory"
        init_repo(history)
        for index, (author, email, date, subject) in enumerate([
            ("Vendor", "vendor@example.test", "2022-01-10", "Import vendor baseline"),
            ("Lin Chen", "lin@example.test", "2024-03-10", "Implement acquisition workflow"),
            ("Build Bot", "bot@example.test", "2024-04-07", "Regenerate bindings"),
            ("Lin Chen", "lin@example.test", "2024-06-12", "Verify disconnect recovery"),
            ("Colleague", "other@example.test", "2025-09-01", "Maintain another component"),
        ]):
            (history / "work.txt").write_text(f"revision {index}\n", encoding="utf-8")
            git(history, "add", "work.txt")
            commit_env = {**os.environ, "GIT_AUTHOR_NAME": author, "GIT_AUTHOR_EMAIL": email,
                          "GIT_COMMITTER_NAME": author, "GIT_COMMITTER_EMAIL": email,
                          "GIT_AUTHOR_DATE": f"{date}T12:00:00+0000",
                          "GIT_COMMITTER_DATE": f"{date}T12:00:00+0000"}
            git(history, "commit", "-m", subject, env=commit_env)
    init_repo(root)
    git(root, "add", ".")
    git(root, "commit", "-m", "Synthetic resume input")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def section(text: str, labels: tuple[str, ...]) -> str:
    headings = list(re.finditer(r"^## (.+)$", text, re.M))
    for index, heading in enumerate(headings):
        if any(label.lower() in heading[1].lower() for label in labels):
            end = headings[index + 1].start() if index + 1 < len(headings) else len(text)
            return text[heading.end():end]
    raise AssertionError(f"Missing section: {labels}")


def project(text: str, name: str) -> str:
    match = re.search(r"^(#{3,6}) .*" + re.escape(name) + r".*$", text, re.M)
    require(match is not None, f"Missing identifiable product: {name}")
    tail = text[match.end():]
    following = re.search(r"^#{1," + str(len(match[1])) + r"} ", tail, re.M)
    body = tail[:following.start()] if following else tail
    return match[0] + "\n" + body


def check(case: str, text: str) -> None:
    # Emphasis placement does not change a date, count or skill-label contract.
    text = text.replace("**", "")
    for identifier in PRIVATE_NAMES:
        require(identifier not in text, f"Private identifier leaked: {identifier}")
    if case == "capabilities":
        summary = section(text, ("职业概述", "专业概述", "个人概述", "个人简介", "职业简介",
                                 "专业简介", "Professional Summary", "Professional Profile"))
        for stream in ("检测", "切割", "焊接"):
            require(stream in summary, f"Summary hides business stream: {stream}")
        skills = section(text, ("核心技能", "核心能力", "Core Skills"))
        bullets = re.split(r"(?m)^[-*] ", skills)[1:]
        require(len(bullets) >= 2, "Expected multiple evidenced capabilities")
        for bullet in bullets:
            label = re.match(r"([^：:\n]+)[：:]\s*(.*)", bullet, re.S)
            require(label is not None, "A core skill must start with a skill-name label")
            sentences = [s.strip() for s in re.split(r"[。！？]", label[2]) if s.strip()]
            require(len(sentences) == 2, "Each core skill needs two sentences after the colon")
            require(not re.search(r"(?:HR|技术读者|技术说明)[：:]", label[2]),
                    "Audience sublabels are not resume copy")
    elif case == "boundaries":
        work = section(text, ("工作经历", "项目经历", "Professional Experience"))
        headings = list(re.finditer(r"^(#{3,6}) (.+)$", work, re.M))
        leaves = [h for i, h in enumerate(headings) if i + 1 == len(headings)
                  or len(headings[i + 1][1]) <= len(h[1])]
        require(len(leaves) == 3, "Seven component records must yield three actual product entries")
        legacy = project(text, "焊接生产工作台")
        redesign = project(text, "焊接规划重构")
        cutting = project(text, "型钢切割工作台")
        require("现场" in legacy and "模型" in legacy, "Legacy field use or model contribution lost")
        require("评审" in redesign, "Redesign review state lost")
        require("内部" in redesign and ("验证" in redesign or "测试" in redesign),
                "Native component's separate internal-validation state lost")
        require(re.search(r"余料|剩余材料", cutting) is not None, "Independent cutting workflow lost")
    elif case == "registry":
        require(re.search(r"225\s*(?:次|下载)|225\s+downloads", text, re.I) is not None,
                "Expected 225 downloads after owner/prefix filtering and ID deduplication")
        require(re.search(r"(?:3|三)\s*(?:个|packages)", text, re.I) is not None,
                "Expected three distinct included packages")
        measurement = re.findall(r"2026[.年/-]0?1[.月/-]15日?", text)
        require(len(measurement) == 1, "Metric needs one measurement date, separate from chronology")
        metric_block = next((p for p in text.split("\n\n") if "225" in p), "")
        require(re.search(r"2026[.年/-]0?1[.月/-]15", metric_block) is not None,
                "Measurement date must stay attached to its statistic")
        require(not re.search(r"^#{3,6} .*TestKit\.(Core|Text|Paths)", text, re.M),
                "Packages were expanded into independent resume projects")
        require(not re.search(r"225\s*(?:位|名|家|个用户|users|organizations)", text, re.I),
                "Download count misrepresented as users or organizations")
    elif case == "dates":
        device = project(text, "设备采集工作台")
        reports = project(text, "报表导出支持")
        for body in (device, reports):
            lines = [line.strip() for line in body.splitlines() if line.strip()]
            range_index = 0 if re.search(r"20\d{2}", lines[0]) else 1
            require(len(lines) > range_index and re.search(r"20\d{2}", lines[range_index]),
                    "Project range must be beside the name or precede prose")
            require(not re.search(r"20\d{2}", "\n".join(lines[range_index + 1:])),
                    "Chronology leaked into project prose")
            require(re.search(r"记录|个人|研发|维护", lines[range_index]) is not None,
                    "Observed work interval must be labeled, not presented as acceptance")
        require(re.search(r"2024[.年/-]0?3", device) is not None
                and re.search(r"2024[.年/-]0?6", device) is not None,
                "Candidate's authored March-June interval not recovered")
        require("2022" not in device and "2025" not in device and "至今" not in device,
                "Vendor/colleague dates or unknown current status widened the interval")
        require(re.search(r"2023年?\s*(?:[—–~-]+|至|到)\s*2023年?", reports) is not None,
                "Year-only source must retain both boundaries without invented months")
        require(not re.search(r"2023[.年/-]\d{1,2}", reports), "Months invented from an annual record")
        require("lin@example.test" not in text, "Git authorship key became a resume contact")
    else:
        raise ValueError(case)


class BehaviorChecks(unittest.TestCase):
    def test_core_format_and_business_coverage(self):
        good = ("## 职业概述\n检测、切割与焊接应用开发。\n## 核心技能\n"
                "- **桌面开发：**支持检测人员审核结果。采用 C# WPF 实现报告流程并通过回归测试。\n"
                "- **设备通信：**支持中断后恢复作业。采用连接状态跟踪和自动重连并验证恢复。\n")
        check("capabilities", good)
        check("capabilities", good.replace("**桌面开发：**", "**桌面开发**："))
        check("capabilities", good.replace("**", ""))
        check("capabilities", good.replace("## 职业概述", "## 个人简介"))
        for bad in (good.replace("切割", "平台"), good.replace("并验证恢复。", "。另有能力。"),
                    good.replace("**设备通信：**", "**设备通信**")):
            with self.assertRaises(AssertionError):
                check("capabilities", bad)

    def test_product_boundaries_and_states(self):
        good = ("## 工作经历\n### 公司\n#### 焊接生产工作台\n现场运行，包含 BREP 模型包装。\n"
                "#### 焊接规划重构\n原生适配通过内部验证，模型导入仍在评审。\n"
                "#### 型钢切割工作台\n余料审核已独立验收。\n")
        check("boundaries", good)
        for bad in (good + "#### 另一个模型项目\nBREP 包装。\n",
                    good.replace("#### 型钢切割工作台", "切割也算在焊接里"),
                    good.replace("仍在评审", "已经交付"), good + "ForgePrivateApp"):
            with self.assertRaises(AssertionError):
                check("boundaries", bad)

    def test_registry_scope_count_and_date(self):
        good = "### TestKit\n2025—至今\n\n3 个包累计 225 次下载（截至 2026.01.15）。\n"
        check("registry", good)
        check("registry", good.replace("225 次", "**225** 次"))
        for bad in (good.replace("225", "450"), good.replace("3 个", "4 个"),
                    good.replace("2026.01.15", ""), good.replace("次下载", "家组织"),
                    good + "### TestKit.Core\n单独一个项目。\n",
                    good + "\n截至 2026.01.15。\n"):
            with self.assertRaises(AssertionError):
                check("registry", bad)

    def test_authored_period_and_source_precision(self):
        good = ("### 设备采集工作台\n2024.03—2024.06（个人研发记录期）\n\n- 实现采集与恢复。\n"
                "### 报表导出支持\n2023—2023（已知工作记录期）\n\n- 验证导出。\n")
        check("dates", good)
        check("dates", good.replace("\n2024.03—2024.06", "｜2024.03—2024.06"))
        check("dates", good.replace("2023—2023", "2023年至2023年"))
        for bad in (good.replace("2024.03", "2022.01"), good.replace("2024.06", "至今"),
                    good.replace("2023—2023", "2023.01—2023.12"),
                    good.replace("- 实现采集", "- 在2024.03实现采集"),
                    good.replace("个人研发记录期", "已验收")):
            with self.assertRaises(AssertionError):
                check("dates", bad)

    def test_git_fixture_separates_authorship_and_status(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            setup("dates", root)
            history = git(root / "evidence" / "DevicePrivateHistory", "log", "--reverse",
                          "--author=lin@example.test", "--format=%as").splitlines()
            self.assertEqual(["2024-03-10", "2024-06-12"], history)
            self.assertEqual("", git(root, "status", "--porcelain"))

    def test_setup_preserves_existing_directories(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sentinel = root / "existing.md"
            sentinel.write_text("preserve me", encoding="utf-8")
            with self.assertRaises(AssertionError):
                setup("capabilities", root)
            self.assertEqual("preserve me", sentinel.read_text(encoding="utf-8"))
            self.assertFalse((root / ".git").exists())


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("operation", choices=("setup", "check", "self-test"))
    parser.add_argument("case", nargs="?", choices=tuple(NOTES))
    args = parser.parse_args()
    if args.operation == "self-test":
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(BehaviorChecks)
        result = unittest.TextTestRunner(verbosity=2).run(suite)
        raise SystemExit(0 if result.wasSuccessful() else 1)
    if args.case is None:
        parser.error("setup/check require a case")
    if args.operation == "setup":
        setup(args.case, Path.cwd())
    else:
        check(args.case, Path("resume.md").read_text(encoding="utf-8"))
        status = git(Path.cwd(), "--no-optional-locks", "status", "--porcelain", "--untracked-files=all")
        require(status == "?? resume.md",
                f"Only resume.md may change; actual Git status: {status!r}")
        if args.case == "dates":
            require(not git(Path("evidence/DevicePrivateHistory"), "--no-optional-locks", "status", "--porcelain"),
                    "Git evidence was modified")
        print(f"PASS: {args.case} resume behavior and artifact boundary")


if __name__ == "__main__":
    try:
        main()
    except (AssertionError, OSError) as error:
        raise SystemExit(f"FAIL: {error}") from None
