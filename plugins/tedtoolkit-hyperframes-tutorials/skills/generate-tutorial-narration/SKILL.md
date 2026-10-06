---
name: generate-tutorial-narration
description: >-
  Generate narration.wav from narration.txt with Fish Audio using FISH_API_KEY and
  FISH_VOICE_ID. Use when a tutorial script is ready to become spoken audio. Do not use to write or
  revise the script, create a Fish voice, transcribe audio, design a storyboard, or build a video.
---

# Generate Tutorial Narration

Turn `narration.txt` into `narration.wav` with Fish Audio. This skill owns only that conversion.
Before generation, review the approved text's punctuation and paragraph breaks for natural
breathing room. Fish documents punctuation as a cue for natural pauses; it does not provide a
verified per-comma millisecond pause control for this request. If the user asks to revise wording
or punctuation for pacing, return that edit to `design-tutorial` for script review, then generate
from the newly approved text. Listen to the WAV before finalizing it: punctuation may still produce
pauses that are too short or inconsistent. Leave precise extra silence to the measured editing and
timeline synchronization in `build-tutorial`.
Request 44.1 kHz WAV from Fish. The course's `video.audioSampleRate` is the final video
encoding setting and does not change the Fish request.

Resolve [`fish-tts.mjs`](../../scripts/fish-tts.mjs) relative to this `SKILL.md`. Missing helper code
is a stop condition.

## Prepare the request

For a file-based course, resolve the packaged
[`validate-course.mjs`](../../scripts/validate-course.mjs), run it, and require effective
`script-approved` state.
Confirm that the approved review included the current `storyboard-preview.html` and written
`storyboard.md`. If the visual preview is missing or has exposed a needed script change, return to
`design-tutorial` and `review-tutorial-script` before sending text to Fish. A visual-only refinement
after audio generation that leaves approved spoken words intact does not by itself require a second WAV.

Require a non-empty `narration.txt` and these two environment variables:

- `FISH_API_KEY`: the Fish Audio API key.
- `FISH_VOICE_ID`: the saved Fish voice model ID sent as `reference_id`.

Let the helper validate the text file; do not print or read the full narration into the agent
context just to generate audio. Check environment-variable presence without showing their values.

Never print or persist either value. Do not upload reference audio or send the Fish API `references`
field.

Use the paid `s2.1-pro` model by default. Use `s2.1-pro-free` only when the user explicitly requests
the free model. Do not silently retry with a different model.

## Generate the audio

Place `narration.wav` beside `narration.txt` unless the user selects another output path. Run a dry
run first to confirm the model, UTF-8 input byte count, destination, existing output, previous
request status, and request lock without contacting Fish:

```bash
node <resolved-fish-tts.mjs> narration.txt narration.wav --dry-run
```

A direct request to generate the named narration authorizes the API call. Otherwise, show the dry-run
boundary before making the paid request. Then run:

```bash
node <resolved-fish-tts.mjs> narration.txt narration.wav
```

The helper keeps `<output.wav>.fish-request.json` beside the WAV. It records request fingerprints,
attempt status, and output hash without saving the narration or voice ID. A matching completed WAV
is reused without another API call. Keep this record with the audio; do not delete or edit it to
make a request appear new. If the WAV is missing after a completed request, or a previous request
has no confirmed output, stop and inspect the local files and provider usage before any retry. The
helper blocks another request in that state by default. Use `--retry-uncertain` only after the user
explicitly asks to retry despite possible duplicate billing. A concurrent request lock is also
created during a call; if it remains after a crash, inspect the request record and provider usage
before clearing it. `--replace` remains necessary to generate over an existing WAV.

When `HTTPS_PROXY` is configured and Node supports `--use-env-proxy`, the helper enables it before
the request; an explicit `NODE_USE_ENV_PROXY` setting takes precedence. If the request reports
`fetch failed` without an HTTP response, check network access before attributing the failure to
Fish Audio. Do not print proxy values or credentials. If the request may have reached Fish, report
that uncertainty rather than assuming a failed local fetch means no charge.

Do not overwrite an existing output unless the user requested replacement; use `--replace` only in
that case. The helper preserves the replaced file as a timestamped backup.

Return the output path, selected model, input byte count, and any provider error. Do not create a
transcript, edit or master the audio, change `narration.txt`, or edit `storyboard.md`. In a course
workflow, hand the generated WAV to `design-tutorial` for storyboard synchronization.
