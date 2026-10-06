# Align storyboard to final narration

## Align and finalize after narration generation

When generated narration is available, read `lesson.md`, `narration.txt`, the provisional
`storyboard.md`, `narration.wav`, every declared demonstration source, and the course's visual
constraints. For a course lesson, require effective `narration-final` state before finalization.
Use the installed `media-use` workflow when available to inspect or transiently align the actual
`narration.wav`. Compare the spoken content with `narration.txt`, but do not save a separate
transcript artifact. Surface missing, added, or meaning-changing speech instead of animating a false
step.
If `build-tutorial` returns a measured pause map for editing room, use the paced audio asset and
its cumulative offsets as the timing source for the final storyboard. Preserve the original Fish
WAV, verify that each added silence falls at a speech boundary, and retime affected shots and beats
before recording `storyboard-final` again. Do not change the approved spoken words just to make the
timestamps fit.

Replace provisional timing notes with the actual audio range and spoken cue for every shot. Write
each range in `HH:MM:SS.mmm --> HH:MM:SS.mmm` form. Keep the ranges ordered and non-overlapping, and
make their paragraph IDs and cues cover every approved spoken paragraph. Use the
speaker's pauses, emphasis, and delivery to split or combine provisional shots, while preserving the
approved teaching purpose and visual evidence. Confirm that on-screen text and source material remain
readable for their real durations. If the generated narration exceeds an agreed episode limit, identify a
coherent split point or script revision rather than compressing instructional visuals or speeding up
speech.
Also check whether the actual delivery leaves time to inspect essential code, labels, and state
changes at the intended playback size. If the audio is shorter than estimated and compresses that
reading or the learner's chance to predict, hold a useful state where possible; otherwise return the
affected script or narration to its owning stage instead of packing more content into each frame.
When a learner must compare two states, keep both or a compact trace available after the transition;
do not make them reconstruct a vanished state from memory. Check a normal-speed preview rather than
using a universal seconds-per-line rule.

Within each shot, map every materially different spoken claim or action to a visual beat anchored to
the corresponding phrase in the generated audio. Record that beat's exact audio range, spoken cue,
visible state or action, and exact on-screen text. A paragraph-level shot boundary alone does not
establish audio-visual alignment: for example, a code change should appear when the narration reaches
the change, and a test result should appear when the narration reaches verification. Keep the beat
ranges ordered and gapless across the shot; explicitly hold an existing visual when the voice does
not call for a new state. Put each beat range on its own line or table row beginning with `Beat`,
directly after its parent shot; label the shot row `Shot` for clarity. This format lets the course
validator distinguish an internal beat from another shot. Check the plan at each semantic change
against `narration.wav`, and revise
the affected beats before calling the storyboard final.

Mark `storyboard.md` final only when every spoken paragraph is covered, every shot has a verified
audio range, every declared source exists, no critical visual contradicts the narration, and the
overall pace follows `narration.wav`. The final storyboard must still specify paragraph IDs,
narration cues, visual states, motion, exact on-screen text, source paths, and transitions. After it
passes these checks, record `storyboard-final` with the packaged recorder and re-run the validator.

## Deliver and hand off

After final audio alignment, deliver the final `storyboard.md` with its verified ranges and unresolved
feasibility questions, then hand `lesson.md`, `narration.txt`, `narration.wav`, the final storyboard,
and all referenced source files to `build-tutorial`.
