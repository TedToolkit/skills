# Candidate Target Research Schema

Use this schema for attributable company and company-role research inside one selected candidate
workspace. Read `career-integrity.md` for the authoritative evidence and authorization rules.

## Identity and paths

Normalize supplied company and role names to stable, non-sensitive kebab-case identifiers. Do not
merge similarly named organizations or roles without evidence that they are the same target.

```text
<selected-root>/
├── companies/<company-id>/company.md
└── applications/<company-id>/<role-id>/
    ├── role.md
    ├── match.md
    ├── resume.md
    └── interview-preparation.md
```

`company.md` owns current external facts about one company. `role.md` owns requirements attributable
to one identified role at that company. `match.md`, `resume.md`, and
`interview-preparation.md` are derived for exactly that company-role target and never become
candidate-profile or company-source facts.

## Research record format

Every research record is UTF-8 Markdown. Use frontmatter that keeps identity and freshness visible:

```md
---
company_id: <company-id>
company: <supplied display name>
role_id: <role-id>                 # role.md only
role: <supplied display title>     # role.md only
retrieved: YYYY-MM-DD
status: current | stale | closed | unknown
---
```

For `company.md`, use these sections when supported:

```md
# <Company>
## Identity
## Products and customers
## Engineering and operating context
## Candidate-relevant observations
## Contradictions and unknowns
## Sources
```

For `role.md`, use:

```md
# <Role> at <Company>
## Role identity
## Responsibilities
## Required qualifications
## Preferred qualifications
## Domain and operating constraints
## Contradictions and unknowns
## Sources
```

Each material fact or compact group of facts must cite a source marker. In `## Sources`, record for
each marker: URL or supplied source description, retrieval date, source owner, confidence
(`high`, `medium`, or `low`), direct support versus inference, and any contradiction or access
limitation. An inference must identify the supporting facts and remain labeled `Inference`.
Unknowns stay under `## Contradictions and unknowns`; do not turn them into requirements or claims.

## Update and use

Inspect an existing record before updating it. Preserve still-relevant prior sources and explicit
contradictions; replace or mark stale facts only when newer evidence supports the change. Never
silently change company or role identity. Research writes only the exact authorized record.

Before matching or final resume writing, require a `role.md` or equivalent supplied dossier that
identifies both company and role and makes its material requirements attributable to that target.
If the information is stale or ambiguous, refresh or clarify it before treating it as current. A
generic occupation description, role title alone, unattributed requirement list, or company facts
without one role do not satisfy this gate.
