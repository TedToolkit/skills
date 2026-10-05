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
Name the series file by a course-root-relative path in prose rather than a Markdown link: the
existing course validator permits local specimen links only inside the course root. Resolve that path when reading
the series system; do not copy the series rules into the course document.
For a standalone lesson, use its selected brief or existing local style document; do not invent a
course or series hierarchy. A lesson's `storyboard.md` and preview decide the content, composition,
and timing of its individual shots. Covers adapt the established identity at thumbnail scale under
their own cover contract; the cover layout does not dictate every video frame.

Keep production parameters such as dimensions and codecs in the production contract. Keep exact
code, outputs, measurements, and tool states in lesson sources or verified recordings. A style
document may specify how those materials appear and how real evidence differs from illustration,
but must not duplicate them or turn a current example into a permanent template.

## Describe a visual grammar that can grow

Choose the categories the project actually uses from this open inventory; add others when a new
teaching or presentation need warrants them:

- **Identity:** course mark, title treatment, chapter or route cue, opening and closing treatment.
- **Reading:** type hierarchy, code, labels, callouts, tables, charts, captions safe area.
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

## Review and revise

Review representative frames at the intended viewing size and motion passages at normal speed.
Compare unlike lesson situations and, for a series, adjacent courses. Ask whether a viewer can
recognize the shared identity, follow the same object through a change, distinguish observation
from prediction or illustration, read exact evidence, and understand the purpose of a transition.
If the answer fails, identify the rule or specimen to revise rather than demanding identical
layouts. A style-only revision does not alter approved spoken words or require a new WAV. If it
changes an explanation, evidence, or spoken cue, return to the owning lesson stage.

The course validator can check that a newly recorded script draft has a non-empty `video-style.md`
and that linked local course references exist; it cannot certify visual similarity or motion
quality. Existing courses without this file keep their prior records. Create or revise the contract
when their visual direction is next authorized for change rather than inventing retroactive approval.
