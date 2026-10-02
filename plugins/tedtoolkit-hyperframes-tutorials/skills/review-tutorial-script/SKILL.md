---
name: review-tutorial-script
description: >-
  Review one or many narrated tutorial lesson scripts against their course direction,
  course-level outcomes, outline, lesson cards, audience brief, sources, and episode
  duration and provisional storyboards. Use for script quality review, course-wide narration audit,
  visual-feasibility review, or requested fixes after drafting. Do not use to finalize storyboard
  timing, edit recorded audio, or render a video.
---

# Review Tutorial Script

Assess whether each script teaches its promised result accurately and can be recorded as written.
Review is read-only unless the user asks for fixes; a request to write and then review scripts
authorizes correcting those drafts and their lesson cards.
For a file-based course, check artifacts against the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Also read the [course state contract](../../references/tutorial-course-state.md) and resolve the
packaged [`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md`.

## Establish the review set

Read the course README, outline, course-specific audience and voice brief, and each selected `lesson.md`
with its `narration.txt`, provisional `storyboard.md`, and every demonstration source declared by the
lesson card or storyboard. For a whole-course request, inventory every outline lesson and inspect
every script; do not infer quality from a sample. Identify missing scripts before claiming the
course is reviewed. Treat course-specific visual style as a project artifact, not a rule from
this skill.
Extract the course promise, intended audience, entry assumptions, course-level observable outcome
IDs, chapter exit capabilities, core route, optional extensions, and the selected lesson's declared
contribution before judging its prose. If these artifacts do not make that relationship verifiable,
report the missing curriculum evidence instead of inventing a course direction.
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

Apply a course-direction gate before prose quality can pass. For an ordinary lesson, identify the
course-level outcome or chapter exit capability it advances and verify that its depth, example,
learner assumptions, and conclusion serve that contribution. Check that a core lesson advances the
required route, that an extension remains optional, and that neither silently changes the promised
audience, progression level, prerequisites, or teaching premise. A course introduction instead must
frame the real audience, route, and achievable outcomes without promising material the core lessons
do not deliver. Accurate, engaging prose still fails review when its dominant teaching work points
away from this declared course role.

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

Check the opening independently. Every lesson needs a brief spoken entry that acknowledges the
learner and provides enough orientation to enter this episode naturally. The instructor's first
course appearance or a standalone video may include a concise name or role; later lessons should not
repeat a biography or credentials. A continuous lesson may reconnect to prior understanding, while
an independently accessible lesson must orient itself without inventing a previous or next lesson.
Do not require identical greeting words across the course.

By the end of the first short paragraph, the entry should establish a concrete consequence,
question, or useful result before course metadata, an agenda, or design rationale. Flag both abrupt
openings that drop into unexplained material and ceremonial openings that delay relevance. Also flag
generic welcomes, slow throat-clearing, manufactured mystery, and openings that ask for attention
before giving the learner a reason to care.

Review `narration.txt` as something a person must say and a listener must understand on the first
hearing, not as written documentation. Fail the draft when it oralizes the lesson card, recites
course metadata or dense statistics, stacks abstract terminology, or relies on the screen for its
basic meaning. Check every specialized term, notation, exact label, unusual name, and number: it
must be necessary, introduced in plain language, easy to pronounce, and distinguishable by ear.
Context-free labels, arbitrary placeholder data, and unexplained example rules are not neutral;
replace them with familiar material whose differences actually support the lesson's reasoning.

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
course, not the recording, owns presentation of this text.

Check technical claims, version-dependent behavior, commands, and framework syntax against
authoritative sources or a runnable example. Put citations and verification notes in the lesson
card, never in the read-aloud file. Distinguish a simplified model or analogy from literal runtime
behavior. Flag a pattern introduced without a real pressure, comparison, verification, and tradeoff.
When screen code lives in Markdown, check that it matches the narration, uses the course's code
style, includes the needed surrounding types or labels a partial excerpt, and does not present a
conceptual result as a verified run.

Review the provisional storyboard as part of the script rather than as a later decoration. Confirm
that every paragraph maps to a clear visual purpose, exact on-screen text is concise, each declared
demonstration has a real source, motion explains a relationship or change, and no unsupported UI or
result is implied. Require paragraph anchors and narration cues, but reject fabricated timestamps or
precise durations before final audio exists. If a paragraph is visually overloaded, repetitive, or
not supportable with available evidence, correct the spoken and visual drafts together before
recording.

Read the script aloud when possible; otherwise simulate a natural technical speaking pace including
demonstration pauses. The estimate is provisional until recorded audio exists. Flag sentences that
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
When reporting a pre-recording duration, require a range based on a stated count, a natural speaking
rate appropriate to the script's language and density, and explicit allowance for demonstrations,
predictions, or silence. Do not present a single exact duration as verified before audio exists.

Check that `narration.txt` has spoken words only: no title, Markdown, paragraph identifier,
timestamp, citation URL, or production note. Match each blank-line-separated paragraph in order
to the paragraph map in `lesson.md`; make the card's sources, teaching purpose, and required
on-screen evidence agree with the provisional storyboard. Do not ask the speaker to read a title
merely because it appears in the card.

Check every spoken preview or forward transition against the course's actual ordering model. Do not
infer a successor from lesson number, outline position, or array order. In a prerequisite graph,
parallel wave, or branching course, reject "next lesson" language and previews that imply one fixed
route; close on the current takeaway unless the course brief explicitly requests optional navigation
guidance. Even in a linear course, a preview must stay within the declared scope and introduce a
real continuation rather than a convenient teaser.

## Course-wide pass and result

Compare adjacent lessons for concept ordering, repeated explanations, inconsistent terminology,
case continuity, and promises in the introduction that the course does not fulfill. Reconstruct the
course-level outcome coverage from the scripts themselves, not only from lesson-card declarations:
every promised core outcome must receive sufficient explanation and observable evidence on the core
route; no core outcome may depend on an extension; and every ordinary lesson must make a traceable
contribution to its declared course outcome or chapter capability. Flag a collection of individually
plausible scripts when their combined emphasis, depth, or examples lead to a different course than
the outline promises.

Verify lesson count, script and provisional-storyboard coverage, post-lesson-question coverage,
per-lesson status, and local links. For each reviewed lesson, report its course outcome or
chapter-capability contribution, its
core or extension role, and a course-direction verdict alongside the ordinary findings. Report
findings by lesson ID and severity, with a concrete correction, and distinguish script defects from
curriculum conflicts. When fixes are authorized, correct the script, card, and provisional
storyboard together, then reread the affected lesson, neighboring transitions, and the affected
course-outcome coverage. Say explicitly
which lessons passed, which remain in draft, which cannot be checked against the course direction,
and which checks still depend on recorded narration or runnable code.

For a file-based course, run the validator before review and treat stale output as the review
boundary. When authorized fixes change `lesson.md`, `narration.txt`, or a declared source, record the
lesson as `script-draft` after the corrected draft passes review; this invalidates later production
claims. A passing review makes the script ready for human approval but does not approve it. Only when
the user explicitly approves that reviewed version may this skill call the recorder for
`script-approved`, passing a concise approval source. Re-run the validator after either state change.
Never treat validator success, paragraph-map completeness, or factual correctness as evidence that
the prose passed the oral-readability review.
