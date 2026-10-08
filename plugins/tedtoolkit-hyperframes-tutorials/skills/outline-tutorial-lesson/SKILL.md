---
name: outline-tutorial-lesson
description: >-
  Plan or revise one narrated tutorial lesson as a very short list of teaching points before its
  spoken script. Use when the user wants to review or approve a lesson-level outline. Do not use
  to write narration, a paragraph map, a storyboard, or a whole-course curriculum.
---

# Outline Tutorial Lesson

Make one lesson's teaching logic reviewable as a very short list of key points before any spoken
prose is drafted. The course outline defines the lesson's scope; this skill lists the path from the
opening problem to the promised result. Hand an approved outline to `design-tutorial` for the script
and provisional storyboard.

For a file-based course, read the [tutorial workspace contract](../../references/tutorial-workspace-layout.md)
and [course state contract](../../references/tutorial-course-state.md). Resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md` and
run the validator before changing a lesson. If the lesson is already scripted or produced, identify
which downstream records and release artifacts a changed outline will invalidate before writing.

## Establish the boundary

Read the selected lesson's course outline, audience and voice brief, sources, prerequisites,
demonstration medium, and any fixed duration or scope. When the course belongs to a series, read its
series README before the course README. For a standalone lesson, use the user's brief. Check facts,
commands, and example behavior against supplied or authoritative sources when they determine the
teaching path; mark unresolved details rather than inventing an outcome.

If the lesson is the first to require a tool, check that a viewer following the required videos
has already seen how to prepare and verify it, or that this lesson teaches those actions before
using the tool. Surface a missing or contradictory video handoff to course planning; a linked
setup page alone is insufficient for a video-led course.
For `00.00`, outline the whole-course explanation and state any readiness needed before subject
practice without naming a particular preparation video. For a `00.01+` preparation lesson, outline
one readiness result, the necessary on-screen actions, a success check, and a failure path. Keep substantial subject teaching in its regular
chapter rather than hiding it in the preparation sequence.

State the single primary promise as an answerable question or observable capability. Distinguish it
from supporting examples, methods, and optional guidance. If the title and required outcome disagree,
surface that conflict before outlining; if two independent outcomes must dominate, propose a narrower
lesson or split. Respect the course's actual prerequisite and route model instead of assuming the
next lesson from its ID.
Treat the course outline as the authority for scope and prerequisites. The lesson outline decides
how to teach that scope; it may sharpen the opening question or example without silently changing
the promised outcome or the course's post-lesson question. If the course-level lesson entry cannot
support a coherent teaching path, surface the mismatch for course planning rather than hiding it
inside a more appealing story.
When the request selects one lesson, draft or revise only that lesson's outline. Do not create an
outline for a later lesson, assign its example, or add a future-lesson promise as a way to finish the
current lesson. Note a needed course-level correction for the user without writing unrelated lesson
artifacts. Treat actual prerequisites as inputs, not as a presumption that viewers watched every
lower-numbered lesson.

## Write the short outline

List every essential point in brief phrases or single sentences. For an ordinary 5–10 minute lesson,
aim for about 6–9 short lines and 200–350 Chinese characters of explanatory text; adapt the length
to the lesson instead of padding or omitting a necessary point. Use one numbered teaching sequence,
with short labels only where they help. Cover:

- the single learner outcome and the concrete opening question or situation;
- the teaching beats in causal order: what the learner tries or notices, the decisive example or
  evidence, the inference, and the usable conclusion;
- the course outline's one post-lesson question (or one proposed question for a standalone lesson)
  and the point that equips the learner to answer it;
- a scope limit, source uncertainty, audience assumption, or duration constraint only when it
  materially changes the script.

Make the outline locally complete: state the starting situation needed for this lesson, teach its
own promised result, and end with that result. Keep references to prior or future lesson IDs,
recaps, and watch-next directions out of the teaching sequence. If a previous lesson established a
concept or artifact needed here, include only the minimal context needed to use it. If the full
background cannot fit, name the required starting capability and leave the dependency and
navigation link in the course outline or learner page. This applies even when the course has a
recommended viewing order.

Put the key evidence or visual demonstration beside the beat it supports. Keep an exact command or
value when it is essential to the lesson; if provenance matters, link the source or name the runnable
check in a few words. Leave verification logs, command transcripts, expanded citations, and
production instructions in their source files or for the script stage. Do not
repeat the course brief or add separate paragraphs for evidence, learner misconceptions, handoff,
and timing. A list of disconnected topics is insufficient: short verbs and results should make the
progression clear without narrating every transition.

For an explanatory lesson, retain the central thinking turn—initial question, observation, and
inference—without forcing a wrong answer. For a procedure, list the essential actions and their
observable result. For a long-form episode, group major sections into a few connected bullets;
read the [long-form spoken lesson guide](../../references/long-form-lesson-script.md) when applicable.
Keep spoken lines, paragraph IDs, shot specifications, timestamps, and animation directions for
`design-tutorial`.

At this outline stage, make the teaching sequence fit the lesson's specified duration. Estimate the
time needed for explanation, demonstration, learner inspection, and useful pauses; do not count only
the number of bullets. If the essential beats cannot be taught clearly within that duration, revise
the outline or surface a needed course-level split or duration change before seeking outline approval.
Do not defer an already visible time-design conflict to script writing.

Before handoff, check internally that the opening, main explanation, conclusion, and post-lesson
question serve the same promise; each beat has its needed prerequisite and evidence, and the planned
teaching fits the specified duration. Revise a gap
instead of adding a long rationale to the outline. `design-tutorial` reads this approved list
together with the course brief and sources, then expands it into the script and storyboard. Wording,
visual treatment, and supporting examples may change during scripting while the promise and
reasoning path hold; a new central problem, inference, or teaching sequence needs a revised outline.

## Deliver and approve

For a file-based course, save the reviewable draft as `lessons/<lesson-id>/lesson-outline.md` and
record `outline-draft` with the packaged recorder. This file is distinct from the course outline and
from `lesson.md`, which `design-tutorial` creates after outline approval. Re-run the validator and
identify the exact draft awaiting review. A direct request to create or revise a named lesson
outline authorizes that draft write, but does not approve it or authorize drafting the narration.
For an in-conversation lesson, present the same outline in chat or at the user's selected location.

When the user requests changes, revise the outline and present the new version for review. Only
explicit human approval of that version authorizes the transition to `outline-approved`; for a
file-based course, record it with `--approval-source` and re-run the validator. Then hand the
approved outline and its source constraints to `design-tutorial`. Do not write `narration.txt`,
`lesson.md`, or `storyboard.md` from this skill.
