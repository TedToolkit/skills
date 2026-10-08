---
name: build-tutorial
description: >-
  Build, revise, verify, and render one narrated animated tutorial in HyperFrames from a
  lesson script, final storyboard, and generated narration audio. Use for production or changes to an
  existing tutorial video. Do not use for course-level curriculum planning, script-only work,
  or storyboard-only work.
---

# Build Tutorial

Produce one editable HyperFrames composition and a checked rendered video from the verified generated
narration and lesson storyboard. This skill also owns production review and revisions to existing
tutorial projects; there is no separate review or revision skill.
For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Read the shared [video style contract](../../references/tutorial-video-style.md) and the course's
`video-style.md` when present, plus any series visual system linked from it. Compare their local
references with available verified lesson frames and short motion specimens.
For an older course without the contract, use its established videos as references and establish
the contract when a course-wide visual redesign is authorized.
Read the [course state contract](../../references/tutorial-course-state.md) and resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md`.
Use the [visual and motion decisions](../../references/evidence-informed-guide/visual-and-motion.md)
when deciding how visual evidence, attention cues, and recurring screen elements appear in the render.
Its animation section informs motion choices without prescribing an effect library, visual style,
or amount of animation.

## Check the handoff

For a file-based course, require `lesson.md`, `narration.txt`, the generated `narration.wav`, final
`storyboard.md`, and every demonstration source referenced by the lesson card or storyboard. Do not
require or create a canonical `demo.md`.
Run the course validator and require effective `storyboard-final` state before a formal render. A
stale script, narration, source, or storyboard returns to its owning workflow; do not
render around the mismatch or refresh hashes without re-verification.
Also inspect the existing project and user delivery constraints. Treat `narration.txt` as the
approved spoken content and `narration.wav` as the final timing source; titles, headings, paragraph
IDs, and production notes in other files are not spoken. Confirm the required artifacts describe the
same lesson and script version. If `narration.wav` is missing, return the lesson to
`generate-tutorial-narration`. If `storyboard.md` is missing or provisional, return the lesson to
`design-tutorial` for timing finalization. Create only an explicitly requested project scaffold or silent preview when
these gates are incomplete, and never claim it is a finished narrated video. If script, storyboard,
and verified narration materially disagree, show the mismatch and resolve the affected upstream
artifact before final rendering.
Use the pre-audio `storyboard-preview.html` as the reviewed visual direction when it exists. Adapt
framing and motion to the final audio and viewing size; a visual refinement that preserves the
approved spoken meaning does not require regenerating `narration.wav`.
Track the final storyboard's stable `Shot S01` identifiers through the editable composition. For a
new file-based lesson, put one static `data-shot-id` on each rendered HTML scene root so the
recorder can compare it with the final storyboard. For a standalone lesson using other composition
tooling, keep an equivalent inspectable scene-to-shot mapping. Reuse the preview's shared components and
assets where they still represent the approved evidence. If production needs a materially different
visual explanation, return it to `design-tutorial` for a revised storyboard and preview before the
formal render.
Inspect the reusable CSS/HTML assets linked from `video-style.md` and identify how their type roles,
surface depth, semantic labels, and safe areas map into the editable composition. Reuse the assets
directly when the renderer supports them; otherwise implement equivalent visual rules and compare
captured frames with the approved preview. Do not treat a stylesheet import or a successful render
as evidence that the intended font was resolved or that the foreground stayed prominent.
For HTML/CSS compositions, load the shared entry directly and keep lesson content and scene logic in
HTML; do not recreate its aesthetic rules in a project-local stylesheet. An isolated renderer may
use a generated copy of the shared tree with corrected relative paths. Check CSS imports and font
URLs after copying, and wait for fonts to load before any frame is captured.
For a new file-based production, keep the editable HTML composition and its source files under
`lessons/<lesson-id>/composition/`. Write `lessons/<lesson-id>/video-source.json` with only an
`htmlEntries` array listing every HTML file relative to the lesson directory, such as
`["composition/index.html"]`. Each entry must load only stylesheets declared in `video-style.md`;
put course variations in the declared shared asset directory, give each shot one static
`data-shot-id` root matching the final storyboard order, and keep local CSS files out of the
composition. Keep generated renders and dependency caches outside this source tree. The recorder
fingerprints all files in the tree at `video-verified`, so later edits require rechecking the video.
Keep static HTML resource links inside the source tree, in declared `sourcePaths` evidence, or in
shared assets linked from `video-style.md`; do not rely on network resources. Review dynamic paths
constructed by JavaScript because the static validator cannot discover every runtime dependency.
Keep inline `<style>` blocks, `style` attributes, and script style writes to scene placement and
motion properties. Move typography, palette, surface, border, shadow, and font decisions into the
declared shared CSS. The validator rejects direct local aesthetic overrides and stylesheet injection;
review runtime-generated styles against the visual contract in the encoded video.
Confirm that the declared source is the one actually used to render; the validator cannot infer
that relationship from the MP4 pixels alone.
Before video verification, inspect the editable HTML/CSS sources that actually render the lesson.
Confirm each rendered HTML entry loads the declared shared stylesheet or its generated render copy,
and that recurring typography, palette, surfaces, and component rules have not been redefined in
lesson-local CSS or inline styles. Reuse shared semantic markup or render components where a pattern
truly recurs; keep scene-specific structure and motion local. Compare the encoded frames with the
approved preview because source reuse alone does not establish visual consistency.
Read the video production contract from `course.config.json`; for an older course that omits it,
use the defaults in the course state contract. Configure the composition and formal render to the
declared aspect ratio, pixel dimensions, integer fps, container, codecs, pixel format, and audio
sample rate. Do not choose a fixed total frame count independently of the final timeline duration.
Confirm that the lesson card contains exactly one `## Post-lesson question`. It belongs to the
packaged course page, not the narration or storyboard. Return a missing question to the lesson
workflow; do not append it to the narration, captions, composition, or video during production.

Inspect the selected project and propose the files or scenes to create or change before writing.
A direct request to build or revise this named tutorial authorizes edits to its project files and
rendered local output. Do not publish or upload the video without separate user authorization.

## Build with HyperFrames

Use the installed HyperFrames skills when available: `hyperframes` for the entry contract,
`hyperframes-core` for composition timing, `hyperframes-creative` for visual hierarchy and
typography, `hyperframes-animation` and
`hyperframes-keyframes` for seekable motion, `media-use` for assets, and `hyperframes-cli` for the
development loop. Follow the project's installed CLI and current official documentation when
versions differ; do not copy a fixed upstream command or timing API into this skill. The official
source is [HyperFrames](https://github.com/heygen-com/hyperframes).

Translate the storyboard into a designed sequence rather than a stack of text slides. Let the
material determine each scene's composition: an illustration, evolving diagram, code trace,
photograph, character, map, or other visual form may take the lead. Reuse course identity without
forcing every scene into one layout. Animate meaningful objects through a process when that process
is the point; fading in a complete replacement card does not show the promised action. Expressive
camera moves, transitions, accents, and visual jokes are also available for pacing and personality.
Choose them by how the sequence reads at normal speed, without a required number or proportion of
effects.
Reuse approved local imagery from `storyboard-preview.html` when it remains accurate. Before the
formal full-length render, inspect frame captures across the shots and preview short intervals around
the riskiest motion, code, results, and caption areas. Use a quick or reduced-resolution preview when
the installed tooling supports it, while checking final-size text at the target player size. Fix
clear composition problems in these local previews before paying the time and compute cost of a
full render. A preview does not replace the required full-resolution render and normal-speed review.
Compare representative frames and a short cross-lesson handoff with `video-style.md` and another
available lesson video or preview. Also compare across courses when a series style applies. Check
the motion vocabulary in normal-speed passages: the stated object remains traceable through a move
or transform, a transition communicates the intended relationship, competing movement does not hide
evidence, and code or results become stable for reading. Keep shared visual identity recognizable
while preserving the lesson's evidence and appropriate variation. If production suggests changing
the course-wide or series-wide style, revise the owning project contract and review affected earlier
videos before declaring the new style stable.
Let a diagram or process develop in time when the viewer benefits from seeing how it forms. Time
attention cues with the event they clarify, and leave room to inspect a result or anticipate the next
one. Use playful movement where it builds curiosity or character. These are creative choices shaped
by the lesson and audience; a static hold, energetic transition, or stylized flourish may each be the
right choice at a different moment.
When the user asks to review a visual direction, show representative frames; include a short moving
passage if motion is what they need to judge. For a new or substantially changed style, consider this
exploration early enough to influence the build. It does not create another formal course stage or
require a preview for every ordinary scene revision.

Start scene and teaching-action alignment from `narration.wav`. Preserve the original Fish WAV.
Use the storyboard's pause intents and the shared
[intentional pause guide](../../references/intentional-pauses.md) to check where the learner needs
quiet time to predict, compare, inspect, or absorb a result. Also listen for natural breathing room
at phrase and sentence boundaries. Prefer pauses already in the recording. Where a consequential
pause is still too short, insert measured silence at a verified speech boundary in an edited audio
asset; retime every downstream scene, teaching beat, caption cue,
and the total composition duration by the same cumulative offsets. Return the measured pause map
to `design-tutorial` so the final storyboard ranges are updated and revalidated before the formal
render; do not leave the production timeline and storyboard with different timestamps. Keep a pause
map with source time, added duration, and teaching reason beside the editable project. Do not cut a
word, stretch speech, insert silence in the middle of a syllable, or add silence without a specific
learner action that needs it.
Review the result at normal speed with the held visual and captions; a brief speech pause and a
longer thinking or result hold serve different purposes. If the spoken wording or delivery itself
needs to change, return to `generate-tutorial-narration` and refresh the storyboard timing. Use local assets where practical and
track their source. Implement storyboarded states and transitions with seekable, deterministic animation so
arbitrary-frame preview and render agree. Keep exact procedural text, code, and visual results
faithful to the verified script, storyboard, and declared demonstration sources. Render short exact
on-screen text from `storyboard.md`; render runnable code and substantial result panels from their
actual source files. Do not substitute an editor capture for a course that chose rendered source
files, or copy a large source artifact into the storyboard.
Before rendering, check that each animation selector matches its intended elements, including its
expected match count. In particular, avoid a broad class selector controlling one object while a
second animation also controls that object's opacity, transform, or position over the same time
range. Resolve competing writes or define their composition explicitly; a successful render or
lint pass does not prove the resulting motion is stable.

Implement every audio-anchored visual beat inside a shot, not just the shot's opening concept.
For each materially different spoken action or claim, show the matching state when that phrase is
heard; do not reveal later results early or leave a generic summary card on screen through several
unrelated statements. Use the storyboard's phrase ranges as the timing source, and check the exact
transition frames on both sides of each semantic change.
Preserve the storyboard's division of work: visible route labels, code, comparisons, and state
changes may carry information that narration does not read verbatim. Give each a clear spoken cue
and adequate reading time. Confirm that the narration conveys any meaning needed for the primary
outcome. For a file-based course, necessary exact visual details need a learner-facing equivalent in
`lesson.md`'s `## Visual descriptions` section for packaging; for a standalone lesson, deliver that
text with the video. Return missing content to `design-tutorial` instead of treating author-only
storyboard notes or speech-only captions as the equivalent. Avoid placing full narration text over
an active diagram; the concise burned-in subtitles and separate transcript remain available.
Give the depicted change a readable movement when it helps the learner follow the mechanism. Keep
an inspectable stable state for exact code or comparison, and preserve a before/after pair or compact
trace when understanding depends on both states. If actual audio timing leaves too little time to
inspect a necessary state, return the timing or upstream script for correction rather than
accelerating the animation.
Preserve recognizable case elements across the shots that depend on them, so an added rule or
capability visibly changes the same model. If the storyboard instead supplies disconnected states
or misleading continuity, return it to `design-tutorial` rather than inventing a new case during
production.
Implement recurring labels, footers, counters, and progress indicators only when the storyboard
gives them a clear learner-facing purpose and defines their meaning. Do not add a progress bar from
a composition template by default. Distinguish course or concept progress from per-shot timing;
keep any retained indicator consistent and visually subordinate to the teaching evidence. Leave
playback progress, pause, and seeking to the actual player unless the approved storyboard requires
a distinct instructional cue.

For a file-based course, create `lessons/<lesson-id>/captions.txt` as a separate, edited subtitle
text with verified timing from the final audio and storyboard. `narration.txt` is the spoken script,
not the subtitle copy. Show exactly one concise line per cue. If it is too long at the intended
player size, shorten the copy without losing meaning or split it at a verified phrase boundary;
replace spoken spellings of exact commands, filenames, and symbols with their written forms where
the meaning remains clear (for example, `Program.cs` rather than “Program 点 C S”). Remove verbal
filler and harmless repetition, but preserve the teaching claim, negation, order, and factual
detail. Do not add unspoken facts or use subtitles to replace necessary visual descriptions. Omit
authoring labels and Markdown in cue text. Use simple blocks separated by a blank line: a stable
paragraph-derived cue ID, a `HH:MM:SS.mmm --> HH:MM:SS.mmm` timing line, then one subtitle
line. Review edited text against the actual audio phrase by phrase, including technical
terms, then check legibility and duration at the intended viewing size.
Map narration timing onto the formal video timeline, including any intentional lead-in and inserted
pauses, and verify the caption cues against the rendered video. If reliable word or phrase alignment
is missing, align the audio and return the corrected ranges to `design-tutorial`; do not silently rewrite storyboard
timing during production. Never estimate cue boundaries by spreading a paragraph evenly over its duration.
Treat `captions.txt` as the canonical editable subtitle source. Generate any encoder-specific ASS
or SRT in a temporary location from those same cues; do not maintain a second subtitle source.
Burn these verified cues into the formal `video.mp4`. Derive the encoder's font, weight, scale,
placement, and contrast treatment from the applicable series visual system and course
`video-style.md`; use an explicit course exception only when the series contract allows it. Match
the approved subtitle specimens in the shared HTML example and shot previews. CSS in an HTML
preview does not automatically style subtitles burned by the video encoder. Check contrast and
single-line fit at the actual embedded-player size over representative light, dark, footage, code,
and result frames as applicable, and keep subtitles clear of essential evidence and controls.
Keep `captions.txt` beside the video for search, transcript navigation, and later revision. Check
the encoded pixels at several cue starts, endings, and line breaks; the mere presence of a subtitle stream does not prove that
text was burned into the picture.

Implement the selected course visual mode explicitly and deterministically. Use the course style,
its series inheritance, and the reviewed shot preview; do not infer video colors from the learner
page or a viewer's OS color-scheme preference. Keep semantic color, typography, diagrams, code
presentation, and recurring chrome consistent across lessons while allowing evidence and teaching
needs to change a scene's treatment. Preserve the authentic appearance of screenshots,
applications, and other source evidence when recoloring would misrepresent it; keep the surrounding
labels and contrast readable.
Before declaring the formal render verified, compare encoded representative frames with the
reviewed preview and course HTML example at the intended player size. Check the actual rendered
glyphs and weights, the project's intended visual hierarchy, evidence
labels, and caption/control clearance. Correct a composition-only mismatch here; return a changed
shared rule to its owning style asset and recheck affected lessons. Follow an explicit project
production contract when it differs from a generic rendering default, and surface the conflict.
For each new file-based lesson, write `video-shot-review.md` after inspecting the encoded video.
Use one table row per storyboard shot in order: `Shot S01`, a checked encoded-frame time in
`HH:MM:SS.mmm` form, `Pass` after any correction, and the observed match or justified
difference from the preview. Include the important moving interval and settled state in that review,
not only a contact-sheet thumbnail. The recorder checks complete shot coverage and fingerprints
this author-only record; it cannot determine whether the human judgment was correct. Do not record
`video-verified` while any shot has an unresolved material mismatch. Keep the review record out of
the learner release.

## Verify and deliver

Run the available HyperFrames validation and render commands. Inspect representative frames at
the start, middle, and end of each shot, through important stable holds, and around transitions;
listen to the finished audio and check shot, action, and caption cue timing against the rendered video.
For every entrance, exit, handoff, and movement of a teaching object, inspect the encoded video's
transition interval at normal speed and step through nearby consecutive frames when a collision or
flicker could be brief. Check readable text, labels, cards, arrows and their endpoints, plus the
caption and player-control area. Follow a moving object's whole path, not just its settled frame;
an outgoing element must clear a reused area before the incoming one occupies it unless the overlap
is an intentional, readable part of the transition. Treat unintended occlusion, doubled text,
connector collisions, or frame-to-frame disappearance as a failed production check. Fix the owning
layout or animation, render again, and recheck the affected interval and its boundaries. Automated
layout checks and sparse contact sheets are useful signals but cannot replace this viewing check.
Also watch the movement between sampled frames: a contact sheet can show visual variety but cannot
show whether a filter, transformation, or causal change actually happens. If the sequence feels like
the same layout repeatedly replacing narration with text, revise the affected scenes using the
lesson's visual language. Treat this as a viewing judgment, not a fixed layout-diversity score or
ban on quiet scenes.
Check readability at the target
resolution and at the intended embedded-player size, at normal playback speed. Watch the complete
render without relying on the script or storyboard: check whether the learner can follow the case,
see why its state changes, demonstrate or explain the primary outcome, and answer the post-lesson
question using what the video actually teaches. When representative learners are available, use
their explanations and application errors to find confusion; do not treat a personal preference
score, watch time, or visual polish as proof of learning.
For a trial with representative learners, use the lesson's main explanation or application question
and a nearby transfer situation; ask separately what held interest and where they became confused.
Keep the prompts and viewing conditions comparable when checking a revised version. Note the
learner's answer or action, the relevant video moment, the expected reasoning, and the observed
difference. Record enough to guide a correction without collecting identifying details or reducing
the trial to a liking score. Do not require a fixed number of learners or a pass percentage, and do
not block ordinary production when a learner trial is unavailable.
During that full viewing, inspect persistent overlays and ambient motion at moments when the learner
must read code or follow a change. Keep elements that contribute to understanding, identity, or mood
without pulling attention from the current evidence. Remove or quiet redundant progress bars and
other chrome; use the course player's controls for ordinary
playback navigation. Reconcile a storyboarded element with `design-tutorial` if removing it would
change the agreed teaching plan.
Review the composed player with captions and native controls visible. Check whether a persistent
element attracts attention away from the current line, state, or result; whether a highlight appears
with the matching spoken cue; and whether a progress indicator communicates what it claims across
shot boundaries. At normal speed, check whether a viewer can locate the referred-to code line,
label, or result as the cue is spoken, then compare the settled result with its prior state or trace.
With captions enabled, check that neither captions nor controls obscure essential evidence and that
code and labels remain legible against their actual backgrounds at the embedded-player size. Fix
layout, contrast, timing, cueing, or unnecessary template chrome in the owning artifact and recheck
the affected render.
For each primary outcome, locate the rendered beat that teaches it and check the spoken cue,
visible evidence, and final inspectable state together at normal speed. A lesson-card promise
cannot substitute for a missing rendered explanation.
Fix material gaps in the owning script, storyboard, or composition before marking the video verified.
Route an observed failure to the earliest stage that can correct its cause: an inaccurate or changed
lesson promise to `outline-tutorial-lesson` or course planning; a missing inference or misleading
analogy to `design-tutorial` and `review-tutorial-script`; an absent, premature, or unreadable
visual state to `design-tutorial` for storyboard or audio-range correction, or to this skill for a
composition correction. A spoken-content change returns to `design-tutorial`, then requires renewed
script approval, narration generation, and audio alignment. Use the course state contract to
revalidate and rebuild downstream work;
do not patch a later artifact to conceal an upstream defect. When trial evidence is inconclusive,
report the uncertainty rather than claiming that a preference or one answer proves effectiveness.
Inspect the encoded output to confirm its dimensions, fps, container, codecs, pixel
format, and audio sample rate match `course.config.json`. Also check completeness of all spoken
paragraphs, factual visual fidelity, missing assets, clipped
text, a natural ending without an appended post-lesson question, ending audio, and any agreed episode duration. Fix
material problems and render again. If the generated narration makes the lesson longer than agreed, report
the actual length and seek a coherent lesson split or script change; do not silently speed up the
narration. On later revision requests, change only affected scenes and repeat checks for those
scenes plus their boundaries.

In a file-based course, write the formal lesson render as `lessons/<lesson-id>/video.mp4`; this file
is the publication signal used by course packaging. Also deliver the aligned `captions.txt`.
Deliver the editable project, rendered video, and a concise note of validation performed and any
remaining limitation. State separately whether representative learners tried the video and what
their explanations or transfer attempts showed. If no learner trial occurred, say so without
presenting production verification as a learning-effect result. If rendering cannot run in the
environment, preserve the project and report the exact blocker rather than presenting a preview as
a final video.
After the formal video and canonical caption text pass every production check, record `video-verified`
with the packaged recorder and re-run the validator. A preview does not advance this state without
the captioned video and verified caption text. `video-verified` attests to production checks, not to a
measured learning gain or universal appeal to the target audience.
