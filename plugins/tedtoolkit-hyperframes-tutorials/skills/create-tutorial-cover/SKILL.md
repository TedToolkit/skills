---
name: create-tutorial-cover
description: >-
  Design and maintain a coherent cover system for an animated tutorial course, including the
  course cover and lesson-level video covers created from verified lesson content. Use when the
  user wants a course cover, thumbnail, poster image, video cover, series-wide cover consistency,
  or a refreshed cover. Do not use to design the lesson storyboard or render the video.
---

# Create Tutorial Cover

Create one recognizable cover family, anchored by the course cover and applied to every lesson
cover. Verify each image at both full size and thumbnail size. This skill owns the course cover
system and publication covers; it does not change a video master.

## Gate the current turn

Before designing or writing anything, classify the current request:

- **Read-only:** inspect, summarize, explain, review, plan, propose a next action, or report the
  resolved scope before creation.
- **Write-authorized:** create, generate, revise, or replace a named course or lesson cover now.

For a read-only request, inspect the course, report the resolved scope, and stop. Do not create
concept previews, `cover-system.md`, `course-cover.png`, lesson covers, editable sources, or any
other supporting artifact; do not continue into the design, rendering, or verification workflow
below. Naming this skill or referring to "the current course" is not itself write authorization.
Creation authorization from an earlier turn does not override an explicit read-only boundary in the
current turn.

For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md) and read the
[course state contract](../../references/tutorial-course-state.md). Resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md`.

When the current request designs, compares, reviews, or revises a visual direction, read the
[cover design principles](references/cover-design-principles.md) before proposing concepts or
judging a cover. A scope, status, path, or production-state report that makes no design judgment
does not need that reference. A missing linked reference is a stop condition.

## Discover the current course before asking

When the current directory or one of its parents contains `course.config.json`, treat that file as
the current course unless the user names a different course. Resolve the course root first, then
read the configured title and outline, the audience and observable outcome, any existing
`cover-system.md`, `video-style.md` when present, the established course and video style, and
relevant brand, logo, font, or iconography assets. Use `README.md` and focused style or asset
documents when present; do not ask
the user to repeat a course name, directory, audience, outcome, visual mode, or production setting
that the workspace answers reliably.

Ask only for a missing preference that would materially change the cover and cannot be inferred
from the course. An established current course is sufficient scope for a request such as "create
this course's cover." If the user leaves an aesthetic choice open, propose or choose a direction as
described below instead of returning a generic intake checklist.

For a read-only scope report, summarize the resolved course title, audience and outcome, effective
cover dimensions, aspect ratio and format, established visual inputs, any genuinely missing choice,
and the next design action. The artifact instructions below apply only after the current turn passes
the write-authorization gate.

## Choose the cover scope

For a write-authorized course cover or first cover in a series, read the course outline, audience,
observable course outcome, established visual mode, and production settings. Create or update these
canonical files:

- `cover-system.md`: the reusable course cover contract.
- `course-cover.png`: the overall course cover and visual anchor.

For a lesson cover, run the course validator and require effective `video-verified` state. Read the
lesson title and outcome from `lesson.md`, inspect `storyboard.md`, and inspect the formal
`video.mp4` at several representative frames. Require the current `cover-system.md` and
`course-cover.png`; if this is the first cover and they do not exist, create the system and course
cover before the lesson cover. Do not silently redesign an established system for one lesson.

Use the final video as the lesson cover's visual source of truth. Do not create a lesson cover from
an unverified preview or imply a feature, interface, result, or visual that the lesson does not
actually contain. A course cover may synthesize the course's promised outcome, but it must not imply
content absent from the approved outline.

Read the `cover` and `video` production settings from `course.config.json`. When an older course
omits them, use the backward-compatible defaults directly: a `1920x1080`, `16:9`, PNG course and
lesson cover matching the default video aspect ratio. Do not modify `course.config.json` merely to
materialize those defaults. The canonical course cover is `course-cover.png`; the canonical lesson
cover is `lessons/<lesson-id>/cover.png`. Both use the effective configured or default cover
dimensions. A direct request to create or revise this named cover authorizes edits to the relevant
local cover and its cover contract after the gate above passes. It never overrides a read-only
current turn. Do not upload or publish them without separate authorization.

Treat the canonical cover as the course master, not as every publication destination's upload
asset. Do not change the canonical course aspect ratio or production contract merely to satisfy one
platform. When the user names YouTube, Bilibili, or another destination, verify that destination's
current official requirements at the time of export because platform dimensions and crops change.
Create a separate derivative only when the user requests that destination deliverable, and keep it
distinct from the canonical cover. Record the required crop and safe-area behavior in
`cover-system.md`; do not encode a platform pixel size as permanent course truth.

## Define continuity explicitly

Derive its shared identity from `video-style.md`, its linked series visual system when present, and
verified lesson frames when available. Adapt
that identity for a thumbnail's different reading size and composition; do not make an unrelated
cover style or force the video to imitate the cover layout.
Write `cover-system.md` before producing a cover family. Record only decisions that another cover
can reproduce:

- canvas dimensions, aspect ratio, outer safe area, grid, and thumbnail crop behavior;
- course mark, logo, chapter badge, and title positions;
- typefaces, weights, title size range, maximum title lines, text alignment, and the display-headline
  policy for each named publication destination;
- base palette, contrast rules, chapter accent mapping, and background treatment;
- recurring frame, shape, texture, illustration, or screenshot treatment;
- which elements are fixed across the series and which may vary by lesson;
- one course-cover composition and one lesson-cover composition;
- prohibited treatments that would break recognition or misrepresent the lesson.

Keep the invariant visual grammar stronger than the lesson variation. The course cover uses the
course title and broad course subject. A lesson cover keeps a compact course mark, uses the lesson
title and chapter marker, and introduces one lesson-specific focal visual grounded in that lesson's
verified video. Do not force every cover to reuse the same screenshot or become indistinguishable.

## Design the cover

Prefer evidence and established identity in this order: existing brand and course assets; verified
lesson frames or course teaching elements; a new vector or typographic composition consistent with
the course; generated illustration only when the user requests it or the established visual mode
calls for it. Inspect available logos, fonts, iconography, palettes, and layout rules before invoking
an image generator. Do not use generated art merely because the final deliverable is an image.

For a lesson, start from a strong representative video frame when it remains legible after cropping
and title treatment. Recompose verified lesson elements when a raw frame is too busy, but preserve
the course cover system, visual mode, palette, typography, and recognizable teaching subject. Use
generated illustration only when the user requests it or the established course style calls for it;
treat generated art as presentation rather than evidence.

Treat the publication title and cover text as complementary. Default to at most one display headline
and no other informational copy. A text-free cover is valid when the focal visual plus the adjacent
publication title already identifies the lesson. Use the official course or lesson title when it is
already short; when it is too long for thumbnail reading, derive a shorter truthful display headline
from the title and observable outcome. Record the mapping in `cover-system.md`. If the user has
delegated the design choice, choose the strongest truthful wording; otherwise include the display
headline in the concept approval. Do not place paragraphs, dense code, subtitles, episode metadata,
or decorative UI chrome on the cover.

For a Bilibili-bound cover, optimize for the mobile information feed rather than a full-size poster:

- when text is used, use one short Chinese display headline, preferably `4–10` Han characters and
  normally no more than `15` full-width-character equivalents; count a compact Latin or code token
  such as `pH` or `ISO 400` as one semantic unit rather than splitting it;
- use at most two lines and one to three emphasized semantic chunks; remove subtitles and low-value
  badges before reducing the headline;
- give the headline a bold or heavy, high-contrast face and enough visual scale that its Han-character
  height is roughly `28–40` pixels in a `320`-pixel-wide preview; treat this as a working range, not a
  substitute for visual inspection;
- let the adjacent Bilibili video title carry detail that the image omits. Do not repeat the entire
  publication title on the image merely because space remains.

For other destinations, use the same low-copy bias unless an established cover system or explicit
platform need justifies more. Keep the primary subject readable at thumbnail size, and keep important
text, faces, and focal objects away from the outer edges so common player crops do not remove them.
Preserve sufficient contrast without misleading clickbait, fabricated results, or unrelated stock
imagery.

When the direction is not already established, present a small number of meaningfully different
course-cover concepts rather than many cosmetic variants. Keep concept previews outside the
canonical paths: do not overwrite `course-cover.png` or finalize `cover-system.md` until a direction
is selected. If the user delegates the design choice, select the strongest concept and continue;
otherwise present the previews and wait for the user's selection. Then establish the selected
system before producing lesson covers. Preserve the approved system across lessons; vary the
lesson-specific subject and title instead of redesigning the series each time.

## Verify and deliver

Inspect every cover at its configured dimensions and at a 320-pixel-wide thumbnail. For a Bilibili
destination, also inspect it at 160 pixels wide as a mobile-feed stress test. Check title accuracy,
spelling, contrast, safe margins, focal clarity, and whether the image remains identifiable without
tiny details. At 160 pixels, a viewer should be able to read the display headline and identify the
primary subject at a glance without zooming. If this fails, shorten the wording first, then enlarge
or recompose it; do not squeeze a long title into smaller type. Compare the course cover and all
existing lesson covers together as a contact sheet; check fixed-element alignment, typography,
recurring treatment, chapter accents, and enough lesson-specific differentiation. For every
requested publication destination, also inspect the current destination crop or aspect-ratio preview
and confirm that essential text, marks, faces, and focal objects remain inside its safe area. Confirm
that the PNG dimensions match the effective configured or default production settings, the course
cover matches the current outline, and every lesson cover represents its current `video.mp4`.

After a lesson cover and its shared system pass these checks, record `cover-verified` with the
packaged recorder and re-run the validator. Deliver the cover paths and briefly identify the frame
or verified lesson elements used. A course-cover or cover-system revision requires affected lesson
covers to be rechecked and invalidates the packaged release, but it must not require re-rendering an
unchanged verified video.
