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

## Lesson lifecycle

Use these ordered states:

| State | Meaning | Next owner |
| --- | --- | --- |
| `planned` | The outline and dependency graph contain the lesson; no script is claimed. | `design-tutorial` |
| `script-draft` | `lesson.md`, `narration.txt`, and every declared demonstration source exist as a draft. | `review-tutorial-script` |
| `script-approved` | The reviewed script has explicit human approval for recording. | `edit-tutorial-narration` |
| `narration-final` | The edited voice master and verified timing data match the approved script. | `storyboard-tutorial` |
| `storyboard-final` | The final storyboard is aligned to the voice master and has complete evidence. | `build-tutorial` |
| `video-verified` | The formal video and WebVTT track passed production verification. | `package-tutorial-course` |

Only explicit human approval may advance `script-draft` to `script-approved`. A review result such
as “passed,” silence, or a request to continue is not approval. Record the user's approval source in
the `script-approved` record. Other stages advance only after their owning skill completes its stated
verification.

Course release state is separate: `not-packaged` or `packaged`. A packaged release does not rewrite
lesson states. Any new or replaced lesson-stage record resets release state to `not-packaged`.

## Fingerprint records and invalidation

Never hand-author hashes. Use the packaged
[`record-course-stage.mjs`](../scripts/record-course-stage.mjs) after a stage passes. It records a
SHA-256 fingerprint for every required artifact through that stage plus the lesson's identity, type,
direct prerequisites, and declared source paths; it then removes later stage records and sets the
lesson status. Use
[`record-course-release.mjs`](../scripts/record-course-release.mjs) only after packaging and release
verification; pass both the generated release directory and ZIP path so it fingerprints every
regular release file and the verified archive.

Required cumulative lesson artifacts are:

| State | Additional artifacts |
| --- | --- |
| `script-draft` | `lesson.md`, `narration.txt`, plus every path in `sourcePaths` |
| `script-approved` | No new file; a fresh script snapshot plus `approvalSource` |
| `narration-final` | `narration-source.wav`, `narration.wav`, `transcript.json` |
| `storyboard-final` | `storyboard.md` |
| `video-verified` | `video.mp4`, `captions.vtt` |

Run [`validate-course.mjs`](../scripts/validate-course.mjs) before resuming work and before packaging.
It recomputes fingerprints rather than trusting declared status. A changed or missing file makes its
record and all downstream claims stale. Do not repair stale state by copying old hashes or editing
the JSON: return to the earliest affected workflow, verify the current artifacts, and record that
stage again. A changed approved script therefore returns to `script-draft` and needs fresh approval;
a changed final narration returns to `script-approved`; a changed storyboard returns to
`narration-final`.

## Transcript data required for deterministic validation

`transcript.json` is a normalized flat word array:

```json
[
  { "id": "w0001", "text": "Hello", "start": 0.4, "end": 0.9 },
  { "id": "w0002", "text": "world.", "start": 1.0, "end": 1.6 }
]
```

Word IDs are unique and stable, spoken text is non-empty, and time ranges are finite, ordered, and
non-overlapping. Concatenated transcript text must match `narration.txt`; the stage fingerprint binds
both files to the same approved snapshot. `captions.vtt` must be valid, ordered, non-overlapping
WebVTT whose spoken text matches `narration.txt`; its cue range must be consistent with the transcript
plus a non-negative video lead-in.

All stored paths are course-root-relative, use forward slashes, and must stay inside the course root.
Absolute paths, parent traversal, and network-dependent release media are invalid.
List specific evidence files in `sourcePaths`, not a broad directory; enumerate every file whose
content supports the lesson so the validator can fingerprint it deterministically.
