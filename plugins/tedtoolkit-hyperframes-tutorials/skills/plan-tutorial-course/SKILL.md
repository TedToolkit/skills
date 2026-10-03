---
name: plan-tutorial-course
description: >-
  Plan the curriculum for a multi-chapter, multi-lesson animated video tutorial course.
  Use when the user needs the course outline, chapter and lesson sequence, learning goals,
  prerequisites, chapter learning levels, core and extension lesson types, non-linear content
  dependencies, lesson count, pacing, or coverage before scripting individual lessons. Do not use
  for a single lesson script, animation storyboard, or HyperFrames production.
---

# Plan Tutorial Course

Design the learning path for a whole course. This skill owns the course outline, not the spoken
script or finished video for any lesson. A standalone video begins with `design-tutorial`.
For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Also read the [course state contract](../../references/tutorial-course-state.md) before creating or
changing a file-based course. Resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) relative to this `SKILL.md`; a missing
linked resource is a stop condition.

## Establish the course boundary

Read the user's topic, audience, desired outcome, supplied source material, format, and constraints.
Record course-wide choices such as episode duration, target .NET or product version, required tools,
testing framework, assumed learner experience, and narration style so later lessons do not silently
replace them. Distinguish general programming experience from knowledge of the course's language.
Record the course's demonstration medium when specified: source files, rendered Markdown, an
editor or IDE, or another format. Decide which minimum setup and run actions learners need to
follow the examples; do not turn the presentation tool itself into a curriculum chapter unless
using that tool is an explicit learning outcome.
Record one course-wide visual mode for the lesson videos. Default to a light visual mode that
matches the course's light `index.html` output, and keep that mode consistent across every lesson;
do not let individual lessons independently switch to a dark theme. A user-supplied established
theme may override this default. Treat screenshots, IDEs, terminals, and other source evidence as
content that may retain its authentic appearance inside the course's light visual frame rather than
recoloring evidence solely for uniformity.
Record one course-wide production contract in `course.config.json`. Default lesson videos to 16:9,
1920x1080, 30 fps, MP4/H.264/yuv420p with AAC audio at 48 kHz, and default lesson covers to
1920x1080 PNG. Override dimensions or integer fps only for a stated delivery requirement. Keep the
video and cover aspect ratios equal, and never record a fixed total frame count; final duration and
fps determine it after narration and scene timing are complete.
Record any supplied brand constraints or cover direction as inputs for `create-tutorial-cover`, but
do not invent or render `cover-system.md`, `course-cover.png`, or lesson covers during curriculum
planning.
Inspect an existing outline before changing it. If a source is current or product-specific, verify
material claims against the supplied authoritative material or current official documentation;
mark unsupported assumptions and version-dependent steps. Clarify only a missing choice that would
materially change the curriculum.

Show the proposed scope and chapter structure before an open-ended course planning write. A direct
request to create or update the course outline authorizes that draft write at the selected location;
it does not authorize scripting or producing every lesson. Keep the user's requested depth and
chapter count when specified. Otherwise let the learning outcomes determine the structure. Use 3
to 8 chapters as a planning reference for a complete course, not as a quota. A short or narrowly
scoped course may use 1 or 2 chapters. When a draft exceeds 8 chapters, recheck for overly narrow
chapter boundaries, repeated outcomes, or a course scope that contains several independent parts.
When it exceeds 10 chapters, prefer a course series or clearly separated parts when the outcomes
support that split. Do not merge or invent chapters merely to reach these ranges; every chapter
must still own a meaningful exit capability and useful stopping point.

## Design the learning path

Work backward from what the learner should be able to do at the end. Before dividing the content
into chapters, write a course-level **observable learning outcomes overview** as a numbered list
with stable IDs such as `LO-01`. Each item states what the learner can do under what conditions and
what visible work or decision would demonstrate it. Use assessable actions rather than topic names
or vague verbs such as "understand." Keep the list at the level of meaningful course capabilities;
the individual lesson outcomes provide finer detail. Mark optional extension outcomes separately
so the main list describes what completing the core route actually achieves.

For each chapter, state its purpose, prerequisite knowledge, progression level, observable exit capability, and a useful
stopping point. Link each chapter's exit capability to the course outcome IDs it advances. For each
lesson, record a stable identifier, title, one observable learning outcome, the concepts or procedure
it must explain, a useful example or demonstration, its lesson type, its direct content
prerequisites, and exactly one learner-facing post-lesson question. Make the question a concise
recall, explanation, choice, prediction, or application prompt aligned to the lesson outcome, not a
confidence check such as "Do you understand?" Treat it as static text shown after the lesson video,
outside the narration, storyboard, captions, and video duration. It does not require an input,
submission, answer reveal, scoring, or completion gate. Give a rough duration only as an estimate;
actual timing will come from the generated narration audio later. Derive a valid viewing order from the
dependency graph after the content relationships are designed; do not use list position as a
substitute for prerequisites. Avoid repeating a full explanation across lessons without a reason.

### Classify progression and learning paths

Classify chapters and lessons on two independent axes: every chapter has one progression level, and
every lesson has one lesson type. Use the canonical chapter levels below internally, while giving
them domain-appropriate display names in the course outline:

- `L1 foundation`: understand or reproduce one core concept or procedure under stated conditions,
  including a minimal working example and the most basic failure case.
- `L2 application`: combine prior concepts to complete a useful task independently, handle common
  failures or boundaries, choose among known techniques under clear conditions, and verify the result.
- `L3 advanced judgment`: diagnose an unfamiliar or ambiguous problem, compare credible solutions,
  explain tradeoffs, or extend a design under new constraints, including when not to use an advanced
  technique.

Assign a chapter's level from the highest capability required by its exit capability, not from how
sophisticated its topic name sounds or where the chapter happens to appear. All lessons in that
chapter inherit the chapter level; do not assign L1, L2, or L3 independently to lessons. If one
lesson would require a materially different level, move it to a suitable chapter or revise the
chapter boundary. Interpret levels relative to the stated course entry profile rather than as an
absolute industry rating. Default to considering all three levels, but collapse unused levels
instead of inventing chapters to fill them. A short or narrowly scoped course may legitimately use
only one or two levels, and several chapters may share the same level.

Classify every lesson with one of these lesson types:

- `core`: required for the course's promised outcome.
- `extension`: an optional application, comparison, edge case, transfer exercise, or deeper treatment
  that does not unlock required core content.

Record the canonical level once on the chapter and exactly one lesson type on every lesson. Do not
add subtypes or parallel classifications beneath `extension`; express its specific purpose through
the title, outcome, and example. Every chapter must contain at least one core lesson. Add extension
lessons only when they provide a meaningful optional way to apply, compare, transfer, or deepen the
core route; do not add a decorative extension merely to create a type mix. Prefer 5 to 12 lessons
per chapter as a planning reference, not a quota. A coherent short chapter may contain fewer, and a
substantial chapter may contain more. A chapter may contain up to 20 lessons. Do not split a
coherent chapter merely to force a small uniform lesson count, but split it at a real capability
boundary before it exceeds 20. Do not create a one-lesson chapter solely for a course introduction;
keep a standalone introduction outside the chapter taxonomy or place it in an opening chapter with
a real exit capability.

For each level actually used, summarize the chapters at that level, its entry capability, observable
exit capability, required lesson and duration totals, optional paths, and a valid stopping point where
the learner has achieved something complete. Do not impose fixed lesson-count ratios, but revisit a
chapter level when its exit capability cannot be demonstrated.

When the output format supports emoji, use them consistently in titles as visual wayfinding rather
than decoration. Default to `🌱 L1 foundation`, `🛠️ L2 application`, and `🧭 L3 advanced judgment` for
chapter level labels and `📌 core` and `✨ extension` for lesson types. Prefix chapter titles or
compact lesson-type labels when it improves a long outline. Keep the canonical identifier and a
text label beside every emoji, use no more than one semantic emoji prefix per title, and never make
color or emoji the only carrier of meaning. Preserve this mapping throughout one course unless the
user supplies an established visual vocabulary.

### Design content dependencies as a graph

Design lesson dependencies from required knowledge, decisions, or artifacts, not from chapter order,
lesson numbering, or a desire to connect every adjacent pair. For every dependency edge, record the
specific capability or artifact the prerequisite supplies. Add only direct prerequisites: if A
enables B and B enables C, do not also add A to C unless C uses A independently of B.

The lesson graph must be a directed acyclic graph rather than a disguised chain. Expose genuinely
independent topics as parallel roots or branches, and show where branches converge in an integrative
lesson. A substantial course should normally contain multiple valid learning routes, at least one
meaningful fork, and at least one later convergence. If the draft gives nearly every lesson exactly
one predecessor and one successor, revisit the content decomposition and remove sequencing-only
edges. Do not invent false dependencies or artificial branches merely to make the diagram look
complex.

Apply these invariants:

- A core lesson may depend only on course-entry assumptions or other core lessons. If an extension
  is required to unlock core content, reclassify it as core.
- An extension may depend on core lessons and other directly prerequisite extensions, but optional
  branches must remain independently skippable and must never become hidden prerequisites of core
  content.
- Cross-chapter edges are allowed when the later lesson truly consumes an earlier capability or
  artifact. A chapter may therefore have several entry lessons rather than one mandatory first lesson.
- Required edges must not point from a lower-level chapter to a higher-level prerequisite. If they do,
  revise the chapter level or boundary. Chapters at the same level may branch and converge freely.
- The graph must be acyclic, every referenced lesson ID must exist, and every promised outcome must be
  reachable through core lessons without silently taking an extension.

Audit the graph for cycles, missing prerequisites, hidden optional-to-core dependencies, redundant
transitive edges, and accidental linearity. Present both a dependency table (`lesson`, `requires`,
`reason`) and a graph or grouped dependency waves when the output format permits it. Treat a
topological viewing order as one valid route through the graph, not as the dependency model itself.

Plan every lesson, including a separately counted course introduction, for an estimated video
duration of 5 to 10 minutes. Treat this range as a course-design constraint, not a target to reach
with filler. When a topic cannot be explained and demonstrated clearly within 10 minutes, divide it
into more lessons with distinct outcomes instead of rushing or omitting prerequisites. When a
lesson would take less than 5 minutes, combine it with closely related content or add only an
essential demonstration, check, or explanation; do not pad it. Count the resulting lessons by
chapter and for the whole course. A brief overview may introduce an idea early, but schedule its
full mechanism after the concepts needed to understand it. Separate estimated video time from
exercises the learner completes afterward.

When the user requests a course introduction, plan it as a short, separately counted lesson that
answers the course purpose, intended learners, prerequisites, reason for the approach, learning
path, and realistic outcome. Hand its synthesis-ready narration brief to `design-tutorial`. Keep the
introduction aligned with the course-wide episode duration and teaching premise. Do not let it
create a chapter that violates the mixed lesson-type rule.

Keep the course scope coherent. Distinguish required lessons from optional deep dives when that
helps. Include a course-level coverage check: every promised outcome has a lesson, every lesson
contributes to an outcome, and dependencies are satisfiable in at least one topological order.
For each course outcome ID, identify the core lesson or lessons that provide its observable evidence;
flag an outcome that exists only in extension lessons or has no demonstrable evidence. A core lesson
may support more than one outcome, and an outcome may require several core lessons.
Record source gaps or uncertain product behavior as questions, not invented instruction.

When the user wants paradigms, principles, design patterns, or code smells taught through practice,
map each selected idea to the first real change or failure that makes it useful. Keep the course
sequence problem-driven: show the existing approach, the new pressure, a verifiable improvement,
and the cost or case where the named solution is unnecessary. Do not create a catalog chapter merely
to cover names. Check that the chosen terminology stays consistent across the outline and visual
assets. A pattern catalog can inform candidate coverage, but only schedule a lesson when the
example and prerequisites make its use credible within the episode duration.

When a recurring case ties the course together, keep its domain knowledge within the audience's
stated prerequisites. Introduce every case rule before using it to justify a technical choice.
Use tiny examples for mechanisms, chapter snapshots for evolving code, and isolated comparison
implementations for alternative designs when one continually expanding codebase would obscure
the lesson. Do not force a pattern or architecture into the main example solely for coverage.

## Deliver and hand off

Return a readable outline or save it as Markdown in the user-selected project. Include the audience,
course outcome, the numbered observable learning outcomes overview near the beginning,
prerequisites, course-wide tool and pacing choices, chapter and lesson map with counts, chapter-level
progression summary, lesson-type mix per chapter, required core path, optional
extensions, level and lesson-type duration totals, dependency table and graph or dependency waves,
outcome-to-core-lesson coverage, the course-wide visual mode, dependency audit, and unresolved
questions. Do not write full
narration, precise timestamps, or animation specifications here. Identify the first dependency-ready
core lessons for `design-tutorial` and pass along each outcome, scope, and source
references; there may be more than one valid starting lesson.

For a file-based course, give each lesson a stable `lessons/<lesson-id>/` directory. The canonical
course cover artifacts are root `cover-system.md` and `course-cover.png`; canonical per-lesson
artifacts are `lesson.md`, `narration.txt`, `narration.wav`, `storyboard.md`,
`video.mp4`, `captions.vtt`, and `cover.png`; create each only when its workflow stage produces real
content. `narration.wav` is generated directly from the approved script and saved Fish voice ID. Do not
create a canonical `demo.md`: record demonstration source paths in `lesson.md`, keep runnable or
substantial evidence in its actual project or asset file, and let `storyboard.md` own short exact
on-screen text and the choice of what source range or state to show.

Create or update `course.config.json` and `course-state.json` with the outline. Include the explicit
`video` and `cover` production objects from the shared course state contract for new courses;
preserve compatible intentional overrides in existing courses. Initialize every new
lesson as `planned`, preserve existing records for unchanged lesson IDs, and keep `type`, direct
`requires`, and course-root-relative `sourcePaths` synchronized with the approved outline and lesson
cards. When a change makes an existing stage record stale, leave its recorded evidence intact for
the validator to diagnose; the owning stage recorder will replace that record and remove later ones
after re-verification. Never manufacture, delete, or edit approval and fingerprint records by hand.

The course outline remains the human-readable sequence index; `course-state.json` is the
machine-readable dependency and production-status source. A lesson card records its title, outcome, example,
prerequisites, inherited chapter level, lesson type, estimated duration, post-lesson question, and
demonstration sources. Create cards when the user
requests a navigable per-lesson workspace. Do not create empty narration, audio, storyboard,
caption, video, or cover placeholders. Keep any course-wide voice and audience brief outside the
read-aloud text.
Run the packaged validator after writing the outline and initial state; a planned course should pass
its configuration, identity, dependency-graph, path, and state-shape checks before handoff.
