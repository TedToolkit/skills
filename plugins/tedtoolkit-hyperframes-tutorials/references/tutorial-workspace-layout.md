# Tutorial workspace contract

Use this layout for a file-based tutorial course. Keep stable lesson IDs and canonical filenames so
every workflow stage can discover its inputs without guessing.

When several course roots form one planned series, keep their portfolio-level outcomes, course
tiers, prerequisite capabilities, briefs, and release waves in the sibling
[tutorial series contract](tutorial-series-contract.md). Do not copy series planning state into each
course's production state. Treat the series README as the authority for information shared unchanged
by every course. A course README, when present, links to it and contains only course-specific facts
and explicit exceptions; downstream work reads the shared series README before applying the local
delta.

```text
<course-root>/
├── README.md
├── course.config.json
├── course-state.json
├── <course-outline>.md
├── practice.md
├── video-style.md
├── cover-system.md
├── course-cover.png
├── tools/
│   ├── build-course-player.mjs
│   └── package-course.mjs
├── lessons/
│   └── <lesson-id>/
│       ├── lesson-outline.md
│       ├── lesson.md
│       ├── narration.txt
│       ├── narration.wav
│       ├── narration.wav.fish-request.json
│       ├── captions.vtt
│       ├── storyboard.md
│       ├── storyboard-preview.html
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
are canonical. A standalone course README may be self-contained. A series course README follows the
inheritance rule above and must not duplicate the shared charter. Create an artifact only when its
owning stage has real content; do not create empty placeholders.
For new courses, `practice.md` carries chapter Core checkpoints and the final Core completion task;
an existing course may retain a differently named learner-facing practice document listed in
`course.config.json` under `learnerDocuments`.

Use the [course state contract](tutorial-course-state.md) for the production lifecycle, dependency
graph, fingerprints, and stale-artifact handling. `course-state.json` is the only mutable production
status source; lesson cards must not maintain another status field.

## Artifact ownership

| Artifact | Owner and meaning |
| --- | --- |
| `course-state.json` | `plan-tutorial-course` initializes identity and dependencies; stage owners advance it only through the packaged recorders. |
| `video-style.md` | `design-tutorial` drafts or maintains the course video identity, inherited series rules, lesson variation, motion vocabulary, and visual references; `plan-tutorial-series` may seed selected course style drafts when a series visual request explicitly includes them. Review the contract with the first script and shot preview. See the [video style contract](tutorial-video-style.md). |
| `cover-system.md` | `create-tutorial-cover`; reproducible course-wide layout, typography, palette, safe-area, and variation rules. |
| `course-cover.png` | `create-tutorial-cover`; course-level visual anchor used by the learner page and cover family. |
| `lesson-outline.md` | `outline-tutorial-lesson`; the separately reviewable narrative spine approved before scripting. |
| `lesson.md` | `design-tutorial`; stable production card carrying the approved teaching arc, paragraph map, sources, one `## Post-lesson question`, and conditional learner-facing `## Visual descriptions`; no mutable status. |
| `narration.txt` | `design-tutorial`; approved spoken words only. |
| `narration.wav` | `generate-tutorial-narration`; Fish Audio output generated directly from the approved `narration.txt`. |
| `narration.wav.fish-request.json` | `fish-tts.mjs`; local attempt history that prevents blind duplicate requests and contains no narration or voice ID. Keep with its WAV; it is not published or a course stage record. |
| `captions.vtt` | `build-tutorial`; learner-facing WebVTT cues aligned to the formal video timeline. |
| `captions.srt` | Optional `build-tutorial` export for a named destination that requires SubRip captions. |
| `storyboard.md` | `design-tutorial`; the provisional visual plan created with the script and later finalized against verified generated narration. |
| `storyboard-preview.html` | `design-tutorial`; locally viewable, untimed frames for every provisional shot, reviewed with the script before narration. |
| Editable composition | `build-tutorial`; implementation of the final storyboard. |
| `video.mp4` | `build-tutorial`; formal render and the packaging workflow's publication signal. |
| `cover.png` | `create-tutorial-cover`; verified lesson-level poster created from the current formal video and lesson identity. |

Starting at `script-draft`, the validator requires each `lesson.md` to contain exactly one non-empty
`## Post-lesson question` section. This is a hard authoring gate for every lesson, including an
introduction or extension. The question stays outside the narration and video. A finished offline
release must render its text visibly and identify its static container with
`data-post-lesson-question="<lesson-id>"`; missing or duplicated authoring content and missing release
content both fail validation.
When essential visual meaning is absent from narration, fix the narration before approval. For
necessary exact visual details that should remain on screen rather than in speech, use one optional
`## Visual descriptions` section in `lesson.md`. Write it in the learner's language and scene order,
without production IDs. `package-tutorial-course` extracts this section near the video and transcript;
the rest of the production card remains author-only. Mark the rendered section with
`data-visual-descriptions="<lesson-id>"` so release validation can check the handoff. The spoken
WebVTT cues alone do not describe visual-only facts.
The validator rejects duplicate or empty authored sections and checks that a packaged lesson
shows the current text inside its marked section. Keep essential meaning in the main narration;
the page section is not a substitute for an audio-description review when one is required.

Do not create a canonical `demo.md`. Record the teaching purpose and paths to demonstration evidence
in `lesson.md`. Put short, exact learner-facing text or illustrative snippets directly in
`storyboard.md`. Keep runnable code, substantial command output, diagrams, screenshots, and other
large or independently verified evidence in their real project or asset files; the storyboard
references those paths and the exact state or range to show. Final storyboarding and rendering stop
when a declared source is missing or unverified.

The final `storyboard.md` is the production timing source. Give every shot one verified audio range
in `HH:MM:SS.mmm --> HH:MM:SS.mmm` form, plus its paragraph IDs and spoken cue. Keep ranges ordered
and non-overlapping. Put each shot range on its own line or table row. Put each internal range on a
subsequent line or row beginning with `Beat` (for example, `| Beat B01 | P01 | 00:00:00.000 -->
00:00:00.500 | Show the changed line |`). When beat rows are used, every shot must have ordered,
gapless beats that cover its full range; a hold is an explicit beat. This label lets the validator
distinguish nested beats from adjacent shots. Older shot-only storyboards remain valid.
`captions.vtt` is the canonical learner-facing sidecar because the course
player is HTML-based. Generate SRT from the same verified cues only when a target platform requires
it; never maintain VTT and SRT as independent timing sources.

## Production gates

The normal order is:

1. `lesson-outline.md` is drafted, reviewed, and explicitly approved.
2. Existing series visual system when present, course `video-style.md`, then `lesson.md`, `narration.txt`, provisional `storyboard.md`, visual `storyboard-preview.html`, and all referenced demonstration sources. Review the script and shot images against the applicable style rules together before approval; inspect a short motion specimen when movement itself defines the style or teaching relationship.
3. Fish Audio generates `narration.wav` from the approved text and saved voice model ID.
4. `design-tutorial` listens to that audio and writes verified shot ranges into `storyboard.md`.
5. Editable HyperFrames composition, formal `video.mp4`, and aligned `captions.vtt`.
6. Course `cover-system.md` and `course-cover.png`, plus a verified lesson `cover.png` based on the current formal video.
7. Generated offline learner release and ZIP.

A provisional storyboard is a normal part of lesson design. It must identify itself as provisional,
use paragraph anchors and narration cues without invented timestamps or precise durations, and
cannot unlock formal rendering. The same file is aligned and finalized after narration generation; do
not create a parallel draft-storyboard artifact. The visual preview shows actual frame compositions
for every shot before the paid WAV step. It may use HTML, CSS, SVG, and local images, but must open
locally and accurately reflect the written storyboard and narration; it is an author review artifact.
A final video requires `lesson.md`, `narration.txt`, `narration.wav`, and final `storyboard.md`, plus every
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
