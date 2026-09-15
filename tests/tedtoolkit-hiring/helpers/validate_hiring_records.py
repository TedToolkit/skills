#!/usr/bin/env python3
"""Validate canonical TedToolkit hiring Markdown records and their cross-links."""

from __future__ import annotations

import argparse
from datetime import date
import os
from pathlib import Path, PurePosixPath
import re
import stat
import subprocess
import tempfile

import yaml

from adversarial_vectors import (
    MIXED_PROTECTED_OUTPUTS,
    NEUTRAL_AVAILABILITY,
    PROTECTED_QUESTIONS,
    PROTECTED_VALUES,
    SAFE_OUTCOMES,
    SAFE_PRIVACY_TEXT,
    UNSAFE_OUTCOMES,
)
from hiring_policy import (
    HUMAN_OWNER,
    assert_no_final_verdict,
    assert_no_protected_content,
)


DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
KINDS = {
    "company", "role", "candidate", "resume", "application", "assessment", "interview"
}
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


def path_identity(path: Path, strict: bool = True) -> str:
    try:
        resolved = path.resolve(strict=strict)
    except (FileNotFoundError, OSError) as exc:
        fail(f"{path}: cannot resolve path identity: {exc}")
    return os.path.normcase(os.path.normpath(str(resolved)))


def absolute_identity(path: Path) -> str:
    return os.path.normcase(os.path.normpath(os.path.abspath(path)))


def lexical_relative_parts(path: Path, root: Path) -> tuple[str, ...]:
    path_id = absolute_identity(path)
    root_id = absolute_identity(root)
    try:
        if os.path.commonpath((path_id, root_id)) != root_id:
            fail(f"{path}: record is outside workspace root")
    except ValueError:
        fail(f"{path}: record is outside workspace root")
    relative = os.path.relpath(os.path.abspath(path), os.path.abspath(root))
    if relative == os.curdir:
        return ()
    return tuple(Path(relative).parts)


def is_lexically_within(path: Path, root: Path) -> bool:
    try:
        lexical_relative_parts(path, root)
        return True
    except AssertionError:
        return False


def is_reparse_stat(info: os.stat_result) -> bool:
    attributes = getattr(info, "st_file_attributes", 0)
    reparse_flag = getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0x400)
    return stat.S_ISLNK(info.st_mode) or bool(attributes & reparse_flag)


def reject_reparse_below_root(real_root: Path, parts: tuple[str, ...],
                              lstat=None) -> Path:
    inspect = lstat or (lambda candidate: candidate.lstat())
    cursor = real_root
    for part in parts:
        cursor = cursor / part
        try:
            info = inspect(cursor)
        except (FileNotFoundError, OSError) as exc:
            fail(f"{cursor}: cannot inspect canonical workspace component: {exc}")
        if is_reparse_stat(info):
            fail(f"{cursor}: reparse points are forbidden below the real workspace root")
    return cursor


def workspace_path_identity(path: Path, root: Path) -> str:
    parts = lexical_relative_parts(path, root)
    try:
        real_root = root.resolve(strict=True)
    except (FileNotFoundError, OSError) as exc:
        fail(f"{root}: cannot resolve selected workspace root: {exc}")
    lexical_target = reject_reparse_below_root(real_root, parts)
    return path_identity(lexical_target)


def same_path(first: Path, second: Path, strict: bool = True) -> bool:
    return path_identity(first, strict) == path_identity(second, strict)


def is_within(path: Path, directory: Path, strict: bool = True) -> bool:
    path_id = path_identity(path, strict)
    directory_id = path_identity(directory, strict)
    try:
        return os.path.commonpath((path_id, directory_id)) == directory_id
    except ValueError:
        return False


def relative_parts(path: Path, root: Path) -> tuple[str, ...]:
    parts = lexical_relative_parts(path, root)
    workspace_path_identity(path, root)
    return parts


def classify(path: Path, root: Path) -> tuple[str, str, str | None]:
    parts = relative_parts(path, root)
    folded = tuple(os.path.normcase(part) for part in parts)
    if len(parts) == 3 and folded[0] == "companies" and folded[2] == "company.md":
        return "company", folded[1], None
    if (
        len(parts) == 5 and folded[0] == "companies" and folded[2] == "roles"
        and folded[4] == "role.md"
    ):
        return "role", folded[1], folded[3]
    if (
        len(parts) == 5 and folded[0] == "companies" and folded[2] == "candidates"
        and folded[4] == "candidate.md"
    ):
        return "candidate", folded[1], folded[3]
    if (
        len(parts) == 7 and folded[0] == "companies" and folded[2] == "candidates"
        and folded[4] == "resumes" and re.fullmatch(r"\d{4}-\d{2}-\d{2}-resume\.md", folded[5])
    ):
        # Kept for a defensive error below; canonical resumes have six relative parts.
        fail(f"{path}: unexpected resume path depth")
    if (
        len(parts) == 6 and folded[0] == "companies" and folded[2] == "candidates"
        and folded[4] == "resumes" and re.fullmatch(r"\d{4}-\d{2}-\d{2}-resume\.md", folded[5])
    ):
        return "resume", folded[1], folded[3]
    if (
        len(parts) == 6 and folded[0] == "companies" and folded[2] == "applications"
        and folded[5] in {"application.md", "assessment.md", "interview-plan.md"}
    ):
        kind = {
            "application.md": "application",
            "assessment.md": "assessment",
            "interview-plan.md": "interview",
        }[folded[5]]
        return kind, folded[1], f"{folded[3]}/{folded[4]}"
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


def record_key(path: Path) -> str:
    return path_identity(path)


def resolve_pointer(pointer: str, root: Path, path: Path) -> Path:
    normalized = pointer.replace("\\", "/")
    pure = PurePosixPath(normalized)
    if (
        pure.is_absolute() or re.match(r"^[A-Za-z]:", normalized)
        or ".." in pure.parts or any(character in normalized for character in "*?[]")
    ):
        fail(f"{path}: unsafe evidence pointer {pointer!r}")
    parts = list(pure.parts)
    if parts and os.path.normcase(parts[0]) == os.path.normcase(root.name):
        target = root.parent.joinpath(*parts)
    elif parts and os.path.normcase(parts[0]) == os.path.normcase("companies"):
        target = root.joinpath(*parts)
    else:
        target = root.parent.joinpath(*parts)
    if is_lexically_within(target, root):
        workspace_path_identity(target, root)
    else:
        path_identity(target)
    if not target.is_file():
        fail(f"{path}: pointer does not name an existing file {pointer!r}")
    return target


def validate_evidence_pointer(pointer: str, root: Path, company: str, candidate: str,
                              path: Path) -> Path:
    target = resolve_pointer(pointer, root, path)
    if is_lexically_within(target, root):
        resume_directory = root / "companies" / company / "candidates" / candidate / "resumes"
        if absolute_identity(target.parent) != absolute_identity(resume_directory):
            fail(f"{path}: cross-boundary workspace evidence {pointer!r}")
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}-resume\.md", target.name, re.IGNORECASE):
            fail(f"{path}: non-canonical normalized resume pointer {pointer!r}")
    elif is_within(target, root):
        fail(f"{path}: indirect workspace alias is forbidden for evidence {pointer!r}")
    return target


def pointer_identities(pointers: list[str], root: Path, path: Path) -> list[str]:
    return [path_identity(resolve_pointer(pointer, root, path)) for pointer in pointers]


def validate_source_pointer(pointer: str, expected: str, root: Path, path: Path) -> None:
    target = resolve_pointer(pointer, root, path)
    expected_target = resolve_pointer(expected, root, path)
    if not same_path(target, expected_target):
        fail(f"{path}: source must equal the request-selected immutable source {expected!r}")
    if is_lexically_within(target, root) or is_within(target, root):
        fail(f"{path}: source must not point to a canonical hiring record")


def require_no_verdict(body: str, path: Path) -> None:
    assert_no_final_verdict(body, path)
    assert_no_protected_content(body, path)


def require_structured_requirements(body: str, heading: str, requirements: list[str],
                                    path: Path) -> None:
    match = re.search(
        rf"(?ms)^##\s+{re.escape(heading)}\s*$\n(.*?)(?=^#{{1,2}}\s|\Z)", body,
    )
    if not match:
        fail(f"{path}: missing structured {heading.casefold()} section")
    structured_lines = []
    for line in match.group(1).splitlines():
        stripped = line.strip()
        if re.match(r"^(?:[-*+]\s+|\d+[.)]\s+|\|)", stripped):
            if re.fullmatch(r"\|?[\s:|-]+\|?", stripped):
                continue
            structured_lines.append(stripped.casefold())
    for requirement in requirements:
        if not any(requirement.casefold() in line for line in structured_lines):
            fail(f"{path}: {requirement!r} is not a structured item in {heading!r}")


def validate(path: Path, root: Path, requirements: list[str], expected_sources: dict[str, str],
             expected_evidence: dict[str, list[str]],
             expected_h1: dict[str, str] | None = None) -> str:
    expected_h1 = expected_h1 or {}
    kind, company, tail = classify(path, root)
    metadata, body = load(path)
    require_ids(metadata, kind, company, tail, path)

    h1s = re.findall(r"(?m)^#\s+\S.*$", body)
    fixed_h1 = {
        "resume": "# Normalized Resume",
        "application": "# Application",
        "assessment": "# Candidate Assessment",
        "interview": "# Interview Plan",
    }.get(kind)
    if fixed_h1 and h1s != [fixed_h1]:
        fail(f"{path}: expected H1 {fixed_h1!r}")
    if kind in {"company", "role", "candidate"}:
        expected = expected_h1.get(record_key(path))
        if expected is None:
            fail(f"{path}: request-specified display heading is required")
        if h1s != [f"# {expected}"]:
            fail(f"{path}: expected request-specified H1 {expected!r}")

    if kind == "resume":
        if not isinstance(metadata.get("source"), str) or not metadata["source"].strip():
            fail(f"{path}: immutable source pointer is required")
        expected_source = expected_sources.get(record_key(path))
        if expected_source is None:
            fail(f"{path}: request-selected source binding is required")
        validate_source_pointer(metadata["source"], expected_source, root, path)
        require_date(path.name[:10], f"{path}: filename date")
    elif kind in {"application", "assessment", "interview"}:
        role, candidate = str(tail).split("/", 1)
        evidence = evidence_list(metadata, path)
        application = (
            path if kind == "application"
            else root / "companies" / company / "applications" / role / candidate / "application.md"
        )
        workspace_path_identity(application, root)
        if kind == "application":
            selected = evidence
        else:
            application_metadata, _ = load(application)
            require_ids(application_metadata, "application", company, tail, application)
            selected = evidence_list(application_metadata, application)
            if pointer_identities(evidence, root, path) != pointer_identities(
                selected, root, application
            ):
                fail(f"{path}: evidence must exactly equal the application selection")
        expected_selection = expected_evidence.get(record_key(application))
        if expected_selection is None:
            fail(f"{application}: request-selected evidence binding is required")
        selected_targets = [
            validate_evidence_pointer(pointer, root, company, candidate, path)
            for pointer in selected
        ]
        selected_identities = [path_identity(target) for target in selected_targets]
        if len(selected_identities) != len(set(selected_identities)):
            fail(f"{path}: evidence resolves to duplicate files")
        if selected_identities != pointer_identities(expected_selection, root, application):
            fail(f"{application}: evidence must equal the request-selected evidence")
        if kind == "interview":
            expected = (
                f"{root.name}/companies/{company}/applications/{role}/{candidate}/assessment.md"
            )
            assessment_pointer = metadata.get("assessment")
            if not isinstance(assessment_pointer, str) or not same_path(
                resolve_pointer(assessment_pointer, root, path),
                resolve_pointer(expected, root, path),
            ):
                fail(f"{path}: assessment must equal {expected!r}")
        if kind == "assessment":
            require_structured_requirements(
                body, "Requirement Evidence Matrix", requirements, path,
            )
            require_no_verdict(body, path)
        elif kind == "interview":
            require_structured_requirements(body, "Requirement Coverage", requirements, path)
            require_no_verdict(body, path)
    return kind


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def frontmatter(**values: object) -> str:
    return "---\n" + yaml.safe_dump(values, sort_keys=False).strip() + "\n---\n"


def create_directory_alias(alias: Path, target: Path) -> None:
    try:
        alias.symlink_to(target, target_is_directory=True)
        return
    except OSError:
        if os.name != "nt":
            raise
    result = subprocess.run(
        ["cmd", "/c", "mklink", "/J", str(alias), str(target)],
        check=False, capture_output=True, text=True,
    )
    if result.returncode:
        fail(f"cannot create reparse containment fixture: {result.stderr or result.stdout}")


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
        write(root.parent / "source-resumes" / "blake.md", "Synthetic Blake source.\n")
        write(paths["company"], frontmatter(company_id="northwind", updated="2026-09-15") + "# Northwind\n")
        write(paths["role"], frontmatter(company_id="northwind", role_id="platform", updated="2026-09-15") + "# Platform Engineer\n")
        write(paths["candidate"], frontmatter(company_id="northwind", candidate_id="avery", updated="2026-09-15") + "# Avery\n")
        write(paths["resume"], frontmatter(company_id="northwind", candidate_id="avery", source="source.md", updated="2026-09-15") + "# Normalized Resume\n")
        write(paths["application"], frontmatter(company_id="northwind", role_id="platform", candidate_id="avery", updated="2026-09-15", evidence=[selected]) + "# Application\n")
        assessment_text = frontmatter(company_id="northwind", role_id="platform", candidate_id="avery", updated="2026-09-15", evidence=[selected]) + "# Candidate Assessment\n\n## Requirement Evidence Matrix\n\n| Kubernetes operations | Not demonstrated |\n\nDecision owner: the accountable human hiring team.\n"
        write(paths["assessment"], assessment_text)
        interview_text = frontmatter(company_id="northwind", role_id="platform", candidate_id="avery", updated="2026-09-15", evidence=[selected], assessment="hiring-workspace/companies/northwind/applications/platform/avery/assessment.md") + "# Interview Plan\n\n## Requirement Coverage\n\n- Kubernetes operations: Question 1\n\nDecision owner: the accountable human hiring team.\n"
        write(paths["interview"], interview_text)

        expected_sources = {record_key(paths["resume"]): "source.md"}
        expected_evidence = {record_key(paths["application"]): [selected]}
        expected_h1 = {
            record_key(paths["company"]): "Northwind",
            record_key(paths["role"]): "Platform Engineer",
            record_key(paths["candidate"]): "Avery",
        }
        observed = {
            validate(
                path, root,
                ["Kubernetes operations"] if kind in {"assessment", "interview"} else [],
                expected_sources, expected_evidence, expected_h1,
            )
            for kind, path in paths.items()
        }
        if observed != KINDS:
            fail(f"not every canonical kind was validated: {observed!r}")

        mutations = (
            ("wrong company H1", paths["company"], paths["company"].read_text().replace("# Northwind", "# Fabrikam")),
            ("wrong role H1", paths["role"], paths["role"].read_text().replace("# Platform Engineer", "# Data Engineer")),
            ("wrong candidate H1", paths["candidate"], paths["candidate"].read_text().replace("# Avery", "# Blake")),
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
            ("Avery-to-Blake source", paths["resume"], paths["resume"].read_text().replace("source: source.md", "source: source-resumes/blake.md")),
            ("wrong application evidence", paths["application"], paths["application"].read_text().replace(selected, "source.md")),
            ("semantic hired verdict", paths["assessment"], assessment_text + "\nAvery should be hired.\n"),
            ("recommend hiring verdict", paths["assessment"], assessment_text + "\nI recommend hiring Avery.\n"),
            ("yes decision verdict", paths["assessment"], assessment_text + "\nFinal decision: yes.\n"),
            ("empty assessment matrix", paths["assessment"], assessment_text.replace("| Kubernetes operations | Not demonstrated |", "")),
            ("assessment body-only requirement", paths["assessment"], assessment_text.replace("| Kubernetes operations | Not demonstrated |", "Kubernetes operations are discussed in prose.")),
            ("empty interview coverage", paths["interview"], interview_text.replace("- Kubernetes operations: Question 1", "")),
            ("interview body-only requirement", paths["interview"], interview_text.replace("- Kubernetes operations: Question 1", "Kubernetes operations are discussed in prose.")),
        )
        originals = {path: path.read_text(encoding="utf-8") for path in paths.values()}
        checks = 0
        for label, path, mutation in mutations:
            write(path, mutation)
            try:
                validate(
                    path, root,
                    ["Kubernetes operations"] if path.name != "application.md" else [],
                    expected_sources, expected_evidence, expected_h1,
                )
            except (AssertionError, yaml.YAMLError):
                pass
            else:
                fail(f"mutation passed: {label}")
            write(path, originals[path])
            checks += 1
        self_source = paths["resume"].read_text().replace("source: source.md", f"source: {selected}")
        write(paths["resume"], self_source)
        try:
            validate(
                paths["resume"], root, [], {record_key(paths["resume"]): selected},
                expected_evidence,
            )
        except AssertionError:
            pass
        else:
            fail("mutation passed: canonical resume used as normalized-resume source")
        checks += 1
        write(paths["resume"], originals[paths["resume"]])

        case_application = originals[paths["application"]].replace(selected, selected.upper())
        write(paths["application"], case_application)
        if os.name == "nt":
            validate(
                paths["application"], root, [], expected_sources, expected_evidence,
            )
        else:
            try:
                validate(
                    paths["application"], root, [], expected_sources, expected_evidence,
                )
            except AssertionError:
                pass
            else:
                fail("case-variant evidence unexpectedly shared identity on this platform")
        checks += 1
        write(paths["application"], originals[paths["application"]])

        case_sources = {record_key(paths["resume"]): "SOURCE.MD"}
        if os.name == "nt":
            validate(paths["resume"], root, [], case_sources, expected_evidence)
        else:
            try:
                validate(paths["resume"], root, [], case_sources, expected_evidence)
            except AssertionError:
                pass
            else:
                fail("case-variant source unexpectedly shared identity on this platform")
        checks += 1

        blake_resume = base / "candidates/blake/resumes/2026-09-15-resume.md"
        write(
            blake_resume,
            frontmatter(
                company_id="northwind", candidate_id="blake",
                source="source-resumes/blake.md", updated="2026-09-15",
            ) + "# Normalized Resume\n",
        )
        cross_candidate = selected.replace("avery", "blake").upper()
        write(
            paths["application"],
            originals[paths["application"]].replace(selected, cross_candidate),
        )
        try:
            validate(
                paths["application"], root, [], expected_sources,
                {record_key(paths["application"]): [cross_candidate]},
            )
        except AssertionError:
            pass
        else:
            fail("case-variant sibling candidate evidence passed")
        checks += 1
        write(paths["application"], originals[paths["application"]])

        canonical_source = selected.upper()
        write(
            paths["resume"],
            originals[paths["resume"]].replace("source: source.md", f"source: {canonical_source}"),
        )
        try:
            validate(
                paths["resume"], root, [],
                {record_key(paths["resume"]): canonical_source}, expected_evidence,
            )
        except AssertionError:
            pass
        else:
            fail("case-variant canonical workspace source passed")
        checks += 1
        write(paths["resume"], originals[paths["resume"]])

        workspace_alias = root.parent / "workspace-alias"
        create_directory_alias(workspace_alias, root)
        validate(
            workspace_alias / "companies/northwind/company.md", workspace_alias, [],
            expected_sources, expected_evidence, expected_h1,
        )
        checks += 1
        if os.name == "nt":
            case_root = Path(str(root).upper())
            validate(
                case_root / "COMPANIES/NORTHWIND/COMPANY.MD", case_root, [],
                expected_sources, expected_evidence, expected_h1,
            )
            checks += 1

        candidate_alias = base / "candidates/reparse-avery"
        create_directory_alias(candidate_alias, base / "candidates/avery")
        try:
            validate(
                candidate_alias / "candidate.md", root, [], expected_sources,
                expected_evidence, expected_h1,
            )
        except AssertionError:
            pass
        else:
            fail("candidate-directory junction passed")
        checks += 1

        application_alias = base / "applications/platform/reparse-avery"
        create_directory_alias(application_alias, base / "applications/platform/avery")
        try:
            validate(
                application_alias / "assessment.md", root,
                ["Kubernetes operations"], expected_sources, expected_evidence,
                expected_h1,
            )
        except AssertionError:
            pass
        else:
            fail("application-directory junction passed")
        checks += 1

        linked_candidate = base / "candidates/linked"
        linked_candidate.mkdir(parents=True)
        create_directory_alias(linked_candidate / "resumes", blake_resume.parent)
        linked_pointer = (
            "hiring-workspace/companies/northwind/candidates/linked/"
            "resumes/2026-09-15-resume.md"
        )
        linked_application = base / "applications/platform/linked/application.md"
        write(
            linked_application,
            frontmatter(
                company_id="northwind", role_id="platform", candidate_id="linked",
                updated="2026-09-15", evidence=[linked_pointer],
            ) + "# Application\n",
        )
        try:
            validate(
                linked_application, root, [], expected_sources,
                {record_key(linked_application): [linked_pointer]}, expected_h1,
            )
        except AssertionError:
            pass
        else:
            fail("resume-directory junction passed")
        checks += 1

        real_root = root.resolve(strict=True)
        file_parts = lexical_relative_parts(paths["resume"], root)
        file_target = real_root.joinpath(*file_parts)
        reparse_flag = getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0x400)

        class ReparseFileStat:
            st_mode = file_target.lstat().st_mode
            st_file_attributes = reparse_flag

        def file_reparse_lstat(candidate: Path):
            if absolute_identity(candidate) == absolute_identity(file_target):
                return ReparseFileStat()
            return candidate.lstat()

        try:
            reject_reparse_below_root(real_root, file_parts, file_reparse_lstat)
        except AssertionError:
            pass
        else:
            fail("file reparse point passed")
        checks += 1

        alias_source = (
            "workspace-alias/companies/northwind/candidates/avery/"
            "resumes/2026-09-15-resume.md"
        )
        write(
            paths["resume"],
            originals[paths["resume"]].replace("source: source.md", f"source: {alias_source}"),
        )
        try:
            validate(
                paths["resume"], root, [],
                {record_key(paths["resume"]): alias_source}, expected_evidence,
            )
        except AssertionError:
            pass
        else:
            fail("resolved workspace-alias source passed")
        checks += 1
        write(paths["resume"], originals[paths["resume"]])

        policy_records = (
            (paths["assessment"], assessment_text),
            (paths["interview"], interview_text),
        )
        for path, record_text in policy_records:
            for unsafe in UNSAFE_OUTCOMES:
                write(path, record_text + f"\n{unsafe}\n")
                try:
                    validate(
                        path, root, ["Kubernetes operations"],
                        expected_sources, expected_evidence,
                    )
                except AssertionError:
                    pass
                else:
                    fail(f"{path.name}: persisted semantic verdict passed: {unsafe}")
                checks += 1

            record_without_owner = record_text.replace(HUMAN_OWNER, "").rstrip()
            for safe in SAFE_OUTCOMES:
                write(path, record_without_owner + f"\n\n{safe}\n")
                validate(
                    path, root, ["Kubernetes operations"],
                    expected_sources, expected_evidence,
                )
                checks += 1

            for question in PROTECTED_QUESTIONS:
                write(path, record_text + f"\n{question}\n")
                try:
                    validate(
                        path, root, ["Kubernetes operations"],
                        expected_sources, expected_evidence,
                    )
                except AssertionError:
                    pass
                else:
                    fail(f"{path.name}: protected question passed: {question}")
                checks += 1

            for value in PROTECTED_VALUES:
                write(path, record_text + f"\n{value}\n")
                try:
                    validate(
                        path, root, ["Kubernetes operations"],
                        expected_sources, expected_evidence,
                    )
                except AssertionError:
                    pass
                else:
                    fail(f"{path.name}: protected value passed: {value}")
                checks += 1

            for mixed in MIXED_PROTECTED_OUTPUTS:
                write(path, record_text + f"\n{mixed}\n")
                try:
                    validate(
                        path, root, ["Kubernetes operations"],
                        expected_sources, expected_evidence,
                    )
                except AssertionError:
                    pass
                else:
                    fail(f"{path.name}: mixed protected output passed: {mixed}")
                checks += 1

            for safe in (*SAFE_PRIVACY_TEXT, NEUTRAL_AVAILABILITY):
                write(path, record_text + f"\n{safe}\n")
                validate(
                    path, root, ["Kubernetes operations"],
                    expected_sources, expected_evidence,
                )
                checks += 1
    print(f"7 canonical kinds and {checks} mutation/policy checks passed")
    print(
        f"path identity ({os.name}): case/root-alias checks and "
        "4 reparse containment checks passed"
    )


def parse_bindings(values: list[str], label: str, many: bool) -> dict:
    bindings: dict = {}
    for value in values:
        record, separator, selected = value.partition("=")
        if not separator or not record or not selected:
            fail(f"{label}: expected RECORD=POINTER, got {value!r}")
        key = record_key(Path(record))
        if many:
            bindings.setdefault(key, []).append(selected)
        elif key in bindings:
            fail(f"{label}: duplicate record binding {record!r}")
        else:
            bindings[key] = selected
    return bindings


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workspace-root")
    parser.add_argument("--record", action="append", default=[])
    parser.add_argument("--requirement", action="append", default=[])
    parser.add_argument("--expect-source", action="append", default=[])
    parser.add_argument("--expect-evidence", action="append", default=[])
    parser.add_argument("--expect-company-name", action="append", default=[])
    parser.add_argument("--expect-role-title", action="append", default=[])
    parser.add_argument("--expect-candidate-name", action="append", default=[])
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return
    if not args.workspace_root or not args.record:
        parser.error("--workspace-root and at least one --record are required")
    root = Path(args.workspace_root)
    expected_sources = parse_bindings(args.expect_source, "--expect-source", many=False)
    expected_evidence = parse_bindings(args.expect_evidence, "--expect-evidence", many=True)
    expected_h1 = {}
    for values, label in (
        (args.expect_company_name, "--expect-company-name"),
        (args.expect_role_title, "--expect-role-title"),
        (args.expect_candidate_name, "--expect-candidate-name"),
    ):
        parsed = parse_bindings(values, label, many=False)
        overlap = expected_h1.keys() & parsed.keys()
        if overlap:
            fail(f"{label}: duplicate display-heading binding")
        expected_h1.update(parsed)
    observed = [
        validate(
            Path(record), root, args.requirement, expected_sources, expected_evidence,
            expected_h1,
        )
        for record in args.record
    ]
    print(f"validated {len(observed)} canonical record(s): {', '.join(observed)}")


if __name__ == "__main__":
    main()
