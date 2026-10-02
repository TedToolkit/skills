---
name: storyboard-tutorial
description: >-
  Design the visual storyboard and animation for one narrated tutorial lesson.
  Use when a lesson script and its final edited narration are available and the user wants shots,
  visual explanations, motion, and timing before HyperFrames production, or explicitly requests a
  provisional pre-recording storyboard.
  Do not use to plan a whole course, write the spoken script, or build and render the video.
---

# Storyboard Tutorial

Turn one lesson's spoken explanation into an animation plan that helps the learner understand it.
Use `design-tutorial`'s paragraph identifiers as the bridge between script, recording, and shots.
For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Read the [course state contract](../../references/tutorial-course-state.md) and resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md`.

## Establish timing and evidence

Read the lesson card (`lesson.md`), spoken-only script (`narration.txt`), final edited narration
(`narration.wav`), its word-level `transcript.json`, every demonstration source declared by the
lesson card, any course-wide visual or teaching constraints, and existing `storyboard.md`. Treat `narration.wav` as
the timing source and record the actual time range and spoken cue for each mapped paragraph. Verify
the transcript timings against the audio rather than trusting them blindly. Identify missing, added, or
materially changed speech before assigning shots. If only `narration-source.wav` exists, return it
to `edit-tutorial-narration`; do not build final shots against an unedited take. If no final audio is
available, create `storyboard.md` only when the user explicitly requests a provisional storyboard,
label every duration as estimated, and never present invented timestamps as final.
If the recording exceeds an agreed episode limit, identify a coherent split point or a script
revision for the user rather than compressing instructional visuals or speeding up speech.

For a course lesson, run the validator and require effective `narration-final` state before creating
a final storyboard. An explicitly requested provisional storyboard may still be drafted earlier, but
it never advances course state.

Confirm that the lesson card supplies an exit-check prompt, success criteria, and remediation
pointer and that the narration tells the learner to pause and answer. If any part is missing, return
it for script correction rather than inventing assessment content in the storyboard.

Inspect existing storyboard material before changing it. Show a proposed shot structure before an
open-ended storyboard write. In a file-based course, save the result as
`lessons/<lesson-id>/storyboard.md`; this is the single storyboard consumed by production. A direct
request to create or update the storyboard authorizes that draft write at the selected location.
Keep the lesson's teaching objective and the exact procedure
from the script intact. If the recording changes the meaning, surface the discrepancy for a script
or audio correction rather than animating a false step.

## Design the shots

For each shot, specify the paragraph ID, narration cue and final audio time range, learner-facing visual,
initial and final states, motion sequence, on-screen text, required asset or source, and transition
to the next shot. Make motion reveal relationships, sequence, state changes, or cause and effect;
use stillness when movement adds no teaching value. Keep code, labels, diagrams, and critical
actions readable long enough to follow. Use a consistent visual grammar across lessons in the
same course.
Follow the course's chosen way of presenting code. For a Markdown-based course, derive code,
project trees, commands, and results from the declared source files and animate those rendered
elements without inventing an editor screen. If the course uses an IDE, show the actual editor or
test output only when its state is evidence for the lesson. Follow the course's chosen visual mode;
when none is recorded, use a light mode that matches the course's light `index.html` output. Apply
that mode consistently to the canvas, typography, diagrams, cards, code presentation, and shared
course chrome in every shot and lesson. Do not introduce a dark-theme scene merely for visual
variety. Authentic screenshots, IDEs, terminals, and other source evidence may retain their native
appearance inside the light course frame. Check contrast and code legibility in both the course
surfaces and embedded source material.

When the course supplies an icon library or design map, use its concept names, variant choices,
and lesson links consistently. Introduce a paradigm, principle, pattern, or code smell icon only
after the visual problem and changed behavior are clear. Record the asset path and provenance for
the production handoff; verify permission before placing third-party illustrations in the video.

Map every spoken demonstration to visible evidence. Avoid visuals that imply an unsupported UI,
output, or result. Put short exact learner-facing text and illustrative snippets directly in
`storyboard.md`. For runnable code, substantial output, diagrams, screenshots, or other independently
verified evidence, record the source path and exact state or range to show rather than copying the
whole source into the storyboard. When exact spoken text is required, carry it verbatim from the
verified lesson script.
Do not preselect a HyperFrames implementation technique unless it affects feasibility or the
handoff; production decisions belong to `build-tutorial`.

End with an exit-check sequence that presents the exact prompt, gives the learner an intentional
opportunity to pause and respond, and then reveals the success criteria and targeted remediation
pointer. Keep the question readable without competing motion. Do not leave the answer criteria only
in the production card; they must be available to the learner in the delivered lesson.

## Deliver and hand off

Return or save `storyboard.md` in the user-selected project. Include a concise shot list, audio cues,
visual and motion directions, exact on-screen text, asset needs, and unresolved feasibility or
source questions. Check that each spoken paragraph is covered, no critical visual contradicts the
narration, the exit-check prompt and reveal are learner-accessible, and the overall visual pace
follows `narration.wav`. Mark the storyboard final only when every shot has verified audio ranges and
every declared demonstration source exists. Pass `lesson.md`, `narration.txt`, `narration.wav`,
`transcript.json`, the final `storyboard.md`, and all referenced source files to `build-tutorial`.
After the final storyboard passes these checks, record `storyboard-final` with the packaged recorder
and re-run the validator.
