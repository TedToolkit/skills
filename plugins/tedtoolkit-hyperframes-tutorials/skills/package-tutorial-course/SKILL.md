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
lesson IDs, types, titles, and prerequisites; use `lessons/<id>/video.mp4` as the publication
artifact and effective `video-verified` state as the publication gate. Keep each lesson's stable ID
and the learner's local-progress storage key across rebuilds.

Run the packaged validator before building. Do not package while the graph is invalid, a required
artifact is stale, or a core lesson selected for release is below `video-verified`. An incomplete
extension may remain unpublished without blocking a complete core release.

Skill instructions being written in English do not require English learner content. Keep the
page, source text, and metadata in the course's chosen language. For a requested translation,
prepare and review localized source text and UI strings before building; do not silently translate
at package time or emit a mixed-language release. A locale setting must reflect the language of
the actual content, not merely alter the HTML `lang` attribute.

## Build the offline release

Prefer the course-local `tools/package-course.mjs`; invoke it from the course root. It must call
`tools/build-course-player.mjs` first so the page reflects current outline, text, and video
metadata, then collect learner-facing Markdown/plain text, referenced assets/examples, and formal
videos and caption tracks into a generated output directory and ZIP. If a different course lacks these scripts,
adapt or create project-local scripts for its real schema before packaging; do not assume that
one course's Chinese outline parser works for every course. Keep author-only demo clips and raw
production files out of the release unless the user explicitly wants them.

Treat a lesson without its formal video as `unpublished`, even when all prerequisites are complete.
It must not be clickable, playable, markable as completed, or counted as a completed prerequisite.
Previously stored completion for an unpublished lesson must not unlock descendants. A published
lesson whose prerequisites are incomplete remains locked. Keep the generated directory clearly
separate from authoring sources; never overwrite an unknown directory just because its path
matches the intended output.

Keep the player width available for learning content. Group the current lesson's status and duration
in one compact metadata row beside or directly below the lesson title; do not place them at opposite
edges of the content area. Let the group wrap as one unit on narrow screens instead of reserving a
second column or shrinking the video.

For every published narrated lesson, include `captions.vtt` as a local WebVTT track on the video and
use those same cues to render the learner transcript; do not create a second independently timed
subtitle source from `narration.txt`. On a sufficiently wide viewport, the transcript may occupy a
right-side panel while the video retains a useful viewing width. On smaller viewports, move it below
the video as a collapsible section. Highlight the active cue, keep it in view during playback, and
let a learner select a cue to seek the video. Do not fight deliberate manual scrolling: pause
auto-follow until the learner explicitly resumes it or selects or seeks to a cue. Keep native caption
controls available for learners who prefer subtitles over the transcript panel, but do not show both
the overlay captions and the transcript panel as duplicate text by default.

Package the clean `video.mp4` together with its sidecar `captions.vtt`. WebVTT is the canonical
course experience and supports switching, restyling, accessibility, synchronized transcript display,
and later localization. Never render subtitle text into the video pixels or package a second
captioned video variant.

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
top-level folder contains `index.html`, course text, and each video referenced by the HTML; there
must be no absolute or network-dependent media path. Open the extracted HTML as a local file when
the environment supports it, and check the unpublished/locked/completed behavior, compact lesson
metadata, conditional next-lesson navigation, native subtitle track, active-cue highlighting,
seeking, responsive transcript placement, and manual-scroll behavior. A published narrated lesson
without a valid local caption track prevents a finished release; report it as a missing artifact.
Report the number of published and unpublished lessons, the output paths, and any missing videos,
captions, or translation gaps. If no formal videos exist, label the result a structural preview,
not a finished course release.

Only after the extracted release and ZIP pass these checks, call the packaged release recorder with
the generated directory and ZIP path. It fingerprints the complete release and archive, then sets
the separate course release state to `packaged`. Re-run the validator; never hand-edit release hashes
or infer packaged state from the existence of a ZIP.
