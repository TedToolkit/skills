# Draft script, provisional storyboard, and visual preview

## Establish the lesson

Read the approved `lesson-outline.md` when one exists, the course outline, the user's sources,
intended audience, desired outcome, prerequisites, and constraints. Select one lesson and preserve
its place in the course.
Carry forward the course's selected tools, framework, and episode duration when specified.
When the course belongs to a series, read the series README first as the shared charter, then read the
course README as its course-specific delta. Also read the course's audience and voice brief when
present. Apply explicit local exceptions without expecting the course README to duplicate shared
audience, terminology, teaching, case, or viewing rules. These artifacts define this course's tone
and examples, not a universal tone for other tutorials. A learner may be new to the target language
while already fluent in programming; avoid teaching beneath that stated baseline.
Read the course's ordering model as well as its outline order. Lesson IDs and file order identify
content; they do not by themselves define what the learner takes next. When the course is organized
by prerequisites, waves, optional branches, or another non-linear model, keep navigation choices in
the course interface or lesson card. For any course order, keep references to other lessons and
their content out of the spoken script and on-screen teaching sequence. A direct entry into this
lesson must make its question and required starting conditions clear without assuming the viewer
watched a particular video. If essential background is too large to recap briefly, state the
required capability and let the learner page route to it. Do not create or plan a future lesson
while drafting this one.
Follow the course's chosen demonstration medium. If it names an IDE, explain the actions needed
to run, observe, or verify this lesson. Show required menu choices in the video when learners must
repeat them; a separate tool guide may retain version-specific details for later reference.
When a video-led course requires setup before a later lesson, make the preparation video's spoken
script and synchronized storyboard show the required actions, success check, and failure route.
For `00.01+`, demonstrate the learner's actual choice and result instead of a generic installation
montage; explain any platform branch needed to reach the common check without making every viewer
perform every branch. Keep the video's single readiness outcome distinct from the course overview
in `00.00` and the subject teaching in Chapter 01.
Keep a companion setup page for changing links or platform detail, never as the only place a viewer
can discover a required step. In the first video that uses the tool, state the ready starting
condition before the demonstration without referring back to the preparation video.
If it supplies demonstration files, keep exact code, diagrams, commands, and observable results in
their real source files and align the spoken explanation to them. Make source files and results understandable
without prior expertise in the example's business domain; define any new rule before relying on it.
For a standalone tutorial, define the outcome directly with the user-supplied brief. Check
source-dependent commands, UI steps, facts, and terminology against authoritative material when
they matter to the lesson. Mark uncertain or version-specific details rather than inventing them.

Before writing, check that the user approved this lesson's current narrative spine. For a new
file-based lesson, require a fresh `outline-approved` stage record; for a standalone lesson, use the
approved outline supplied in the conversation or at the selected location. A direct request to
create or update a named script authorizes that draft write, but does not approve an unreviewed
outline. If the outline is missing or changed, return to `outline-tutorial-lesson` for review.
Existing lessons that predate this stage may continue final audio alignment without retroactively
creating an outline. Carry the approved promise, audience assumptions, connected beats, decisive
evidence, and learner check into the script, lesson card, and provisional storyboard. Wording,
composition, motion, and a supporting example may change as the explanation develops when the
approved reasoning path still holds. If scripting changes the central problem, inference, promised
outcome, or teaching sequence, return the revised spine to `outline-tutorial-lesson` for review
before continuing the draft.
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
apply the [long-form spoken lesson guide](../../../references/long-form-lesson-script.md). Do not use a
minute threshold to classify the format or shorten the learning outcome merely to imitate
short-video conventions.

## Write the lesson and spoken script

Follow the approved outline's teaching sequence while turning its beats into speakable prose. Make
each explanation earn its place against the learning objective. Give the learner enough context to
follow a procedure without padding the script with repeated introductions or decorative narration.
For each decisive beat, coordinate what the learner hears, what changes or remains visible, and
what they should infer. If the approved evidence proves difficult to show or verify, revise the
outline's reasoning path rather than compensating with a stronger claim in narration or an
illustration presented as proof.
For a high-school audience, let their real questions and prior knowledge set the problem's level
and spoken voice; avoid childish framing, forced slang, or a joke that needs its own explanation.
Keep the lesson's center of gravity on its primary promise. A hook, case, diagnostic method, or
demonstration is supporting material unless it is itself the promised outcome. Give supporting
material only the space needed to prove or illuminate the main idea; do not let an increasingly
detailed example become the topic learners are most likely to remember. The opening, largest
explanatory movement, closing, and post-lesson question should all point to the same primary promise.
Choose the smallest code slice that proves the mechanism. Reuse a course case only after showing
the exact starting state this lesson needs; do not require memory of another video's ending or
claim that all lessons modify one continuously growing codebase. Mark a pattern
comparison as an alternative implementation rather than silently folding it into the main example.
Set the amount of guidance from the audience's prior knowledge of this mechanism, not merely from
their familiarity with the programming language. When essential components or states are unfamiliar,
introduce them briefly before showing their interaction. For a new procedure, show a complete
inspectable example, then invite a local prediction or missing step and explain the observed result;
reduce scaffolding as the learner can account for more of the mechanism. Do not force this sequence
into a course guide or a lesson whose outcome does not involve practicing a procedure.
When the outcome asks a novice to repeat an operation, trace the handoff between files and tools:
where the learner opens the source, what changes, how it is saved, and where the next command runs.
A visual replacement of code does not by itself show how to perform the edit. If a command skips a
step, explain which prior state it reuses and what must happen after a source change before the
result can reflect that change. Connect a plausible stale result to a useful check without
expanding the lesson into a full tool model.

For a lesson that introduces a paradigm, principle, code smell, or design pattern, begin with the
concrete requirement change or failure. Show the old behavior and the smallest useful change,
then name the concept. Explain its benefit, implementation and maintenance cost, and a condition
where the simpler approach is preferable. Treat a code smell as a reason to inspect change cost,
not an automatic mandate to apply a pattern. Demonstrate the resulting behavior with the course's
selected test framework or another observable check; avoid a stand-alone terminology lecture.

Write the actual words to be synthesized, in natural spoken language. Give the lesson a coherent arc:
an opening question or concrete problem, the relevant mechanism and example, an observable check,
the limits or cost of the solution, and a natural closing takeaway. Close on the current lesson's
usable result, without a recap of another lesson or a preview of a future one. Adapt this arc to an
introduction or other non-procedural lesson rather than forcing a demonstration.

For the required `00.00` course guide, make the whole course the primary subject. Across the spoken
script and synchronized storyboard, explain what the course teaches, the real problem and scope,
who it is and is not for, its prerequisites, what
completing the Core route enables, what each optional Extension route adds, its distinctive teaching
features, and how its chapters, routes, and sustained case fit together. Give every major content
part meaningful context instead of merely reading headings or lesson numbers. Keep the guide
concise relative to the course
without turning it into a trailer or compressing the first technical lesson into the introduction.
If the course requires setup before practice, state the readiness condition and a concrete success
check in the guide; put the specific preparation video link in the learner page.
Keep detailed dependency tables, evidence matrices, and production metadata on the course page or
lesson card unless a learner needs a specific item to understand the route. Its post-lesson question
should check whether the learner can explain the course scope, audience, gains, features, or learning
route using information actually provided in the guide.
When the guide names a distinctive practice method, a small nontechnical learner action and its
feedback can make the method concrete. Stop before teaching a later lesson's rule or example.

For a course guide that should feel light or game-like, carry one familiar learner-facing problem
through the route: show the starting state, the useful capability gained at each major part, and the
final result. Treat chapters as changes in what the learner can do, not as a spoken table of contents.
Use a small amount of playful language to make a real obstacle or payoff memorable; keep the same
metaphor coherent, and do not imply that the course has points, rewards, gates, or other game features
unless those features actually exist. A novice should still be able to explain the literal course
route and outcome without translating a string of jokes.

Start every spoken script directly with a recognizable consequence, question, result, or action that
begins the lesson. Do not add greetings, welcomes, or ceremonial lead-ins to `narration.txt`. Give
only the context needed to understand that opening. Use the learner's relevant knowledge as
context without claiming they watched a previous or next lesson.
Include an instructor name or role only when the brief requests it or it helps explain the content.
Keep agendas, design rationale, navigation, course metadata, repeated credentials, and manufactured
mystery from delaying the teaching point. Maintain a consistent course voice without forcing
identical opening wording.
When the lesson will test a claim or compare outcomes, leave the deciding evidence for the
demonstration instead of stating the whole procedure and conclusion in the opening. Give learners a
reason to inspect the next action or result without withholding facts they need to follow it.
Make the target of that comparison concrete before the result appears: what does the learner want to
make, explain, or check, and which observation would count? A success message alone is not a
meaningful problem until the desired behavior is clear. Keep the actual result unrevealed until the
lesson has established the expectation it will test.

Treat `narration.txt` as performance text, not as a lesson card read aloud. Write for comprehension
on the first viewing: use speakable sentences, plain transitions, concrete verbs, and one main idea
per paragraph. Do not mechanically convert every outline bullet, production requirement, or
paragraph-map row into narration. Keep planning metadata, inventory-like coverage, detailed course
statistics, dependency bookkeeping, source notes, and acceptance criteria out of the spoken text
unless the learner must hear them to understand or act. Material that is useful mainly when seen
belongs in `lesson.md` or `storyboard.md`. Let the storyboard carry exact labels, routes, code,
comparisons, and visible state changes while narration points to them and explains their significance.
Do not read every on-screen item aloud. Put the meaning of any visual fact needed for the primary
outcome in the narration so the spoken track can teach it. For a file-based course, when exact
visual details still matter but would burden the speech, put a concise learner-facing equivalent
in `lesson.md` under `## Visual descriptions` for the course page; identify the corresponding scene
in viewing order. For a standalone lesson, deliver equivalent learner-facing text with the video.
Do not rely on `storyboard.md` or author notes as the learner's alternative.

Do not invent context-free labels or arbitrary placeholder data merely to make an example feel
specific. Prefer familiar entities, values, objects, or actions whose differences matter to the
question being explored. Introduce every example rule before the result depends on it. When a
specialized term, notation, exact label, or number must be spoken, explain what it means and make
sure a listener can distinguish it without looking at the screen.
For a novice lesson, introduce a term or symbol when its visible use makes the explanation necessary;
do not recite several definitions before the learner encounters their purpose. Let the frame hold
exact syntax, filenames, and command spelling while the voice explains the action or distinction.
Keep spoken precision where a listener needs it to perform the step or understand the result.

Write exactly one post-lesson question that lets the learner recall, explain, choose, predict, or
apply the lesson outcome without merely reporting confidence. Keep it outside the spoken script so
the narration can end naturally. It is static learner-facing text for the course page, not a prompt
that requires an input, submission, answer reveal, score, or completion gate.

In a file-based course, save `lesson.md`, `narration.txt`, and `storyboard.md` inside
`lessons/<lesson-id>/`.
`lesson.md` is the production card: lesson ID and title, objective, audience assumptions,
prerequisites, the teaching arc carried forward from `lesson-outline.md`, paragraph map,
demonstrations, sources, and estimated
duration.
`narration.txt` is the sole TTS text source and contains only the words the selected voice should speak,
as plain-text paragraphs. Do not put a title, Markdown heading, segment label, timestamp, citation,
stage direction, pronunciation note, or production instruction in that file. Never make the speaker
read a heading simply because it appears on the lesson card or screen. Put the exact question in a
`## Post-lesson question` section of `lesson.md`, in the learner's language. Do not copy it into
`narration.txt` or turn it into a spoken pause instruction.
Use a single `## Visual descriptions` section only when the video has necessary details that the
spoken track and captions do not convey. Write it as plain paragraphs or simple list lines for
learners, without production IDs or stage directions; keep it distinct from the post-lesson question.
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
from likely speaking pace; the generated and verified master will determine final timecodes.

Use the course's requested voice. When it calls for humor or allusions, make them illuminate the
technical point and suit the stated audience. Prefer concise, accurate references to primary
sources; put attribution and links in `lesson.md`, and avoid invented quotations or jokes that
obscure a failure mode. Preserve technical precision even when the prose is playful.
When humor serves a lesson, place it where a real expectation, surprise, or human-scale consequence
already exists. Check that the learner can still state the underlying cause without the joke and
that the analogy does not imply a false mechanism. A visual reaction or one light line may be enough;
do not set a joke count or force levity into every beat.
Vary the rhythm of spoken paragraphs: alternate a concrete problem, an action the learner will take,
and an observable payoff where the material supports it. If several consecutive paragraphs merely
name topics or promises, connect them through one developing example or cut the recital. Humor should
offer a quick release of tension, then return to the explanation; do not make every sentence carry a
quip.
When a prediction is part of the teaching, let the learner see the relevant source or prior state,
form an expectation, and inspect the actual result before narrating the inference. Do not pose a
prediction and answer it immediately in the next spoken line merely to check a script box. Plan a
brief visual beat for that thinking time without adding a forced quiz or pause instruction to
`narration.txt`. Do not fill an on-screen prediction with the intended answer before that thinking
beat has occurred. After the reveal, explain what the result proves once; revisit it only to draw a
new distinction or apply it to another case.
For prediction, comparison, or inspection beats that need quiet time, follow the shared
[intentional pause guide](../../../references/intentional-pauses.md). Record the cue, learner action,
stable visual state, and reveal or resumption in the provisional storyboard. Add the needed silence
during production editing instead of encoding its timing with punctuation.
Before handoff, perform an oral-readability pass from `narration.txt` alone, then read the script
alongside the provisional storyboard. Generated audio and exact synchronization are checked after
narration generation. Read the words aloud when possible. Rewrite sentences whose referent is
unclear even with the planned visual, contain several nested clauses,
stack abstract nouns, or present a dense list of terms or numbers. Turn necessary lists into a
conversational progression rather than a recital. Confirm that every name, acronym, identifier,
notation, and numeral has an obvious spoken form and a reason to be heard. Cut repeated setup,
restated definitions, and transitions that merely announce another lesson. Keep a transition
within this lesson when it poses a real unanswered question.
Write narration and learner-facing storyboard text in the course's chosen language. Retain literal
code, commands, source strings, and necessary terms in their original form, but translate ordinary
descriptive words that would otherwise make the speaker switch languages mid-sentence. Read those
mixed-language passages aloud as part of the performance check.
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
as provisional until Fish Audio generates the narration audio.

Preserve exact commands, labels, and results when correctness depends on them. Do not generate
narration before the reviewed script receives explicit human approval.

## Design the provisional storyboard

Choose a visual language that fits this lesson and its audience before filling the storyboard with
screen text. Carry forward an established course identity when one exists, while allowing scene
palettes, illustration, diagrams, photographs, visual humor, and composition to change with the
subject. A course's main color is an anchor, not the only color permitted. Describe the recurring
objects and how their appearance or position can change across the lesson; use different spatial
arrangements when the explanation calls for them rather than making every beat another title and
two-column card. Do not impose a layout, asset, color, or animation quota.
For a course lesson, compare representative frames with `video-style.md`, its referenced series
visual system when present, and prior lesson
references at the intended viewing size. Identify a deliberate difference that helps this lesson in
the storyboard or style contract; resolve an accidental mismatch before requesting script approval.
If a course-wide style revision is needed, update the contract and inspect earlier affected lessons.
Do not revise approved narration or regenerate audio for a visual-only change.
Before requesting script approval or generating narration, make the provisional storyboard visible
as `storyboard-preview.html` beside `storyboard.md` for a file-based lesson. Show a designed frame
for every shot in storyboard order, with its paragraph ID and enough initial/final or intermediate
states to judge framing, visual hierarchy, exact learner-facing text, evidence, and the intended
visual change. Use local or inline assets so the preview opens without a service. This is a visual
draft, not a timed HyperFrames composition or a substitute for the final render. Do not invent audio
durations. For a standalone lesson, provide an equivalently viewable shot sequence in the selected
project. A short moving study may supplement frames when the motion itself needs review.
Use HTML, CSS, SVG, and verified existing assets for the draft wherever they can communicate the
shot. Generate a bitmap only when that specific shot needs imagery those sources cannot provide.
Keep approved generated assets as local source files and reuse them in the video; change an asset
only when a content or visual review identifies a concrete problem. If a bitmap determines a shot's
meaning or visual direction, generate it before script approval so the user can judge the real image.
Otherwise, an accurate SVG or CSS draft may carry the shot until video production.
Inspect the preview at the intended viewing size. Revise `narration.txt`, `storyboard.md`, and the
preview together when a visual problem changes what must be said or shown. Give the user the preview
alongside the script for review while the text can still change; the existing script approval covers
that reviewed pair, so this does not add a separate approval stage.

Design the visual explanation while the script is still editable. Every spoken paragraph must map
to one or more shots, and every shot must identify its paragraph IDs and narration cue. For each
shot, specify the learner-facing visual, initial and final states, motion sequence, exact on-screen
text, required asset or evidence source, and transition to the next shot. Split or revise narration
that cannot be visualized clearly, would overload the screen, or requires evidence that does not
exist; do not postpone those script defects until after narration generation.
For moving objects and scene handoffs, describe what must remain readable as elements enter,
travel, and leave, including when an outgoing label or card gives way to its replacement. Reserve
space for essential text, captions, and connector paths; an arrow must remain legible between the
objects it relates while either object moves. Call out an overlap only when it is an intentional
part of the explanation. The provisional storyboard needs these relationships, not pixel coordinates
or invented timings; production must verify the actual trajectories against the final audio.
For a relationship or process, name the visible entities and show what their connection or state
change looks like. Labels can name things and arrows, paths, gestures, or motion can express actions;
use another visual form when it explains the idea better. Do not turn a spoken list into the same
list of large on-screen sentences by default. Let the case, diagram, image, code, or result carry
information the viewer can see rather than hear repeated.
Consider how an idea enters, develops, and settles on screen, as well as how the sequence feels to
watch. A path might draw itself while explained, a familiar object might change state, or a playful
reaction might mark a surprise. Keep the audience's prior knowledge and the actual visual material
in mind; neither progressive drawing nor constant motion is a universal teaching method.
Read the shots in order as a silent visual sequence. If several consecutive shots only replace a
label or card on the same layout, find a visible action or comparison in the lesson evidence that can
carry the change of thought. Let a recurring object change role, scale, or position as the learner's
understanding changes, and preserve a prior state when it makes the contrast legible. A small visual
reaction may add character at a real mismatch or payoff, but must not invent a result or crowd out
the evidence. Do not add motion just to satisfy this check.
For each teaching beat, decide what the learner hears, sees, and infers. Let a route map, trace, or
comparison show relationships that are cumbersome to say; use a short spoken cue to direct attention
and explain why the visible change matters. Reveal a result after the learner has a chance to predict
when prediction is part of the lesson. Avoid a full written duplicate of the narration over a moving
diagram, but retain short labels, exact code, and optional captions.
Where the lesson's thinking turn depends on a prediction or surprising observation, plan the
visible evidence before its explanatory label, then show enough of the prior state to compare with
the result. Let the narration ask or sharpen the question and explain the inference; let motion show
the process and a stable frame make the evidence inspectable. A reflective beat can be brief and
need not become a forced playback pause or a quiz in the synthesized narration.
For an element that stays on screen across teaching beats, consider whether it helps orientation,
course identity, mood, or visual continuity and whether its motion competes with the current code,
diagram, or evidence. A course badge, step indicator, or ambient graphic can support those roles;
avoid a progress display that misstates progress or merely duplicates the player's controls.
The general HyperFrames creative guidance on persistent decoration is a design option, not a
requirement for a narrated lesson. Put navigation and playback controls in the course player when
they do not teach a relationship inside the video.
Choose the main visible evidence for each shot before adding titles, decoration, or course chrome.
For a recurring footer, route label, shot count, or progress indicator, consider what it communicates
and whether the course player already supplies the same function. If it implies measured progress,
make the units and behavior truthful. An expressive recurring element can remain for identity or
rhythm when it does not obscure the current evidence.
Do not prescribe a shot-by-shot timer as lesson progress. Use highlights and reveals to point at the
specific line, state, or relation as the narration reaches it, then let the evidence remain readable.
At each spoken cue, name the code line, label, object, or result the learner should find. Remove
simultaneous details that are not needed for that inference before adding a highlight; use a local
cue when the necessary display remains complex. Set no universal label count or visual-density quota.
Record the learner's relevant prior knowledge, intended inference, action if any, visible before and
after states, and evidence or feedback for a teaching beat. Use this as a drafting check, not as
required learner-facing metadata or a separate file; the paragraph map or storyboard can carry it.
When a prediction is included, make the feedback explain which
line, state, or rule accounts for the outcome; a bare right/wrong reveal leaves the mechanism hidden.
When a lesson uses a continuing case or staged artifact, carry recognizable inputs, entities, or
structure across the relevant shots. Show what remains, what new problem forces a change, and what
capability or evidence the change adds. A course guide may simplify this to a capability map; it
should still let a learner see how the same case develops instead of presenting unrelated chapter
cards. Do not imply that separate examples share one evolving codebase when they do not.

Mark the pre-generation storyboard as provisional. Preserve shot order and paragraph anchors, but do
not invent timestamps or precise durations. Use qualitative pacing only when it changes the teaching
intent, such as holding for a comparison or revealing a result after a prediction. Include a pause
intent at those beats when the learner needs time to act before speech or visuals advance. The generated
`narration.wav` and timing derived from it will determine final shot boundaries, reading time,
motion beats, and transitions.

Use motion to reveal relationships, sequence, state changes, or cause and effect, and also to give
the lesson rhythm, character, and moments of surprise. Expressive transitions and playful details
need not each encode a separate teaching fact. Give exact syntax and comparisons stable moments when
the learner needs to inspect them. Preserve recognizable before and after states and plan room to
inspect the result at the intended viewing size; verify the actual hold after audio exists.
Segment at a meaningful state or reasoning boundary without imposing a fixed shot length. Keep
code, labels, diagrams, and critical actions readable. Follow the course's chosen visual mode and
code-presentation medium. If none is recorded, select a mode from the audience, teaching material,
existing brand or verified course footage, and intended viewing context; record the choice in
`video-style.md` before the script-and-preview review. Authentic screenshots, applications, and
other evidence may retain their native appearance inside that course treatment.
Check the planned composition at the intended embedded-player size with captions and native player
controls in view. Preserve enough area and time for the code, state, or comparison that teaches the
shot; do not let persistent chrome or an animated ornament become the strongest visual cue. Reserve
space so optional captions do not cover essential code, labels, or results, and plan readable contrast
against the actual background. The final check belongs to the rendered player.

Map every demonstration to visible evidence. Put short exact learner-facing text and illustrative
snippets directly in `storyboard.md`. For runnable code, substantial output, diagrams, screenshots,
or other independently verified evidence, record the source path and exact state or range to show
rather than copying the whole source. Do not imply an unsupported UI, output, or result. Do not
preselect a HyperFrames implementation technique unless it affects feasibility or the production
handoff.

Keep the post-lesson question out of the storyboard, narration, captions, and video. It remains
static course-page content owned by packaging; do not invent a pause or answer-reveal sequence for
it.

## Deliver and hand off

Before narration generation, return or save one lesson card, synthesis-ready script, provisional
storyboard, and viewable shot preview in the user-selected project. Check that the stated outcome is
taught, the example works from the
stated prerequisites, the teaching arc still matches the script's actual progression, every paragraph
has a clear reason to exist, the post-lesson question tests that outcome, and `narration.txt` contains
spoken words only without the post-lesson question. Confirm that the provisional storyboard covers
the script without fabricated timing. For each primary outcome, identify at least one beat whose
spoken cue and visible evidence let a learner explain or apply it; check that any necessary visual-only
fact has an accessible equivalent. Confirm that the preview covers every shot and matches the current
script and storyboard. For a course, confirm the preview uses the shared visual grammar and identify
any intentional lesson-specific variation. Then identify the exact script and preview versions
awaiting approval. The
next file-based stage sends that approved text and the environment-provided saved voice ID to
`generate-tutorial-narration`, which writes `narration.wav` directly. Pass the provisional
storyboard, visual preview, paragraph identifiers, required demonstrations, post-lesson question,
and sources with that handoff.

Before writing the `script-draft` stage record, apply a recall test: if a learner summarized the episode in one
sentence immediately after watching, would that sentence answer the title's primary promise? Also
check whether the post-lesson question can be answered while missing that promise. If the likely
summary names the example, method, or side topic instead, or the question tests only supporting
material, restructure the lesson before handoff.

For a course lesson, record `script-draft` only after these checks, the provisional storyboard,
and its visual preview pass. Re-recording `script-draft` after an approved or produced lesson
deliberately removes downstream records and resets release state; report that invalidation before
handing the revision to `review-tutorial-script`. Never record
`script-approved` from this skill. The course validator makes the single non-empty
`## Post-lesson question` section a hard `script-draft` gate. A validator pass proves structural
consistency only; it does not prove that the narration is natural, clear, or ready for synthesis.
When a rendered-video review or learner trial sends a lesson back, start from the observed answer,
confusion, and video moment rather than a general request to make it more engaging. Compare those
observations with the outline's intended reasoning and the rendered evidence. Revise the spoken and
visual explanation together when the reasoning is missing; return a changed primary promise or
teaching spine to `outline-tutorial-lesson` for review. Use the course state contract to invalidate
and rebuild affected downstream artifacts after a script or storyboard change.
