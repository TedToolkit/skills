# Verify spoken cues against visible evidence

Use this contract during visual design, final audio alignment, and encoded-video review. Keep the
teaching plan in `storyboard.md` and the observed result in `video-shot-review.md`; do not create a
second timing plan. `build-tutorial` continues to own production and production review.

## Define an observable beat

For a materially different explanation, reference, or action, name the spoken cue, its exact visual
target, the visible state before and after, the change between them, and what would demonstrate
success. Keep these fields with the provisional storyboard before audio exists, without invented
timestamps. After listening to final narration, use these nine cells for each timed Beat row:

```text
| Beat ID | Audio range | Kind | Spoken cue | Target | Before | Change | After | Observable check |
| Beat S01.1 | 00:00:00.000 --> 00:00:02.000 | point | Look at this semicolon | final semicolon on line 1 | source line visible | point to that semicolon | source line and pointer readable | the pointer identifies the exact semicolon as the cue is heard |
| Beat S01.2 | 00:00:02.000 --> 00:00:05.000 | action | Replace only the text inside the quotes | string contents on line 1 | original string visible | select its contents and replace them in place | new string with original quotes and punctuation | selection and replacement are visible and surrounding symbols remain unchanged |
```

Use `action` for a process or state change, `point` for locating a referred-to part, `reveal` for
introducing evidence, and `hold` when an already useful state stays available. A quiet explanation
can use a hold; these categories do not require constant animation or a particular visual style.
Beat IDs start with their parent shot ID, such as `S01.1`. Put the verified range in the second
cell and escape literal pipes inside cells as `\|`. Every shot has ordered, gapless beats covering
its range, including necessary holds. Start a beat at its verified spoken cue; split an extended
passage when its target or teaching action changes. Do not spread cues evenly over a paragraph.
Update these ranges after any inserted pause; a constant lead-in is the only offset accepted by
the evidence helper.

Choose checks that could fail on a specific rendered interval:

| Situation | Required visible evidence | Failure to report |
| --- | --- | --- |
| “Save using the filename on screen” | The exact filename is readable by the reference cue. | The filename arrives after the viewer is told to use it. |
| Explain quotes, parentheses, or a semicolon | An unambiguous local cue identifies the particular symbol in its source context. | A detached explanation label leaves the viewer searching. |
| Select, replace, and save | The same object persists through selection, in-place replacement, and the relevant saved-state feedback. | Two finished versions and a save label omit the promised process. |

Apply these checks when the lesson actually promises that reference or process. A comparison whose
purpose is comparing two finished states may legitimately show both together. A diagram may explain
a mechanism without simulating a literal editor. The accepted evidence follows the teaching claim.

## Prepare encoded evidence

Run the packaged [`prepare-video-review.mjs`](../scripts/prepare-video-review.mjs), resolving its
path from the loaded skill/reference location. Its shared parsing, evidence, and review mechanics
are in [`visual-beat-review.mjs`](../scripts/visual-beat-review.mjs). Use installed `ffmpeg` and
`ffprobe`, or supply their executable paths; the helper does not install or download them.

```text
node <resolved prepare-video-review.mjs> <course-root> <lesson-id>
node <resolved prepare-video-review.mjs> <course-root> <lesson-id> --offset-seconds 0.5 --ffmpeg <executable> --ffprobe <executable>
```

The inputs are final `storyboard.md`, `narration.wav`, and formal `video.mp4` with an audio stream.
The helper preserves the full frame, prepares one clip with encoded sound per beat plus half a
second of available context on each side, and extracts frames immediately before the cue, at its
onset, and at the beat's final frame. Inspect additional consecutive frames or a longer passage
when an action, transition, or comparison extends beyond that window.

It writes author-only media and a review template to a new `video-review/evidence-*/` directory,
then publishes `video-review.json` with input hashes, encoded intervals, frame times, and media
hashes. Existing evidence and the human review are preserved. The template's links are relative to
the lesson directory: use its contents in `video-shot-review.md` after inspection, preserving the
per-shot comparison rows and adding a row for every beat. Extraction always returns `Unverified`;
it does not change course state or judge what the pictures mean. Failed extraction does not publish
a replacement manifest. Preserve the previous manifest and any partial output for diagnosis.
Preserve the template's generated `Evidence manifest: sha256:...` line in the review. It binds
observations to this extraction; an old review cannot pass against a newly generated manifest.
Never copy or refresh that binding merely to retain old Pass results.

## Inspect and record the result

Listen and watch each extracted interval at normal speed, using the actual encoded pixels and
sound. Compare the referred-to object, action, and readable result with the storyboard check.
Use the before/cue/after frames to locate a late appearance or incorrect pointer; use the moving
clip to establish selection, replacement, saving, and other processes. Source code, captions,
storyboard prose, and one attractive frame cannot establish that those events occurred.
When AI assists, give it the clip or the observed frames and actual audio timing; require observations
about visible evidence rather than a restatement of the plan. If the available tools cannot inspect
the relevant audio, motion, or detail, leave that check `Unverified` and report the limitation.

Record four cells per beat, using the helper's encoded interval including context:

```text
| Beat | Encoded interval checked | Result | Observation |
| Beat S01.1 | 00:00:00.000 --> 00:00:02.500 | Fail | The pointer lands on the closing parenthesis; the spoken cue names the semicolon. |
| Beat S01.2 | 00:00:01.500 --> 00:00:05.500 | Unverified | Replacement motion has not been inspected with sound. |
```

Replace a result with `Pass` only after observing the required evidence, and state what was seen
and whether its onset, target, action, and settled result meet the check. Correct a failure in its
owning storyboard or composition, render again, regenerate evidence, and inspect the affected
beats and boundaries before advancing. Do not carry old Pass judgments forward to changed footage.

New or re-recorded `storyboard-final` records set `visualBeatReviewRequired`. For those lessons,
`video-verified` requires the manifest, existing per-shot review, every beat reviewed in order,
matching encoded intervals, `Pass` observations, and unchanged input/media hashes. An unresolved
`Fail`, `Unverified`, missing clip/frame, or stale extraction prevents verification. The validator
checks this traceability; it cannot certify that an observer's semantic judgment is correct.
Records made before this marker remain readable. When revising an older lesson, adopt the contract
by updating its storyboard and re-recording `storyboard-final` after verification; keep valid
script approval and narration when spoken meaning has not changed. Keep all review artifacts out
of the learner release.
