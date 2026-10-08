# Tutorial course state contract

Use `course-state.json` at the course root as the only machine-readable production status source.
Keep curriculum rationale, descriptions, and the readable dependency table in the course outline;
mirror only stable lesson identity, type, direct prerequisites, and production state here. Do not
duplicate mutable status in `lesson.md` or infer it from whichever files happen to exist.

## State document

```json
{
  "formatVersion": 1,
  "courseId": "example-course",
  "lessons": [
    {
      "id": "lesson-01",
      "type": "core",
      "requires": [],
      "sourcePaths": [],
      "status": "planned",
      "records": {}
    }
  ],
  "release": {
    "status": "not-packaged"
  }
}
```

Lesson IDs are stable and unique. `type` is `core` or `extension`; `requires` contains direct lesson
IDs only. `sourcePaths` contains the course-root-relative demonstration evidence declared by the
lesson card. The array order is the preferred topological viewing order, while `requires` remains
the actual dependency model.

The required `course.config.json` fields are `courseId`, `title`, `slug`, `contentLanguage`, and
`outline`. `outline` is a course-root-relative path to the readable course plan. `courseId` must
match `course-state.json`.
Optional `learnerDocuments` is an array of distinct course-root-relative learner-facing files.
New courses list their practice document there. The validator checks that each listed file exists;
a packaged release must contain its current bytes and expose a local link in `index.html`.

New courses also record the production contract below. Existing courses that omit `video` or
`cover` use these same defaults so the configuration change is backward compatible.

```json
{
  "video": {
    "aspectRatio": "16:9",
    "width": 1920,
    "height": 1080,
    "fps": 30,
    "container": "mp4",
    "videoCodec": "h264",
    "pixelFormat": "yuv420p",
    "audioCodec": "aac",
    "audioSampleRate": 48000
  },
  "cover": {
    "width": 1920,
    "height": 1080,
    "format": "png"
  }
}
```

The configured video and cover dimensions must have the same aspect ratio. Override width, height,
or integer fps only when the course delivery target requires it. Keep the MP4/H.264/yuv420p and
AAC compatibility contract and the canonical PNG cover format. Do not store a fixed total frame
count: derive it from the final timeline duration and configured fps.

## Lesson lifecycle

Use these ordered states:

| State | Meaning | Next owner |
| --- | --- | --- |
| `planned` | The course outline and dependency graph contain the lesson; no lesson narrative spine is claimed. | `outline-tutorial-lesson` |
| `outline-draft` | `lesson-outline.md` contains a reviewable teaching progression. | `outline-tutorial-lesson` for revision or human approval |
| `outline-approved` | The current lesson outline has explicit human approval. | `design-tutorial` |
| `script-draft` | `lesson.md`, `narration.txt`, every declared demonstration source, provisional `storyboard.md`, and viewable `storyboard-preview.html` exist as a draft. | `review-tutorial-script` |
| `script-approved` | The reviewed script and visual shot preview have explicit human approval for Fish narration generation. | `generate-tutorial-narration` |
| `narration-final` | Fish Audio generated `narration.wav` from the approved script. | `design-tutorial` aligns and finalizes the storyboard |
| `storyboard-final` | The final storyboard contains verified shot ranges aligned to the generated narration. | `build-tutorial` |
| `video-verified` | The formal video with burned-in subtitles and its caption text passed production verification; new productions include a per-shot encoded review. | `create-tutorial-cover` |
| `cover-verified` | The lesson cover represents the current verified video and passed full-size, thumbnail, and course-family review. | `package-tutorial-course` |

`video-verified` is a production status. It does not claim that representative learners were
available for a trial or that the lesson has demonstrated a learning effect. Report trial evidence
separately from the stage state when it exists.

Only explicit human approval may advance `outline-draft` to `outline-approved` or `script-draft` to
`script-approved`. A review result such as “passed,” silence, or a request to continue is not approval.
Record the user's approval source in each approval record. Other stages advance only after their owning skill completes its stated
verification.

Course release state is separate: `not-packaged` or `packaged`. A packaged release does not rewrite
lesson states. Any new or replaced lesson-stage record resets release state to `not-packaged`.

## Fingerprint records and invalidation

Never hand-author hashes. Use the packaged
[`record-course-stage.mjs`](../scripts/record-course-stage.mjs) after a stage passes. It records a
SHA-256 fingerprint for every required artifact through that stage plus the lesson's identity, type,
direct prerequisites, and declared source paths. Video and cover records also fingerprint the
effective production settings that govern them. The recorder then removes later stage records and sets the
lesson status. Use
[`record-course-release.mjs`](../scripts/record-course-release.mjs) only after packaging and release
verification; pass both the generated release directory and ZIP path so it fingerprints every
regular release file and the verified archive.

Required cumulative lesson artifacts are:

| State | Additional artifacts |
| --- | --- |
| `outline-draft` | `lesson-outline.md` |
| `outline-approved` | No new file; a fresh outline snapshot plus `approvalSource` |
| `script-draft` | `lesson.md`, `narration.txt`, plus every path in `sourcePaths` |
| `script-approved` | No new file; a fresh script snapshot plus `approvalSource` |
| `narration-final` | `narration.wav` |
| `storyboard-final` | `storyboard.md` |
| `video-verified` | `video.mp4`, `captions.txt`, `video-shot-review.md` for records with `shotMappingRequired`, and `video-source.json` plus its editable composition for records with `videoSourceRequired` |
| `cover-verified` | Root `cover-system.md`, root `course-cover.png`, and lesson `cover.png` |

The Fish helper also keeps `narration.wav.fish-request.json` beside the WAV as local request
recovery data. It is outside stage fingerprints and the learner release. Preserve it with the WAV
so an uncertain request cannot be repeated blindly; `narration.wav` remains the authoritative audio
artifact for `narration-final`.

An approved outline is fingerprinted through every later stage. Outline records track lesson identity,
type, and prerequisites; demonstration `sourcePaths` enter the contract at `script-draft`, when the
script's evidence files are known. Changing the outline returns a new lesson to
`outline-draft` for review and invalidates its script and production records. Legacy lessons that
already reached `script-draft` without this new stage remain readable and may continue later-stage
work; a material rewrite should establish an outline and obtain approval first.

`design-tutorial` creates a provisional `storyboard.md` and viewable `storyboard-preview.html` with
the script before `script-draft` is recorded; the stage recorder enforces both for new or re-recorded
drafts. Review every shot's frame composition before human script approval. The storyboard enters
the cumulative fingerprints only at `storyboard-final`, because it gains real time ranges after
`narration-final`. The preview is an untimed author review artifact and is not fingerprinted in the
script or narration records; a visual-only refinement need not invalidate approved spoken audio.
A change to `narration.txt` still
invalidates approval and downstream records. Legacy stage records remain readable and can acquire
these preview artifacts when the lesson next enters design work.
For new or re-recorded drafts, label each storyboard shot `Shot S01`, `Shot S02`, and so on. The
preview gives each shot exactly one same-ordered `data-shot-id` container, with its initial, key,
and settled visual states inside. The recorder sets `shotMappingRequired` at `script-draft` and
rejects missing, duplicate, or reordered IDs. After audio alignment, every timed shot retains an
ID; a split, merge, or reordered shot requires the preview to be updated. Older records without
this marker remain valid. ID equality establishes coverage and traceability, not visual fidelity.
New or re-recorded `script-draft` records also require a non-empty root `video-style.md`, a linked
shared CSS file, and a linked shared HTML example under `series-standards/` for a series or `visual/`
for a standalone course. Series membership in an ancestor `course-series.json` permits relative
visual references inside that series root. The HTML example and lesson preview must load a
common declared stylesheet through a static `<link rel="stylesheet" href="...">`. The recorder adds
`videoStylePath`, `visualAssetsRequired`, and `videoSourceRequired` markers; validation then checks the contract, linked files,
and stylesheet handoff remain available. Older records without these markers remain valid.
The visual contract, its linked local assets, the lesson preview, and the recursive CSS imports/URL
dependencies enter a separate `visualDependencies` fingerprint record at `video-verified`. This
includes font binaries and declared license records. A visual change therefore makes the
video and later claims stale while preserving script approval, narration, and final audio timing.
Inspect affected previews and rendered intervals, rebuild when pixels must change, and only then
re-record verification; never refresh fingerprints just to hide a changed visual dependency. This
structural check cannot certify font resolution, foreground hierarchy, or visual similarity.
At `video-verified`, a lesson with `shotMappingRequired` also needs an author-only
`video-shot-review.md`. Record one table row per storyboard shot, in order, with its ID, an inspected
encoded-frame timestamp, `Pass` after any correction, and a note about the preview match or justified change.
The file is fingerprinted through later stages. The validator checks coverage and row shape; the
producer still checks the actual frames, motion intervals, evidence, and reading time. Do not
advance a shot with an unresolved material mismatch or put this record in the learner release.
For a lesson with `videoSourceRequired`, `video-verified` also requires
`lessons/<lesson-id>/video-source.json` containing only a non-empty `htmlEntries` array, with
lesson-relative paths such as `composition/index.html`. Keep the actual editable HTML project under
`lessons/<lesson-id>/composition/`; list every HTML file there, load only CSS declared in
`video-style.md`, give every rendered shot a static `data-shot-id` root matching the final
storyboard order, and keep local CSS out of the composition. The recorder fingerprints the manifest
and every file in that source tree as `sourceDependencies`. Later source edits make `video-verified`
and downstream claims stale. Generated render outputs and dependency caches stay outside this tree.
Static HTML resource references outside the tree must point to `sourcePaths` evidence or visual
assets linked from `video-style.md`; the validator rejects undeclared and network resources.
The source checker also rejects inline visual CSS and direct script writes to shared aesthetic
properties while allowing local placement and motion parameters. Runtime-generated visual states
still need the encoded-frame review.
This check proves an inspectable source dependency, not that encoded pixels came from it; compare
the final video with the reviewed preview and inspect the encoded subtitles and motion.

Run [`validate-course.mjs`](../scripts/validate-course.mjs) before resuming work and before packaging.
It recomputes fingerprints rather than trusting declared status. A changed or missing file makes its
record and all downstream claims stale. Do not repair stale state by copying old hashes or editing
the JSON: return to the earliest affected workflow, verify the current artifacts, and record that
stage again. A changed approved script therefore returns to `script-draft` and needs fresh approval;
a changed final narration returns to `script-approved`; a changed storyboard returns to
`narration-final`; a changed video production contract returns to `storyboard-final`; and a changed
cover-only contract returns to `video-verified`. A changed cover system or course cover also returns
lesson covers to `video-verified` for continuity review. Legacy courses without explicit production objects
continue to use the documented defaults and do not invalidate an existing pre-contract video record.
For a packaged release, validation reads the ZIP entries and compares every decompressed file with
the verified release directory. A single wrapper folder is allowed; missing, extra, changed,
unsafe, encrypted, or unsupported-compression entries invalidate the release. The ZIP fingerprint
alone is not a substitute for this content check.
In addition to file presence and fingerprints, every lesson at `script-draft` or later must have
exactly one non-empty `## Post-lesson question` section in `lesson.md`. A packaged lesson must
also expose that question as visible static page text in a container identified by
`data-post-lesson-question="<lesson-id>"`.
An optional `## Visual descriptions` section must be unique and non-empty. When it exists in a
packaged lesson, the release must expose its current text in a container identified by
`data-visual-descriptions="<lesson-id>"`.

## Storyboard timing required for deterministic validation

`design-tutorial` writes the verified production timeline directly into `storyboard.md`. Every final
shot uses an audio range in `HH:MM:SS.mmm --> HH:MM:SS.mmm` form and identifies its paragraph IDs
and spoken cue. Ranges must be finite, ordered, and non-overlapping; together they must cover every
approved spoken paragraph. A line or table row beginning with `Beat` is an internal audio range
inside the preceding shot. If any beat is present, every shot's beats must be ordered, gapless, and
cover that shot; explicit hold beats account for unchanged visuals. Shot-only legacy files still
validate. The validator checks the stored ranges without requiring a second timing
artifact. `captions.txt` must contain valid, ordered, non-overlapping timed cues, and its cues must remain
inside the final storyboard timeline. Its separately edited wording is checked against the audio
for meaning and technical accuracy during production review; exact text equality with
`narration.txt` is not required.

All stored paths are course-root-relative, use forward slashes, and must stay inside the course root.
Absolute paths, parent traversal, and network-dependent release media are invalid.
List specific evidence files in `sourcePaths`, not a broad directory; enumerate every file whose
content supports the lesson so the validator can fingerprint it deterministically.
