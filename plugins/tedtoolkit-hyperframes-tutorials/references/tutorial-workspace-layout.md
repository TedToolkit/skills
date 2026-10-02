# Tutorial workspace contract

Use this layout for a file-based tutorial course. Keep stable lesson IDs and canonical filenames so
every workflow stage can discover its inputs without guessing.

```text
<course-root>/
├── course.config.json
├── course-state.json
├── <course-outline>.md
├── tools/
│   ├── build-course-player.mjs
│   └── package-course.mjs
├── lessons/
│   └── <lesson-id>/
│       ├── lesson.md
│       ├── narration.txt
│       ├── narration-source.wav
│       ├── narration.wav
│       ├── transcript.json
│       ├── captions.vtt
│       ├── storyboard.md
│       ├── sources/
│       │   └── narration-original.<ext>
│       ├── <editable HyperFrames project files>
│       └── video.mp4
└── <generated-release>/
    ├── index.html
    └── <learner-facing course files>
```

The outline filename and generated-release directory are project choices. The lesson filenames above
are canonical. Create an artifact only when its owning stage has real content; do not create empty
placeholders.

Use the [course state contract](tutorial-course-state.md) for the production lifecycle, dependency
graph, fingerprints, and stale-artifact handling. `course-state.json` is the only mutable production
status source; lesson cards must not maintain another status field.

## Artifact ownership

| Artifact | Owner and meaning |
| --- | --- |
| `course-state.json` | `plan-tutorial-course` initializes identity and dependencies; stage owners advance it only through the packaged recorders. |
| `lesson.md` | `design-tutorial`; stable production card, paragraph map, sources, and exit check; no mutable status. |
| `narration.txt` | `design-tutorial`; approved spoken words only. |
| `sources/narration-original.<ext>` | Immutable uploaded recording when the original is not retained elsewhere. |
| `narration-source.wav` | `edit-tutorial-narration`; canonical unedited PCM working source. |
| `narration.wav` | `edit-tutorial-narration`; edited and verified voice master with no music or SFX. |
| `transcript.json` | `edit-tutorial-narration`; normalized word-level production timing aligned to `narration.wav`. |
| `captions.vtt` | `build-tutorial`; learner-facing WebVTT cues aligned to the formal video timeline. |
| `captions.srt` | Optional `build-tutorial` export for a named destination that requires SubRip captions. |
| `storyboard.md` | `storyboard-tutorial`; the single shot plan consumed by production. |
| Editable composition | `build-tutorial`; implementation of the final storyboard. |
| `video.mp4` | `build-tutorial`; formal render and the packaging workflow's publication signal. |

Do not create a canonical `demo.md`. Record the teaching purpose and paths to demonstration evidence
in `lesson.md`. Put short, exact learner-facing text or illustrative snippets directly in
`storyboard.md`. Keep runnable code, substantial command output, diagrams, screenshots, and other
large or independently verified evidence in their real project or asset files; the storyboard
references those paths and the exact state or range to show. Final storyboarding and rendering stop
when a declared source is missing or unverified.

`transcript.json` is production data, not a learner subtitle file. Keep its normalized word-level
timestamps for precise edit verification and animated captions. `captions.vtt` is the canonical
learner-facing sidecar because the course player is HTML-based. Generate SRT from the same verified
cues only when a target platform requires it; never maintain VTT and SRT as independent timing
sources.

## Production gates

The normal order is:

1. `lesson.md` plus `narration.txt` and all demonstration sources referenced by the lesson.
2. Raw recording preserved and normalized as `narration-source.wav`.
3. Edited `narration.wav` plus word-level `transcript.json`.
4. Final audio-aligned `storyboard.md`.
5. Editable HyperFrames composition, formal `video.mp4`, and aligned `captions.vtt`.
6. Generated offline learner release and ZIP.

A provisional storyboard may precede the final voice master only when explicitly requested. It must
use estimated durations, identify itself as provisional, and cannot unlock formal rendering. A final
video requires `lesson.md`, `narration.txt`, `narration.wav`, `transcript.json`, and final
`storyboard.md`, plus every demonstration source declared by the lesson. Upstream changes invalidate
affected downstream timing, captions, and production artifacts; refresh them in order rather than
patching around the mismatch during rendering.

Keep `video.mp4` as the clean reusable master and `captions.vtt` as the only canonical learner
subtitle source. Never render subtitle text into the video pixels or create a second captioned video
variant. A delivery destination that cannot consume sidecar subtitles is outside this course
workflow and must not change the canonical lesson artifacts.

Keep authoring sources and generated learner releases in separate directories. Never overwrite an
unknown output directory, and do not include raw recordings, internal production files, or author-only
assets in a release unless the user explicitly requests them.
