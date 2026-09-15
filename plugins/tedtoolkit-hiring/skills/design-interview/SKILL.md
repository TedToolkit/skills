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

Before opening any evidence or assessment, read only the selected `application.md`. Validate that
its `company_id`, `role_id`, and `candidate_id` exactly match the request and canonical path, then
validate every evidence pointer without dereferencing it. Reject absolute, traversal, wildcard,
missing, or ambiguous pointers. A workspace-internal pointer must be the exact canonical normalized
resume beneath this company and candidate; reject another company, candidate, role, application,
assessment, interview plan, or any other workspace location. An external immutable source must be
the exact path already selected by this application. When an assessment is selected, require the
canonical `assessment.md` in this same application and validate its three IDs and evidence list
before reading its body.

Resolve a selected workspace-root alias once and normalize that real root using the host platform's
path-case rules. Beneath it, preserve the canonical lexical path and inspect every component before
reading the application, assessment, or evidence. Reject any symlink, junction, or other reparse
point below the real root; never resolve an owner directory in a way that legitimizes redirection.
Case variants may share identity on case-insensitive platforms but cannot change the selected
company, candidate, or application boundary.

Fail closed on any mismatch: read no evidence or assessment, write no plan, and route the bounded
application correction to `maintain-hiring-workspace` without inspecting a forbidden target. Use
literal reads of the resulting exact allowlist only; never use globs, recursive listing, broad
search, or an alternate reader to widen it.

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
Never include a question about age or date of birth, nationality or religion, pregnancy, disability
or health, marital or family status, or another protected trait. For a published on-call or schedule
requirement, ask only a neutral availability question about participation in that stated schedule.

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
decision_owner: accountable-human-hiring-team
---

# Interview Plan
```

Use exactly one H1. `## Requirement Coverage` is a Markdown table with one distinct row per
job-related role requirement and exactly these required fields: `Requirement`, `Question mapping`,
`Evidence anchor`, and `Scoring anchors`. Every row supplies `Score 1`, `Score 3`, and `Score 5`;
never combine requirements into one row or place coverage only in prose. Include neutral probes and
evidence guidance outside the table as needed. Keep `Not demonstrated` distinct from inability.

Do not add a recommendation, verdict, decision, or outcome field or section. End the final response
with exactly one language-matched handoff sentence: English `Final hiring decisions remain with the
accountable human hiring team.` or Chinese `最终招聘决定由负责任的人类招聘团队作出。` Use no other English or
Chinese hire, reject, advance, select, invite, recommendation, verdict, decision, or outcome
wording. This is a bounded bilingual output contract, not a general semantic classifier.

Return the plan in the conversation or write only the exact authorized application file. Never
modify source evidence, candidate facts, assessments, or another application.
