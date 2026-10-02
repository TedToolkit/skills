---
name: edit-tutorial-narration
description: >-
  Edit and verify one or more recorded tutorial narration takes against the approved spoken script,
  producing the canonical narration.wav and normalized word-level transcript for storyboarding. Use
  when human recordings need take selection, transcript alignment, cleanup, silence or mistake cuts,
  and delivery-level normalization before animation production. Do not use to write the script,
  design shots, mix music or sound effects, or render the lesson video.
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
such as `narration-original-01.<ext>`. Create `lessons/<lesson-id>/narration-source.wav` as the
canonical unedited PCM source reel, retaining the mapping back to each original. Never overwrite an
original or the source master with an edited result.

For a course lesson, run the validator and require an effective `script-approved` state before
editing. If the script snapshot is stale, return it for review and explicit approval instead of
editing against an obsolete recording contract.

Match the blank-line-separated paragraphs in `narration.txt` to the stable paragraph identifiers in
`lesson.md`. Transcribe every recording with word timestamps and compare it with the approved text
before cutting. Identify missing lines, changed technical claims, unclear words, unusable takes, and
recorded material that is not in the script. Do not synthesize, reorder, or silently rewrite speech
to conceal a material mismatch.

Lead the inspection result with a pickup list that quotes every complete sentence from
`narration.txt` that the human must record again. Group sentences by paragraph identifier when that
helps, and give a brief reason for each sentence. Do not include time positions in the user-facing
pickup list or make the human find the words from timestamps; timestamps remain internal evidence
for editing and alignment. Separate sentences that truly need a new recording from false starts,
repeated takes, and pauses that editing can repair. If no pickup is needed, say so explicitly. Return
missing or meaning-changing speech for a script decision or re-recording even when editing cannot
yet proceed.

Before an open-ended edit, show the proposed take selections, removals, retained pauses, and audio
processing. A direct request to edit this named narration authorizes changes to derived audio and
transcript data in that lesson directory; it does not authorize replacing the approved script or
publishing any output.

## Produce the narration master

Use the installed `media-use` workflow for transcription and physical audio operations when
available. Work from `narration-source.wav`, not from a previously compressed derivative. Select the
best complete takes; remove false starts, repeated takes, handling noise, and accidental dead air;
and keep natural sentence spacing. Preserve intentional rhetorical or demonstration pauses when
they help the explanation. Do not introduce or retain a special response pause for the static
post-lesson question, which is not part of `narration.txt`.

Apply only source-justified cleanup such as rumble removal, conservative noise control, de-clicking,
level correction, and limiting. Avoid processing that changes the speaker's identity or makes edits
audible. Default the delivery master to 48 kHz PCM WAV, mono for ordinary single-speaker narration,
with a recorded loudness and true-peak target suitable for the course; use -16 LUFS integrated and
-1.5 dBTP when the course has no delivery specification. Accept usable 44.1 kHz raw recordings and
convert only the derived working or delivery audio as needed; sample rate alone is not a reason to
request a pickup. Do not bake background music, sound effects, reverb used for scene design, or
composition automation into this file.

Write the approved result as `lessons/<lesson-id>/narration.wav`. Also write
`lessons/<lesson-id>/transcript.json` as the normalized flat word array consumed by HyperFrames, with
stable word IDs, spoken text, and final start and end seconds. Generate it from the edited master,
not the raw recording, and correct technical words against `narration.txt` without inventing speech.
This JSON is internal production timing, not a learner subtitle file. Preserve sufficiently precise
word or phrase alignment for production to derive readable subtitle cues from the approved text and
final audio. Mark uncertain alignment in the handoff and stop final storyboarding when it affects a
shot; do not invent precise timing or distribute a paragraph's duration evenly across its words.

## Verify and hand off

Listen across every edit boundary and at the beginning and end of the file. Confirm that all approved
spoken paragraphs occur once and in order, technical words remain intelligible, no required phrase
was clipped, retained pauses sound intentional, the lesson ends naturally, and the file
meets the chosen format, peak, and loudness targets. Re-run transcript alignment against the final
file rather than reusing timestamps from the raw recording.

Deliver `narration.wav`, `transcript.json`, and a concise report that begins with any exact sentences
still requiring pickup, without time positions, followed by removed or otherwise unresolved
material. A narration is ready for final storyboarding only when its spoken meaning matches
`narration.txt` and the transcript reliably covers the final audio. Pass the final master and
transcript back to `design-tutorial` for final storyboard timing; `build-tutorial` will use the same
verified alignment to create learner-facing `captions.vtt` against the final video timeline and will
derive SRT only when a named delivery platform requires it.

After the voice master and flat word transcript pass every check, record `narration-final` with the
packaged recorder and re-run the validator. Do not advance state while any word timing that affects a
shot remains uncertain.
