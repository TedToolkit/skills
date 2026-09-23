---
name: prepare-for-interview
description: >-
  Prepare a candidate for interviews using a resume, career evidence, and target role. Use for
  personal talking points, resume and project questions, role-based practice questions,
  evidence-backed answer outlines, preparation tasks, or a timed mock interview. Do not use for
  interviewer plans, hiring scorecards, resume writing, or standalone job matching.
---

# Prepare for Interview

Help a candidate rehearse truthful, relevant evidence without inventing experience. Read
[career-integrity.md](../../references/career-integrity.md) and
[interview-standard.md](../../references/interview-standard.md). When a local career profile is
supplied, read [career-profile-schema.md](../../references/career-profile-schema.md) before using it.
When a company-role dossier is supplied, read
[target-research-schema.md](../../references/target-research-schema.md).

This skill solely owns `# Interview Preparation`. It emits no interviewer scorecard, hiring verdict,
resume copy, target research, `# Resume Review`, or `# Job Match` unless separately requested.
Route requests to interview or evaluate another person to the independently installed
`tedtoolkit-hiring/design-interview`; do not imitate that persona capability here.

## Establish the preparation brief

Identify the target role, seniority, interview stage, available time, language, desired depth,
and supplied resume or career evidence. Choose a study guide when the candidate wants personal
materials and a preparation plan; choose a focused practice set for a timed mock interview or
question-only drill. Infer reasonable defaults for optional details. For a practice set without
specified scope, default to 30 minutes and eight medium-difficulty questions in the source language.
For a study guide, select depth from the available evidence and preparation time rather than
imposing that question count.

Use the supplied resume as the map of claims an interviewer may probe; it is candidate-asserted
evidence, not independent verification. Use career records to find supporting detail, personal
contribution boundaries, outcomes, and distinctive strengths that the resume may compress or omit.
When both candidate evidence and an identified company-role dossier are supplied, use
`match-job-description` as supporting analysis. With only a role dossier, prepare against the role
and state that personal evidence selection is limited. With only candidate evidence, rehearse its
strongest claims and state that role coverage is limited. Ask a question only when neither source
provides a job-related basis for preparation.

If the role dossier contains official or candidate-reported interview questions, preserve their
source class, scope, and date when available. Label questions generated from resume or role evidence
as practice questions; never present them as questions the employer has asked or will ask.

For a planning-only request, present competency coverage, time, question count, and difficulty and
stop. For a direct finished request, state the supplied or default brief and produce the pack in the
same response without another approval gate.

## Build the preparation pack

Use this stable opening:

```md
# Interview Preparation
- Brief: <role, stage, time, count, difficulty, language>
```

For a study guide, add the following material where the supplied evidence supports it:

- **Personal positioning:** an introduction outline, career transitions worth explaining,
  strongest role-relevant capabilities, and distinctive strengths even when the role does not
  explicitly request them. Anchor each talking point in actual work rather than self-ratings.
- **Resume and project defense:** select material claims likely to invite follow-up. Pair each
  likely probe with personal action, scope, decisions, constraints, collaborators, outcome or
  current state, and facts the candidate should verify before repeating.
- **Story bank:** prepare reusable examples from the candidate's strongest work. Outline the
  situation, task, personal action, decision or trade-off, result, and likely follow-up probes.
  Leave missing outcomes or ownership boundaries as preparation questions.
- **Personal questions:** generate practice questions from resume claims and career history,
  including project depth, technical choices, setbacks, collaboration, motivation, and any
  evidence-backed distinctive capability. State the evidence to use and what to rehearse.
- **Role coverage:** map likely questions to the role's highest-priority responsibilities and
  qualifications. For each, identify candidate evidence or a gap and the topic, exercise, or
  example to prepare. Keep sourced interview-question reports separate from inferred practice
  questions.

For every practice question in either mode, provide:

- the competency, job requirement, or career-profile evidence it rehearses;
- the primary question and realistic follow-up probes;
- what a strong answer should demonstrate;
- the candidate's supplied evidence worth preparing; and
- concise preparation guidance or an answer structure.

Never fabricate a model answer from unsupported facts. Mark missing examples, dates, scope,
ownership, or outcomes as preparation gaps. Include at least one probe that separates personal
contribution from team results when applicable. Do not provide warning-sign labels, interviewer
scoring anchors, hiring predictions, or disclosure advice for irrelevant sensitive information.

Finish with a prioritized preparation checklist of concrete actions, such as verifying a metric,
reconstructing a project decision, rehearsing a short walkthrough, reviewing a technical topic,
or practicing a representative task. Check that questions cover both personal claims and role
priorities when both sources are supplied, avoid repetition, fit any stated timebox, and preserve
factual integrity.

## Deliver

Return the finished preparation in the conversation or write only an explicitly authorized file.
Inside a candidate workspace, its canonical path is
`applications/<company-id>/<role-id>/interview-preparation.md`.
Keep useful unresolved fact questions in the preparation checklist so the candidate knows what to
verify. Do not alter the resume, role dossier, or career profile; route profile updates to
`maintain-career-profile`.
