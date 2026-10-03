---
name: generate-tutorial-narration
description: >-
  Generate narration.wav from narration.txt with Fish Audio using FISH_API_KEY and
  FISH_VOICE_ID. Use when a tutorial script is ready to become spoken audio. Do not use to write or
  revise the script, create a Fish voice, transcribe audio, design a storyboard, or build a video.
---

# Generate Tutorial Narration

Turn `narration.txt` into `narration.wav` with Fish Audio. This skill owns only that conversion.

Resolve [`fish-tts.mjs`](../../scripts/fish-tts.mjs) relative to this `SKILL.md`. Missing helper code
is a stop condition.

## Prepare the request

Require a non-empty `narration.txt` and these two environment variables:

- `FISH_API_KEY`: the Fish Audio API key.
- `FISH_VOICE_ID`: the saved Fish voice model ID sent as `reference_id`.

Never print or persist either value. Do not upload reference audio or send the Fish API `references`
field.

Use the paid `s2.1-pro` model by default. Use `s2.1-pro-free` only when the user explicitly requests
the free model. Do not silently retry with a different model.

## Generate the audio

Place `narration.wav` beside `narration.txt` unless the user selects another output path. Run a dry
run first to confirm the model, UTF-8 input byte count, destination, and whether that output already
exists without contacting Fish:

```bash
node <resolved-fish-tts.mjs> narration.txt narration.wav --dry-run
```

A direct request to generate the named narration authorizes the API call. Otherwise, show the dry-run
boundary before making the paid request. Then run:

```bash
node <resolved-fish-tts.mjs> narration.txt narration.wav
```

Do not overwrite an existing output unless the user requested replacement; use `--replace` only in
that case. The helper preserves the replaced file as a timestamped backup.

Return the output path, selected model, input byte count, and any provider error. Do not create a
transcript, edit or master the audio, change `narration.txt`, or edit `storyboard.md`. In a course
workflow, hand the generated WAV to `design-tutorial` for storyboard synchronization.
