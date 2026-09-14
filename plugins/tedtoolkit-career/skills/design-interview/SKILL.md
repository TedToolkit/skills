---
name: design-interview
description: >-
  Design a fair, job-related interviewer plan with timed questions, neutral probes, evidence
  expectations, warning signs, and optional scoring anchors. Use when the user is interviewing or
  evaluating another candidate. Do not use for candidate practice, resume writing, resume critique,
  or a standalone job-match report.
---

# Design Interview

Design an interview that evaluates relevant evidence consistently. Read
[career-integrity.md](../../references/career-integrity.md) and
[interview-standard.md](../../references/interview-standard.md). When a local career profile is
supplied, read [career-profile-schema.md](../../references/career-profile-schema.md) before using it.

This skill solely owns `# Interview Plan`. It emits no candidate preparation, hiring verdict, resume
copy, `# Resume Review`, or `# Job Match` unless separately requested. Route self-practice and mock
preparation for the user's own interview to `prepare-for-interview`.

## Establish the interviewer brief

Identify the role, seniority, interview stage, available time, language, desired depth, published
requirements, and supplied candidate evidence. For a direct finished request, default to 30 minutes
and five primary questions at medium difficulty in the source language, with optional alternates
outside the live plan.

A concrete published job-related requirement is enough to design a focused plan when the broader
role is omitted. With both candidate evidence and a job description, use `match-job-description` as
supporting analysis. With only the role, design consistent competency coverage. With only candidate
evidence, limit the plan to claim verification and state that role coverage is unavailable. Ask one
question only when the available sources cannot support a job-related plan.

If more than five primary questions are requested without a timebox, allow at least five minutes per
question or mark the excess as alternates. For a planning-only request, present competency coverage,
question count, difficulty, and time allocation and stop. For a direct finished request, produce the
plan in the same response without another approval gate.

## Apply fairness and legal boundaries

Exclude protected-trait or otherwise non-job-related questions. Label the omitted request
`Excluded as non-job-related` and provide a neutral replacement only when a published job
requirement supplies a legitimate assessment target. When the requested plan depends on a
jurisdiction-specific legal conclusion, require the jurisdiction and a current authoritative source;
complete any separable neutral work that does not depend on that conclusion.

## Write the interview plan

Use this stable opening:

```md
# Interview Plan
- Brief: <role, stage, time, primary count, difficulty, language>
```

For every primary question, provide:

- competency and source requirement or candidate claim;
- primary question and neutral follow-up probes;
- what strong job-related evidence should contain;
- material job-related warning signs; and
- `Score 1:`, `Score 3:`, and `Score 5:` anchors when evaluation guidance is requested.

Define scores through observable evidence, not personality impressions or keyword counts. Include at
least one probe that separates individual contribution from team outcome when applicable. Do not
convert `Not demonstrated` into an assumption that the candidate lacks a skill, and do not make the
final hiring decision.

Finish with a coverage and timing check showing how the plan follows role priority, avoids duplicate
testing, fits the timebox, and passes factual-integrity, privacy, and fairness checks.

## Deliver

Return the finished plan in the conversation or write only an explicitly authorized file. Route
requests to modify candidate facts to `maintain-career-profile`; interviewer analysis must never
silently update a person's profile.
