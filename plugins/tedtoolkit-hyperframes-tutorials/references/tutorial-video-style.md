# Tutorial video style contract

Use this contract when establishing, applying, or reviewing a tutorial's visual direction. It
describes how to make project-specific style decisions; it supplies no default palette, font,
illustration, layout, transition, or subject matter. A style document is an authoring contract,
not a learner document or a substitute for a lesson's storyboard.

## Scope and inheritance

For a multi-course series, an optional series-level visual system records decisions that must
remain recognizable across courses. Keep it in one linked project file, such as
`visual-system.md` or `series-standards/visual-system.md`, outside the learner-facing series
README. State which rules are invariant and which may vary by course. A series style is useful
when several courses need one identity; do not create it for a standalone lesson or merely because
the series plan exists.

For a file-based course, root `video-style.md` records the course's identity, its inheritance from
the series system when one exists, explicit course exceptions, and choices shared by its lessons.
Link the series file and shared assets using course-root-relative Markdown paths. A course registered
in an ancestor `course-series.json` may resolve visual references inside that series root; a standalone
course resolves them inside its own root. Do not copy series rules into the course document.
For a standalone lesson, use its selected brief or existing local style document; do not invent a
course or series hierarchy. A lesson's `storyboard.md` and preview decide the content, composition,
and timing of its individual shots. Covers adapt the established identity at thumbnail scale under
their own cover contract; the cover layout does not dictate every video frame.

## Shared asset locations and direct reuse

Before recording a new or revised `script-draft`, require reusable CSS and an HTML example linked
from `video-style.md`. Store series-wide assets once under `<series-root>/series-standards/`; store
them under `<course-root>/visual/` for a standalone course. Keep CSS entry files and HTML examples
inside this shared directory, with component subdirectories when useful. Filenames are project
choices: declare the maintained entry paths once in the style contract and preserve coherent
existing paths. Keep font binaries and their source/license records in `<shared-directory>/fonts/`.
This contract prescribes asset ownership, location, and loading; the project chooses the actual
typefaces, weights, colors, surfaces, component shapes, and visual effects.

Each course links the same series CSS/HTML assets directly. Generate lesson previews and new
file-based editable video compositions as HTML that loads those stylesheets; do not create per-course or
per-lesson copies of the shared CSS, `@font-face` declarations, or component styling. HTML contains
the lesson's content, semantic classes, and scene structure. Keep necessary shot-specific placement
and deterministic animation parameters with the shot; move a repeated rule into the shared CSS.
Place an authorized course variation in a named stylesheet inside the shared directory, loaded after
the base entry and declared in `video-style.md`. Do not use inline aesthetic overrides to conceal a
conflict with the approved shared rules. Examples demonstrate reusable markup without dictating
every shot's layout.
Small shared markup patterns or render components may remove repeated scene structure when the
composition tooling supports them. They do not replace lesson-specific HTML for the teaching
object, evidence, and deterministic animation. Keep the reusable source in the shared directory;
do not copy whole example pages into lesson projects as templates.
For new file-based productions, keep the editable, source-only HTML composition under
`lessons/<lesson-id>/composition/` and list every HTML file in `video-source.json`. Every declared
HTML file loads only CSS linked by `video-style.md`; keep course variation in the declared shared
directory, not a lesson-local stylesheet. Give each rendered shot one static `data-shot-id` root
matching the final storyboard order. The recorder checks this source handoff and fingerprints
every file in the composition directory at video verification. Keep generated render outputs and
dependency caches outside that source directory so its fingerprint represents the editable project.
Static HTML resources outside that directory must be declared as lesson evidence in `sourcePaths`
or linked from `video-style.md` as shared visual assets; their fingerprints then belong to the
corresponding evidence or visual dependency record. Keep external network resources out of the
composition. Dynamic references assembled by JavaScript still require production review.
In new examples, previews, and compositions, keep inline CSS to shot placement and motion. The
validator rejects inline typography, palette, surfaces, borders, and similar shared visual rules,
including direct JavaScript style writes and stylesheet injection. Put those decisions in the
declared shared CSS. This source lint catches common direct overrides; inspect runtime frames for
indirect styling and generated elements that static analysis cannot establish.

Use relative `<link rel="stylesheet" href="...">` paths from each HTML file to the declared entry.
Resolve CSS `@import` and `url(...)` paths relative to the CSS file, including font URLs; avoid host
absolute paths and network-only dependencies. Record selected font files, supported weights,
fallback roles, and redistribution terms in the project contract or linked font record; bundle only
fonts the project is authorized to redistribute. Wait for `document.fonts.ready` before captures,
then inspect actual glyphs, weights, fallback, and mixed-script alignment. A family declaration or
`document.fonts.check()` alone does not establish the face actually used for every glyph.

When packaging or copying a composition into an isolated render workspace, copy the shared asset
tree as a unit and preserve or rewrite its relative references. Treat this as a generated dependency
snapshot, not a second editable style source. Include font licenses when distributing font binaries.
After a filename or directory change, update all affected Markdown links, HTML links, CSS imports,
font URLs, render-copy steps, and packaging paths together, then check the dependency graph again.

Keep the precedence explicit: an applicable series visual rule and production contract govern the
course; `video-style.md` records authorized course variations; the storyboard chooses each shot's
teaching composition within those rules. An HTML/CSS asset implements the contract but does not
silently override it. A project-specific production decision takes precedence over a generic skill
default when both cannot be followed; surface the conflict before rendering. Record visual-only
changes in the owning style asset, then review affected previews and renders. Visual fingerprints
recorded at `video-verified` make that video claim stale after a dependency changes; recheck and
re-record it, rebuilding the pixels when needed. CSS changes alone do not invalidate approved spoken audio.

Keep production parameters such as dimensions and codecs in the production contract. Keep exact
code, outputs, measurements, and tool states in lesson sources or verified recordings. A style
document may specify how those materials appear and how real evidence differs from illustration,
but must not duplicate them or turn a current example into a permanent template.

## Describe a visual grammar that can grow

Choose the categories the project actually uses from this open inventory; add others when a new
teaching or presentation need warrants them:

- **Identity:** course mark, title treatment, chapter or route cue, opening and closing treatment.
- **Reading:** type hierarchy, code, labels, callouts, tables, charts, and subtitle treatment.
- **Teaching:** objects and relationships, state changes, comparison, prediction, reveal, attention
  cues, and time to inspect a result.
- **Evidence:** authentic footage or output, sourced excerpts, conceptual diagrams, predictions,
  and their visible provenance or status.
- **Motion:** entrances and exits, tracking, transformation, camera movement, transitions, pauses,
  and continuity between scenes.
- **Media:** illustrations, SVG diagrams, photographs, screen recordings, and software interfaces.

For each recurring element or pattern, record only decisions another author can apply and a
reviewer can recognize: its teaching or identity purpose, when to use it, what stays recognizable,
what may change, what misuse would mislead or distract, and a linked example where visual judgment
is needed. Name semantic color roles and non-color cues rather than relying on color alone. Describe
how authentic evidence keeps its provenance and recognizable appearance; label a simulation or
prediction so it cannot be mistaken for a verified result. Do not require one component shape,
scene layout, motion effect, or number of elements across unlike lesson types.

An element inventory is expandable, not a closed asset catalog. When adding an element, explain
which existing identity, semantic, evidence, and motion rules it inherits or deliberately changes.
If the change alters a shared rule, revise the owning series or course contract once and inspect
the affected earlier work; do not copy a new rule into every lesson.

## Govern subtitle appearance across the series

Record the subtitle visual treatment in the series visual system when one exists, or in course
`video-style.md` for a standalone course. Specify the typeface and mixed-script fallback, weight,
size at the intended embedded-player scale, alignment, position, safe area with native player
controls, and contrast treatment over the backgrounds the series actually uses. Describe when an
outline, shadow, or backing surface is needed and which course variations are allowed. Check
legibility over light and dark scenes, authentic footage, code, and result frames as applicable;
do not prescribe a universal color or pixel size irrespective of the canvas. Reserve space so
subtitles never hide essential evidence, even during movement or with controls visible.

Show representative subtitle specimens in the shared HTML example and lesson shot previews using
the declared visual rules. These specimens establish appearance and clearance, not final cue text
or timing. The editable lesson composition holds subtitle words and cue times.
Because the formal video burns subtitles into its pixels, derive the encoder's subtitle styling
from the visual contract and compare encoded frames with the specimens. Shared CSS can style HTML
previews, but an ASS or other encoder style needs its own matching implementation; do not assume
the CSS link styles burned-in subtitles. An appearance change requires affected previews and
videos to be checked again, without changing approved narration solely for that reason.

## Constrain motion by meaning and continuity

Define a small motion vocabulary by **function** rather than by a fixed effect quota. For each
recurring movement, describe the relationship or event it communicates, its starting and ending
states, the object identity that must remain trackable, its attention target, and when the result
must become stable enough to read or compare. Use motion to reveal causality, orient between views,
direct attention, or give a meaningful moment emphasis; an expressive flourish may establish tone
when it does not hide the lesson's evidence.

Useful functions to consider are construction of a process, tracking one object, switching views,
comparing before and after, focusing attention, and handing an object into the next scene. Record a
pattern only when the project uses it. A motion rule can be as compact as: “The same labeled object
moves from input to result; retain its label during travel; pause on the verified result before the
next explanation.” Add a local example and a counterexample when words alone leave the boundary
unclear.

Record relative rhythm and any project-specific easing or timing choices where consistency matters.
Do not impose UI-transition durations on narrated teaching sequences: derive actual holds and
changes from the narration, amount to read, learner prediction, and final playback. Avoid unrelated
simultaneous movement around exact code, measured results, or a decision the learner must inspect.
Show how a concept survives a camera move or scene transition through an unchanged label, value,
shape, position, or other traceable cue. A static frame must still convey the essential fact when
motion is unavailable or the video is paused. Review a moving passage at normal speed; static
frames alone cannot validate motion, easing, or reading time.

## Supply examples that test the rules

Link a few locally viewable specimens covering the different situations the project actually uses,
such as an explanation, an authentic demonstration, and a result comparison. Prefer the lightest
format that proves the decision:

- PNG or SVG frames for composition, hierarchy, color, labels, and evidence treatment;
- local HTML for interchangeable content, multiple states, or viewing-size checks;
- a short playable clip or animation preview when transformation, transition, or rhythm carries
  the style or teaching meaning.

A still does not prove motion. Do not require all formats, a fixed specimen count, or a fully
rendered lesson before the style can be reviewed. Mark each specimen as concept, provisional
preview, authentic source, or verified final frame; name its lesson or scenario and the rule it
demonstrates. A reference is an example of a rule, not a layout every shot must repeat. Link local
references with course-root-relative Markdown paths in `video-style.md` so the course validator can
check that they exist. For a series-level file, resolve its specimen links relative to that file.
The required reusable CSS and HTML example are authoring assets, not additional learner documents.
The HTML example must load the declared CSS, and each new lesson's `storyboard-preview.html` must
load that same shared CSS; neither may load an undeclared stylesheet. Verify the browser's computed font face and weight, missing glyphs,
readability, and foreground hierarchy on actual frames at the intended viewing size; a stylesheet
link or a successful structural check does not prove visual fidelity.

## Review and revise

Review representative frames at the intended viewing size and motion passages at normal speed.
Compare unlike lesson situations and, for a series, adjacent courses. Ask whether a viewer can
recognize the shared identity, follow the same object through a change, distinguish observation
from prediction or illustration, read exact evidence, and understand the purpose of a transition.
If the answer fails, identify the rule or specimen to revise rather than demanding identical
layouts. A style-only revision does not alter approved spoken words or require a new WAV. If it
changes an explanation, evidence, or spoken cue, return to the owning lesson stage.

The course recorder requires reusable CSS and HTML references for each new or re-recorded script
draft, and checks that the HTML example and lesson preview load a common declared stylesheet.
At video verification it checks the registered editable HTML composition and records its source
fingerprints. The validator keeps checking these dependencies; it cannot prove that the encoder
actually used the declared source, or certify visual similarity, font resolution, or motion quality.
Older records remain readable without the new markers. Add the assets when the course next enters
lesson design rather than inventing retroactive approval.
