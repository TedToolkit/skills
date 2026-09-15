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

Every canonical record has exactly one H1 and these required frontmatter fields:

| Kind | Required fields and path agreement | Fixed H1 |
| --- | --- | --- |
| Company | `company_id`, `updated`; ID equals `<company-id>` | Supplied company name |
| Role | `company_id`, `role_id`, `updated`; IDs equal its canonical path | Supplied role title |
| Candidate | `company_id`, `candidate_id`, `updated`; IDs equal its canonical path | Supplied candidate display name |
| Normalized resume | `company_id`, `candidate_id`, `source`, `updated`; IDs equal its canonical path and filename begins with a valid date | `# Normalized Resume` |
| Application | `company_id`, `role_id`, `candidate_id`, `evidence`, `updated`; IDs equal its canonical path | `# Application` |
| Assessment | Same application IDs and exact `evidence` list, plus `updated` and `decision_owner: accountable-human-hiring-team` | `# Candidate Assessment` |
| Interview plan | Same application IDs and exact `evidence` list, `assessment`, `updated`, and `decision_owner: accountable-human-hiring-team` | `# Interview Plan` |

`evidence` is a non-empty, duplicate-free list. A workspace-internal evidence pointer may identify
only a canonical normalized resume under the same company and candidate. External immutable source
pointers are allowed when the application already selected their exact paths. Reject absolute,
traversal, wildcard, cross-company, cross-candidate, and cross-application pointers before opening
any evidence.

Resolve a selected workspace-root alias once and normalize that real root using the host platform's
path-case rules. Beneath that real root, preserve the canonical lexical path and inspect every
component before reading: reject any symlink, junction, or other reparse point in a company, role,
candidate, application, or evidence path. Never resolve a canonical owner directory in a way that
legitimizes its redirection. Case variants may share identity on case-insensitive platforms, but an
internal reparse point never creates another valid canonical path. Resolve external immutable
sources normally, then reject any whose final identity is inside the real workspace root.

Validate provenance against the current request, not merely path shape: each normalized resume's
`source` must equal the exact immutable source selected for that record, and each application's
ordered `evidence` list must equal the exact selection authorized for that application. A
normalized-resume `source` may never point to any canonical hiring-workspace record, including
itself or another candidate's normalized resume, even through a case variant, symlink, junction, or
reparse point.

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

`assessment.md` and `interview-plan.md` begin with YAML frontmatter before their sole H1. Their
`company_id`, `role_id`, and `candidate_id` values exactly equal the selected application's values;
their `evidence` list exactly repeats that application's selected evidence paths. An interview plan
that consumed the application assessment also records its canonical path in `assessment`:

```md
---
company_id: <company-id>
role_id: <role-id>
candidate_id: <candidate-id>
updated: YYYY-MM-DD
evidence:
  - <path selected by application.md>
assessment: <canonical assessment.md path, interview-plan.md only when consumed>
decision_owner: accountable-human-hiring-team
---

# Candidate Assessment
```

Use `# Interview Plan` instead for `interview-plan.md`; these are the only H1 values and each file
contains exactly one H1.

Neither record contains a recommendation, verdict, decision, or outcome field or section. The
assessment `## Requirement Evidence Matrix` is a Markdown table with one distinct row per role
requirement and required columns `Requirement`, `Evidence state`, `Citation`, `Limitation`, and
`Interview focus`. The interview plan `## Requirement Coverage` is a Markdown table with one
distinct row per role requirement and required columns `Requirement`, `Question mapping`, `Evidence
anchor`, and `Scoring anchors`; every row contains `Score 1`, `Score 3`, and `Score 5` anchors.

Conversation output uses exactly one language-matched handoff: `Final hiring decisions remain with
the accountable human hiring team.` for English or `最终招聘决定由负责任的人类招聘团队作出。` for
Chinese. Other English/Chinese outcome-action wording is prohibited under the bounded bilingual
output contract.

Do not add newly supplied evidence directly to either output. Update the application's `evidence`
list through `maintain-hiring-workspace` first. These derived outputs never become canonical
candidate facts.

## Updates

Inspect only the selected records and their explicit evidence before updating. Create the smallest
set of requested canonical records. Preserve stable IDs and unrelated content. Stop on conflicting
identity, an existing normalized-resume destination without overwrite authorization, a proposed
cross-company pointer, or a request to move or automatically migrate user data.
