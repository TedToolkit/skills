---
name: interview-career-project
description: >-
  Interview a candidate one focused question at a time to enrich only explicitly selected existing
  career-profile project records, writing each supported answer before asking the next question.
  Use for guided project debriefs or filling hiring-relevant project evidence interactively. Do not
  use to create or reorganize profiles, import material in bulk, write resumes, prepare interview
  answers, or design interviewer questions.
---

# Interview Career Project

Elicit hiring-relevant facts from a bounded set of existing project records. Read
[career-integrity.md](../../references/career-integrity.md) and
[career-profile-schema.md](../../references/career-profile-schema.md) before interviewing or
writing.

This skill owns only guided, incremental enrichment of explicitly selected existing project records
under `work/`, `education/`, or `personal/`. Route absent records, schema migration, bulk import,
and general profile maintenance to `maintain-career-profile`. Emit no resume, job match, resume
review, candidate preparation, or interviewer plan.

## Bound the targets

Require the profile root and one or more project record paths, or project names that resolve
unambiguously within a supplied profile root. If either boundary is missing or ambiguous, ask one
focused selection question and do not write. To resolve supplied names, inspect only candidate
filenames and headings; never load every project's contents or choose projects for the user.

Process selected projects in the user's order. Keep exactly one project active and do not read the
next selected record until the active project is finished or the user skips it. Read and modify no
unselected profile record. A request to interview the named projects and write after each answer
authorizes only the incremental updates described here; it does not authorize creation, deletion,
movement, broad restructuring, or changes to private contact data.

When supplied, use the target role or job description only to prioritize truthful evidence gaps.
Do not produce a job-match report or discard facts merely because they are not relevant to that
target.

## Run the one-question loop

Read the active record and choose the single unanswered question with the highest likely hiring
value. Prefer gaps concerning:

1. the problem, users, context, and concrete deliverable;
2. personal responsibility and boundaries from team or company work;
3. concrete systems, modules, workflows, or problems handled;
4. material constraints, failure modes, decisions, and trade-offs;
5. delivery, release, adoption, acceptance, or truthful current state; and
6. supported scale, performance, quality, reliability, time, or cost evidence.

Adapt to what the record and previous answer already establish. Ask exactly one focused question per
turn; do not present a questionnaire or hide several questions in one prompt. A useful answer need
not contain a metric when a concrete deliverable or current state is available.

After every user answer:

1. extract all clear candidate-asserted facts without strengthening them;
2. immediately update only the active project record, placing each fact in its canonical section;
3. remove or revise answered `To Confirm` items, preserve contradictions explicitly, and update the
   record date;
4. re-read the changed record and verify attribution, chronology, responsibility boundaries, and
   absence of invented impact or duplicated facts;
5. report the written delta in one concise sentence; and
6. ask the next single highest-value question.

Write normalized facts, not a question-and-answer transcript or resume prose. If an answer is
partly ambiguous, record only its clear portion and use the next question to clarify the material
remainder. If it contains no usable fact, say that nothing was written and ask one clarification.
Do not claim a write succeeded until the file has been verified.

Do not repeatedly pursue information the user does not know or cannot disclose. Preserve an honest
unknown or confidential boundary when useful, then continue to another gap.

## Finish or switch projects

Finish the active project when its high-value gaps are covered, the user says it is sufficient, or
the user asks to skip it. Summarize the facts added and material gaps left in at most a few lines.
Only then read the next selected record and begin its one-question loop. Stop after the last project
without generating another career artifact.
