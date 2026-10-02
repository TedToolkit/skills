---
name: build-tutorial
description: >-
  Build, revise, verify, and render one narrated animated tutorial in HyperFrames from a
  lesson script, final storyboard, and edited narration master. Use for production or changes to an
  existing tutorial video. Do not use for course-level curriculum planning, script-only work,
  or storyboard-only work.
---

# Build Tutorial

Produce one editable HyperFrames composition and a checked rendered video from the user's recorded
narration and lesson storyboard. This skill also owns production review and revisions to existing
tutorial projects; there is no separate review or revision skill.
For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Read the [course state contract](../../references/tutorial-course-state.md) and resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md`.

## Check the handoff

For a file-based course, require `lesson.md`, `narration.txt`, the edited `narration.wav`, and the
word-level `transcript.json`, final `storyboard.md`, and every demonstration source referenced by the
lesson card or storyboard. Do not require or create a canonical `demo.md`.
Run the course validator and require effective `storyboard-final` state before a formal render. A
stale script, narration, transcript, source, or storyboard returns to its owning workflow; do not
render around the mismatch or refresh hashes without re-verification.
Also inspect the existing project and user delivery constraints. Treat `narration.txt` as the
approved spoken content and `narration.wav` as the final timing source; titles, headings, paragraph
IDs, and production notes in other files are not spoken. Confirm the required artifacts describe the
same lesson and script version. If only `narration-source.wav` exists, return it to
`edit-tutorial-narration`. If `storyboard.md` is missing or provisional, return the lesson to
`storyboard-tutorial`. Create only an explicitly requested project scaffold or silent preview when
these gates are incomplete, and never claim it is a finished narrated video. If script, storyboard,
and edited recording materially disagree, show the mismatch and resolve the affected upstream
artifact before final rendering.
Confirm that the lesson card and storyboard agree on the exit-check prompt, success criteria, and
remediation pointer and that the recording includes the learner-facing prompt and pause instruction.
Return a missing or contradictory check to the lesson workflow rather than inventing it during
production.

Inspect the selected project and propose the files or scenes to create or change before writing.
A direct request to build or revise this named tutorial authorizes edits to its project files and
rendered local output. Do not publish or upload the video without separate user authorization.

## Build with HyperFrames

Use the installed HyperFrames skills when available: `hyperframes` for the entry contract,
`hyperframes-core` for composition timing, `hyperframes-animation` and
`hyperframes-keyframes` for seekable motion, `media-use` for assets, and `hyperframes-cli` for the
development loop. Follow the project's installed CLI and current official documentation when
versions differ; do not copy a fixed upstream command or timing API into this skill. The official
source is [HyperFrames](https://github.com/heygen-com/hyperframes).

Align scene boundaries and key teaching actions to `narration.wav`. Do not recut or repair the
voice master inside this skill; send narration changes back to `edit-tutorial-narration` and then
refresh the affected storyboard timing. Use local assets where practical and track their
source. Implement storyboarded states and transitions with seekable, deterministic animation so
arbitrary-frame preview and render agree. Keep exact procedural text, code, and visual results
faithful to the verified script, storyboard, and declared demonstration sources. Render short exact
on-screen text from `storyboard.md`; render runnable code and substantial result panels from their
actual source files. Do not substitute an editor capture for a course that chose rendered source
files, or copy a large source artifact into the storyboard.

For a file-based course, create `lessons/<lesson-id>/captions.vtt` from `narration.txt`, the final
`narration.wav`, and verified `transcript.json`. Use readable phrase or sentence cues rather than whole
paragraphs, omit authoring labels and Markdown, make the cue text match what is actually spoken, and
use stable WebVTT cue identifiers derived from the lesson paragraph IDs when available.
Map narration timing onto the formal video timeline, including any intentional lead-in, and verify
the WebVTT against the rendered video. If reliable word or phrase alignment is missing, align the
final audio again; never estimate cue boundaries by spreading a paragraph evenly over its duration.
Treat WebVTT as the canonical browser track. Produce SRT only for a named downstream platform that
requires it, deriving it from the same verified cues rather than maintaining a second timing source.

Keep `video.mp4` as a clean master and keep WebVTT as the learner subtitle source so the player can
switch, restyle, localize, search, and reuse it for a synchronized transcript. Never render subtitle
text into the video pixels or create a second captioned video variant in this workflow.

Implement the course's visual mode explicitly and deterministically. When no course-specific mode
is recorded, make the composition and its `index.html` use a light mode, matching the course's light
web output. Keep the canvas, surfaces, typography, diagrams, code presentation, and shared course
chrome in that mode across every lesson; do not inherit a viewer's OS color-scheme preference or
switch a scene to dark mode for decoration. Preserve the authentic appearance of screenshots,
IDEs, terminals, and other source evidence when recoloring would misrepresent it, framing that
content within the light course treatment and maintaining readable contrast.

Implement the storyboarded exit-check sequence as part of the lesson: show the prompt clearly,
preserve the intentional response opportunity, and reveal the success criteria and targeted
remediation pointer in learner-facing form. Keep this sequence seekable and readable like every
other teaching scene; do not omit it merely because the narration has ended.

## Verify and deliver

Run the available HyperFrames validation and render commands. Inspect representative frames at
the start, middle, and end of each shot and around transitions; listen to the finished audio and
check shot, action, and WebVTT cue timing against the rendered video. Check readability at the target
resolution, completeness of all spoken paragraphs, factual visual fidelity, missing assets, clipped
text, exit-check response and reveal states, ending audio, and any agreed episode duration. Fix
material problems and render again. If the recording makes the lesson longer than agreed, report
the actual length and seek a coherent lesson split or script change; do not silently speed up the
narration. On later revision requests, change only affected scenes and repeat checks for those
scenes plus their boundaries.

In a file-based course, write the formal lesson render as `lessons/<lesson-id>/video.mp4`; this file
is the publication signal used by course packaging. Also deliver the aligned `captions.vtt`.
Deliver the editable project, rendered video, and a concise note of validation performed and any
remaining limitation. If rendering cannot run in the environment, preserve the project and report
the exact blocker rather than presenting a preview as a final video.
After the formal video and canonical WebVTT pass every production check, record `video-verified`
with the packaged recorder and re-run the validator. A preview does not advance this state without
the clean master and verified sidecar.
