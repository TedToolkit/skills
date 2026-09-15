#!/usr/bin/env python3
"""Validate canonical TedToolkit hiring Markdown records and their cross-links."""

from __future__ import annotations

import argparse
from datetime import date
from pathlib import Path, PurePosixPath
import re
import tempfile

import yaml


DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
KINDS = {
    "company", "role", "candidate", "resume", "application", "assessment", "interview"
}
VERDICT_PATTERNS = (
    r"(?im)^\s*(?:final\s+)?(?:verdict|recommendation|decision|outcome)\s*:\s*"
    r"(?:hire|reject|advance|proceed|move forward|select|eliminate)",
    r"(?is)\b(?:recommend|recommended|recommends)\b.{0,40}"
    r"\b(?:hire|reject|advance|proceed|select|eliminate)\b",
    r"(?is)\b(?:candidate|applicant)\s+(?:should|must|will|can)\b.{0,50}"
    r"\b(?:hire|hired|reject|rejected|advance|advanced|proceed|selected|eliminate|eliminated)\b",
    r"(?i)\b(?:strong|weak|lean|clear)\s+(?:hire|reject|yes|no)\b",
    r"(?i)\bmov(?:e|ing)\s+(?:(?:the\s+)?(?:candidate|applicant)|[A-Z][\w-]*)\s+forward\b",
    r"(?i)\bmov(?:e|ing)\s+forward\s+with\s+(?:the\s+)?(?:candidate|applicant|[A-Z][\w-]*)\b",
    r"(?i)\b(?:advance|proceed|progress)\s+(?:the\s+(?:candidate|applicant)\s+)?"
    r"(?:to|into|with)\b",
    r"(?i)\b(?:do not|don't|should not|shouldn't)\s+"
    r"(?:hire|advance|proceed|select|move forward|eliminate)\b",
    r"(?i)\b(?:hire|reject|advance|select|eliminate)\s+"
    r"(?:this|the)\s+(?:candidate|applicant)\b",
    r"(?i)\b(?:send|put)\s+(?:the\s+)?(?:candidate|applicant)\s+"
    r"(?:to|through)\s+(?:the\s+)?next\s+(?:round|stage)\b",
    r"(?i)\b(?:continue|proceed)\s+with\s+"
    r"(?:the\s+)?(?:candidate|applicant|application)\b",
    r"(?m)^\s*(?:Hire|Reject|Advance|Select|Eliminate)\s+[A-Z][\w-]*[.!]?\s*$",
)
FORBIDDEN_VALUES = (
    "SyntheticStatus", "SyntheticFamilyStatus", "SyntheticHealthValue",
    "SyntheticDisabilityValue", "ORANGE-NEBULA-7719", "VIOLET-COMET-8820",
    "CYAN-ASTEROID-6631", "SILVER-QUASAR-4402",
)
HUMAN_OWNER = "Decision owner: the accountable human hiring team."


def fail(message: str) -> None:
    raise AssertionError(message)


def load(path: Path) -> tuple[dict, str]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        fail(f"{path}: YAML frontmatter must precede content")
    try:
        closing = lines.index("---", 1)
    except ValueError:
        fail(f"{path}: unterminated YAML frontmatter")
    try:
        metadata = yaml.safe_load("\n".join(lines[1:closing]))
    except yaml.YAMLError as exc:
        fail(f"{path}: malformed YAML frontmatter: {exc}")
    if not isinstance(metadata, dict):
        fail(f"{path}: frontmatter must be a mapping")
    body = "\n".join(lines[closing + 1:])
    h1s = re.findall(r"(?m)^#\s+\S.*$", body)
    if len(h1s) != 1:
        fail(f"{path}: expected exactly one H1, got {h1s!r}")
    return metadata, body


def require_date(value: object, label: str) -> None:
    rendered = value.isoformat() if isinstance(value, date) else str(value)
    if not DATE_RE.fullmatch(rendered):
        fail(f"{label}: expected YYYY-MM-DD")
    try:
        date.fromisoformat(rendered)
    except ValueError:
        fail(f"{label}: invalid calendar date")


def classify(path: Path, root: Path) -> tuple[str, str, str | None]:
    try:
        parts = path.resolve().relative_to(root.resolve()).parts
    except ValueError:
        fail(f"{path}: record is outside workspace root")
    if len(parts) == 3 and parts[0] == "companies" and parts[2] == "company.md":
        return "company", parts[1], None
    if (
        len(parts) == 5 and parts[0] == "companies" and parts[2] == "roles"
        and parts[4] == "role.md"
    ):
        return "role", parts[1], parts[3]
    if (
        len(parts) == 5 and parts[0] == "companies" and parts[2] == "candidates"
        and parts[4] == "candidate.md"
    ):
        return "candidate", parts[1], parts[3]
    if (
        len(parts) == 7 and parts[0] == "companies" and parts[2] == "candidates"
        and parts[4] == "resumes" and re.fullmatch(r"\d{4}-\d{2}-\d{2}-resume\.md", parts[5])
    ):
        # Kept for a defensive error below; canonical resumes have six relative parts.
        fail(f"{path}: unexpected resume path depth")
    if (
        len(parts) == 6 and parts[0] == "companies" and parts[2] == "candidates"
        and parts[4] == "resumes" and re.fullmatch(r"\d{4}-\d{2}-\d{2}-resume\.md", parts[5])
    ):
        return "resume", parts[1], parts[3]
    if (
        len(parts) == 6 and parts[0] == "companies" and parts[2] == "applications"
        and parts[5] in {"application.md", "assessment.md", "interview-plan.md"}
    ):
        kind = {
            "application.md": "application",
            "assessment.md": "assessment",
            "interview-plan.md": "interview",
        }[parts[5]]
        return kind, parts[1], f"{parts[3]}/{parts[4]}"
    fail(f"{path}: not a canonical hiring record path")


def require_ids(metadata: dict, kind: str, company: str, tail: str | None, path: Path) -> None:
    expected = {"company_id": company}
    if kind == "role":
        expected["role_id"] = tail
    elif kind in {"candidate", "resume"}:
        expected["candidate_id"] = tail
    elif kind in {"application", "assessment", "interview"}:
        role, candidate = str(tail).split("/", 1)
        expected.update(role_id=role, candidate_id=candidate)
    for key, value in expected.items():
        if metadata.get(key) != value:
            fail(f"{path}: {key} must equal canonical path value {value!r}")
    for key in {"company_id", "role_id", "candidate_id"} - expected.keys():
        if key in metadata:
            fail(f"{path}: unexpected {key}")
    if "updated" not in metadata:
        fail(f"{path}: updated is required")
    require_date(metadata["updated"], f"{path}: updated")


def evidence_list(metadata: dict, path: Path) -> list[str]:
    evidence = metadata.get("evidence")
    if (
        not isinstance(evidence, list) or not evidence
        or any(not isinstance(item, str) or not item.strip() for item in evidence)
        or len(evidence) != len(set(evidence))
    ):
        fail(f"{path}: evidence must be a non-empty unique string list")
    return evidence


def validate_evidence_pointer(pointer: str, root: Path, company: str, candidate: str,
                              path: Path) -> None:
    normalized = pointer.replace("\\", "/")
    pure = PurePosixPath(normalized)
    if (
        pure.is_absolute() or re.match(r"^[A-Za-z]:", normalized)
        or ".." in pure.parts or any(character in normalized for character in "*?[]")
    ):
        fail(f"{path}: unsafe evidence pointer {pointer!r}")
    parts = list(pure.parts)
    if parts and parts[0] == root.name:
        target = root.parent.joinpath(*parts)
        parts = parts[1:]
    elif parts and parts[0] == "companies":
        target = root.joinpath(*parts)
    else:
        target = root.parent.joinpath(*parts)
    if parts and parts[0] == "companies":
        expected_prefix = ["companies", company, "candidates", candidate, "resumes"]
        if parts[:5] != expected_prefix or len(parts) != 6:
            fail(f"{path}: cross-boundary workspace evidence {pointer!r}")
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}-resume\.md", parts[5]):
            fail(f"{path}: non-canonical normalized resume pointer {pointer!r}")
    if not target.is_file():
        fail(f"{path}: evidence pointer does not name an existing file {pointer!r}")


def require_no_verdict(body: str, path: Path) -> None:
    if HUMAN_OWNER not in body:
        fail(f"{path}: missing required human-decision ownership statement")
    folded = body.casefold()
    for forbidden in FORBIDDEN_VALUES:
        if forbidden.casefold() in folded:
            fail(f"{path}: leaked protected or sibling synthetic value")
    for pattern in VERDICT_PATTERNS:
        if re.search(pattern, body):
            fail(f"{path}: final-verdict language matched {pattern}")


def validate(path: Path, root: Path, requirements: list[str]) -> str:
    kind, company, tail = classify(path, root)
    metadata, body = load(path)
    require_ids(metadata, kind, company, tail, path)

    fixed_h1 = {
        "resume": "# Normalized Resume",
        "application": "# Application",
        "assessment": "# Candidate Assessment",
        "interview": "# Interview Plan",
    }.get(kind)
    if fixed_h1 and re.findall(r"(?m)^#\s+\S.*$", body) != [fixed_h1]:
        fail(f"{path}: expected H1 {fixed_h1!r}")

    if kind == "resume":
        if not isinstance(metadata.get("source"), str) or not metadata["source"].strip():
            fail(f"{path}: immutable source pointer is required")
        validate_evidence_pointer(metadata["source"], root, company, str(tail), path)
        require_date(path.name[:10], f"{path}: filename date")
    elif kind in {"application", "assessment", "interview"}:
        role, candidate = str(tail).split("/", 1)
        evidence = evidence_list(metadata, path)
        application = (
            path if kind == "application"
            else root / "companies" / company / "applications" / role / candidate / "application.md"
        )
        if kind != "application":
            application_metadata, _ = load(application)
            require_ids(application_metadata, "application", company, tail, application)
            selected = evidence_list(application_metadata, application)
            if evidence != selected:
                fail(f"{path}: evidence must exactly equal the application selection")
        for pointer in evidence:
            validate_evidence_pointer(pointer, root, company, candidate, path)
        if kind == "interview":
            expected = (
                f"{root.name}/companies/{company}/applications/{role}/{candidate}/assessment.md"
            )
            if metadata.get("assessment") != expected:
                fail(f"{path}: assessment must equal {expected!r}")
        if kind == "assessment":
            if "## Requirement Evidence Matrix" not in body:
                fail(f"{path}: missing structured requirement evidence matrix")
            require_no_verdict(body, path)
        elif kind == "interview":
            if "## Requirement Coverage" not in body:
                fail(f"{path}: missing structured requirement coverage")
            require_no_verdict(body, path)

    folded = body.casefold()
    for requirement in requirements:
        if requirement.casefold() not in folded:
            fail(f"{path}: missing requirement coverage for {requirement!r}")
    return kind


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def frontmatter(**values: object) -> str:
    return "---\n" + yaml.safe_dump(values, sort_keys=False).strip() + "\n---\n"


def self_test() -> None:
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp) / "hiring-workspace"
        base = root / "companies" / "northwind"
        selected = (
            "hiring-workspace/companies/northwind/candidates/avery/"
            "resumes/2026-09-15-resume.md"
        )
        paths = {
            "company": base / "company.md",
            "role": base / "roles/platform/role.md",
            "candidate": base / "candidates/avery/candidate.md",
            "resume": base / "candidates/avery/resumes/2026-09-15-resume.md",
            "application": base / "applications/platform/avery/application.md",
            "assessment": base / "applications/platform/avery/assessment.md",
            "interview": base / "applications/platform/avery/interview-plan.md",
        }
        write(root.parent / "source.md", "Synthetic immutable resume source.\n")
        write(paths["company"], frontmatter(company_id="northwind", updated="2026-09-15") + "# Northwind\n")
        write(paths["role"], frontmatter(company_id="northwind", role_id="platform", updated="2026-09-15") + "# Platform Engineer\n")
        write(paths["candidate"], frontmatter(company_id="northwind", candidate_id="avery", updated="2026-09-15") + "# Avery\n")
        write(paths["resume"], frontmatter(company_id="northwind", candidate_id="avery", source="source.md", updated="2026-09-15") + "# Normalized Resume\n")
        write(paths["application"], frontmatter(company_id="northwind", role_id="platform", candidate_id="avery", updated="2026-09-15", evidence=[selected]) + "# Application\n")
        assessment_text = frontmatter(company_id="northwind", role_id="platform", candidate_id="avery", updated="2026-09-15", evidence=[selected]) + "# Candidate Assessment\n\n## Requirement Evidence Matrix\n\n| Kubernetes operations | Not demonstrated |\n\nDecision owner: the accountable human hiring team.\n"
        write(paths["assessment"], assessment_text)
        interview_text = frontmatter(company_id="northwind", role_id="platform", candidate_id="avery", updated="2026-09-15", evidence=[selected], assessment="hiring-workspace/companies/northwind/applications/platform/avery/assessment.md") + "# Interview Plan\n\n## Requirement Coverage\n\n- Kubernetes operations: Question 1\n\nDecision owner: the accountable human hiring team.\n"
        write(paths["interview"], interview_text)

        observed = {validate(path, root, ["Kubernetes operations"] if kind in {"assessment", "interview"} else []) for kind, path in paths.items()}
        if observed != KINDS:
            fail(f"not every canonical kind was validated: {observed!r}")

        mutations = (
            ("missing id", paths["assessment"], assessment_text.replace("candidate_id: avery\n", "")),
            ("mismatched id", paths["assessment"], assessment_text.replace("candidate_id: avery", "candidate_id: blake")),
            ("malformed frontmatter", paths["assessment"], assessment_text.replace("company_id: northwind", "company_id: [")),
            ("malformed date", paths["assessment"], assessment_text.replace("2026-09-15", "2026-02-30", 1)),
            ("wrong evidence", paths["assessment"], assessment_text.replace(selected, "newly-named.md")),
            ("cross application", paths["interview"], interview_text.replace("/platform/avery/assessment.md", "/data/avery/assessment.md")),
            ("extra H1", paths["assessment"], assessment_text + "\n# Extra\n"),
            ("sibling candidate pointer", paths["application"], paths["application"].read_text().replace("/avery/resumes/", "/blake/resumes/")),
            ("cross company pointer", paths["application"], paths["application"].read_text().replace("/northwind/candidates/", "/fabrikam/candidates/")),
            ("verdict", paths["assessment"], assessment_text + "\nProceed with the application.\n"),
            ("hire verdict", paths["assessment"], assessment_text + "\nHire Avery.\n"),
            ("reject verdict", paths["assessment"], assessment_text + "\nReject Avery.\n"),
            ("advance verdict", paths["assessment"], assessment_text + "\nAdvance Avery.\n"),
            ("eliminate verdict", paths["assessment"], assessment_text + "\nEliminate Avery.\n"),
            ("move-forward verdict", paths["assessment"], assessment_text + "\nMove Avery forward.\n"),
            ("missing human owner", paths["assessment"], assessment_text.replace(HUMAN_OWNER, "")),
            ("missing evidence", paths["application"], paths["application"].read_text().replace(selected, "source-resumes/missing.md")),
            ("wildcard evidence", paths["application"], paths["application"].read_text().replace(selected, "source-resumes/*.md")),
        )
        originals = {path: path.read_text(encoding="utf-8") for path in paths.values()}
        for label, path, mutation in mutations:
            write(path, mutation)
            try:
                validate(path, root, ["Kubernetes operations"] if path.name != "application.md" else [])
            except (AssertionError, yaml.YAMLError):
                pass
            else:
                fail(f"mutation passed: {label}")
            write(path, originals[path])
    print("7 canonical kinds and 18 mutation checks passed")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workspace-root")
    parser.add_argument("--record", action="append", default=[])
    parser.add_argument("--requirement", action="append", default=[])
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return
    if not args.workspace_root or not args.record:
        parser.error("--workspace-root and at least one --record are required")
    root = Path(args.workspace_root)
    observed = [validate(Path(record), root, args.requirement) for record in args.record]
    print(f"validated {len(observed)} canonical record(s): {', '.join(observed)}")


if __name__ == "__main__":
    main()
