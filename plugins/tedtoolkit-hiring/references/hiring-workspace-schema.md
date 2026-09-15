# Hiring Workspace Schema

Use this schema when creating or reading hiring records. Read
[hiring-integrity.md](hiring-integrity.md) first.

## Root and canonical paths

Use the exact root selected by the user. When none is supplied, propose `hiring-workspace/` in the
active workspace and wait for confirmation before writing. This is the selected root itself, not a
directory added below another chosen root.

```text
hiring-workspace/
└── companies/<company-id>/
    ├── company.md
    ├── roles/<role-id>/role.md
    ├── candidates/<candidate-id>/
    │   ├── candidate.md
    │   └── resumes/<YYYY-MM-DD>-resume.md
    └── applications/<role-id>/<candidate-id>/
        ├── application.md
        ├── assessment.md
        └── interview-plan.md
```

Use supplied stable, non-sensitive, filesystem-safe identifiers. Do not derive candidate IDs from
protected traits, contact details, or unrelated workspace data. A candidate who applies to several
roles has one canonical record under `candidates/<candidate-id>/` and a distinct application under
each role. Assessment and interview-plan files belong only to their explicit application.

## Common record rules

Every record is UTF-8 Markdown. Use YAML frontmatter for identifiers and provenance, followed by a
single H1. Omit unknown optional values rather than inserting placeholders. Dates use `YYYY-MM-DD`;
use the actual current date only for a record created or updated in the current task.

Store sanitized relative source pointers when practical. Never embed source-file contents merely to
preserve provenance. References must stay inside the selected company/application boundary unless
the user explicitly selected an external read-only source.

## Company and role

`company.md` contains only supplied hiring-relevant company context. `role.md` contains the role
title, status when supplied, responsibilities, required and preferred qualifications, working
constraints, and dated source provenance. Keep job requirements distinct from interviewer opinions.

```md
---
company_id: <company-id>
role_id: <role-id>
updated: YYYY-MM-DD
sources:
  - <sanitized supplied source>
---

# <Role title>

## Responsibilities
## Required Qualifications
## Preferred Qualifications
## Working Constraints
## Unknowns and Contradictions
```

## Candidate and normalized resumes

`candidate.md` is the company's stable identity and provenance record for one candidate. Keep only
the supplied preferred display name, stable non-sensitive identifiers, and sanitized source
pointers needed to distinguish the record. Do not copy resume claims, assessments, interview notes,
contact details, or protected traits into it.

A normalized resume record contains only job-related supplied evidence, support classification, and
the immutable source pointer. Preserve chronology, attribution, scope, and the boundary between
personal contribution and team results. Omit unsupported claims and protected-trait or unnecessary
contact details. Its filename date is the supplied resume date when known, otherwise the authorized
record-creation date. Never overwrite another record for the same date without exact authorization.

## Application

`application.md` links exactly one company role, one company-scoped candidate, and the explicitly
selected evidence. It is not an applicant-tracking status log and does not contain an assessment or
hiring decision.

```md
---
company_id: <company-id>
role_id: <role-id>
candidate_id: <candidate-id>
updated: YYYY-MM-DD
evidence:
  - <relative normalized resume or explicit read-only source>
---

# Application

## Scope

- Role: <role-id>
- Candidate: <candidate-id>
```

`assessment.md` and `interview-plan.md` use the same three identifiers in frontmatter and cite only
evidence selected by that application. They never become canonical candidate facts.

## Updates

Inspect only the selected records and their explicit evidence before updating. Create the smallest
set of requested canonical records. Preserve stable IDs and unrelated content. Stop on conflicting
identity, an existing normalized-resume destination without overwrite authorization, a proposed
cross-company pointer, or a request to move or automatically migrate user data.
