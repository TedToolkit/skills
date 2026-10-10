# Intentional pauses in narrated lessons

Design a pause around the learner's next action. A prediction, comparison, inspection, or result may
need quiet time with a stable visual state. Not every question needs a hold. Decide whether the
learner has something specific to examine or infer before the next spoken claim or reveal.

## Before narration

Write punctuation and paragraph breaks for natural spoken language, not to control the length of
instructional pauses. Fish S2 documents `[break]` and `[long-break]`, but they do not guarantee
silence or a number of seconds. In a full lesson, a pause cue can produce a breath, filler, or
disconnected delivery; do not use one at every paragraph boundary to enforce pacing. Treat any
included cue as provisional until its actual voice and surrounding text can be auditioned after
generation. When clean, predictable quiet is needed, synthesize continuous speech and add measured
silence at the verified boundary after narration.
Keep exact pause lengths, stage directions, and silent-beat labels out of `narration.txt`. For a
consequential pause, put its intent in the provisional `storyboard.md`: the spoken cue after which
it begins, what remains visible, what the learner can do during it, and the next cue or reveal that
ends it. For example:

> Pause intent after the prediction prompt: hold the source and an unanswered result area while the
> learner forms an expectation; reveal the observed output only when narration reaches the run.

This is an authoring note, not a required template or a fixed duration. Allow for it in the episode
estimate, but do not assign exact timestamps before the generated voice exists. Check the visual
preview for a useful stable state and an answer that remains unrevealed.

## After narration

Listen to the generated audio with the provisional storyboard at normal speed. At each planned
pause, distinguish the natural speech gap from the time needed for the stated learner action. A
question followed immediately by another spoken instruction may still leave inadequate quiet time;
a longer demonstration may already provide enough. If the recorded delivery is sufficient, use its
actual timing. If it is short, identify the speech boundary and the visual hold that would make an
added pause useful. Judge the recorded timing with the visual state rather than inferring it from
the script or a waveform threshold alone.

`build-tutorial` adds any needed instructional silence during editing, at verified speech boundaries.
Preserve the original Fish WAV. Record each addition's source time, duration, and teaching reason in
a project-local pause map. Use the paced audio and cumulative offsets to update the final storyboard,
all affected visual beats, captions, and composition duration before the formal render. Check the
result at normal speed with captions visible. If the words or delivery need to change, revise the
script through its approval path and regenerate narration instead of editing inside spoken words.
