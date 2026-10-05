---
name: package-tutorial-course
description: >-
  Build and verify a self-contained offline HTML and ZIP release for a file-based,
  multi-lesson tutorial course. Use when the user wants to refresh the learner page,
  bundle lesson text and videos, or hand out a local-openable course archive. Do not
  use for online hosting, uploading, or producing individual lesson videos.
---

# Package Tutorial Course

Package the course the learner can actually open, not an authoring workspace or a single HTML file.
An offline release keeps `index.html`, every referenced local video, and learner-facing text/assets
under one directory, then archives that directory as ZIP. Do not upload or distribute the archive
externally without the user's authorization.
Follow the shared [tutorial workspace contract](../../references/tutorial-workspace-layout.md) for
canonical lesson artifacts and the authoring-versus-release boundary.
Read the [course state contract](../../references/tutorial-course-state.md) and resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-release.mjs`](../../scripts/record-course-release.mjs) relative to this `SKILL.md`.

## Discover the course contract

Inspect the course outline, lesson directories, existing page generator, language setting, and
release conventions before changing anything. In a course using this toolkit's file layout, use
`course.config.json` for the course ID, title, slug, and content language; use the outline for
lesson IDs, types, titles, and prerequisites; use `lessons/<id>/video.mp4`, `captions.vtt`, and
`cover.png` as publication artifacts and effective `cover-verified` state as the publication gate.
Read every path in `learnerDocuments` when present. For a new course, require its learner-facing
chapter checkpoints and final Core completion task in the listed practice document; report a missing
task or self-check as a curriculum gap before calling the release complete.
Keep each lesson's stable ID
and the learner's local-progress storage key across rebuilds.

Run the packaged validator before building. Do not package while the graph is invalid, a required
artifact is stale, or a core lesson selected for release is below `cover-verified`. An incomplete
extension may remain unpublished without blocking a complete core release.
For a video-led course with required `00.01+` preparation lessons, verify that the learner route
shows `00.00` first, presents each required preparation video before its first dependent technical
lesson, and does not rely on a linked document to communicate a mandatory step. Apply the ordinary
Core publication gate to every required preparation video.

Skill instructions being written in English do not require English learner content. Keep the
page, source text, and metadata in the course's chosen language. For a requested translation,
prepare and review localized source text and UI strings before building; do not silently translate
at package time or emit a mixed-language release. A locale setting must reflect the language of
the actual content, not merely alter the HTML `lang` attribute.

## Build the offline release

Prefer the course-local `tools/package-course.mjs`; invoke it from the course root. It must call
`tools/build-course-player.mjs` first so the page reflects current outline, text, and video
metadata, then collect learner-facing Markdown/plain text, referenced assets/examples, formal
videos, caption tracks, `course-cover.png`, and lesson covers into a generated output directory and ZIP. If a different course lacks these scripts,
adapt or create project-local scripts for its real schema before packaging; do not assume that
one course's Chinese outline parser works for every course. Keep author-only demo clips and raw
production files out of the release unless the user explicitly wants them.
Copy each configured `learnerDocuments` file into the release and expose a visible local link from
`index.html`. Place the practice link near the course route and make chapter checkpoints reachable
at the corresponding chapter exit. Preserve task prompts and self-check guidance; do not silently
replace them with a completion checkbox. The release validator checks file identity and the local
link, while the packaging review checks the pedagogical content.

Treat a lesson without its formal video, canonical captions, or verified cover as `unpublished`,
even when all prerequisites are complete.
It must not be clickable, playable, markable as completed, or counted as a completed prerequisite.
Previously stored completion for an unpublished lesson must not unlock descendants. A published
lesson whose prerequisites are incomplete remains locked. Keep the generated directory clearly
separate from authoring sources; never overwrite an unknown directory just because its path
matches the intended output.

Keep the player width available for learning content. Group the current lesson's status and duration
in one compact metadata row beside or directly below the lesson title; do not place them at opposite
edges of the content area. Let the group wrap as one unit on narrow screens instead of reserving a
second column or shrinking the video.

For every published lesson, read the exact learner-facing text from the lesson card's single
`## Post-lesson question` section. Render it as static text after the lesson's video and transcript
and before completion and next-lesson controls. Keep it visible without requiring video playback to
finish. Do not add an input, submission, answer reveal, scoring, stored response, or completion gate;
the learner answers privately. Do not derive the question from `narration.txt`, captions, or video
frames, and do not include author notes from the rest of `lesson.md` in this learner-facing block.
Treat the Markdown heading as an authoring key and localize the visible section label to the course
language. Wrap the learner-facing block in an element with
`data-post-lesson-question="<lesson-id>"` so the packaged-release validator can prove that the
question is present without adding interaction. A missing, empty, duplicate, unmarked, or omitted
question prevents a finished release.

For every published narrated lesson, include `captions.vtt` as a local WebVTT track on the video and
use those same cues to render the learner transcript; do not create a second independently timed
subtitle source from `narration.txt`. On a sufficiently wide viewport, the transcript may occupy a
right-side panel while the video retains a useful viewing width. On smaller viewports, move it below
the video as a collapsible section. Highlight the active cue, keep it in view during playback, and
let a learner select a cue to seek the video. Do not fight deliberate manual scrolling: pause
auto-follow until the learner explicitly resumes it or selects or seeks to a cue. Keep native caption
controls available for learners who prefer subtitles over the transcript panel, but do not show both
the overlay captions and the transcript panel as duplicate text by default.

If a published lesson has a `## Visual descriptions` section in `lesson.md`, render that section as
learner-facing text near the video and transcript, in the same order as the described scenes. Give it
an accessible heading and make it reachable without playing the video. Extract only this section;
do not expose the rest of the production card. Check that the text conveys necessary visual-only
details, including exact labels or code where these affect the lesson outcome; a speech-only WebVTT
transcript does not supply them. If the lesson needs such details but the section is absent or empty,
return it to `design-tutorial` before finishing the release.
For a file-based release, mark each rendered section with
`data-visual-descriptions="<lesson-id>"` and verify that its current learner-facing text appears in
the extracted offline page. The section must switch with the selected lesson, like the post-lesson
question; storing it in the authoring card alone does not complete the handoff.
Prefer integrated spoken description for visual meaning needed to follow the lesson. A page section
for remaining exact details helps readers but does not by itself establish an audio-description
conformance level; evaluate that separately if the course has a stated accessibility target.

Package the clean `video.mp4` together with its sidecar `captions.vtt`. WebVTT is the canonical
course experience and supports switching, restyling, accessibility, synchronized transcript display,
and later localization. Never render subtitle text into the video pixels or package a second
captioned video variant.

Package the current `cover.png` for every published lesson and set it as that video's local `poster`
image. Use the cover in lesson navigation when the layout includes thumbnails, but do not duplicate
large decorative imagery around the player. A missing, stale, or unreferenced cover prevents a
finished release just like a missing video or caption track.

Place the current `course-cover.png` in the course landing or hero area with useful alternative text.
For each lesson player, use the local lesson cover with the native `poster` attribute, keep controls
enabled, set `preload="metadata"` or `preload="none"`, and do not autoplay. The poster must remain
visible before the learner chooses Play; do not replace it with a blank player, first video frame,
or a separately maintained CSS background. If a custom play button overlays the poster, give it an
accessible name and keep the native video as the playback source.

Use lesson covers as optional navigation thumbnails with stable 16:9 boxes and responsive sizing.
Because the canonical images already match the video ratio, avoid decorative cropping in the player;
thumbnail cards may use `object-fit: cover` only within the safe area defined by `cover-system.md`.
Do not rely on text inside an image as the only course or lesson label.

Treat completion and navigation as separate actions: marking a lesson complete updates progress but
does not navigate immediately. After completion, make the recommended next lesson the primary action.
When the next incomplete core lesson is a different eligible destination, also offer it as a secondary
shortcut for learners following only the required path. If both actions resolve to the same lesson,
render one action rather than two duplicate buttons. Derive both destinations from the dependency-valid
viewing order, never jump to an unpublished or locked lesson, and hide an action when no eligible target
exists. In learner-facing labels, call these destinations the next lesson and the next core lesson;
do not describe a lesson as the next course.

## Verify and hand off

Run the packaging script and test ZIP integrity. Inspect the archive listing and confirm that its
top-level folder contains `index.html`, course text, `course-cover.png`, and each video, caption
track, and lesson cover referenced by the HTML; there must be no absolute or network-dependent
media path. Open the extracted HTML as a local file when
the environment supports it, and check the unpublished/locked/completed behavior, compact lesson
metadata, conditional next-lesson navigation, native subtitle track, active-cue highlighting,
seeking, responsive transcript placement, manual-scroll behavior, one static post-lesson question
per published lesson, any authored visual descriptions beside the learner transcript, initial poster
display, and the absence of autoplay. A published narrated
lesson without a valid local caption track, cover, or post-lesson question prevents a finished
release; report it as a missing artifact.
For every configured learner document, verify that the current file is in the ZIP, its link opens
offline, and its tasks still provide the promised independent action, evidence, and self-check.
Report the number of published and unpublished lessons, the output paths, and any missing videos,
captions, covers, or translation gaps. If no formal videos exist, label the result a structural preview,
not a finished course release.

Only after the extracted release and ZIP pass these checks, call the packaged release recorder with
the generated directory and ZIP path. It fingerprints the complete release and archive, then sets
the separate course release state to `packaged`. Re-run the validator; never hand-edit release hashes
or infer packaged state from the existence of a ZIP.
