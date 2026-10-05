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

## Establish the review set

When the course belongs to a series, read the series README first as the shared charter and the course
README second as its course-specific delta; do not treat an intentionally non-duplicated common
section as missing. Then read the course outline, each selected lesson's approved
`lesson-outline.md` when present, the course-specific audience and voice brief, and each selected
`lesson.md` with its `narration.txt`, provisional `storyboard.md`, `storyboard-preview.html`, and every demonstration source
declared by the lesson card or storyboard. For a whole-course request, inventory every outline lesson
and inspect every script; do not infer quality from a sample. Identify missing scripts before claiming
the course is reviewed. Treat course-specific visual style as a project artifact, not a rule from
this skill. When a course has `video-style.md`, read it and its local reference frames or verified
video under the shared [video style contract](../../references/tutorial-video-style.md). An older
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
audience, progression level, prerequisites, or teaching premise. The required `00.00` course guide
must frame the real audience, route, and achievable outcomes without promising material the core
lessons do not deliver. Verify that the learner receives an accurate whole-course guide: what it
teaches, who it is and is not for, prerequisites, Core completion and optional Extension gains,
distinctive teaching features, and how the major content parts and routes fit together. Reject a
guide that makes an optional Extension necessary for course completion or implies that every
Extension must be watched to gain value from any one route. Accurate, engaging prose still fails
review when its dominant teaching work points away from this declared course role.

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

For `00.00`, also check that the coordinated narration and storyboard cover every major course part
at guide depth and explain their relationships rather than merely reciting headings. It should center the subject and
scope, audience fit, prerequisites, Core completion outcome, optional Extension gains, course
characteristics, learning routes,
and case model. Flag lesson-number recitals, ceremonial biography, marketing-only promises, a
compressed first technical lesson, a solved later-lesson example, or named future-video promises.
The post-lesson question should test the learner's grasp of the course scope, audience, gains,
features, or route rather than confidence.

When a lighter or game-like voice is requested, check that one concrete learner problem carries the
guide from its starting point to the final capability. The major parts should feel like meaningful
progress rather than a sequence of course headings. Flag repeated topic inventories even when each
fact is accurate, jokes that interrupt the explanation, and game language that implies features the
course does not provide. A listener should be able to retell the actual route without the metaphor.
When the guide claims a distinctive learning method, check that the narration and provisional
storyboard make it tangible without teaching a later lesson's rule. A brief nontechnical learner
action and observable feedback can show the method; a list of method names alone does not show how
the learner will use them.

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

Open the visual shot preview and inspect every shot in sequence at the intended viewing size before
recommending script approval. Check that its framing, visual weight, exact labels, source evidence,
and before/after states match the current narration and written storyboard. A text description alone
does not settle whether the lesson's shots are repetitive, crowded, misleading, or visually stiff.
For a course, compare representative frames side by side with the shared style references and an
adjacent or earlier lesson when available. Check the visual handoff across different lesson forms,
such as a guide and a demonstration. Report the specific typography, component, evidence treatment,
or motion rule that breaks continuity; allow a difference that serves the learning task and is
explained by the course contract. Do not require identical layouts or a fixed visual effect count.
Return missing or mismatched frames to `design-tutorial`; revise the script and visuals together if
the fix changes a spoken cue. Treat the preview as provisional: final motion and reading time remain
subject to audio-aligned storyboarding and video review.

Read the shot sequence without narration as well: flag a run of nearly identical labeled cards that
does not visibly advance the same evidence objects. Check whether the learner can see what was
expected, what changed, and why the final comparison matters. Ask for a purposeful visual handoff or
contrast when it would clarify the inference; do not require constant movement or decorative effects.
Check what the learner hears, sees, and can infer at each beat. Flag a visual that merely transcribes
the voice, a spoken inventory that the frame could show more clearly, or a result revealed before a
prediction. Check that the narration conveys the meaning of every visual fact needed for the primary
outcome. For a file-based course, if exact visual details remain necessary, require a learner-facing
`## Visual descriptions` section in `lesson.md`; for a standalone lesson, require equivalent text
with the video. Author notes and `storyboard.md` do not reach the learner. At this draft stage,
check that the planned spoken cue and visual state belong together and that the storyboard reserves
plausible reading or prediction space without assigning exact durations.
For a prediction, inspect the entire cue-to-reveal sequence: an exact "expected result" label can
give away the answer even when the actual-output area remains hidden. Leave the source inspectable
and the answer unfilled until the learner has had a plausible chance to form an expectation.
When a prediction or surprise carries the explanation, verify that the storyboard shows the
decisive observation and retains a state the learner can compare with the result. Check that the
spoken line explains what the observation means instead of reading labels or letting motion alone
make the claim. A playful reaction should not mask the evidence or turn an analogy into a false
physical or technical mechanism.
For each consequential beat, check its intended inference, relevant prior knowledge, learner action
if any, visible before and after states, and observable evidence or feedback. Flag motion that only
decorates a claim when it obscures the evidence, a vanished state the learner must compare, or a
still image that hides the change being taught. Expressive motion may serve rhythm or personality
between or alongside teaching beats when the idea remains easy to inspect. Flag obvious visual
overload, but defer normal-speed hold and reading checks
at the intended viewing size until the generated audio and timed storyboard exist. Do not pass
pacing from invented seconds-per-line thresholds or precise timestamps before then.
For each consequential spoken cue, check that the provisional frame gives the learner an identifiable
target without searching through unrelated labels or panels. Suggest removing competing detail before
adding arrows or highlights; keep a targeted cue when the full display is needed for the lesson.
For a change the learner must explain, require a planned stable result and enough prior state or
trace to compare it with. Do not impose a fixed label count, pause length, or shot template.
For each primary outcome, point to the beat that supplies enough spoken and visible evidence to
answer an explanation or application question. If the outcome exists only in the lesson card or
spoken promise, mark it untaught even when the storyboard looks engaging.
Use the outline's expected reasoning and plausible confusion, when recorded, to inspect whether
the learner can distinguish the intended explanation from a tempting but unsupported one. State
which evidence in the script or planned visual resolves that confusion. Do not mark a draft as
effective merely because its post-lesson question repeats the right terms.
For a continuing case, trace its visible state across shots. Flag disconnected diagrams that require
the learner to reconstruct the same case from scratch, or apparent continuity that contradicts the
declared source. Note any extra on-screen information whose planned hold may be too brief; actual
readability and phrase-level synchronization belong to the audio-aligned storyboard and video review.
Check every planned persistent badge, progress display, lower bar, or ambient motion against the
lesson's attention target. Ask what it helps the learner locate, compare, or infer, and flag an
element that competes with the evidence or duplicates a player control. Course identity, mood, or
rhythm can justify a quiet recurring element; review its effect at actual viewing size.
Audit every persistent or repeated on-screen element for its learner-facing purpose. Flag a footer,
shot count, progress bar, or ambient motion that draws attention from the evidence, duplicates
the player's controls, or ambiguously presents shot timing as lesson progress. Keep a course map or
progress cue when it accurately supports a real navigation or learning decision; ask the storyboard
to define its units and behavior. Treat this as a coherence and interface judgment, not a claim that
research has isolated the effect of an in-video progress bar.

Read the script aloud when possible; otherwise simulate a natural technical speaking pace including
demonstration pauses. The estimate is provisional until generated audio exists. Flag sentences that
are hard to say in one pass, paragraphs with more than one main job, transitions that sound like
headings, inventory-like lists, and explanations that become clear only after rereading. Also flag
lessons likely outside the agreed duration, rushed explanations, repeated filler, monotonous
templates, strained jokes, or allusions that obscure the point. Check whether humor clarifies the
mechanism, whether the same idea is explained twice, and whether transitions pose the next problem
rather than repeat a fixed formula. Respect the stated audience and course voice; do not impose
humor when the course did not request it or when a serious failure path calls for a plain explanation.
Audit paragraph continuity, not only sentence quality. Privately summarize each paragraph's single
job and verify that the following paragraph answers, advances, tests, or usefully reframes it. Flag
two passages that independently establish the same context, conflict, or conclusion even when their
wording differs. An example should be introduced once and then developed as one thread; opening with
its consequence, leaving for an abstract detour, and later restarting it as a new example is a
structural repetition, not a fresh hook.
Where several paragraphs restate the same observed result, keep the clearest inference and retain
another pass only if it makes a distinct comparison or supports a new learner action. Name the
specific passage and lost thinking opportunity when reporting a script as stiff; a generic request
for more humor or energy is not a useful correction.
When reporting a pre-generation duration, require a range based on a stated count, a natural speaking
rate appropriate to the script's language and density, and explicit allowance for demonstrations,
predictions, or silence. Do not present a single exact duration as verified before audio exists.

Check that `narration.txt` has spoken words only: no title, Markdown, paragraph identifier,
timestamp, citation URL, or production note. Match each blank-line-separated paragraph in order
to the paragraph map in `lesson.md`; make the card's sources, teaching purpose, and required
on-screen evidence agree with the provisional storyboard. Do not ask the speaker to read a title
merely because it appears in the card.

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
