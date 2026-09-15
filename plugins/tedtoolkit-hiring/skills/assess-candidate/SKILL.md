---
name: assess-candidate
description: >-
  Assess supplied job-related evidence for one candidate's explicit application to one company
  role, recording supported evidence, gaps, and contradictions without a hiring verdict. Do not use
  for resume editing, workspace intake, interview questions, candidate ranking, or selection.
---

# Assess Candidate

Assess one explicit role application. Read
[hiring-integrity.md](../../references/hiring-integrity.md) and
[hiring-workspace-schema.md](../../references/hiring-workspace-schema.md).

This skill solely owns `# Candidate Assessment` and the selected application's `assessment.md`.
Route missing company, role, candidate, resume, or application records to
`maintain-hiring-workspace`. Route interviewer questions to `design-interview`.

## Establish the assessment boundary

Require one selected root, company ID, role ID, candidate ID, and application. Resolve the exact
role, candidate, application, and application-selected evidence paths. Ask for a missing boundary;
never infer it from sibling records or a similarly named candidate.

Before opening any evidence, read only the selected `application.md` and validate that its
`company_id`, `role_id`, and `candidate_id` exactly match both the request and its canonical path.
Then validate every `evidence` pointer without dereferencing it:

- resolve a selected workspace-root alias once and normalize that real root using the host
  platform's path-case rules; beneath it, preserve the canonical lexical path and reject any
  symlink, junction, or other reparse point in every company, candidate, application, and evidence
  component before reading; never resolve an owner directory in a way that legitimizes redirection;

- reject absolute, traversal, wildcard, missing, or ambiguous pointers;
- for a pointer inside the selected workspace, require the exact canonical normalized-resume path
  beneath this company and this candidate;
- reject pointers into another company, candidate, role, application, assessment, interview plan,
  or any other workspace location; and
- for an external immutable source, require the exact path already selected by this application.

If any identity or pointer fails, stop before reading evidence and emit no assessment. Report only
the invalid pointer category and route correction to `maintain-hiring-workspace`; do not inspect the
forbidden target to diagnose it.

Read only:

- `companies/<company-id>/company.md` when relevant;
- `companies/<company-id>/roles/<role-id>/role.md`;
- `companies/<company-id>/candidates/<candidate-id>/candidate.md`;
- `companies/<company-id>/applications/<role-id>/<candidate-id>/application.md`; and
- evidence already listed in that application's `evidence` frontmatter.

Use literal reads of the exact validated allowlist only; never use globs, recursive listing, broad
search, or an alternate reader to widen it. Do not enumerate, read, or compare sibling companies,
roles, candidates, or applications. Source resumes and personal
profiles are immutable. Conversation output is immediate when requested; writing requires the exact
canonical `assessment.md` destination to be absent or separately authorized for overwrite.
Evidence newly named in the assessment request is not selected evidence: do not read or use it.
Route it to `maintain-hiring-workspace` for a bounded, explicitly authorized update of this
application before assessment continues.

## Compare requirements to evidence

Build a requirement-by-requirement evidence matrix using only job-related role requirements. For
each requirement record:

- priority or weight only when supplied or explicitly requested;
- `Demonstrated`, `Partially demonstrated`, `Not demonstrated`, or `Conflicting`;
- a concise application-evidence citation and what it actually supports;
- the limitation, contradiction, or evidence question that remains; and
- a neutral interview focus when additional evidence would materially help.

Exclude protected traits, sensitive values, unrelated personal facts, and non-job-related
requirements from the matrix and any score. Do not repeat excluded values. Do not strengthen resume
claims or treat `Not demonstrated` as inability. If a numeric score is requested, show the
job-related weights and calculation and label it decision support, not a decision.
Do not emit protected-trait questions. When availability is a published role requirement, replace
such a request only with a neutral question about ability to participate in the stated schedule.

## Write the assessment

Use this stable opening:

```md
---
company_id: <exact selected company-id>
role_id: <exact selected role-id>
candidate_id: <exact selected candidate-id>
updated: YYYY-MM-DD
evidence:
  - <every and only path selected by application.md>
decision_owner: accountable-human-hiring-team
---

# Candidate Assessment
```

Use exactly one H1. `## Requirement Evidence Matrix` is a Markdown table with one distinct row per
job-related role requirement and exactly these required fields: `Requirement`, `Evidence state`,
`Citation`, `Limitation`, and `Interview focus`. Never combine requirements in one row or place
coverage only in prose. Do not add a recommendation, verdict, decision, or outcome field or section.

End the final response with exactly one language-matched handoff sentence: English `Final hiring
decisions remain with the accountable human hiring team.` or Chinese
`最终招聘决定由负责任的人类招聘团队作出。` Use no other English or Chinese hire, reject, advance, select,
invite, recommendation, verdict, decision, or outcome wording. This is a bounded bilingual output
contract, not a general semantic classifier.

Return the assessment in the conversation or write only the exact authorized application file.
Never modify source evidence, canonical candidate facts, or another application.
