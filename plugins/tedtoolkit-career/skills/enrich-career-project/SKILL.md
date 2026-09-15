---
name: enrich-career-project
description: >-
  Interview a candidate one focused question at a time to enrich only explicitly selected existing
  career-workspace project records, writing each supported answer before asking the next question.
  Use for guided project debriefs or filling resume-relevant project evidence interactively. Do not
  use to create or reorganize workspaces, import material in bulk, write resumes, prepare interview
  answers, or design interviewer questions.
---

# Enrich Career Project

Elicit useful facts from a bounded set of existing project records. Read
[career-integrity.md](../../references/career-integrity.md) and
[career-profile-schema.md](../../references/career-profile-schema.md) before interviewing or
writing.

This skill owns only guided, incremental enrichment of explicitly selected existing project records
under `work/`, `education/`, or `personal/`. Route absent records, workspace migration, bulk import,
and general profile maintenance to `maintain-career-profile`. Emit no target research, resume, job
match, resume review, or interview preparation.

## Bound the targets

Require the selected workspace root and one or more project record paths, or project names that
resolve unambiguously within that root. If either boundary is missing or ambiguous, ask one focused
selection question and do not write. An explicitly supplied legacy profile root is valid and stays
in place. To resolve supplied names, inspect only candidate filenames and headings; never load every
project's contents or choose projects for the user.

Process selected projects in the user's order. Keep exactly one project active and do not read the
next selected record until the active project is finished or the user skips it. Read and modify no
unselected record. A request to enrich the named projects and write after each answer authorizes
only those incremental updates; it does not authorize creation, deletion, movement, broad
restructuring, target research, or changes to private contact data.

When supplied, use one identified company-role dossier only to prioritize truthful evidence gaps.
Do not produce a job-match report or turn target-company or role facts into candidate facts.

## Run the one-question loop

Read the active record and choose the single unanswered question with the highest likely resume or
interview value. Prefer gaps concerning context and deliverable, personal responsibility, concrete
work, constraints and trade-offs, delivery or current state, and supported outcome evidence.

After every user answer:

1. extract all clear candidate-asserted facts without strengthening them;
2. immediately update only the active project record in its canonical sections;
3. revise answered `To Confirm` items, preserve contradictions, and update the record date;
4. re-read the record and verify attribution, chronology, boundaries, and absence of invented impact;
5. report the written delta in one concise sentence; and
6. ask the next single highest-value question.

Write normalized facts, not a transcript or resume prose. If an answer is partly ambiguous, record
only its clear portion and clarify the material remainder next. If it contains no usable fact, say
nothing was written and ask one clarification. Do not repeatedly pursue information the candidate
does not know or cannot disclose.

## Finish or switch projects

Finish the active project when its high-value gaps are covered, the user says it is sufficient, or
the user asks to skip it. Summarize facts added and material gaps left briefly. Only then read the
next selected record. Stop after the last project without generating another career artifact.
