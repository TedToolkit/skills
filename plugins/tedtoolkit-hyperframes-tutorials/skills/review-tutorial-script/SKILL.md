---
name: review-tutorial-script
description: >-
  Review one or many narrated tutorial lesson scripts against their course outline,
  lesson cards, audience brief, sources, and episode duration. Use for script quality
  review, course-wide narration audit, or requested fixes after drafting. Do not use
  to storyboard animation, edit recorded audio, or render a video.
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
with its `narration.txt` and every demonstration source declared by the lesson card. For a whole-course request, inventory every outline lesson and inspect
every script; do not infer quality from a sample. Identify missing scripts before claiming the
course is reviewed. Treat course-specific visual style as a project artifact, not a rule from
this skill.

## Review each lesson

Check the exact learning outcome, prerequisites, demonstration, and intended sequence against the
spoken words. The learner should encounter a concrete question, the mechanism needed to answer
it, observable evidence, the solution's limits or cost, and a closing exit check. A non-procedural
introduction can use a different teaching arc, but it still needs an exit check aligned to its stated
outcome. Check that every new example rule is explained without requiring unannounced industry
knowledge and that the script does not teach a later concept as an unexplained prerequisite.

Verify that each lesson has exactly one exit-check prompt, concise success criteria, and a specific
remediation pointer. The prompt must require recall, explanation, choice, prediction, or application;
a confidence question such as "Do you understand?" is not evidence. Confirm that the learner is
told to pause before the answer or criteria are revealed and that the final production can expose
the criteria without relying on private production notes. The remediation pointer should name the
relevant concept, paragraph, or demonstration rather than directing the learner only to rewatch the
entire lesson.

Check technical claims, version-dependent behavior, commands, and framework syntax against
authoritative sources or a runnable example. Put citations and verification notes in the lesson
card, never in the read-aloud file. Distinguish a simplified model or analogy from literal runtime
behavior. Flag a pattern introduced without a real pressure, comparison, verification, and tradeoff.
When screen code lives in Markdown, check that it matches the narration, uses the course's code
style, includes the needed surrounding types or labels a partial excerpt, and does not present a
conceptual result as a verified run.

Read the script aloud or estimate at a natural technical speaking pace including demonstration
pauses. The estimate is provisional until recorded audio exists. Flag lessons likely outside the
agreed duration, rushed explanations, repeated filler, monotonous templates, strained jokes, or
allusions that obscure the point. Check whether humor clarifies the mechanism, whether the same
idea is explained twice, and whether transitions pose the next problem rather than repeat a fixed
formula. Respect the stated audience and course voice; do not impose humor when the course did not
request it or when a serious failure path calls for a plain explanation.

Check that `narration.txt` has spoken words only: no title, Markdown, paragraph identifier,
timestamp, citation URL, or production note. Match each blank-line-separated paragraph in order
to the paragraph map in `lesson.md`; make the card's sources, teaching purpose, and required
on-screen evidence clear enough for storyboard handoff. Do not ask the speaker to read a title
merely because it appears in the card.

## Course-wide pass and result

Compare adjacent lessons for concept ordering, repeated explanations, inconsistent terminology,
case continuity, and promises in the introduction that the course does not fulfill. Verify lesson
count, script coverage, exit-check coverage, per-lesson status, and local links. Report findings by
lesson ID and severity, with a concrete correction. When fixes are authorized, correct the script
and card, then reread the affected lesson and neighboring transitions. Say explicitly which lessons
passed, which remain in draft, and which checks still depend on recorded narration or runnable code.

For a file-based course, run the validator before review and treat stale output as the review
boundary. When authorized fixes change `lesson.md`, `narration.txt`, or a declared source, record the
lesson as `script-draft` after the corrected draft passes review; this invalidates later production
claims. A passing review makes the script ready for human approval but does not approve it. Only when
the user explicitly approves that reviewed version may this skill call the recorder for
`script-approved`, passing a concise approval source. Re-run the validator after either state change.
