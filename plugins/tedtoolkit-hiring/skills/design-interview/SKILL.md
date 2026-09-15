---
name: design-interview
description: >-
  Design a fair, job-related interviewer plan for one candidate's explicit company-role
  application, with neutral probes and observable evidence anchors. Use for an interviewer
  evaluating another candidate. Do not use for candidate self-practice, assessment-only requests,
  resume editing, or final hiring decisions.
---

# Design Interview

Design an evidence-gathering plan for one explicit hiring application. Read
[hiring-integrity.md](../../references/hiring-integrity.md),
[hiring-workspace-schema.md](../../references/hiring-workspace-schema.md), and
[interview-standard.md](../../references/interview-standard.md).

This skill solely owns `# Interview Plan` and the selected application's `interview-plan.md`. Route
missing workspace records to `maintain-hiring-workspace` and a requested evidence comparison to
`assess-candidate`. Candidate self-practice belongs to
`tedtoolkit-career/prepare-for-interview`; name that replacement without requiring the candidate
plugin at runtime and do not emit an interviewer plan for a self-practice request.

## Establish the interviewer brief

Require one selected root, company ID, role ID, candidate ID, and application. Read only its bounded
company, role, candidate, application, evidence already listed by that application, and that
application's assessment when selected. Do not enumerate or compare sibling companies, roles,
candidates, or applications. Treat source resumes and personal profiles as immutable. Evidence
newly named in the interview request is not selected evidence: do not read or use it. Route it to
`maintain-hiring-workspace` for a bounded, explicitly authorized application update before interview
design continues.

Identify the stage, available time, language, desired depth, role requirements, and selected
candidate evidence. For a direct finished request, default to 30 minutes and five primary questions
at medium difficulty in the source language. Ask one focused question when the explicit application
or its job-related role evidence is missing. Planning-only requests stop after coverage and timing;
direct finished requests produce the plan without another conversational approval gate.

Writing requires the exact canonical `interview-plan.md` destination to be absent or separately
authorized for overwrite. Conversation output authorizes no file.

## Apply fairness and legal boundaries

Exclude protected-trait or otherwise non-job-related requests. Label the omitted category
`Excluded as non-job-related` without repeating the sensitive value. Provide a neutral replacement
only when a selected published role requirement supplies a legitimate assessment target. Require a
jurisdiction and current authoritative source for jurisdiction-specific legal conclusions; continue
any separable neutral work.

## Write the interview plan

Use this stable opening:

```md
---
company_id: <exact selected company-id>
role_id: <exact selected role-id>
candidate_id: <exact selected candidate-id>
updated: YYYY-MM-DD
evidence:
  - <every and only path selected by application.md>
assessment: <canonical assessment.md path when consumed>
---

# Interview Plan
```

Use exactly one H1. Add the brief and a structured `## Requirement Coverage` section that maps every
job-related role requirement to primary questions or a stated alternate. For every primary question
provide its selected role requirement or candidate claim, the question, neutral probes, strong
job-related evidence, material job-related warning signs, and `Score 1:`, `Score 3:`, and `Score 5:`
anchors when evaluation guidance is requested. Include a probe separating individual contribution
from team outcome when applicable. Keep `Not demonstrated` distinct from inability.

Finish with a coverage and timing check plus privacy, fairness, and source-integrity checks. State
`Decision owner: the accountable human hiring team.` Never rank candidates, choose an outcome, or
recommend hire, reject, advance, proceed, move forward, select, or eliminate.

Return the plan in the conversation or write only the exact authorized application file. Never
modify source evidence, candidate facts, assessments, or another application.
