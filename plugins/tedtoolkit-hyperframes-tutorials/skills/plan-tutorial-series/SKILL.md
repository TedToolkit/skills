---
name: plan-tutorial-series
description: >-
  Plan or restructure a multi-course animated tutorial series. Use when the user needs to decide
  how many courses the series should contain, merge or split courses, define graduation and
  extension routes, assign outcomes and topic ownership across courses, design prerequisite courses
  and valid learning routes, share cases and teaching rules, or maintain a series README and
  course-series.json. Do not use for the chapter and lesson plan inside one course, a single lesson
  script, or video production.
---

# Plan Tutorial Series

Design the portfolio-level learning path for a series of independently planable and publishable
courses. Own the series charter, course boundaries, cross-course prerequisite graph, and handoff
briefs. Hand each approved course boundary to `plan-tutorial-course`; do not duplicate that skill's
chapter, lesson, or production-state work.

For a file-based series, read the
[tutorial series contract](../../references/tutorial-series-contract.md) before creating or changing
series artifacts. Resolve the packaged
[`validate-series.mjs`](../../scripts/validate-series.mjs) relative to this `SKILL.md`; a missing
linked resource is a stop condition.

## Inspect before proposing changes

Read the existing series README, `course-series.json`, every available course README, course outlines
and configs, and any supplied source material. Identify facts or maintained sections repeated across
course READMEs; those belong in the series README when they apply unchanged to every course. Inventory
course roots and identify lessons that have progressed beyond `planned`; those artifacts constrain a
restructure even when most of the curriculum remains editable. Do not infer that a topic deserves its
own course merely because it has a familiar technology or method name.

Calculate the current minimum-completion burden from the declared graduation courses: course count,
core lesson count, and estimated duration when available. Compare that burden with every prose route
and stopping point. Flag a contradiction when the charter says all courses or all Core lessons are
required but the roadmap presents some of those same courses as optional branches, specializations,
or need-based routes. Treat “complete every course” as full-series completion unless the audience and
observable graduation promise genuinely require every specialty.

If the series does not yet have machine-readable state, inspect the available outlines and describe
the inferred current structure. Do not manufacture prior approval, production state, or a migration
history.

For a read-only evaluation, report the current boundary problems, missing capabilities, overlap,
and a recommended series structure, then stop. Do not create planning files or move course roots.

## Establish the series charter

Define the audience, entry capability, delivery context, excluded scope, and observable series
outcomes before deciding how many courses exist. Give every outcome a stable ID such as `SO-01`, an
assessable description, and one tier:

- `graduation`: required for the minimum completion promise of the series.
- `extension`: deeper judgment, transfer, or specialization beyond that promise.

Keep these series tiers distinct from the `core` and `extension` lesson types inside an individual
course. A graduation course may still contain optional extension lessons. An extension course still
has its own required core lessons. Explain both levels explicitly whenever the same words could be
confused.

Name full-series completion separately from the minimum graduation promise when both are useful. Do
not use a course-local `core` label as evidence that the course belongs in the series graduation
route; first decide whether every intended graduate needs that course's exit capability.

Make the series README the shared learner-facing charter for all courses. Put every genuinely common
README fact there once, including shared audience assumptions, terminology, teaching and navigation
conventions, case model, and viewing expectations when applicable. A course README must link to the
series charter and state only its own promise, prerequisites, completion routes, course-specific
choices, and explicit exceptions. Do not maintain copied common sections in separate course READMEs.

Record the series-wide teaching method when one exists. For a problem-driven series, preserve the
full reasoning arc: observable problem, reproducible evidence, simplest credible baseline,
alternative solutions, comparative verification, and the conditions where a solution is not worth
using. Do not turn patterns, tools, principles, or product features into a catalog merely to claim
coverage.

## Design coherent course boundaries

Group content by a continuous learner problem and an independent exit capability. A course earns a
separate boundary when it has a distinct outcome, prerequisite profile, evidence model, practice
environment, or delivery value. Merge courses when their content participates in the same problem
and verification loop. Keep them separate when combining them would create a collector course with
several unrelated exits or materially different toolchains and risk boundaries.

Let outcomes determine the course count. Do not optimize for the smallest number, mirror a topic
taxonomy, or preserve an existing count without evidence. Audit every proposed course for:

- one concise purpose and observable exit capability;
- one course-completion outcome for its Core route and, when it has optional outcomes, the additional
  gains of each named Extension route, all backed by observable evidence;
- explicit ownership of one or more series outcomes;
- a defensible reason to be independent;
- overlap or repeated prerequisites with other courses;
- content that belongs in another course, a brief bridge, or an optional lesson;
- a realistic first release rather than an obligation to produce the entire long-term catalog.

Compare course-local core lesson counts and estimated durations across the series. A large imbalance
is not automatically wrong, but it is a prompt to look for multiple independent exit capabilities,
different prerequisite profiles, or a useful publishable stopping point hidden inside one collector
course. Split only when that evidence exists; otherwise make the internal stages and stopping points
explicit.

## Design course prerequisites and learning routes

Derive course dependencies from capabilities or artifacts the later course actually consumes. For
every direct prerequisite, record both the prerequisite course ID and the capability it supplies.
Do not connect adjacent course numbers merely to force one viewing order, and do not repeat
transitive prerequisites unless the later course independently consumes them.

The cross-course graph must be acyclic. A graduation course may depend only on other graduation
courses; an extension course must never become a hidden prerequisite for a graduation outcome.
Expose independent courses as parallel branches and show where advanced courses combine capabilities
from several earlier courses. From the graph, derive:

- courses available from the stated series-entry assumptions;
- courses unlocked after each prerequisite wave;
- blocked courses and the exact missing prerequisite capabilities;
- one or more valid learning routes rather than one mandatory numeric sequence;
- useful stopping points where a learner has completed a coherent capability.

Schedule a course in the same release wave as all of its prerequisites only when they can be planned
and delivered together; otherwise place it later. Never publish a route that asks learners to start
a course before its prerequisites are available.

When one course contains independent branches with different prerequisite capabilities, do not make
the stronger prerequisite block the whole course merely because one branch consumes it. Either split
the course at a defensible boundary, keep the stronger capability as a branch-specific recommendation,
or redesign the Core completion outcome so its prerequisite profile is honest.

## Reuse cases deliberately

Prefer a small number of sustained cases whose domain rules remain below the audience's prerequisite
ceiling. Reuse a case across chapters or courses when its evolving pressure makes the comparison
clearer. Use a small isolated example only when the shared case would hide the mechanism, introduce
irrelevant domain knowledge, or make two credible alternatives difficult to compare.

Record each shared case, the courses that use it, and its teaching purpose in `course-series.json`.
Do not force every course to mutate one universal codebase, and do not create a new case for every
lesson merely for visual variety.

## Propose before restructuring

Before an open-ended series planning write, show the proposed charter, courses, course tiers,
outcome coverage, prerequisite graph and learning waves, shared-case strategy, and release waves.
Include a mapping from the current structure when courses would be merged, split, renamed, or
archived.

A direct request to create or update a series plan authorizes draft `README.md`,
`course-series.json`, and course brief writes at the selected root. It does not authorize lesson
scripts, production, or changing approval records. Before moving, renaming, or archiving existing
course roots that contain authored or produced artifacts, require approval for the exact migration
boundary unless the user already approved that concrete mapping and operation. Preserve fixed or
produced lessons and report any series decision that would make them inconsistent.

## Write the series plan

For a new file-based series, create only real planning artifacts:

- root `README.md`: the human-readable charter, routes, course map, teaching method, prerequisite
  graph and learning waves, shared cases, release waves, unresolved decisions, and all information
  that course READMEs would otherwise repeat unchanged;
- root `course-series.json`: the machine-readable identity, outcomes, course tiers, direct
  prerequisite capabilities, briefs, shared cases, and release waves;
- `course-briefs/<course-id>.md`: each course's audience slice, problem chain, exit capability,
  Core completion outcome and any optional Extension route outcomes with evidence, owned outcomes,
  prerequisites and supplied capabilities, excluded scope, case use, and handoff questions. Every
  brief must also include the required `00.00` course-guide brief: what the course teaches, who it
  suits, prerequisites, Core completion and optional Extension gains, distinctive course features,
  major content parts and their relationships, recommended routes, stopping points, and capabilities
  or later courses it unlocks. Identify any course-entry tools or access requirements that
  `plan-tutorial-course` must turn into video-led `00.01+` preparation; keep substantive knowledge
  prerequisites in the cross-course graph.

Order the series README for learner decisions: audience and promise, minimum graduation and optional
specializations, observable outcomes, course map and prerequisites, then teaching conventions. Move
long production, visual, asset, or internal review contracts to linked series-level references when
they would delay the learner from discovering what is required, optional, and unlocked next.

When course READMEs already duplicate shared material, describe the deduplication mapping: which
content becomes authoritative in the series README and which course-specific deltas remain local.
Do not leave two maintained copies. When creating or revising a course README is in the approved
write boundary, replace repeated shared prose with a link rather than paraphrasing it again.

Do not create empty course directories, course configs, outlines, lesson cards, or media
placeholders during series planning. When a course already exists, its series brief may point to
the existing root; preserve its course-local identity and production records. Let
`plan-tutorial-course` create or revise the detailed course workspace after its boundary is approved.

Run the packaged validator after writing. Resolve every structural error: unsafe or duplicate paths,
unknown outcome or course references, cycles, graduation routes that depend on extension courses,
uncovered outcomes, duplicate release placement, and release waves scheduled before prerequisites.

## Hand off the approved structure

Identify the dependency-ready graduation courses and the smallest useful first release wave. Hand
each selected course brief to `plan-tutorial-course`; do not automatically expand every course into
chapters unless the user asked for that broader write. Report preserved produced work, remaining
boundary questions, later extension waves, and the exact next course or courses that can be planned
independently.
