---
name: generate-interview-questions
description: >-
  Generate a finished job-related interview pack in either Interviewer mode or Candidate practice
  mode. Use for interviewer questions, follow-up probes, scoring anchors, mock-interview questions,
  self-practice, or candidate preparation. Do not use for resume rewriting, resume critique, or a
  standalone resume-to-job evidence matrix.
---

# Generate Interview Questions

Create questions that test or rehearse relevant evidence fairly. Read
[resume-integrity.md](../../references/resume-integrity.md) before designing the interview.

This skill solely owns `# Interview Pack`. It may consume supporting analysis but emits no resume
copy, `# Resume Review`, or `# Job Match` unless separately requested. Apply the shared artifact and
legal-source gates to any requested destination or jurisdiction-dependent conclusion.

## Establish the interview brief

Select exactly one mode:

- `Interviewer`: the user is interviewing or evaluating another candidate. Produce questions,
  neutral probes, evidence expectations, warning signs, and optional scoring anchors.
- `Candidate practice`: the user is preparing for their own interview or requests mock/practice
  questions. Produce questions, probes, what the answer should evidence, and concise preparation
  guidance; do not provide a hiring verdict or warning-sign labels.

Infer the mode from the user's role. When wording is genuinely ambiguous, default to
`Candidate practice` and state that default. Identify the role, seniority, stage, available time,
target language, and desired depth from supplied context.

An omitted role does not block a finished pack when the user supplies a concrete published
job-related requirement such as an on-call schedule. In that case, do not ask for the role: scope
the pack to that requirement, state the limitation, and use the normal defaults.

Invoke `match-job-description` only when both candidate background/resume and a job description are
supplied. With only a job description, derive competency coverage from the role. With only candidate
evidence, generate claim-verification or practice questions from that evidence and state that role
coverage is limited. Apply the shared evidence meanings when turning source claims into questions.

For a direct request for finished questions, use explicit defaults instead of adding a planning
gate. In `Interviewer` mode, default to 30 minutes and five primary questions, with optional
alternates outside the live plan. In `Candidate practice` mode, default to a 30-minute, eight-question
practice bank. Use medium difficulty, the source language, and a balanced general stage. Override the
defaults the user supplied. If an interviewer requests more than five primary questions without a
timebox, allow at least five minutes per question or mark the excess as alternates. Ask a question
only when a missing role or source makes a job-related pack impossible.

## Design the blueprint

Allocate questions across the role's highest-value competencies. Balance:

- resume-claim verification;
- past-behavior evidence;
- technical or domain depth;
- situational judgment tied to realistic role constraints;
- motivation and role understanding when relevant.

Apply the shared privacy and fairness rules. Avoid trivia, riddles, leading questions, and generic
questions that do not affect role readiness. When jurisdiction-specific legality matters, require
authoritative local guidance. When replacing a requested protected-trait question, label the omitted
question `Excluded as non-job-related` and provide only the neutral replacement in the pack.

For a planning-only request, present the proposed competency coverage, question count, difficulty,
and time allocation and stop. For a direct finished-pack request, state the selected mode and supplied
or default brief, then produce the pack in the same response without a second approval gate.

## Write the interview pack

Use this stable opening:

```md
# Interview Pack
- Mode: Interviewer | Candidate practice
- Brief: <role, stage, time, count, difficulty, language>
```

For every question, provide:

- competency and source requirement or resume claim;
- primary question and neutral follow-up probes;
- what strong evidence should contain;
- in `Interviewer` mode, material job-related warning signs and concise scoring anchors when
  evaluation guidance was requested; or
- in `Candidate practice` mode, concise preparation guidance and evidence to prepare.

In `Interviewer` mode, use consistent scoring anchors labeled `Score 1:`, `Score 3:`, and `Score 5:`,
defined by observable evidence rather than vague labels. In either mode, include at least one probe that explicitly
separates individual contribution from team outcome when the source claim is collective.

Finish with a coverage check showing that question volume follows role priority, avoids duplicate
testing, fits the timebox, and passes the shared integrity, privacy, and fairness checks.
