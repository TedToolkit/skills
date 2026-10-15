import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import test from "node:test";
import { checkFingerprintRecord, fingerprintFiles, lessonContractSha256, parseStoryboardTiming, requiredLessonFiles, validateLessonArtifacts } from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/course-state-lib.mjs";
import { beatEvidenceWindow, sha256File, validateVideoBeatReview } from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/visual-beat-review.mjs";
import { prepareVideoReview } from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/prepare-video-review.mjs";
import { writeReviewFixture } from "./video-review-fixture.mjs";

const storyboard = `# Final storyboard
| Shot S01 | P01 | 00:00:00.000 --> 00:00:01.200 | Edit the source |
| Beat S01.1 | 00:00:00.000 --> 00:00:00.400 | point | Find the quotes | string on line 1 | source visible | point at both quotes | quotes identified | cue identifies both quotes |
| Beat S01.2 | 00:00:00.400 --> 00:00:00.800 | action | Replace the text | string contents | old text | select and replace in place | new text | quotes stay unchanged during replacement |
| Beat S01.3 | 00:00:00.800 --> 00:00:01.200 | hold | Read the result | updated source | new text | hold the source | new text | result remains readable |
`;

async function withReview(callback) {
  const tempRoot = fs.realpathSync(os.tmpdir());
  const root = fs.mkdtempSync(path.join(tempRoot, "tedtoolkit-beat-review-"));
  const lessonRoot = path.join(root, "lessons", "one");
  fs.mkdirSync(lessonRoot, { recursive: true });
  const write = (name, value) => fs.writeFileSync(path.join(lessonRoot, name), value);
  write("storyboard.md", storyboard);
  write("lesson.md", "## Post-lesson question\nWhat changed?\n");
  write("narration.txt", "Replace the text.\n");
  write("narration.wav", "audio fixture");
  write("video.mp4", "video fixture");
  write("storyboard-preview.html", '<main data-shot-id="S01">Edit</main>');
  const lesson = { id: "one", sourcePaths: [], records: { "script-draft": { shotMappingRequired: true }, "storyboard-final": { visualBeatReviewRequired: true } } };
  const { shots, manifest } = writeReviewFixture(lessonRoot);
  const beats = shots.flatMap((shot) => shot.beats);
  try {
    await callback({ root, lessonRoot, lesson, beats, manifest, write });
  } finally {
    if (path.dirname(fs.realpathSync(root)) !== tempRoot) throw new Error("test cleanup escaped temp root");
    fs.rmSync(root, { recursive: true });
  }
}

test("typed beats retain exact cues, targets, state changes, checks, and literal pipes", () => {
  const shots = parseStoryboardTiming(storyboard.replace("old text |", "old \\| text |"), { visualBeatsRequired: true });
  assert.equal(shots[0].beats[1].before, "old | text");
  assert.equal(shots[0].beats[1].kind, "action");
  assert.equal(shots[0].beats[1].check, "quotes stay unchanged during replacement");
  assert.throws(() => parseStoryboardTiming(storyboard.replace("select and replace in place", ""), { visualBeatsRequired: true }), /nine cells/);
  assert.throws(() => parseStoryboardTiming(storyboard.replace("Beat S01.2", "Beat S02.2"), { visualBeatsRequired: true }), /nine cells/);
  assert.throws(() => parseStoryboardTiming(storyboard.replace("Beat S01.2", "Beat S01.1"), { visualBeatsRequired: true }), /duplicate/);
  assert.throws(() => parseStoryboardTiming(storyboard.split("\n").slice(0, 2).join("\n"), { visualBeatsRequired: true }), /cover every shot/);
});

test("legacy shot-only timing stays readable without upgrading an existing stage", () => {
  assert.equal(parseStoryboardTiming("Shot S01 | 00:00:00.000 --> 00:00:01.000 | hold").length, 1);
  const lesson = { id: "old", records: { "script-draft": {} } };
  assert(!requiredLessonFiles(lesson, "video-verified").some((file) => file.includes("video-review")));
});

test("current evidence and ordered observations pass the structural verification gate", async () => {
  await withReview(({ root, lesson, lessonRoot, beats }) => {
    assert.doesNotThrow(() => validateVideoBeatReview(lessonRoot, beats));
    assert.deepEqual(validateLessonArtifacts(root, lesson, "video-verified"), []);
    assert(requiredLessonFiles(lesson, "video-verified").includes("lessons/one/video-review.json"));
  });
});

test("missing, unverified, failed, or reordered beat observations cannot advance", async () => {
  await withReview(({ root, lesson, lessonRoot, write }) => {
    const original = fs.readFileSync(path.join(lessonRoot, "video-shot-review.md"), "utf8");
    for (const changed of [
      original.replace("| Beat S01.2", "| Beat S09.2"),
      original.replace(/(\| Beat S01.2[^\n]*)Pass/, "$1Unverified"),
      original.replace(/(\| Beat S01.2[^\n]*)Pass/, "$1Fail"),
      original.replace(/^\| Beat S01.2[^\n]*\n/m, ""),
      original.replace(/(\| Beat S01.2 \| )[^|]+/, "$100:00:00.000 --> 00:00:00.100 "),
    ]) {
      write("video-shot-review.md", changed);
      assert(validateLessonArtifacts(root, lesson, "video-verified").some((item) => item.code === "VIDEO_BEAT_REVIEW"));
    }
  });
});

test("changing source video, narration, or storyboard makes prepared evidence stale", async () => {
  await withReview(({ lessonRoot, beats, write }) => {
    for (const name of ["video.mp4", "narration.wav", "storyboard.md"]) {
      const original = fs.readFileSync(path.join(lessonRoot, name));
      write(name, Buffer.concat([original, Buffer.from("changed")]));
      assert.throws(() => validateVideoBeatReview(lessonRoot, beats), /evidence is stale/);
      write(name, original);
    }
  });
});

test("changed media invalidates video freshness even when the manifest is unchanged", async () => {
  await withReview(async ({ root, lessonRoot, lesson, manifest }) => {
    const files = requiredLessonFiles(lesson, "video-verified");
    const record = { fingerprints: await fingerprintFiles(root, files), lessonContractSha256: lessonContractSha256(lesson, "video-verified") };
    assert.equal((await checkFingerprintRecord(root, record, files, lesson, undefined, "video-verified")).fresh, true);
    fs.appendFileSync(path.join(lessonRoot, manifest.beats[1].clip.path), "changed pixels");
    const checked = await checkFingerprintRecord(root, record, files, lesson, undefined, "video-verified");
    assert.equal(checked.fresh, false);
    assert.match(checked.errors.join(" "), /evidence is missing, empty, changed/);
  });
});

test("an old Pass review cannot be reused with a regenerated manifest", async () => {
  await withReview(({ lessonRoot, beats, manifest, write }) => {
    // A byte-only change keeps the same timeline, but still needs a fresh review binding.
    write("video-review.json", JSON.stringify(manifest));
    assert.throws(() => validateVideoBeatReview(lessonRoot, beats), /bind its observations/);
  });
});

test("wrong frame times, missing frames, and escaped media paths fail closed", async () => {
  await withReview(({ lessonRoot, beats, manifest, write }) => {
    for (const change of [
      (value) => { value.beats[0].frames.cue.seconds += 0.1; },
      (value) => { delete value.beats[0].frames.before; },
      (value) => { value.beats[0].clip.path = "video-review/../../video.mp4"; },
      (value) => { value.beats[0].start = -1; },
    ]) {
      const changed = structuredClone(manifest);
      change(changed);
      write("video-review.json", JSON.stringify(changed));
      assert.throws(() => validateVideoBeatReview(lessonRoot, beats));
    }
  });
});

test("timeline windows apply a constant lead-in and reject a beat beyond video duration", () => {
  const beat = { id: "S01.1", start: 1, end: 2 };
  const window = beatEvidenceWindow(beat, 0.5, 3, 30);
  assert.equal(window.frames.cue, 1.5);
  assert.equal(window.start, 1);
  assert.equal(window.end, 3);
  assert.throws(() => beatEvidenceWindow(beat, 0.5, 2, 30), /outside/);
});

const hasFFmpeg = ["ffmpeg", "ffprobe"].every((command) => spawnSync(command, ["-version"], { windowsHide: true }).status === 0);
test("real extraction produces audio clips, cue frames, bound hashes, and an Unverified template", { skip: !hasFFmpeg }, async () => {
  await withReview(({ root, lessonRoot, beats, write }) => {
    const video = path.join(lessonRoot, "video.mp4");
    const generated = spawnSync("ffmpeg", ["-v", "error", "-nostdin", "-y", "-f", "lavfi", "-i", "testsrc2=size=160x90:rate=30:duration=2", "-f", "lavfi", "-i", "sine=frequency=440:sample_rate=48000:duration=2", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-c:a", "aac", "-shortest", video], { windowsHide: true, encoding: "utf8" });
    assert.equal(generated.status, 0, generated.stderr);
    write("video-shot-review.md", "Existing human notes\n");
    const result = prepareVideoReview(root, "one", { offsetSeconds: 0.2 });
    assert.equal(result.result, "Unverified");
    assert.equal(fs.readFileSync(path.join(lessonRoot, "video-shot-review.md"), "utf8"), "Existing human notes\n");
    const manifest = JSON.parse(fs.readFileSync(result.manifest, "utf8"));
    assert.equal(manifest.beats.length, 3);
    assert.equal(manifest.videoSha256, sha256File(video));
    assert.equal(manifest.beats[0].frames.cue.seconds, 0.2);
    const template = fs.readFileSync(result.template, "utf8");
    write("video-shot-review.md", template);
    assert.throws(() => validateVideoBeatReview(lessonRoot, beats), /Unverified/);
    write("video-shot-review.md", template.replaceAll("Unverified", "Pass"));
    assert.throws(() => validateVideoBeatReview(lessonRoot, beats), /actual observation/);
    write("video-shot-review.md", template.replaceAll("Unverified", "Pass").replaceAll("| Pass | |", "| Pass | Synthetic moving pattern and tone inspected for the extraction test. |"));
    assert.doesNotThrow(() => validateVideoBeatReview(lessonRoot, beats));
    const before = manifest.beats[1].frames.before;
    const expectedFrame = path.join(lessonRoot, "expected-frame.png");
    const extracted = spawnSync("ffmpeg", ["-v", "error", "-nostdin", "-n", "-i", video, "-vf", `select=eq(n\\,${Math.round(before.seconds * 30)})`, "-frames:v", "1", expectedFrame], { encoding: "utf8", windowsHide: true });
    assert.equal(extracted.status, 0, extracted.stderr);
    assert.equal(sha256File(expectedFrame), before.sha256, "frame extraction must not round a fractional time into the next frame");
    const probe = spawnSync("ffprobe", ["-v", "error", "-show_streams", "-of", "json", path.join(lessonRoot, manifest.beats[1].clip.path)], { encoding: "utf8", windowsHide: true });
    assert.equal(probe.status, 0, probe.stderr);
    assert(JSON.parse(probe.stdout).streams.some((stream) => stream.codec_type === "audio"));
    const previous = fs.readFileSync(result.manifest, "utf8");
    assert.throws(() => prepareVideoReview(root, "one", { ffmpeg: path.join(root, "missing-executable") }), /failed/);
    assert.equal(fs.readFileSync(result.manifest, "utf8"), previous);
  });
});
