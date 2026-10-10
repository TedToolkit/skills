---
name: review-tutorial-script
description: >-
  Audit one or many existing narrated tutorial lesson drafts against their course direction,
  outcomes, outline, lesson cards, audience brief, sources, duration, provisional storyboards, and visual shot previews.
  Use for review-only work or fixes supported by that review. Do not use to originate or materially
  redesign a lesson, finalize storyboard timing, generate narration audio, or render a video.
---

# Review Tutorial Script

Assess whether each script teaches its promised result accurately and can be synthesized as written.
Review is read-only unless the user asks for fixes; a request to write and then review scripts
authorizes correcting those drafts and their lesson cards.
Use `design-tutorial` when the user wants a new lesson or a material redesign; this skill owns
evaluation and review-driven corrections to an existing draft.
For a file-based course, check artifacts against the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Also read the [course state contract](../../references/tutorial-course-state.md) and resolve the
packaged [`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md`.
Use the [writing and learning decisions](../../references/evidence-informed-guide/writing-and-learning.md)
when judging spoken engagement and practice. Read the
[visual and motion decisions](../../references/evidence-informed-guide/visual-and-motion.md)
when the storyboard's visual evidence or recurring screen elements need review. Open the
[source list](../../references/evidence-informed-guide/sources.md) only when checking a cited claim.
When a lesson uses a prediction, comparison, or inspection hold, use the shared
[intentional pause guide](../../references/intentional-pauses.md) to review its spoken cue and
provisional visual plan.
For a new file-based draft, check that every `Shot S01` identifier in `storyboard.md` has one
same-ordered `data-shot-id` container in `storyboard-preview.html`. Inspect the initial, key-change,
and settled states within that container against the script, evidence sources, and shared style;
matching identifiers alone do not make a misleading or unreadable preview acceptable.

## Establish the review set

When the course belongs to a series, read the series README first as the shared charter and the course
README second as its course-specific delta; do not treat an intentionally non-duplicated common
section as missing. Then read the course outline, each selected lesson's approved
`lesson-outline.md` when present, the course-specific audience and voice brief, and each selected
`lesson.md` with its `narration.txt`, provisional `storyboard.md`, `storyboard-preview.html`, and every demonstration source
declared by the lesson card or storyboard. For a whole-course request, inventory every outline lesson
and inspect every script; do not infer quality from a sample. Identify missing scripts before claiming
the course is reviewed. Treat course-specific visual style as a project artifact, not a rule from
this skill. When a course has `video-style.md`, read it, its linked series visual system when
present, and local reference frames or verified video under the shared
[video style contract](../../references/tutorial-video-style.md). An older
course without that file can be reviewed against its existing videos; do not invent retroactive
approval or create the contract during a read-only review.
Extract the course promise, intended audience, entry assumptions, course-level observable outcome
IDs, chapter exit capabilities, core route, optional extensions, and the selected lesson's declared
contribution before judging its prose. If these artifacts do not make that relationship verifiable,
report the missing curriculum evidence instead of inventing a course direction.
For a whole-course review, audit both the Core-only preferred route and a recommended route containing
all Core and Extension lessons. The Core-only route must not refer to concepts, case changes, or
artifacts introduced only in skipped extensions. The comprehensive route must place each extension
after its prerequisites without causing repeated setup, contradictory case state, abrupt resets, or
illogical transitions. A valid dependency graph does not by itself prove either route is coherent.
When the user or course brief calls for a long-form, lecture-like, or chaptered episode, or the
lesson deliberately combines several conceptual sections into one continuous episode, read the
[long-form spoken lesson guide](../../references/long-form-lesson-script.md) and review the complete
episode as well as its individual paragraphs. Do not classify the format from runtime alone.

## Review each lesson

Start with an alignment audit before judging style. State the title's promise, the primary observable
outcome, any supporting outcomes, the dominant subject of the spoken paragraphs, the role of each
example, the closing claim, and what the post-lesson question actually tests. Do not accept lexical
overlap as alignment; check what understanding receives the most explanation and evidence. If the
title and required outcome conflict, report that curriculum issue rather than rewriting toward one
side without authorization.
Compare the script's actual progression with the approved lesson outline when one exists. Flag a
missing teaching beat, an unsupported leap, or a new dominant example or outcome. A material change
to the approved spine returns to `outline-tutorial-lesson` for review before the script is approved;
do not silently treat a better-sounding draft as approval of a different lesson plan. Compare the
promised inference and evidence path, not just section names or paragraph order. More engaging
wording, expressive motion, or a different supporting example can improve the realization without
changing the approved outline; an example that changes what the learner concludes cannot. Compare
the card's post-lesson question with the approved question or learner check, and flag a question
that tests a different conclusion even if the script sounds coherent.

Apply a course-direction gate before prose quality can pass. For an ordinary lesson, identify the
course-level outcome or chapter exit capability it advances and verify that its depth, example,
learner assumptions, and conclusion serve that contribution. Check that a core lesson advances the
required route, that an extension remains optional, and that neither silently changes the promised
audience, progression level, prerequisites, or teaching premise. For `00.00`, verify the real
audience, route, Core outcome, and optional gains; reject promises the Core cannot deliver or a
guide that makes any Extension necessary for completion or for another route's value. Accurate,
engaging prose still fails when its dominant teaching work misses the declared course role.

When the script and curriculum artifacts disagree, classify the finding rather than choosing a side:
identify whether the script drifted from a coherent course plan or whether the title, lesson outcome,
chapter role, and course outcome mapping conflict with one another. Do not rewrite the script toward
an arbitrary interpretation or revise the curriculum without authorization.

Check the exact learning outcome, prerequisites, demonstration, and intended sequence against the
spoken words. The learner should encounter a concrete question, the mechanism needed to answer
it, observable evidence, the solution's limits or cost, and a natural closing takeaway. A
non-procedural introduction can use a different teaching arc. Check that every new example rule is
explained without requiring unannounced industry knowledge and that the script does not teach a
later concept as an unexplained prerequisite.
For a video-led course, trace every required setup action through the required viewing route.
Fail a preparation lesson that omits the spoken and visible action, readiness result, or failure
route; fail the first tool-using lesson when it assumes setup taught only in a linked document.
Check that the guide states the required readiness condition and success check before subject
practice; the learner page supplies the preparation video link. The preparation video's own
instructions and verification must be audible and visible, not left solely to a linked document.
Check that `00.00` remains a whole-course explanation and each `00.01+` lesson has a distinct
readiness outcome. Flag a preparation video that merely lists prerequisites, duplicates the guide,
or tries to compress substantial missing subject knowledge into a setup walkthrough.
For an explanatory lesson, locate the central thinking turn in the spoken and visible draft. What
could this audience reasonably expect, which observation distinguishes that expectation from the
lesson's explanation, and can the learner use the resulting idea in a nearby case? Flag a hook that
never becomes evidence, an answer disclosed before its question can be considered, or a reveal that
gives the result without explaining the cause. Do not require a misconception, prediction, or
surprise when the outcome calls for a different teaching shape. For a high-school audience, check
that the difficulty and voice respect their stated prior knowledge rather than relying on childish
framing or forced slang.
If the lesson invites a prediction, check that the learner can inspect the relevant source or prior
state before the result appears and that the next spoken line does not immediately supply the answer.
The storyboard should allow a brief thinking beat and then show the actual evidence; do not require
a spoken quiz or a fixed pause length.
Judge the amount of help against prior knowledge of the mechanism. For an unfamiliar procedure,
check that essential parts or states are introduced before interaction, that an inspectable example
precedes a larger independent task, and that any prediction or missing-step prompt can be answered
from what was taught. Flag feedback that only announces right or wrong without connecting the
observed output to the relevant line, state, or rule. Do not demand these devices in a course guide
or an advanced lesson when they do not serve its outcome.
If the learner is meant to repeat a tool or editing procedure independently, follow the handoff
through opening the right file, making and saving the change, returning to the intended working
location, and running the command. Flag a storyboard that only animates a source change while the
novice-facing procedure remains unstated. When a command skips a build or another update step,
check that the script says which prior state is reused, repeats the necessary update after an edit,
and explains a stale result using that cause rather than a generic checklist.

For `00.00`, check that narration and storyboard cover the whole course at guide depth: subject and
scope, audience fit, prerequisites, Core and optional gains, teaching features, routes, and case
relationships. Flag heading or lesson-number recitals, ceremonial biography, marketing-only
promises, a compressed first technical lesson, a solved later example, or named future-video promises.
The post-lesson question should test the actual scope, audience, gains, features, or route, not
confidence.
Can a first-time listener identify the subject, starting point, and achievable destination from the
opening? An evocative image does not rescue an unspecified spoken promise. If the course has a
sustained case or progressive task, each major part should change a recognizable problem,
capability, or result; otherwise check its actual organizing logic without demanding one artifact.
Optional routes need plain-language reasons to choose them and stated added gains, not just names or
terms. The ending should offer attainable Core evidence or a nearby transfer check, not repeat the
opening's capabilities.
For a light or game-like voice, reject repeated inventories, distracting jokes, and invented game
features; the literal route must remain clear without the metaphor. If the guide claims a teaching
method, require a small learner action and feedback, with visible before/after states when something
changes. Method names and flow labels alone do not demonstrate it; do not teach a later rule here.

Check the opening independently. The spoken script should begin with a concrete consequence,
question, useful result, or action, with enough context to understand it. Flag greetings, welcomes,
and ceremonial lead-ins in `narration.txt`, as well as openings that drop into unexplained material.
A lesson may use prerequisite knowledge, but must orient itself without referring to a previous
or next video. Include an instructor name or role only when the brief requests it or it helps the
learner understand the content; avoid repeated biography
or credentials. Flag course metadata, agendas, design rationale, slow throat-clearing, and
manufactured mystery when they delay the teaching point.
When a later demonstration supplies the decisive evidence, flag an opening that narrates its full
procedure and conclusion before the learner has a reason to watch. Preserve necessary orientation;
do not demand suspense from a lesson that has no meaningful result to reveal.
For a comparison lesson, check that the desired result or decision criterion is clear before the
first outcome appears. If the script asks whether something is "right" without saying what the
learner wanted to happen, the later success or failure contrast has no usable standard.

Review `narration.txt` as something a person must say and a listener must understand on the first
viewing, not as written documentation. Fail the draft when it oralizes the lesson card, recites
course metadata or dense statistics, or stacks abstract terminology. A visual may carry exact labels,
routes, code, and state changes when the narration gives a clear cue and explains their significance.
Test first-hearing comprehension with an audio-only, single-pass read-through. Hide the storyboard,
paragraph map, and on-screen labels; read the uncued narration at a natural pace, or listen to
generated audio once without pausing. After a paragraph, a learner should be able to say what is
being discussed and what changed; at a transition, why the next point follows; after a list, what
each item belongs to. Mark the exact place where understanding requires rereading, a visual label,
an unstated prior fact, or guessing the referent of "this" or "it". Diagnose whether the cause is
an unnamed object, competing referents, stacked new terms, an overloaded sentence, or an ungrouped
list, then recommend the smallest spoken rewrite. Do not claim verified listener comprehension from
a text-only read-through.
Treat Fish cues as non-spoken directions: verify the selected model's syntax, placement by the
affected words, and fit with sentence meaning and course voice. A genuine question or payoff may
need a cue; flag conflicting, excessive, or theatrical cues, without requiring one per paragraph.
For Fish S2, review each sentence's intended delivery; prefer one sentence per line, with blank
lines separating coherent spoken paragraphs. Check that emotion cues start the sentence they affect,
that `[emphasis]` precedes its phrase, and that untagged sentences do not rely on a previous cue
persisting.
At an adjacent cue change, review the last sentence before and first sentence after as one intended
spoken span. Before narration exists, flag contradictions visible in the text and leave actual
continuity for audio verification. When generated audio exists, listen across the change at normal
speed and flag a cue whose heard delivery disrupts the intended transition; a shorter ASR word gap
by itself does not establish better continuity.
Do not require `[break]` or `[long-break]` at paragraph boundaries; flag routine
pause tags in a long script. They cannot guarantee clean silence and can disrupt continuity. For
predictable section or learner holds, require a storyboard pause intent and later measured editing.
At consequential delivery changes, inspect storyboard and preview together: visual action should
support the same question, discovery, setback, or resolution without early answers or decorative
reactions. Adjacent voice and visual shifts should follow the evidence and established style.
Check every specialized term, notation, exact label, unusual name, and number that is spoken: it
must be necessary, introduced in plain language, easy to pronounce, and distinguishable by ear.
Context-free labels, arbitrary placeholder data, and unexplained example rules are not neutral;
replace them with familiar material whose differences actually support the lesson's reasoning.
Check language consistency in read-aloud text and learner-facing storyboard labels. Keep literal
code, commands, source strings, and needed technical names exact; flag an untranslated ordinary
descriptor that makes the speaker switch languages without serving the explanation.
For novices, flag a run of definitions or spelled-out syntax before the corresponding object or
action appears. Keep terms needed for the next step, but move exact spellings that learners can
inspect to the frame and introduce later terms at their first useful encounter.

Reject topic drift even when the prose and example are individually strong. A hook or case must
open the same problem the title promises; a teaching method must remain a method unless it is the
primary outcome; and navigation guidance must not displace the lesson topic. If most of the learner's
attention, evidence, or recall is likely to center on a supporting example, compress or replace it
and restore the primary explanation. Use this counterfactual check: a learner should not be able to
answer the post-lesson question well while still missing the title's central claim.

Verify that each lesson card, including an introduction lesson, has exactly one static
`## Post-lesson question` containing a concise learner-facing prompt. It must require recall,
explanation, choice, prediction, or application and be answerable from the lesson; a confidence
question such as "Do you understand?" is not evidence. Confirm that `narration.txt` does not read
the question aloud or tell the learner to pause, answer, submit, or wait for a reveal. The packaged
course, not the narration audio, owns presentation of this text.

Check factual claims and version-dependent behavior against authoritative sources or an observable
demonstration. For software lessons, also verify commands and framework syntax against a runnable
example. Put citations and verification notes in the lesson card, never in the read-aloud file.
Distinguish a simplified model or analogy from literal behavior. Flag a method introduced without
a real pressure, comparison, verification, and tradeoff. When on-screen source material lives in
Markdown, check that it matches the narration, follows the course's conventions, includes enough
context to understand it, and does not present a conceptual result as a verified observation.

Review the provisional storyboard as part of the script rather than as a later decoration. Confirm
that every paragraph maps to a clear visual purpose, exact on-screen text is concise, each declared
demonstration has a real source, explanatory motion shows the relevant relationship or change, and
no unsupported UI or result is implied. Expressive motion can establish rhythm or character when
it leaves the evidence legible. Require paragraph anchors and narration cues, but reject fabricated
timestamps or precise durations before final audio exists. If a paragraph is visually overloaded,
repetitive, or not supportable with available evidence, correct the spoken and visual drafts together
before narration generation.

Open every preview shot in order at the intended size before recommending approval. Match framing,
visual weight, exact labels, source evidence, and before/after states to narration and storyboard;
text alone cannot settle repetition, crowding, misleading visuals, or stiffness. For a course,
compare representative frames with shared references and an adjacent lesson, including handoffs
between guide and demonstration. Name any typography, component, evidence, or motion mismatch;
allow task-driven differences recorded in the style contract. If movement carries identity or
meaning, inspect a short specimen for object continuity, attention, and a stable reading state;
still frames cannot prove timing.
For a new or revised course style, open linked CSS/HTML and confirm the preview loads that CSS.
Inspect rendered font fallback, surface hierarchy, and first reading target; valid paths alone do
not prove appearance. Fix shared defects in their course or series asset, not one preview. Require
neither identical layouts nor an effect quota. Return mismatched frames to `design-tutorial`, revising
speech and visuals together when needed. Audio-aligned storyboard and video review settle final
motion and reading time.

Read shots silently and in order. Flag repeated label cards that do not advance the evidence object;
the learner should see what was expected, what changed, and why comparison matters. Seek a useful
handoff or contrast, not constant motion. For each consequential beat, identify prior knowledge,
what the learner hears, sees, and infers, any action, before/after states, and feedback. Flag visuals
that transcribe speech, spoken inventories better shown, early reveals, motion that obscures
evidence, or stills that hide a necessary change. Expressive motion may add rhythm when the idea
remains inspectable. Narration must convey the meaning of visual facts needed for the main outcome.
If exact visual details remain necessary,
require learner-facing `## Visual descriptions` in `lesson.md` or equivalent standalone text;
author notes and storyboards do not reach the learner.
For predictions, keep source and prior state inspectable and the answer unfilled, including labels
that might give it away. Reserve plausible thinking space before the decisive observation, then
retain a comparable prior state and explain the inference aloud. A playful reaction must not hide
evidence or make an analogy seem literal. Each spoken cue needs a clear visual target: remove
competing detail before adding a highlight, and plan a stable result plus prior trace for changes
the learner must explain. Do not impose label counts, shot templates, or pause lengths.
For a consequential pause, name what stays visible, what the learner can inspect or think through,
and when the next claim or reveal resumes. Flag immediate answers or demands that erase thinking
space; not every question needs a hold. For each primary outcome, locate enough spoken and visible
evidence to answer an explanation or application question; a card promise or question repeating
terms is insufficient. Use any outline-recorded plausible confusion to check which evidence
distinguishes the intended explanation. Trace a continuing case across shots; flag disconnected or
source-contradicting continuity. Flag obvious overload or risky reading space now, but defer actual
hold duration, normal-speed readability, and phrase synchronization until audio and video review;
invented timestamps or seconds-per-line thresholds cannot pass pacing.
Check each persistent badge, footer, progress cue, lower bar, or ambient motion at viewing size:
does it aid orientation, comparison, inference, identity, mood, or rhythm without competing with
evidence or duplicating player controls? A course map or progress cue must support a real decision
and define truthful units and behavior, never confuse shot timing with lesson progress. Treat this
as an interface judgment, not a claim about an isolated research effect of progress bars.

Read the script aloud when possible; otherwise simulate a natural technical speaking pace including
demonstration pauses. The estimate is provisional until generated audio exists. Flag sentences that
are hard to say in one pass, paragraphs with more than one main job, transitions that sound like
headings, inventory-like lists, and explanations that become clear only after rereading. Also flag
rushed explanations, repeated filler, monotonous
templates, strained jokes, or allusions that obscure the point. Check whether humor clarifies the
mechanism, whether the same idea is explained twice, and whether transitions pose the next problem
rather than repeat a fixed formula. Respect the stated audience and course voice; do not impose
humor when the course did not request it or when a serious failure path calls for a plain explanation.
Report a substantial estimated overrun for planning, but do not treat it alone as a script defect
or require cutting approved outline content. Judge whether the explanation earns its time and teaches every
approved beat clearly.
Audit paragraph continuity, not only sentence quality. At normal listening speed, check whether
a first-time listener can tell what each paragraph did and why the next one follows without seeing
the paragraph map or storyboard. Privately summarize each paragraph's single job; flag a boundary
whose logic exists only in blank lines, a visual cut, an emotion cue, or silence. Where the reason
for moving on is unclear, ask for a natural connective thought, the next necessary question, or a
changed learner action rather than a formulaic heading. Compare the spoken weight of the primary
route with optional inventories. Flag two passages that independently establish the same context,
conflict, or conclusion even when their wording differs. An example should be introduced once and
then developed as one thread; opening with its consequence, leaving for an abstract detour, and later
restarting it as a new example is a structural repetition, not a fresh hook.
Where several paragraphs restate the same observed result, keep the clearest inference and retain
another pass only if it makes a distinct comparison or supports a new learner action. Name the
specific passage and lost thinking opportunity when reporting a script as stiff; a generic request
for more humor or energy is not a useful correction.
When reporting a pre-generation duration, require a range based on a stated count, a natural speaking
rate appropriate to the script's language and density, and explicit allowance for demonstrations,
predictions, or silence. Do not present a single exact duration as verified before audio exists.

Check that `narration.txt` has only spoken words and intentional non-spoken Fish expression and
pause cues: no title, Markdown, paragraph identifier, timestamp, citation URL, or production note.
Exclude cues when assessing what a listener hears, estimating spoken length, and planning subtitle
copy. Match each blank-line-separated paragraph in order to the paragraph map in `lesson.md`; make
the card's sources, teaching purpose, and required on-screen evidence agree with the provisional
storyboard. Do not ask the speaker to read a title merely because it appears in the card.

Audit each lesson's narration and storyboard as though a learner opened that lesson directly,
without a known viewing history. Its required starting capability should be clear; route a viewer
who lacks it through the learner page rather than a spoken cross-reference. Reject references to
prior or future lesson IDs, "last time" or "next time" language, recaps that require another video's context, and previews that assign
content to an unrequested future lesson. A reused case must show the starting state needed here;
close on the current lesson's usable result. Keep navigation and route suggestions in the learner
page or lesson card even when the course recommends a linear order. During a one-lesson review,
do not draft or revise unrelated future lessons to repair a transition; report a genuine course
plan conflict separately.

## Course-wide pass and result

Compare adjacent lessons for concept ordering, repeated explanations, inconsistent terminology,
case continuity, and promises in the introduction that the course does not fulfill. Reconstruct the
course-level outcome coverage from the scripts themselves, not only from lesson-card declarations:
every promised core outcome must receive sufficient explanation and observable evidence on the core
route; no core outcome may depend on an extension; and every ordinary lesson must make a traceable
contribution to its declared course outcome or chapter capability. Flag a collection of individually
plausible scripts when their combined emphasis, depth, or examples lead to a different course than
the outline promises.

Verify lesson count, script, provisional-storyboard and visual-preview coverage, post-lesson-question coverage,
per-lesson status, and local links. For each reviewed lesson, report its course outcome or
chapter-capability contribution, its
core or extension role, and a course-direction verdict alongside the ordinary findings. Report
findings by lesson ID and severity, with a concrete correction and owning stage. Distinguish an
outline or curriculum mismatch from a gap in spoken reasoning, a missing or misleading planned
visual, and a timing or legibility risk that can only be settled after audio or rendering. Do not
rewrite narration to solve a problem that belongs to the course outcome or to final video timing.
When fixes are authorized, correct the script, card, provisional storyboard, and visual preview
together, then reread the affected lesson, neighboring transitions, and the affected
course-outcome coverage. Say explicitly
which lessons passed, which remain in draft, which cannot be checked against the course direction,
and which checks still depend on generated narration or runnable code.

For a file-based course, run the validator before review and treat stale output as the review
boundary. When authorized fixes change `lesson.md`, `narration.txt`, or a declared source, record the
lesson as `script-draft` after the corrected draft passes review; this invalidates later production
claims. A passing review makes the script ready for human approval but does not approve it. Only when
the user explicitly approves that reviewed version may this skill call the recorder for
`script-approved`, passing a concise approval source that identifies the reviewed script and visual
preview. Re-run the validator after either state change.
Never treat validator success, paragraph-map completeness, or factual correctness as evidence that
the prose passed the oral-readability review.
