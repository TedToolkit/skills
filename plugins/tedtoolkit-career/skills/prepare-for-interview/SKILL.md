---
name: prepare-for-interview
description: >-
  Create evidence-based interview preparation for a candidate, including practice questions,
  follow-up probes, answer evidence, and focused preparation guidance. Use for self-practice, mock
  interview preparation, or rehearsing a target role. Do not use for interviewer plans, hiring
  scorecards, resume writing, resume critique, or a standalone job-match report.
---

# Prepare for Interview

Help a candidate rehearse truthful, relevant evidence without inventing experience. Read
[career-integrity.md](../../references/career-integrity.md) and
[interview-standard.md](../../references/interview-standard.md). When a local career profile is
supplied, read [career-profile-schema.md](../../references/career-profile-schema.md) before using it.

This skill solely owns `# Interview Preparation`. It emits no interviewer scorecard, hiring verdict,
resume copy, `# Resume Review`, `# Job Match`, or `# Interview Plan` unless separately requested.
Route requests to interview or evaluate another person to `design-interview`.

## Establish the preparation brief

Identify the target role, seniority, interview stage, available time, language, desired depth, and
supplied candidate evidence. Infer reasonable defaults when optional details are absent. For a
direct request for a finished pack, default to a 30-minute, eight-question practice bank at medium
difficulty in the source language.

When both candidate evidence and a job description are supplied, use `match-job-description` as
supporting analysis. With only a job description, prepare against the role and state that personal
evidence selection is limited. With only candidate evidence, rehearse its strongest relevant claims
and state that role coverage is limited. Ask a question only when neither the role nor supplied
evidence provides a job-related basis for preparation.

For a planning-only request, present competency coverage, time, question count, and difficulty and
stop. For a direct finished request, state the supplied or default brief and produce the pack in the
same response without another approval gate.

## Build the preparation pack

Use this stable opening:

```md
# Interview Preparation
- Brief: <role, stage, time, count, difficulty, language>
```

For every practice question, provide:

- the competency, job requirement, or career-profile evidence it rehearses;
- the primary question and realistic follow-up probes;
- what a strong answer should demonstrate;
- the candidate's supplied evidence worth preparing; and
- concise preparation guidance or an answer structure.

Never fabricate a model answer from unsupported facts. Mark missing examples, dates, scope,
ownership, or outcomes as preparation gaps. Include at least one probe that separates personal
contribution from team results when applicable. Do not provide warning-sign labels, interviewer
scoring anchors, hiring predictions, or disclosure advice for irrelevant sensitive information.

Finish with a prioritized preparation checklist and a coverage check showing that the pack follows
role priority, avoids duplicate testing, fits the timebox, and preserves factual integrity.

## Deliver

Return the finished preparation in the conversation or write only an explicitly authorized file.
Keep unresolved fact questions outside a saved preparation artifact unless the user requested them
inside it. Route requests to update the underlying career profile to `maintain-career-profile`.
