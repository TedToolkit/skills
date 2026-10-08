---
name: design-tutorial
description: >-
  Write or materially redesign one narrated animated video lesson from an approved lesson outline,
  producing its synthesis-ready spoken script, provisional storyboard, and visual shot preview
  before narration, then aligning the storyboard to final audio. Use for a standalone tutorial or
  one lesson from a course outline.
  Do not use for review-only requests, narrow fixes to an existing draft, narration generation, course-level
  curriculum planning, or rendering.
---

# Design Tutorial

Design one lesson so its spoken and visual explanations work together. Use the narrative spine
approved through `outline-tutorial-lesson`. Before narration generation, produce a synthesis-ready
script, a provisional storyboard, and a viewable visual preview of its shots without invented
timecodes. After the generated narration exists, return
to the same storyboard, align it to verified audio timing, and finalize it for production. An existing
`plan-tutorial-course` outline supplies the lesson's scope, but a standalone lesson does not require
a course outline.
For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Read the shared [video style contract](../../references/tutorial-video-style.md) when designing or
revising lesson visuals. Read the linked series visual system when one exists; use
`design-tutorial-visual-system` when the shared identity itself needs to be created or revised.
If the course has no `video-style.md`, draft it from its established choices, the series rules, and
representative shot types before finishing the first visual preview. Record explicit exceptions
rather than silently overriding a series rule. Review that draft with the script and preview; it
does not create another approval stage. For a later lesson, inspect the contract and locally viewable
reference frames or verified video before designing new frames. Where motion is part of the visual identity or the
explanation, inspect or create a short moving specimen before committing to the full sequence;
static frames alone cannot settle its rhythm or continuity. Carry forward the recognizable visual
grammar while letting the subject determine the scene form.
Before recording a new or revised file-based course script draft, resolve the shared
CSS and HTML example required by that contract, link them from `video-style.md`, and make each shot
preview load the declared CSS. Inspect the example and preview in the actual browser before seeking
script approval; confirm the resolved fonts and the intended foreground hierarchy rather than
trusting family names or CSS declarations alone.
Reuse the series bundle in `series-standards/`, or maintain `visual/` for a standalone course.
Generate HTML with shared semantic classes and shot-specific layout/motion; avoid new copies of the
shared stylesheet or font declarations in lesson directories.
Read the [course state contract](../../references/tutorial-course-state.md) and resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md` before
changing a course lesson. Run the validator first. From `outline-approved` or `script-draft`, design the
script and provisional storyboard together. From `narration-final`, align and finalize that
storyboard. When revising another later-stage lesson, identify the downstream records and release
state that the change will invalidate before writing.
For a new draft or material script revision, read [draft script and visuals](references/draft-script-and-visuals.md).
This phase produces the synthesis-ready script, provisional storyboard, and viewable shot preview
before any WAV request. Read only the relevant sections of the
[evidence-informed guide](../../references/evidence-informed-script-and-storyboard.md) for the
current design decision.

For a lesson with final narration and effective `narration-final` state, read
[align to audio](references/align-to-audio.md). Use actual `narration.wav` timing to finalize
`storyboard.md`; do not repeat draft instructions unless the script or preview must change.
