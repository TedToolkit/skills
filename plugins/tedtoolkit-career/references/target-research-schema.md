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
## Organization and workforce
## Management model and practices
## Compensation and benefits
## Employee-reported experience
## Candidate-relevant observations
## Contradictions and unknowns
## Sources
```

Organization and workforce evidence may describe public business units, functions, reporting or
coordination structure, geographic distribution, headcount, and material growth or reduction. Do
not reconstruct private reporting lines or collect employees' personal information.

For management, distinguish documented structure and policy from employee perceptions. For
compensation, preserve currency, period, geography, function, level, and pay component; do not merge
incomparable ranges or imply that one disclosed package applies company-wide. For employee-reported
experience, summarize attributable recurring themes and counter-themes without identifying
reviewers. Record the visible sample size, review period, location or function coverage, and
self-selection or access limitations when available. An isolated review remains an individual
report, not a company-wide pattern.

For `role.md`, use:

```md
# <Role> at <Company>
## Role identity
## Responsibilities
## Work content and success context
## Required qualifications
## Preferred qualifications
## Capability analysis
## Interview and assessment evidence
## Domain and operating constraints
## Contradictions and unknowns
## Sources
```

`## Work content and success context` translates sourced responsibilities into an inspectable view
of work after joining without inventing a generic day in the life. When supported, cover recurring
work and deliverables, ownership boundaries, collaboration interfaces, operating cadence and
conditions, success measures, and onboarding or early-tenure expectations. For every item, preserve
whether it is direct role evidence, an attributable employee or candidate report, or a labeled
inference, together with its team, location, seniority, and time scope. Company-wide practices belong
in `company.md` unless evidence connects them to this role. Missing evidence about on-call, working
arrangements, performance expectations, reporting, or early-tenure outcomes remains an explicit
unknown rather than a title-based assumption.

`## Capability analysis` explains the synthesis rather than repeating the qualification lists.
Use a compact table or equally scannable structure that records, for each material capability:

- the transferable capability group and the concrete posting or context signals it abstracts;
- its relationship to the role: `required`, `preferred`, `responsibility-derived`, or
  `potentially valuable`;
- why the cited signals make it relevant to the actual work;
- source markers, confidence, and material limitations; and
- a `recently emerging` timing tag, dated signal, and stated research window when recency is part of
  the conclusion.

Keep explicit tool, credential, and priority wording visible even when grouping it under an abstract
capability. A responsibility-derived capability is an inference from published work, not an
unstated qualification. A potentially valuable capability may be supported by company direction,
adjacent roles, or authoritative domain changes, but must remain separate from required and
preferred qualifications. General market evidence does not establish employer intent. If no
credible additional or recent capability signal is found, record that limitation instead of adding
generic expectations for the title.

`## Interview and assessment evidence` records public evidence discovered for this exact target,
not a generated preparation pack. When evidence exists, separate:

- official sample questions or tasks;
- candidate-reported interview questions;
- candidate-reported written, take-home, coding, or online-assessment tasks; and
- inferred topics that are supported by role or process evidence but were not found as questions.

Retain as many distinct, relevant items as the evidence supports; do not impose an arbitrary count
limit. Deduplicate exact and near-duplicate wording while preserving materially different variants,
and group items by stage and topic when known. Each item or clearly sourced group records its source
marker, evidence class, report or publication date when available, retrieval date, company-role
match, location or team scope when available, and confidence. Record independently supported
recurrence without converting reports into a guaranteed current process. Summarize the query
dimensions, languages, source types, date range, and the diminishing-return or access limitation
that ended live searching so coverage is inspectable.

Do not mix generic practice questions into reported evidence, fabricate exact wording for an
inferred topic, or reproduce private, leaked, paywalled, or proprietary assessment banks. Preserve
conflicting process accounts and limitations caused by age, geography, seniority, sample size,
self-selection, or inaccessible sources.

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
