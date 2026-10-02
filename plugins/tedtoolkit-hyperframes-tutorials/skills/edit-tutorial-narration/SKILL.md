---
name: edit-tutorial-narration
description: >-
  Turn one or more recorded tutorial narration WAVs into a verified narration.wav that matches the
  approved narration.txt exactly, with a normalized transcript for storyboarding. Use when human
  recordings need paragraph-level take selection, missing-paragraph pickup requests, cleanup,
  silence or mistake cuts, and delivery normalization before animation production. Do not use to
  write the script, design shots, mix music or sound effects, or render the lesson video.
---

# Edit Tutorial Narration

Turn the approved script and raw human recordings into the stable voice master that controls the
lesson's final timing. This skill owns narration post-production only. Keep music, sound effects,
and composition-level mixing out of the voice master.
For a file-based course, follow the shared
[tutorial workspace contract](../../references/tutorial-workspace-layout.md).
Read the [course state contract](../../references/tutorial-course-state.md) and resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs) and
[`record-course-stage.mjs`](../../scripts/record-course-stage.mjs) relative to this `SKILL.md`.

## Establish the source and edit boundary

Read `lesson.md`, `narration.txt`, and every supplied raw recording. Accept one continuous recording,
multiple sequential recordings, alternate takes, and pickup recordings; do not require the human to
combine them first. In a file-based course, preserve a single original as
`lessons/<lesson-id>/sources/narration-original.<ext>` or multiple originals as stable numbered files
such as `narration-original-01.<ext>`. Create a lossless PCM working WAV for each original. Basic
conditioning may include channel/sample-format normalization, rumble removal, conservative steady
noise reduction, and de-clicking, but it must not change timing, remove breaths or pauses, or cut
speech. Preserve the source-to-working-file map. When the course contract requires one
`lessons/<lesson-id>/narration-source.wav`, concatenate the complete working WAVs without semantic
cuts and preserve their reel offsets. Never overwrite an original or source master with an edited
result.

For a course lesson, run the validator and require an effective `script-approved` state before
editing. If the script snapshot is stale, return it for review and explicit approval instead of
editing against an obsolete recording contract.

Match the blank-line-separated paragraphs in `narration.txt` to the stable paragraph identifiers in
`lesson.md`. Transcribe every recording with word timestamps and compare it with the approved text
before cutting. Identify missing lines, changed technical claims, unclear words, unusable takes, and
recorded material that is not in the script. Do not synthesize, reorder, or silently rewrite speech
to conceal a material mismatch.

Treat automatic transcription as a locator, not as proof of what the speaker said. A low-confidence
token, homophone, repeated ASR output, or disagreement with the script does not by itself justify a
pickup; a clean transcript does not prove that a take is complete. For each suspected mismatch,
inspect the localized audio and compare a prompt-free transcription with a script-guided local
transcription when useful. Resolve the words from the recording itself, and mark the passage
uncertain when the audio cannot support a confident decision.

Before calling a pickup list complete, build a paragraph-level coverage map that identifies one
complete chosen take and usable range for every approved paragraph. Render a temporary diagnostic
rough cut from the best available material, then re-transcribe and inspect that complete cut in short,
overlapping regions. Confirm that every approved paragraph occurs once and in order, and that no
false start, repeated sentence, or off-script remark remains. If the human supplies pickups, repeat
this whole-cut coverage audit before saying that no further recording is needed. Keep diagnostic
cuts outside the canonical lesson artifacts.

Lead the inspection result with a pickup list that quotes every complete paragraph from
`narration.txt` that the human must record again. Identify it by paragraph ID and give a brief reason.
Do not ask for isolated replacement words or splice together a paragraph from phonemes when no
complete usable take exists. Do not include time positions in the user-facing pickup list or make
the human find the words from timestamps; timestamps remain internal evidence
for editing and alignment. Separate paragraphs that truly need a new recording from false starts,
repeated takes, and pauses that editing can repair. If no pickup is needed, say so explicitly. Return
missing or meaning-changing speech for a script decision or re-recording even when editing cannot
yet proceed.

Before an open-ended edit, show the proposed take selections, removals, retained pauses, and audio
processing. A direct request to edit this named narration authorizes changes to derived audio and
transcript data in that lesson directory; it does not authorize replacing the approved script or
publishing any output.

## Produce the narration master

Use the installed `media-use` workflow for transcription and physical audio operations when
available. Work from the conditioned PCM working WAVs, or from `narration-source.wav` when the course
contract has created that lossless consolidated source; never edit from a compressed derivative.
Select the best complete takes; remove false starts, repeated takes, handling noise, and accidental
dead air; and keep natural spoken pacing. Preserve intentional rhetorical or demonstration pauses
when they help the explanation. Do not introduce or retain a special response pause for the static
post-lesson question, which is not part of `narration.txt`.

For recordings with alternate takes, pickups, repeated sentences, or several cuts, read the
[auditable narration-edit workflow](references/narration-edit-workflow.md) and resolve the packaged
[`narration-edit.mjs`](../../scripts/narration-edit.mjs) relative to this `SKILL.md`. Use its stable
paragraph plan to prove that every approved paragraph is selected exactly once from a named WAV
before rendering.
Run its strict transcript verification on the rendered semantic cut and again on the actual final
master. Do not use a passing automatic report as a substitute for listening.

Use ASR timestamps to find a region, not as exact cut boundaries: word timestamps may be coarse,
zero-length, or shifted. Place boundaries from the waveform and audible room tone with enough handle
to preserve initial consonants and trailing syllables. Prefer boundaries in silence or steady room
tone, use short fades or crossfades where needed, and inspect every seam in the rendered audio. When
a word is clipped, move or replace the source range; never repair it by inventing timing or splicing
phonemes into speech the human did not deliver.

Read [loudness targets](references/loudness-targets.md) when choosing or explaining a level target.
Measure integrated loudness and maximum true peak with an ITU-R BS.1770-5-compatible meter; the ITU
measurement recommendation does not itself prescribe one delivery loudness. Prefer the course or
named destination's specification. Treat `narration.wav` as a speech stem when it will later be
mixed with music or effects: make it internally consistent and leave suitable headroom, but do not
claim that the future full mix meets a final-program target. Measure and normalize that mix again at
its owning stage.

Apply only source-justified cleanup such as rumble removal, conservative noise control, de-clicking,
level correction, and limiting. Avoid processing that changes the speaker's identity or makes edits
audible. Default the delivery master to 48 kHz PCM WAV, mono for ordinary single-speaker narration,
with a recorded loudness and true-peak target suitable for the course. For a standalone speech-only
online lesson with no course or destination specification, use the house default of -16 LUFS
integrated with a +/-1 LU acceptance band and no true peak above -1.5 dBTP. This is a web-speech
default with conservative encoding headroom, not a universal broadcast standard. Accept usable
44.1 kHz raw recordings and convert only the derived working or delivery audio as needed; sample
rate alone is not a reason to request a pickup. Do not bake background music, sound effects, reverb
used for scene design, or composition automation into this file.

Complete semantic take selection before breath or pause processing. Attenuate an objectionable
breath only after confirming that it is outside speech; prefer a modest, reversible local gain
reduction to hard deletion or a global gate, and audition the following consonant for damage.
Preserve natural breathing and intentional pauses. Re-transcribe after cleanup because breath
reduction, silence changes, and resampling can invalidate earlier timing evidence.

When combining recordings, match usable speech level and background character between takes before
the final program-wide loudness pass; do not normalize each sentence independently. Apply
de-clipping only where measured clipping and an audible benefit justify it. Use a measured or
two-pass normalization workflow for a formal output, then measure the rendered master again instead
of treating filter settings as proof that sample rate, channels, loudness, true peak, or clipping
meet the delivery contract. Report the target, tolerance, measured integrated loudness, and measured
maximum true peak in the handoff.

Write the approved result as `lessons/<lesson-id>/narration.wav`. Also write
`lessons/<lesson-id>/transcript.json` as the normalized flat word array consumed by HyperFrames, with
stable word IDs, spoken text, and final start and end seconds. Generate it from the edited master,
not the raw recording, and correct technical words against `narration.txt` without inventing speech.
This JSON is internal production timing, not a learner subtitle file. Preserve sufficiently precise
word or phrase alignment for production to derive readable subtitle cues from the approved text and
final audio. Mark uncertain alignment in the handoff and stop final storyboarding when it affects a
shot; do not invent precise timing or distribute a paragraph's duration evenly across its words.

## Verify and hand off

Require bidirectional agreement with the text contract. Text-to-audio coverage proves that no
approved paragraph is missing; audio-to-text review proves that no false start, repeated take,
recording-room remark, or other unapproved speech remains. A plausible overall transcript is not
enough when either direction fails.

Listen across every edit boundary and at the beginning and end of the file. Confirm that all approved
spoken paragraphs occur once and in order, technical words remain intelligible, no required phrase
was clipped, retained pauses sound intentional, the lesson ends naturally, and the file
meets the chosen format, peak, and loudness targets. Re-run transcript alignment against the final
file rather than reusing timestamps from the raw recording.

Deliver `narration.wav`, `transcript.json`, and a concise report that begins with any exact paragraphs
still requiring pickup, without time positions, followed by removed or otherwise unresolved
material. A narration is ready for final storyboarding only when its spoken meaning matches
`narration.txt` and the transcript reliably covers the final audio. Pass the final master and
transcript back to `design-tutorial` for final storyboard timing; `build-tutorial` will use the same
verified alignment to create learner-facing `captions.vtt` against the final video timeline and will
derive SRT only when a named delivery platform requires it.

After the voice master and flat word transcript pass every check, record `narration-final` with the
packaged recorder and re-run the validator. Do not advance state while any word timing that affects a
shot remains uncertain.
