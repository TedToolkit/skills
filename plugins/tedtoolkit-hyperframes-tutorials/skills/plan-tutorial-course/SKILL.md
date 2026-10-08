---
name: plan-tutorial-course
description: >-
  Plan the curriculum for a multi-chapter, multi-lesson animated video tutorial course.
  Use when the user needs the course outline, chapter and lesson sequence, learning goals,
  the Core completion outcome, optional Extension route outcomes, the required 00.00 course guide,
  00.01 and later preparation videos, prerequisites, chapter learning levels, core and extension
  lesson types, non-linear content
  dependencies, lesson count, pacing, or coverage before scripting individual lessons. Do not use
  for a single lesson script, animation storyboard, or HyperFrames production.
---

# Plan Tutorial Course

Design the learning path for a whole course. This skill owns the course outline, not the spoken
script or finished video for any lesson. A standalone video begins with `outline-tutorial-lesson`.
When the request concerns the number or boundaries of several independently publishable courses,
series-wide graduation and extension routes, or cross-course prerequisites, use
`plan-tutorial-series` first and treat its approved course brief as this skill's boundary.
When creating or changing a file-based course, read the
[file-based course planning reference](references/file-based-course-planning.md) before writing. A
missing linked resource is a stop condition.

## Establish the course boundary

Read the user's topic, audience, desired outcome, supplied source material, format, and constraints.
Record course-wide choices such as episode duration, relevant product or equipment version, required
tools, verification method, assumed learner experience, and narration style so later lessons do not
silently replace them. Distinguish related prior experience from knowledge of this course's subject.
Record the course's demonstration medium when specified: physical materials, an application,
source files, rendered documents, or another format. Decide which minimum setup and operating actions learners need to
follow the examples. In a video-led course, the required viewing route must teach and visibly
demonstrate each action learners need before they can follow a later video. A linked document alone
does not satisfy this requirement.

Separate entry knowledge from operational readiness. For each required tool or account, identify
the first lesson that needs it, a learner-visible readiness check and expected result, where to
find setup and troubleshooting help, and the route from the course entry to that help. In a
video-led course, put actions learners must complete before the first subject lesson in required
`00.01+` preparation videos after the guide. A tool introduced later may be prepared in its first
teaching lesson when that is part of the lesson outcome; otherwise plan a dedicated lesson at its
point of use. Give each preparation video an observable operational outcome:
the learner can install or access the tool, run the readiness check, recognize success, and know
what to do when it fails. Keep operating-system details and changing links in a companion reference
when useful, but make the video complete enough for a viewer to discover and perform the prerequisite.
Reserve `00.01`, `00.02`, and later `00.xx` IDs for distinct course-opening preparation videos.
Count each required one as Core outside the subject chapters, and make the first lesson that needs
its result depend directly on it. Account for those videos in Core lesson and duration totals and
both recommended viewing routes. Do not create a new video merely for a second operating system:
show the relevant choice and a common success check in the same preparation lesson when that keeps
the route clear.
Do not create an installation lesson for a tool that learners never need to operate.

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
When it exceeds 10 chapters, consider whether the outcomes support independently publishable
courses. Route that portfolio decision to `plan-tutorial-series`; do not split the course by topic
count alone. Do not merge or invent chapters merely to reach these ranges; every chapter must still
own a meaningful exit capability and useful stopping point.

## Design the learning path

Work backward from what the learner should be able to do at the end. Before dividing the content
into chapters, write a course-level **observable learning outcomes overview** as a numbered list
with stable IDs such as `LO-01`. Each item states what the learner can do under what conditions and
what visible work or decision would demonstrate it. Use assessable actions rather than topic names
or vague verbs such as "understand." Keep the list at the level of meaningful course capabilities;
the individual lesson outcomes provide finer detail. Mark optional extension outcomes separately
so the main list describes what completing the core route actually achieves.

Before listing chapters, define one learner-facing course-completion contract:

- **Core completion outcome:** what a learner can do after the required Core route, under what
  conditions, and which finished artifact, demonstration, diagnosis, comparison, or decision proves
  it. This is the course's completion promise, not a list of topics watched.
- **Extension route outcomes:** what additional transfer, depth, edge-case handling, comparison, or
  judgment a learner can demonstrate after each named optional Extension route, plus the evidence
  that proves it. When extensions form independent branches, describe their gains separately rather
  than implying that course completion requires every optional lesson. When the course has no
  meaningful Extension outcome, state that it has no Extension route instead of inventing optional
  lessons.

Keep the completion contract concise enough to appear near the beginning of the course outline and
learner page. Every course-completion capability must be reachable through Core lessons only. Every
optional capability must identify the Extension route that develops it. State important exclusions
so the contract does not promise professional mastery, unrelated tools, or production contexts the
course does not cover.

For each chapter, state its purpose, prerequisite knowledge, progression level, observable exit
capability, and a useful stopping point. Link its exit capability to the course outcome IDs it
advances. For each chapter's Core route, define a practice checkpoint with given inputs or
constraints, an independent learner action, observable evidence, acceptance conditions, and
learner-facing self-check guidance that explains how to diagnose a likely error. Include a small
transfer or failure variant when the chapter promises application or judgment. Define a final Core
completion task that combines the required outcomes without relying on an Extension lesson: give
its inputs, independent action, finished evidence, acceptance conditions, and self-check guidance.
Map each task to the outcome IDs it demonstrates. Keep these tasks separate from the static
post-lesson questions; they do not add player completion gates or automatic scoring. Do not reveal
the result before the learner has had a chance to attempt the task.

For each lesson, record a stable identifier, title, one observable learning outcome, the concepts or
procedure it must explain, a useful example or demonstration, its lesson type, its direct content
prerequisites, and exactly one learner-facing post-lesson question. Make the question a concise
recall, explanation, choice, prediction, or application prompt aligned to the lesson outcome, not a
confidence check such as "Do you understand?" Treat it as static text shown after the lesson video,
outside the narration, storyboard, captions, and video duration. It does not require an input,
submission, answer reveal, scoring, or completion gate. Give a rough duration only as an estimate;
actual timing will come from the generated narration audio later. Derive a valid viewing order from the
dependency graph after the content relationships are designed; do not use list position as a
substitute for prerequisites. Avoid repeating a full explanation across lessons without a reason.
Match each question's demand to the lesson outcome: recall can establish new vocabulary, while a
procedural or judgment lesson should usually ask for a prediction, choice, or explanation about a
small change in the taught example. Revise a question that can be answered by repeating labels
while missing the lesson's main capability.

Keep the dependency graph and recommended routes in the planning and navigation artifacts, not in
the teaching content of individual videos. Plan each lesson as a complete unit for its own promised
outcome: its opening establishes the local question and any necessary starting state, its example
supplies the evidence, and its ending resolves that question. A real prerequisite remains in the
graph, but the lesson must not rely on phrases such as "as we learned last time," a named previous
video, or a promised next video to make its explanation work. Reuse a concept or case when useful by
briefly supplying the exact context needed here; do not retell another lesson or assume its final
screen is still visible. Keep lesson IDs, watch-next suggestions, and branch choices in the course
page or lesson card. A learner should be able to open a lesson directly and understand its question,
required starting conditions, and result without knowing which videos were watched before it. If
the needed background is too large for a brief local reminder, state the required capability and
let the learner page route to its prerequisite; do not turn this video into a recap.

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

- `core`: the required main route for a learner whose goal is to complete the course successfully.
  It contains only the knowledge and practice needed to achieve the course's promised outcome at a
  competent passing standard.
- `extension`: an optional branch for a learner who wants to go beyond course completion. It adds application,
  comparison, edge cases, transfer, greater depth, or stronger judgment without unlocking required
  core content.

Design the core route as the shortest coherent path that still delivers every promised core outcome
and enough practice and evidence to meet that passing standard; short must not mean incomplete or
superficial. Prefer a compact main route with several meaningful extension branches so learners can
finish the essentials without being forced through every enrichment topic, while ambitious learners
have many ways to go further. Treat this as a curriculum-shaping preference rather than a fixed
core-to-extension ratio: each extension must still earn its place through a distinct outcome,
example, or decision that deepens or broadens the core route.

Audit narrative continuity in two projections, not only dependency validity:

- **Core-only route:** remove every extension lesson and read the remaining preferred route from
  beginning to end. It must still introduce every concept, case state, artifact, and transition before
  use, deliver a complete learning arc, and reach the course-completion outcome without gaps or
  references to skipped material.
- **Comprehensive route:** place every extension after its real prerequisites and derive at least one
  recommended route containing all core and extension lessons. That route must also read as one
  logically ordered course: extensions deepen an established idea at the point they are useful,
  while later lessons do not repeat, contradict, reset without explanation, or assume a different
  case state. Express branch transitions in navigation rather than narration. Apply the same check
  to each named Extension route when extensions form independent branches.

Reorder, bridge, or revise lessons when either projection is only a valid topological order but not a
coherent learning experience. Do not repair the Core-only route by summarizing a skipped extension or
repair the comprehensive route by teaching the same prerequisite twice.

Record the canonical level once on the chapter and exactly one lesson type on every lesson. Do not
add subtypes or parallel classifications beneath `extension`; express its specific purpose through
the title, outcome, and example. Every chapter must contain at least one core lesson. Add extension
lessons only when they provide a meaningful optional way to apply, compare, transfer, or deepen the
core route; do not add a decorative extension merely to create a type mix. Prefer 5 to 12 lessons
per chapter as a planning reference, not a quota. A coherent short chapter may contain fewer, and a
substantial chapter may contain more. A chapter may contain up to 20 lessons. Do not split a
coherent chapter merely to force a small uniform lesson count, but split it at a real capability
boundary before it exceeds 20. Do not create a one-lesson chapter for the course guide or
preparation; keep `00.00` and any `00.01+` preparation lessons outside the chapter taxonomy.

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

### Design lesson dependencies as a graph

Design lesson dependencies from required knowledge, decisions, artifacts, or verified operational
readiness taught by a required video, not from chapter order, lesson numbering, or a desire to
connect every adjacent pair. For every dependency edge, record the specific capability, readiness
result, or artifact the prerequisite supplies. Add only direct prerequisites: if A
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
- The graph must be acyclic, every referenced lesson ID must exist, and every required course
  outcome must be reachable through Core lessons without silently taking an Extension. Every
  optional outcome must be reachable through its named Extension route.
- The Core-only projection and at least one all-lessons projection must each have a documented,
  logically coherent preferred viewing order; dependency validity alone is insufficient.

Audit the graph for cycles, missing prerequisites, hidden optional-to-core dependencies, redundant
transitive edges, and accidental linearity. Present both a dependency table (`lesson`, `requires`,
`reason`) and a graph or grouped dependency waves when the output format permits it. Treat a
topological viewing order as one valid route through the graph, not as the dependency model itself.

Plan ordinary lessons for an estimated video duration of 5 to 10 minutes. Treat this range as a
course-design constraint, not a target to reach with filler. When a topic cannot be explained and
demonstrated clearly within 10 minutes, divide it into more lessons with distinct outcomes instead
of rushing or omitting prerequisites. When an ordinary lesson would take less than 5 minutes,
combine it with closely related content or add only an essential demonstration, check, or
explanation; do not pad it. Count the resulting lessons by chapter and for the whole course. A brief
overview may introduce an idea early, but schedule its full mechanism after the concepts needed to
understand it. Separate estimated video time from exercises the learner completes afterward.
Check each outline's duration against the full planned teaching work, including explanation,
demonstration, inspection, and useful pauses. Resolve a mismatch in the course plan before approving
the outline; do not assume script writing will compress the lesson into its allotted time.

### Plan the `00.xx` course opening

Every course begins with a separately counted `00.00` course-guide lesson. The course landing page
may repeat its completion contract and route summary for reference, but it never replaces this
lesson. Keep `00.00` outside the chapter taxonomy and record it as a core lesson with no lesson prerequisites.
Place it first in the preferred viewing order. Later domain lessons do not need a dependency edge to
`00.00` unless they consume a real artifact produced there; viewing order alone is not a knowledge
dependency.

`00.00` introduces the complete course at guide depth. Its observable outcome is that the learner
can explain what the course teaches, who it is for, what completing it enables, what distinguishes
its teaching approach, and how its main parts fit together. Its content must:

- explain the course's subject, real problem space, scope, and why the course is worth learning;
- state the intended learners, who the course is not designed for, entry prerequisites, and any
  earlier courses or capabilities it assumes;
- give a meaningful overview of every chapter or major content part and the relationships among
  them as learner capabilities, without teaching their mechanisms or walking through examples from
  later lessons;
- state what completing the Core route enables and proves, and what each optional Extension route
  adds;
- explain the course's distinctive teaching features, such as problem-to-solution progression,
  comparative evidence, a sustained case, Core and Extension branches, or a particular practice
  format;
- explain the recommended learning route, optional choices, and useful stopping points at a broad
  level; keep detailed lesson and later-course links in the learner page.

If the course opens with required `00.01+` preparation, have `00.00` say in its spoken narration
what readiness is needed before subject practice and what success looks like. Put the specific
preparation video IDs, links, and ordering in the learner page. The guide may be
watched before installation when it does not use that tool itself. Keep the full installation
walkthrough in the preparation video rather than crowding it into the course guide.

Give each `00.01+` preparation video one concrete readiness outcome and a reason it must precede a
named lesson. Typical outcomes are installing and verifying required software, gaining access to
course materials, or completing a prerequisite skill check that the course actually uses. Specify
the viewer's starting state, the action shown on screen, the expected result, and a next step for a
failed check. Keep a short prior-knowledge review here only when it is enough to make the learner
ready; route substantial missing subject knowledge to its prerequisite course or a regular teaching
chapter. Required preparation videos are Core. Keep optional or platform-specific reference details
available without making an irrelevant setup path mandatory for every viewer.

In the readable course outline, give every `00.01+` preparation video its own lesson row in an
opening lesson table, using the same column structure as the `00.00` or subject lesson table. The
row identifies its ID, type, title, observable readiness outcome, demonstration, direct
prerequisites, estimated duration, and one post-lesson question; include procedures in a separate
column when that is the course's established table format. Keep these rows outside the subject
chapters. Explanatory preparation notes may follow, but prose or bullets alone do not replace the
lesson rows.

Do not turn `00.00` into a marketing trailer, a brief readiness notice, a teacher biography, or a
mechanical recital of lesson numbers. It is a real course guide that covers what will be learned and
what the learner will gain. Use at most a small, nontechnical illustration of the learning method;
do not solve a later lesson's problem, rehearse its rules, or compress the first technical lesson
into the guide. Keep it concise relative to the course's size; its estimate can be shorter than an
ordinary teaching episode when the guide's job is complete. Do not add examples merely to fill the
ordinary episode-duration range.

Use its required post-lesson question to check whether the learner can explain the course scope,
audience, expected gains, distinctive approach, or Core and Extension routes. Do not use a
confidence question. Hand the approved `00.00` course-guide brief to `outline-tutorial-lesson`.

Keep the course scope coherent. Distinguish required lessons from optional deep dives when that
helps. Include a course-level coverage check: every declared outcome has a lesson, every lesson
contributes to an outcome, and dependencies are satisfiable in at least one topological order.
For each required course outcome ID, identify the Core lesson or lessons that provide its observable
evidence. Check that the chapter checkpoints and final Core completion task let a learner demonstrate
that outcome independently; question responses or viewing alone are not sufficient evidence. Flag
a required outcome that exists only in Extension lessons or lacks a demonstrable task. For each
optional outcome ID, identify the named Extension route and the Extension lesson or lessons that
provide its evidence; flag an optional outcome that has no complete Extension route or silently
becomes necessary for course completion. A lesson may support more than one outcome, and an outcome
may require several lessons.
Record source gaps or uncertain product behavior as questions, not invented instruction.

When the course teaches principles, judgment, repeatable procedures, or a recurring case
through practice, read and apply the
[problem-driven curriculum guidance](references/problem-driven-curriculum.md).

## Deliver and hand off

Return a readable outline or save it as Markdown in the user-selected project. Include the audience,
course outcome, the Core completion outcome and optional Extension route outcomes with their
observable evidence, the numbered observable learning outcomes overview near the beginning,
prerequisites, the required
`00.00` course guide, any required `00.01+` preparation videos, course-wide tool and pacing choices,
chapter and lesson map with
counts, chapter-level progression summary, lesson-type mix per chapter, required core path, optional
extensions, level and lesson-type duration totals, dependency table and graph or dependency waves,
outcome-to-route coverage, Core-only and comprehensive-route continuity audits, the course-wide
visual mode, operational readiness handoff, dependency audit, and unresolved questions. Do not write
full narration, precise timestamps, or animation specifications here. Identify the first dependency-ready
core lessons for `outline-tutorial-lesson` and pass along each outcome, scope, and source
references; there may be more than one valid starting lesson.

For a file-based course, complete the planning workspace and validation described in the file-based
course planning reference before handoff.
