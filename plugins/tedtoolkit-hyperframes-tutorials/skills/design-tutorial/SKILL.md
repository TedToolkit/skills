---
name: design-tutorial
description: >-
  Design one narrated animated video lesson and write its recordable spoken script.
  Use for a standalone tutorial or one lesson from a course outline, including its learning
  objective, teaching sequence, examples, exact narration, and a specified episode duration.
  Do not use for planning an
  entire multi-lesson course, designing animation shots, or rendering video.
---

# Design Tutorial

Design one lesson so the learner can follow and apply it. The principal deliverable is a spoken
script that the user can record. An existing `plan-tutorial-course` outline supplies the lesson's
scope, but a standalone lesson does not require a course outline.
For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Read the [course state contract](../../references/tutorial-course-state.md) and resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md` before
changing a course lesson. Run the validator first. Work normally from `planned` or `script-draft`;
when revising a later-stage lesson, identify the downstream records and release state that the new
draft will invalidate before writing.

## Establish the lesson

Read the course outline when one exists, plus the user's sources, intended audience, desired
outcome, prerequisites, and constraints. Select one lesson and preserve its place in the course.
Carry forward the course's selected tools, framework, and episode duration when specified.
Read the course README and its audience and voice brief when present; they define this course's
tone and examples, not a universal tone for other tutorials. A learner may be new to the target language while
already fluent in programming; avoid teaching beneath that stated baseline.
Follow the course's chosen demonstration medium. If it names an IDE, explain only actions needed
to run, observe, or verify this lesson; keep version-specific menu paths in a separate tool guide.
If it supplies demonstration files, keep exact code, diagrams, commands, and observable results in
their real source files and align the spoken explanation to them. Make source files and results understandable
without prior expertise in the example's business domain; define any new rule before relying on it.
For a standalone tutorial, define the outcome directly with the user-supplied brief. Check
source-dependent commands, UI steps, facts, and terminology against authoritative material when
they matter to the lesson. Mark uncertain or version-specific details rather than inventing them.

Before writing an open-ended script, show the lesson boundary and teaching sequence. A direct
request to create or update a named script authorizes that draft write at the selected location.
Ask only when a missing fact would change the teaching content or make a demonstration incorrect.

## Write the lesson and spoken script

Choose a teaching sequence that introduces the need, explains each necessary idea, demonstrates
the action or reasoning, and closes with a usable takeaway. Make each explanation earn its place
against the learning objective. Give the learner enough context to follow a procedure without
padding the script with repeated introductions or decorative narration.
Choose the smallest code slice that proves the mechanism. Reuse a course case as a familiar
thread without claiming that all lessons modify one continuously growing codebase. Mark a pattern
comparison as an alternative implementation rather than silently folding it into the main example.

For a lesson that introduces a paradigm, principle, code smell, or design pattern, begin with the
concrete requirement change or failure. Show the old behavior and the smallest useful change,
then name the concept. Explain its benefit, implementation and maintenance cost, and a condition
where the simpler approach is preferable. Treat a code smell as a reason to inspect change cost,
not an automatic mandate to apply a pattern. Demonstrate the resulting behavior with the course's
selected test framework or another observable check; avoid a stand-alone terminology lecture.

Write the actual words to be recorded, in natural spoken language. Give the lesson a coherent arc:
an opening question or concrete problem, the relevant mechanism and example, an observable check,
the limits or cost of the solution, and a closing exit check. The exit check asks one concrete
question or task that lets the learner demonstrate the lesson outcome without merely reporting
whether they feel confident. Tell the learner to pause and answer before continuing. Record concise
success criteria and a specific concept, paragraph, or demonstration to revisit when they cannot
answer; make those learner-accessible in the final lesson rather than leaving them only in production
notes. A transition to the next lesson may follow the check when it introduces a real next problem.
Adapt this arc to an introduction or other non-procedural lesson rather than forcing a demonstration.

In a file-based course, save `lesson.md` and `narration.txt` inside `lessons/<lesson-id>/`.
`lesson.md` is the production card: lesson ID and title, objective, audience assumptions,
prerequisites, teaching arc, paragraph map, demonstrations, sources, and estimated duration.
`narration.txt` is the sole recording source and contains only the words the speaker should read,
as plain-text paragraphs. Do not put a title, Markdown heading, segment label, timestamp, citation,
stage direction, pronunciation note, or production instruction in that file. Never make the speaker
read a heading simply because it appears on the lesson card or screen. Put the exit-check prompt,
success criteria, and remediation pointer in `lesson.md`; include the spoken prompt and pause
instruction in `narration.txt`, while leaving visual reveal instructions in the lesson card.
Do not create a canonical `demo.md`. Record each demonstration's purpose and source path in
`lesson.md`. Keep runnable code, substantial commands and output, diagrams, screenshots, and other
independently verified evidence in their actual project or asset files. Label conceptual or partial
snippets and verify runnable claims with a project build or execution before using them as evidence.
Leave short exact learner-facing text and the decision about what source state or range appears on
screen to `storyboard.md`; do not make the lesson card a duplicate visual script.

Assign stable paragraph identifiers such as P01, P02, ... in the `lesson.md` paragraph map, in the
same order as the blank-line-separated paragraphs in `narration.txt`. For each paragraph, note its
teaching purpose, any required demonstration or exact on-screen value, and the source for claims
that require verification. Keep these notes out of spoken text. Do not prescribe camera moves or
animation timing here. Estimate total length only from likely speaking pace; the recording will
determine final timecodes.

Use the course's requested voice. When it calls for humor or allusions, make them illuminate the
technical point and suit the stated audience. Prefer concise, accurate references to primary
sources; put attribution and links in `lesson.md`, and avoid invented quotations or jokes that
obscure a failure mode. Preserve technical precision even when the prose is playful.
Before handoff, read the words as speech: cut repeated setup, restated definitions, and transitions
that merely announce the next lesson. Keep a transition when it poses a real unanswered question.
Confirm that the closing exit check can be answered from what the lesson actually taught and that
its remediation pointer identifies the relevant explanation rather than telling the learner only to
rewatch the whole video. Do not force a joke into every paragraph or lesson; a precise example or a
brief wry observation can carry the requested voice without slowing the explanation.

Estimate whether the spoken text, demonstration, and necessary pauses fit the episode's time
budget. If they do not, split the teaching outcome into two lessons or propose a narrower scope;
do not accelerate speech or remove an essential explanation merely to hit the limit. Treat the
estimated duration as provisional until the user records the script.

Preserve exact commands, labels, and results when correctness depends on them. If the user supplies
an existing recording, compare it with the script and identify material differences; do not silently
replace what was spoken with new claims. Do not generate a voice recording unless requested.

## Deliver and hand off

Return or save one lesson card and recordable script in the user-selected project. Check that the
stated outcome is taught, the example works from the stated prerequisites, every paragraph has a
clear reason to exist, the exit check tests that outcome with usable success and remediation
guidance, and `narration.txt` contains spoken words only. Tell the user which script version to
record. The next file-based stage records the raw take as `narration-source.wav` and passes it with
the approved script to `edit-tutorial-narration`; do not create an empty audio placeholder. Pass the
lesson card's paragraph identifiers, required demonstrations, exit check, and sources with that
handoff. Final storyboarding follows the edited `narration.wav`, not the raw take.

For a course lesson, record `script-draft` only after these checks pass. Re-recording `script-draft`
after an approved or produced lesson deliberately removes downstream records and resets release
state; report that invalidation before handing the revision to `review-tutorial-script`. Never record
`script-approved` from this skill.
