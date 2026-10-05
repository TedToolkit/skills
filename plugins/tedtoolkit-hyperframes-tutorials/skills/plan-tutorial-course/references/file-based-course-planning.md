# File-based course planning

Read this reference only when creating or changing a file-based tutorial course. Follow the shared
[tutorial workspace contract](../../../references/tutorial-workspace-layout.md) and
[course state contract](../../../references/tutorial-course-state.md). Resolve the packaged
[`validate-course.mjs`](../../../scripts/validate-course.mjs) relative to the loaded skill; a missing
linked resource is a stop condition.

## Read and preserve course-wide state

Record one course-wide visual mode for the lesson videos. Default to a light visual mode that
matches the course's light `index.html` output, and keep it consistent across every lesson. A
user-supplied established theme may override this default. Screenshots, IDEs, terminals, and other
source evidence may retain their authentic appearance inside the course's visual frame.
Record supplied brand assets, visual constraints, and references for later video design. Do not
invent a detailed lesson-video style while planning the curriculum: `design-tutorial` develops the
course's `video-style.md` with actual shot previews. See the shared
[video style contract](../../../references/tutorial-video-style.md).

Record one course-wide production contract in `course.config.json`. Default lesson videos to 16:9,
1920x1080, 30 fps, MP4/H.264/yuv420p with AAC audio at 48 kHz, and lesson covers to 1920x1080 PNG.
Override dimensions or integer fps only for a stated delivery requirement. Keep video and cover
aspect ratios equal, and derive total frames from final duration and fps. Record supplied brand or
cover direction for `create-tutorial-cover`; do not create cover artifacts during curriculum
planning.

When the course belongs to a series, read the series README before the course README and outline.
Inherit shared audience assumptions, terminology, teaching conventions, case rules, and viewing
expectations. Keep the course README as a link plus its course-specific promise, prerequisites,
routes, choices, and explicit exceptions. An exception names the shared rule it changes.

## Write the planning workspace

Create or update the root course README as the learner-facing entry. A standalone course README is
self-contained. A course in a series links to the series README and does not restate inherited
common sections.

Give each lesson a stable `lessons/<lesson-id>/` directory. Canonical course-cover artifacts are
root `cover-system.md` and `course-cover.png`; canonical lesson artifacts are `lesson.md`,
`narration.txt`, `narration.wav`, `storyboard.md`, `video.mp4`, `captions.vtt`, and `cover.png`.
Create an artifact only when its owning workflow produces real content. Do not create a canonical
`demo.md`: record demonstration source paths in `lesson.md`, keep substantial evidence in its actual
project or asset file, and let `storyboard.md` own short exact on-screen text and source ranges.

When following a lesson requires setup, put the required demonstration in the video route. In a
video-led course, reserve `00.01+` lesson IDs for distinct preparation videos that learners must
watch before the first subject lesson; teach later tool setup at first use or in a dedicated subject
lesson immediately before that tool appears. Put each preparation video in
its own `lessons/<lesson-id>/` directory, mark required ones Core, and include them in the outline,
preferred viewing order, lesson counts, and estimated duration. The course README and optional
learner-facing setup document may provide searchable steps and current links; if present, list the
document in `course.config.json` `learnerDocuments` for packaging. Neither document substitutes
for the video. State the first lesson that needs the setup, the readiness check and expected result,
and the failure path. Keep operational readiness distinct from content prerequisites in the graph,
and give the first tool-using lesson a direct `requires` edge to the preparation video when it
consumes the verified readiness result. Keep that edge and the required Core video in
`course-state.json` so the player cannot skip the preparation and unlock tool use.

Represent each `00.01+` video as an actual row in the readable outline's opening lesson table,
with the same lesson fields as ordinary lessons. A heading or setup checklist without that row is
incomplete. Keep the row, `course-state.json` identity and direct prerequisites, and course totals
consistent.

Create or update `course.config.json` and `course-state.json` with the outline. Include the explicit
`video` and `cover` production objects from the course state contract for new courses, while
preserving compatible intentional overrides in existing courses. Initialize new lessons as
`planned`; preserve existing records for unchanged lesson IDs; and keep `type`, direct `requires`,
and course-root-relative `sourcePaths` synchronized with the approved outline and lesson cards.
When a change makes a stage record stale, preserve its evidence for the validator to diagnose. Let
the owning stage recorder replace it after re-verification; never hand-edit approval or fingerprint
records.

The outline is the readable sequence index; `course-state.json` is the machine-readable dependency
and production-status source. A lesson card records its title, outcome, example, prerequisites,
inherited chapter level, lesson type, estimated duration, post-lesson question, and demonstration
sources. Create lesson cards only when the user requests a navigable per-lesson workspace. Keep
course-wide voice and audience briefs outside the read-aloud text.

For a new course, write one learner-facing `practice.md` with every chapter Core-route checkpoint
and the final Core completion task. Give each task its outcome IDs, inputs or constraints, action,
expected evidence, acceptance conditions, and self-check guidance for likely errors. Keep authoring
rationale in the outline. Link `practice.md` from the course README and list it in
`course.config.json` as `"learnerDocuments": ["practice.md"]`; preserve any existing learner
documents in that array. For an existing course that already has a learner-facing practice document,
reuse its path rather than duplicating tasks. The packaging workflow must copy and link every listed
document. These tasks are curriculum evidence, not lesson production states; do not add them to
`course-state.json` or turn a static post-lesson question into a scored gate.

Run the packaged validator after writing the outline and initial state. A planned course must pass
configuration, identity, dependency-graph, path, and state-shape checks before handoff.
