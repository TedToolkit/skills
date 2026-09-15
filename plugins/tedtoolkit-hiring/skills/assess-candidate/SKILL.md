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

Read only:

- `companies/<company-id>/company.md` when relevant;
- `companies/<company-id>/roles/<role-id>/role.md`;
- `companies/<company-id>/candidates/<candidate-id>/candidate.md`;
- `companies/<company-id>/applications/<role-id>/<candidate-id>/application.md`; and
- evidence already listed in that application's `evidence` frontmatter.

Do not enumerate, read, or compare sibling candidates or applications. Source resumes and personal
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
- a concise selected-source citation and what it actually supports;
- the limitation, contradiction, or evidence question that remains; and
- a neutral interview focus when additional evidence would materially help.

Exclude protected traits, sensitive values, unrelated personal facts, and non-job-related
requirements from the matrix and any score. Do not repeat excluded values. Do not strengthen resume
claims or treat `Not demonstrated` as inability. If a numeric score is requested, show the
job-related weights and calculation and label it decision support, not a decision.

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
---

# Candidate Assessment
```

Use exactly one H1. Include `## Requirement Evidence Matrix` with one structured row for every
job-related role requirement, followed by material contradictions or unknowns, privacy and fairness
exclusions, and bounded interview focuses. Finish with:
`Decision owner: the accountable human hiring team.` Never rank candidates, choose an outcome, or
recommend hire, reject, advance, proceed, move forward, select, or eliminate.

Return the assessment in the conversation or write only the exact authorized application file.
Never modify source evidence, canonical candidate facts, or another application.
