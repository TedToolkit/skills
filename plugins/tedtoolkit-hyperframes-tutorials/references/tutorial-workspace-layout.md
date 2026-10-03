# Tutorial workspace contract

Use this layout for a file-based tutorial course. Keep stable lesson IDs and canonical filenames so
every workflow stage can discover its inputs without guessing.

```text
<course-root>/
├── course.config.json
├── course-state.json
├── <course-outline>.md
├── cover-system.md
├── course-cover.png
├── tools/
│   ├── build-course-player.mjs
│   └── package-course.mjs
├── lessons/
│   └── <lesson-id>/
│       ├── lesson.md
│       ├── narration.txt
│       ├── narration.wav
│       ├── captions.vtt
│       ├── storyboard.md
│       ├── cover.png
│       ├── sources/
│       │   └── <lesson evidence files>
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
| `cover-system.md` | `create-tutorial-cover`; reproducible course-wide layout, typography, palette, safe-area, and variation rules. |
| `course-cover.png` | `create-tutorial-cover`; course-level visual anchor used by the learner page and cover family. |
| `lesson.md` | `design-tutorial`; stable production card, paragraph map, sources, and one `## Post-lesson question`; no mutable status. |
| `narration.txt` | `design-tutorial`; approved spoken words only. |
| `narration.wav` | `generate-tutorial-narration`; Fish Audio output generated directly from the approved `narration.txt`. |
| `captions.vtt` | `build-tutorial`; learner-facing WebVTT cues aligned to the formal video timeline. |
| `captions.srt` | Optional `build-tutorial` export for a named destination that requires SubRip captions. |
| `storyboard.md` | `design-tutorial`; the provisional visual plan created with the script and later finalized against verified generated narration. |
| Editable composition | `build-tutorial`; implementation of the final storyboard. |
| `video.mp4` | `build-tutorial`; formal render and the packaging workflow's publication signal. |
| `cover.png` | `create-tutorial-cover`; verified lesson-level poster created from the current formal video and lesson identity. |

Starting at `script-draft`, the validator requires each `lesson.md` to contain exactly one non-empty
`## Post-lesson question` section. This is a hard authoring gate for every lesson, including an
introduction or extension. The question stays outside the narration and video. A finished offline
release must render its text visibly and identify its static container with
`data-post-lesson-question="<lesson-id>"`; missing or duplicated authoring content and missing release
content both fail validation.

Do not create a canonical `demo.md`. Record the teaching purpose and paths to demonstration evidence
in `lesson.md`. Put short, exact learner-facing text or illustrative snippets directly in
`storyboard.md`. Keep runnable code, substantial command output, diagrams, screenshots, and other
large or independently verified evidence in their real project or asset files; the storyboard
references those paths and the exact state or range to show. Final storyboarding and rendering stop
when a declared source is missing or unverified.

The final `storyboard.md` is the production timing source. Give every shot one verified audio range
in `HH:MM:SS.mmm --> HH:MM:SS.mmm` form, plus its paragraph IDs and spoken cue. Keep ranges ordered
and non-overlapping. `captions.vtt` is the canonical learner-facing sidecar because the course
player is HTML-based. Generate SRT from the same verified cues only when a target platform requires
it; never maintain VTT and SRT as independent timing sources.

## Production gates

The normal order is:

1. `lesson.md`, `narration.txt`, provisional `storyboard.md`, and all referenced demonstration sources.
2. Fish Audio generates `narration.wav` from the approved text and saved voice model ID.
3. `design-tutorial` listens to that audio and writes verified shot ranges into `storyboard.md`.
4. Editable HyperFrames composition, formal `video.mp4`, and aligned `captions.vtt`.
5. Course `cover-system.md` and `course-cover.png`, plus a verified lesson `cover.png` based on the current formal video.
6. Generated offline learner release and ZIP.

A provisional storyboard is a normal part of lesson design. It must identify itself as provisional,
use paragraph anchors and narration cues without invented timestamps or precise durations, and
cannot unlock formal rendering. The same file is aligned and finalized after narration generation; do
not create a parallel draft-storyboard artifact. A final
video requires `lesson.md`, `narration.txt`, `narration.wav`, and final `storyboard.md`, plus every
demonstration source declared by the lesson. A finished release also
requires `course-cover.png` and `cover.png` for every published lesson. A changed
`cover-system.md` or course cover requires lesson covers to be rechecked for continuity. Upstream changes invalidate affected downstream
timing, captions, video, cover, and packaging artifacts; refresh them in order rather than
patching around the mismatch during rendering.

Keep `video.mp4` as the clean reusable master and `captions.vtt` as the only canonical learner
subtitle source. Never render subtitle text into the video pixels or create a second captioned video
variant. A delivery destination that cannot consume sidecar subtitles is outside this course
workflow and must not change the canonical lesson artifacts.

Keep authoring sources and generated learner releases in separate directories. Never overwrite an
unknown output directory, and do not include internal production files or author-only assets in a
release unless the user explicitly requests them.
