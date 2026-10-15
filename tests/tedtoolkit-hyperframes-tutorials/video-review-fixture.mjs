// Structural test data only: these files do not simulate a semantic viewing judgment.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { parseStoryboardTiming } from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/course-state-lib.mjs";
import { beatEvidenceWindow, sha256File, videoReviewTemplate } from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/visual-beat-review.mjs";

export function writeReviewFixture(lessonRoot) {
  const shots = parseStoryboardTiming(fs.readFileSync(path.join(lessonRoot, "storyboard.md"), "utf8"), { visualBeatsRequired: true });
  const duration = shots.at(-1).end;
  const directory = path.join(lessonRoot, "video-review", "fixture");
  fs.mkdirSync(directory, { recursive: true });
  const media = (name) => {
    const file = path.join(directory, name);
    fs.writeFileSync(file, `Structure-only media fixture ${name}`);
    return { path: `video-review/fixture/${name}`, sha256: sha256File(file) };
  };
  const manifest = {
    formatVersion: 1,
    videoSha256: sha256File(path.join(lessonRoot, "video.mp4")),
    storyboardSha256: sha256File(path.join(lessonRoot, "storyboard.md")),
    narrationSha256: sha256File(path.join(lessonRoot, "narration.wav")),
    offsetSeconds: 0, durationSeconds: duration, fps: 30,
    beats: shots.flatMap((shot) => shot.beats).map((beat) => {
      const window = beatEvidenceWindow(beat, 0, duration, 30);
      return {
        id: beat.id, shotId: beat.shotId, start: window.start, end: window.end,
        clip: media(`${beat.id}.mp4`),
        frames: Object.fromEntries(Object.entries(window.frames).map(([role, seconds]) => [role, { seconds, ...media(`${beat.id}-${role}.png`) }])),
      };
    }),
  };
  fs.writeFileSync(path.join(lessonRoot, "video-review.json"), `${JSON.stringify(manifest, null, 2)}\n`);
  fs.writeFileSync(path.join(lessonRoot, "video-shot-review.md"), videoReviewTemplate(shots, manifest)
    .replaceAll("Unverified", "Pass").replaceAll("| Pass | |", "| Pass | Structural fixture observation; no semantic claim. |"));
  return { shots, manifest };
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) writeReviewFixture(path.resolve(process.argv[2]));
