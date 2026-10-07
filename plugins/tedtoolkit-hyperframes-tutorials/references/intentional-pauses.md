# Intentional pauses in narrated lessons

Design a pause around the learner's next action, not around punctuation alone. A spoken comma or
sentence ending may need only natural phrasing; a prediction, comparison, inspection, or result may
need quiet time with a stable visual state. Not every question needs a hold. Decide whether the
learner has something specific to examine or infer before the next spoken claim or reveal.

## Before narration

Write natural, speakable punctuation and paragraph breaks in `narration.txt`. Keep pause lengths,
stage directions, and silent-beat labels out of the read-aloud file. For a consequential pause, put
its intent in the provisional `storyboard.md`: the spoken cue after which it begins, what remains
visible, what the learner can do during it, and the next cue or reveal that ends it. For example:

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
added pause useful. Do not infer pause quality from punctuation or a waveform threshold alone.

`build-tutorial` may add measured silence to an edited audio asset at verified speech boundaries.
Preserve the original Fish WAV. Record each addition's source time, duration, and teaching reason in
a project-local pause map. Use the paced audio and cumulative offsets to update the final storyboard,
all affected visual beats, captions, and composition duration before the formal render. Check the
result at normal speed with captions visible. If the words or delivery need to change, revise the
script through its approval path and regenerate narration instead of editing inside spoken words.
