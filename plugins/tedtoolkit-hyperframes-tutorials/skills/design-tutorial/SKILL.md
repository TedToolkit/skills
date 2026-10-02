---
name: design-tutorial
description: >-
  Design one narrated animated video lesson from its recordable spoken script and provisional
  storyboard through its final audio-aligned shot plan. Use for a standalone tutorial or one lesson
  from a course outline, including its learning objective, teaching sequence, exact narration,
  visual explanation, animation intent, and final storyboard timing. Do not use for planning an
  entire multi-lesson course, editing narration audio, or building and rendering the video.
---

# Design Tutorial

Design one lesson so its spoken and visual explanations work together. Before recording, produce a
recordable script and a provisional storyboard without invented timecodes. After the edited voice
master exists, return to the same storyboard, align it to verified audio timing, and finalize it for
production. An existing `plan-tutorial-course` outline supplies the lesson's scope, but a standalone
lesson does not require a course outline.
For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Read the [course state contract](../../references/tutorial-course-state.md) and resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md` before
changing a course lesson. Run the validator first. From `planned` or `script-draft`, design the
script and provisional storyboard together. From `narration-final`, align and finalize that
storyboard. When revising another later-stage lesson, identify the downstream records and release
state that the change will invalidate before writing.

## Establish the lesson

Read the course outline when one exists, plus the user's sources, intended audience, desired
outcome, prerequisites, and constraints. Select one lesson and preserve its place in the course.
Carry forward the course's selected tools, framework, and episode duration when specified.
Read the course README and its audience and voice brief when present; they define this course's
tone and examples, not a universal tone for other tutorials. A learner may be new to the target language while
already fluent in programming; avoid teaching beneath that stated baseline.
Read the course's ordering model as well as its outline order. Lesson IDs and file order identify
content; they do not by themselves define what the learner takes next. When the course is organized
by prerequisites, waves, optional branches, or another non-linear model, keep navigation choices in
the course interface or lesson card. Do not call another lesson "the next lesson" or preview its
content unless the course brief explicitly defines one linear continuation from the current lesson.
Follow the course's chosen demonstration medium. If it names an IDE, explain only actions needed
to run, observe, or verify this lesson; keep version-specific menu paths in a separate tool guide.
If it supplies demonstration files, keep exact code, diagrams, commands, and observable results in
their real source files and align the spoken explanation to them. Make source files and results understandable
without prior expertise in the example's business domain; define any new rule before relying on it.
For a standalone tutorial, define the outcome directly with the user-supplied brief. Check
source-dependent commands, UI steps, facts, and terminology against authoritative material when
they matter to the lesson. Mark uncertain or version-specific details rather than inventing them.

Before writing an open-ended lesson, show the lesson boundary, teaching sequence, and high-level
visual approach. A direct request to create or update a named lesson, script, or storyboard
authorizes that draft write at the selected location.
Ask only when a missing fact would change the teaching content or make a demonstration incorrect.
Derive one sentence that joins the title to the observable outcome: after the lesson, what question
named or implied by the title can the learner answer or act on? Treat that sentence as the lesson's
primary promise. When the outline lists several outcomes, identify which one is primary and which
ones are supporting tools, examples, or navigation guidance. If two independent outcomes both need
to dominate, narrow or split the lesson; if the title and required outcome disagree, surface the
conflict before drafting instead of choosing one silently. In `lesson.md`, make the primary outcome
and any supporting outcomes distinguishable rather than hiding them in one compound objective.
When the user or course brief calls for a long-form, lecture-like, or chaptered episode, or the
lesson deliberately combines several conceptual sections into one continuous episode, read and
apply the [long-form spoken lesson guide](../../references/long-form-lesson-script.md). Do not use a
minute threshold to classify the format or shorten the learning outcome merely to imitate
short-video conventions.

## Write the lesson and spoken script

Choose a teaching sequence that introduces the need, explains each necessary idea, demonstrates
the action or reasoning, and closes with a usable takeaway. Make each explanation earn its place
against the learning objective. Give the learner enough context to follow a procedure without
padding the script with repeated introductions or decorative narration.
Keep the lesson's center of gravity on its primary promise. A hook, case, diagnostic method, or
demonstration is supporting material unless it is itself the promised outcome. Give supporting
material only the space needed to prove or illuminate the main idea; do not let an increasingly
detailed example become the topic learners are most likely to remember. The opening, largest
explanatory movement, closing, and post-lesson question should all point to the same primary promise.
Choose the smallest code slice that proves the mechanism. Reuse a course case as a familiar
thread without claiming that all lessons modify one continuously growing codebase. Mark a pattern
comparison as an alternative implementation rather than silently folding it into the main example.

For a lesson that introduces a paradigm, principle, code smell, or design pattern, begin with the
concrete requirement change or failure. Show the old behavior and the smallest useful change,
then name the concept. Explain its benefit, implementation and maintenance cost, and a condition
where the simpler approach is preferable. Treat a code smell as a reason to inspect change cost,
not an automatic mandate to apply a pattern. Demonstrate the resulting behavior with the course's
selected test framework or another observable check; avoid a stand-alone terminology lecture.

Write the actual words to be recorded, in natural spoken language. Give the lesson a coherent arc:
an opening question or concrete problem, the relevant mechanism and example, an observable check,
the limits or cost of the solution, and a natural closing takeaway. A transition to the next lesson
may follow only when the course has an explicit linear continuation and it introduces a real next
problem. Otherwise close on the current lesson's usable result. Adapt this arc to an introduction or
other non-procedural lesson rather than forcing a demonstration.

Give every lesson a brief spoken entry that acknowledges the learner and orients them into this
episode before the main explanation begins. Do not require one fixed greeting. For the instructor's
first appearance in a course or for a standalone video, include a concise name or role when that
human context has not already been established. In a continuous sequence, use a light greeting or a
meaningful connection to prior understanding without repeating the instructor biography. For a
lesson that may be entered independently, supply the minimum context needed to follow this episode
without claiming a previous or next lesson.

Make the entry useful immediately. By the end of its first short paragraph, establish a recognizable
consequence, question, or result before reciting an agenda, design rationale, navigation, or course
metadata. A greeting may lead into that relevance in the same sentence or paragraph; it must not
stand alone as ceremonial filler. The learner should quickly know what is at stake and what they are
about to understand. Avoid repeated credentials, generic welcomes copied across lessons, and
manufactured mystery. Keep a consistent course voice without forcing identical opening wording.

Treat `narration.txt` as performance text, not as a lesson card read aloud. Write for comprehension
on the first listen: use speakable sentences, plain transitions, concrete verbs, and one main idea
per paragraph. Do not mechanically convert every outline bullet, production requirement, or
paragraph-map row into narration. Keep planning metadata, inventory-like coverage, detailed course
statistics, dependency bookkeeping, source notes, and acceptance criteria out of the spoken text
unless the learner must hear them to understand or act. Material that is useful mainly when seen
belongs in `lesson.md` or `storyboard.md`.

Do not invent context-free labels or arbitrary placeholder data merely to make an example feel
specific. Prefer familiar entities, values, objects, or actions whose differences matter to the
question being explored. Introduce every example rule before the result depends on it. When a
specialized term, notation, exact label, or number must be spoken, explain what it means and make
sure a listener can distinguish it without looking at the screen.

Write exactly one post-lesson question that lets the learner recall, explain, choose, predict, or
apply the lesson outcome without merely reporting confidence. Keep it outside the spoken script so
the recording can end naturally. It is static learner-facing text for the course page, not a prompt
that requires an input, submission, answer reveal, score, or completion gate.

In a file-based course, save `lesson.md`, `narration.txt`, and `storyboard.md` inside
`lessons/<lesson-id>/`.
`lesson.md` is the production card: lesson ID and title, objective, audience assumptions,
prerequisites, teaching arc, paragraph map, demonstrations, sources, and estimated duration.
`narration.txt` is the sole recording source and contains only the words the speaker should read,
as plain-text paragraphs. Do not put a title, Markdown heading, segment label, timestamp, citation,
stage direction, pronunciation note, or production instruction in that file. Never make the speaker
read a heading simply because it appears on the lesson card or screen. Put the exact question in a
`## Post-lesson question` section of `lesson.md`, in the learner's language. Do not copy it into
`narration.txt` or turn it into a spoken pause instruction.
Do not create a canonical `demo.md`. Record each demonstration's purpose and source path in
`lesson.md`. Keep runnable code, substantial commands and output, diagrams, screenshots, and other
independently verified evidence in their actual project or asset files. Label conceptual or partial
snippets and verify runnable claims with a project build or execution before using them as evidence.
Put short exact learner-facing text and the decision about what source state or range appears on
screen in `storyboard.md`; do not make the lesson card a duplicate visual script.

Assign stable paragraph identifiers such as P01, P02, ... in the `lesson.md` paragraph map, in the
same order as the blank-line-separated paragraphs in `narration.txt`. For each paragraph, note its
teaching purpose, any required demonstration or exact on-screen value, and the source for claims
that require verification. Keep these notes out of spoken text. Do not prescribe camera moves or
animation timing in the paragraph map; those belong in `storyboard.md`. Estimate total length only
from likely speaking pace; the recording will determine final timecodes.

Use the course's requested voice. When it calls for humor or allusions, make them illuminate the
technical point and suit the stated audience. Prefer concise, accurate references to primary
sources; put attribution and links in `lesson.md`, and avoid invented quotations or jokes that
obscure a failure mode. Preserve technical precision even when the prose is playful.
Before handoff, perform an oral-readability pass from `narration.txt` alone. Read it aloud when
possible. Rewrite sentences that need the screen for basic meaning, contain several nested clauses,
stack abstract nouns, or present a dense list of terms or numbers. Turn necessary lists into a
conversational progression rather than a recital. Confirm that every name, acronym, identifier,
notation, and numeral has an obvious spoken form and a reason to be heard. Cut repeated setup,
restated definitions, and transitions that merely announce the next lesson. Keep a transition when
it poses a real unanswered question.
Perform a paragraph-continuity audit as part of that pass. Privately summarize the single job of
each paragraph, then check that the next paragraph answers, advances, tests, or usefully reframes
what came before. Give distinct paragraphs distinct jobs; merge, cut, or reorder passages that
independently establish the same context, conflict, or conclusion. Treat an example as one continuous
thread: introduce it once, and do not open with its consequence, leave for an abstract detour, then
restart the same example later as though it were new. This audit is working analysis, not text to add
to `narration.txt`.
Confirm that the post-lesson question can be answered from what the lesson actually taught without
requiring unannounced knowledge. Do not force a joke into every paragraph or lesson; a precise
example or a brief wry observation can carry the requested voice without slowing the explanation.

Estimate whether the spoken text and demonstration fit the episode's time budget. Base the estimate
on the script's actual language and density, state the counted unit and assumed natural speaking
rate, and add explicit allowance for demonstrations, predictions, and useful silence. Report a
defensible range with those assumptions rather than a falsely precise single duration. If the range
does not fit, split the teaching outcome into two lessons or propose a narrower scope; do not
accelerate speech or remove an essential explanation merely to hit the limit. Treat every estimate
as provisional until the user records the script.

Preserve exact commands, labels, and results when correctness depends on them. If the user supplies
an existing recording, compare it with the script and identify material differences; do not silently
replace what was spoken with new claims. Do not generate a voice recording unless requested.

## Design the provisional storyboard

Design the visual explanation while the script is still editable. Every spoken paragraph must map
to one or more shots, and every shot must identify its paragraph IDs and narration cue. For each
shot, specify the learner-facing visual, initial and final states, motion sequence, exact on-screen
text, required asset or evidence source, and transition to the next shot. Split or revise narration
that cannot be visualized clearly, would overload the screen, or requires evidence that does not
exist; do not postpone those script defects until after recording.

Mark the pre-recording storyboard as provisional. Preserve shot order and paragraph anchors, but do
not invent timestamps or precise durations. Use qualitative pacing only when it changes the teaching
intent, such as holding for a comparison or revealing a result after a prediction. The edited
`narration.wav` and verified `transcript.json` will determine final shot boundaries, reading time,
motion beats, and transitions.

Make motion reveal relationships, sequence, state changes, or cause and effect; use stillness when
movement adds no teaching value. Keep code, labels, diagrams, and critical actions readable. Follow
the course's chosen visual mode and code-presentation medium. If none is recorded, use a light mode
that matches the course's light `index.html` output. Authentic screenshots, IDEs, terminals, and
other evidence may retain their native appearance inside that course treatment.

Map every demonstration to visible evidence. Put short exact learner-facing text and illustrative
snippets directly in `storyboard.md`. For runnable code, substantial output, diagrams, screenshots,
or other independently verified evidence, record the source path and exact state or range to show
rather than copying the whole source. Do not imply an unsupported UI, output, or result. Do not
preselect a HyperFrames implementation technique unless it affects feasibility or the production
handoff.

Keep the post-lesson question out of the storyboard, narration, captions, and video. It remains
static course-page content owned by packaging; do not invent a pause or answer-reveal sequence for
it.

## Align and finalize after recording

When edited narration is available, read `lesson.md`, `narration.txt`, the provisional
`storyboard.md`, final `narration.wav`, word-level `transcript.json`, every declared demonstration
source, and the course's visual constraints. For a course lesson, require effective
`narration-final` state before finalization. If only `narration-source.wav` exists, return it to
`edit-tutorial-narration`. Verify transcript timings against the audio rather than trusting them
blindly, and surface missing, added, or meaning-changing speech instead of animating a false step.

Replace provisional timing notes with the actual audio range and spoken cue for every shot. Use the
speaker's pauses, emphasis, and delivery to split or combine provisional shots, while preserving the
approved teaching purpose and visual evidence. Confirm that on-screen text and source material remain
readable for their real durations. If the recording exceeds an agreed episode limit, identify a
coherent split point or script revision rather than compressing instructional visuals or speeding up
speech.

Mark `storyboard.md` final only when every spoken paragraph is covered, every shot has a verified
audio range, every declared source exists, no critical visual contradicts the narration, and the
overall pace follows `narration.wav`. The final storyboard must still specify paragraph IDs,
narration cues, visual states, motion, exact on-screen text, source paths, and transitions. After it
passes these checks, record `storyboard-final` with the packaged recorder and re-run the validator.

## Deliver and hand off

Before recording, return or save one lesson card, recordable script, and provisional storyboard in
the user-selected project. Check that the stated outcome is taught, the example works from the
stated prerequisites, every paragraph has a
clear reason to exist, the post-lesson question tests that outcome, and `narration.txt` contains
spoken words only without the post-lesson question. Confirm that the provisional storyboard covers
the script without fabricated timing, then tell the user which script version to record. The next
file-based stage records the raw take as `narration-source.wav` and passes it with the approved
script to `edit-tutorial-narration`; do not create an empty audio placeholder. Pass the provisional
storyboard, paragraph identifiers, required demonstrations, post-lesson question, and sources with
that handoff.

Before recording `script-draft`, apply a recall test: if a learner summarized the episode in one
sentence immediately after watching, would that sentence answer the title's primary promise? Also
check whether the post-lesson question can be answered while missing that promise. If the likely
summary names the example, method, or side topic instead, or the question tests only supporting
material, restructure the lesson before handoff.

For a course lesson, record `script-draft` only after these checks and the provisional storyboard
pass. Re-recording `script-draft` after an approved or produced lesson deliberately removes
downstream records and resets release
state; report that invalidation before handing the revision to `review-tutorial-script`. Never record
`script-approved` from this skill. The course validator makes the single non-empty
`## Post-lesson question` section a hard `script-draft` gate. A validator pass proves structural
consistency only; it does not prove that the narration is natural, clear, or ready to record.

After final audio alignment, deliver the final `storyboard.md` with its verified ranges and unresolved
feasibility questions, then hand `lesson.md`, `narration.txt`, `narration.wav`, `transcript.json`, the
final storyboard, and all referenced source files to `build-tutorial`.
