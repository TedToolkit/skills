# Auditable narration editing

Use this workflow when a recording contains alternate takes, false starts, repeated sentences,
pickup recordings, or enough cuts that an informal list of timestamps is likely to lose content.

## Required order and stop conditions

Follow these gates in order. A later processing step never repairs a failed earlier gate.

1. **Freeze the contract.** Require an approved `narration.txt` and preserve every original WAV.
   Stop if the approved text is stale or a source cannot be mapped back to its original.
2. **Condition without editing.** Create a lossless working WAV for every source. Apply only basic,
   conservative processing that preserves the complete timeline. Do not remove silence, breaths,
   false starts, repeated takes, or any speech in this step.
3. **Inspect before cutting.** Transcribe every working WAV, listen around every mismatch, and distinguish
   material that needs a pickup from material that editing can remove. Treat ASR timestamps as
   locators rather than sample-accurate boundaries.
4. **Select complete paragraphs.** Split the TXT only at blank lines. Assign every paragraph to one
   complete usable range in one working WAV. Prefer a natural complete take over reconstructing
   speech from fragments. Stop and request the exact full paragraph when no usable take preserves
   its complete wording, meaning, and delivery.
5. **Gate the edit plan.** Require every paragraph exactly once, in order, with no unexplained
   source overlap. Review the proposed removals, retained pauses, and source choices before render.
6. **Render the semantic cut.** Cut from the conditioned WAVs, retain consonant and trailing-syllable
   handles, use only short seam fades where needed, and keep a reversible plan. Do not normalize,
   de-breath, or aggressively shorten silence yet.
7. **Prove exact textual continuity.** Re-transcribe the complete semantic cut and run strict verification.
   Listen through the whole cut in short overlapping regions. Stop for any missing paragraph,
   duplicate take, false start, off-script remark, clipped word, or uncertain technical term.
8. **Apply conservative cleanup.** Only after semantic proof, address objectionable breaths, long
   accidental pauses, steady noise, clicks, take-level differences, and measured clipping. Preserve
   natural breathing, rhetorical pauses, and the speaker's identity.
9. **Create and verify the delivery master.** Apply one program-wide loudness pass and required
   sample-rate/channel conversion. Measure the rendered file, regenerate its transcript, rerun strict
   verification, listen to every seam and the complete file at normal speed, and only then write the
   canonical `narration.wav` and `transcript.json`.

Do not record `narration-final` while any gate above is failed or while a timing uncertainty affects
storyboarding.

## Build the edit plan

Resolve `../../../scripts/narration-edit.mjs` relative to this reference. From the lesson directory,
create the plan from all conditioned WAVs:

```bash
node <resolved-script> template narration.txt narration-edit-plan.json \
  --source sources/narration-working-01.wav \
  --source sources/narration-working-02.wav \
  --delivery narration-semantic.wav
```

The command splits only at blank lines and snapshots the approved text into stable paragraph
identifiers such as `P03`. Populate `clips[]` in paragraph order. Each clip requires:

- a unique `id`;
- exactly one `unit` paragraph ID covered by the complete take;
- a `sourceId` naming one of the input WAVs;
- `start` and `end` positions in that WAV;
- a short `selectionReason` that explains why this take is usable;
- optional `gapAfter`, `fadeIn`, and `fadeOut` values in seconds.

For example:

```json
{
  "id": "take-P03",
  "unit": "P03",
  "sourceId": "source-02",
  "start": 12.48,
  "end": 27.16,
  "gapAfter": 0.35,
  "selectionReason": "complete clean paragraph"
}
```

Every paragraph must occur exactly once. Source ranges within the same WAV must not overlap unless
the later clip has `allowSourceOverlap: true` and a concrete `overlapReason`. Overlap is exceptional
because it can reintroduce the end of one paragraph at the start of another.

If even one paragraph has no complete usable take, do not render a best-effort final master. Return a
pickup list containing its paragraph ID, the complete approved text, and the reason it failed. After
the pickup WAV arrives, add it as another source, rebuild the paragraph mapping, and rerun the entire
semantic-cut and final-master verification sequence.

Run the gate before rendering:

```bash
node <resolved-script> check narration-edit-plan.json
node <resolved-script> render narration-edit-plan.json --dry-run --json
```

The dry run exposes the exact FFmpeg operation without changing audio. When the plan and proposed
command are correct, render it. Use `--ffmpeg <path>` when FFmpeg is not on `PATH`. Rendering never
overwrites the source master. If a prior delivery exists, `--replace` preserves it as a timestamped
backup before promoting the new render. Keep this semantic cut separate from canonical
`narration.wav` until cleanup, delivery measurement, final transcription, and listening all pass.

## Separate semantic edits from cleanup

Basic source conditioning happens before matching, but it must preserve the entire source timeline.
First make the narration complete and non-repeating. Re-transcribe that semantic cut before any
timing-changing breath, silence, loudness, or sample-rate processing. Cleanup can hide a bad cut but
cannot repair a missing paragraph or select the correct take.

For breath and pause cleanup:

- attenuate an objectionable breath only after confirming it is outside speech;
- prefer a modest local gain reduction over hard deletion or a global noise gate;
- treat roughly 10 dB of attenuation as a conservative audition starting point, not a mandatory
  value;
- preserve inhalations that make phrasing sound natural;
- shorten long pauses by editing their source range while retaining rhetorical and demonstration
  pauses;
- compare before and after at normal speed and inspect the following consonant for damage.

If a packaged de-breath operation is unavailable, do not install an unreviewed dependency during a
production edit. Use the available media workflow for a reversible localized gain envelope, or leave
the breath unchanged and report it for manual review.

## Verify the rendered master

Create the final transcript from the rendered candidate, then run:

```bash
node <resolved-script> verify narration-edit-plan.json transcript.json --strict
```

The verifier blocks stale or incomplete edit plans, invalid or overlapping transcript times,
immediate in-entry repeats, repeats across edit boundaries, adjacent near-duplicate takes, and low
whole-script or paragraph-level transcript coverage. By default, any normalized token missing from
the approved text or added to the rendered speech is a blocker. The verifier also flags transcript
entries and excess tokens that align poorly with the approved script, which catches many false starts
and recording-room remarks. Automatic transcription is evidence for locating a problem, not proof
that the audio is correct. A passing report still requires listening to the complete file and every
edit boundary at normal speed.

After semantic verification, perform the selected cleanup, loudness normalization, and format
conversion. Re-transcribe and verify the actual final master again; do not reuse the semantic cut's
timestamps.
