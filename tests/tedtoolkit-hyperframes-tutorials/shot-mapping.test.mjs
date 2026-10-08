import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  requiredLessonFiles,
  shotMappingIssues,
  validateLessonArtifacts,
} from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/course-state-lib.mjs";

function withLesson(callback) {
  const tempRoot = fs.realpathSync(os.tmpdir());
  const root = fs.mkdtempSync(path.join(tempRoot, "tedtoolkit-shot-map-"));
  if (path.dirname(fs.realpathSync(root)) !== tempRoot) throw new Error("test fixture escaped temp root");
  const lessonRoot = path.join(root, "lessons", "one");
  fs.mkdirSync(lessonRoot, { recursive: true });
  const write = (name, contents) => fs.writeFileSync(path.join(lessonRoot, name), contents);
  const lesson = { id: "one", sourcePaths: [], records: { "script-draft": { shotMappingRequired: true } } };
  write("lesson.md", "# Lesson\n\n## Post-lesson question\n\nWhat changed?\n");
  write("narration.txt", "The result changed.\n");
  write("narration.wav", "fixture audio");
  write("video.mp4", "fixture video");
  write("captions.txt", "P01-01\n00:00:00.000 --> 00:00:01.000\nThe result changed.\n");
  write("storyboard.md", "| Shot S01 | P01 | 00:00:00.000 --> 00:00:00.500 | Before |\n| Shot S02 | P01 | 00:00:00.500 --> 00:00:01.000 | After |\n");
  write("storyboard-preview.html", '<main><section data-shot-id="S01">Before</section><section data-shot-id="S02">After</section></main>');
  write("video-shot-review.md", "| Shot | Encoded frame checked | Result | Observation |\n| --- | --- | --- | --- |\n| Shot S01 | 00:00:00.250 | Pass | Before state is readable. |\n| Shot S02 | 00:00:00.750 | Pass | After state is readable. |\n");
  try {
    callback({ root, lesson, write });
  } finally {
    if (path.dirname(fs.realpathSync(root)) !== tempRoot) throw new Error("test cleanup escaped temp root");
    fs.rmSync(root, { recursive: true });
  }
}

test("new lessons map ordered storyboard shots to preview and encoded review", () => {
  withLesson(({ root, lesson }) => {
    assert.deepEqual(shotMappingIssues(root, lesson.id, true), []);
    assert(requiredLessonFiles(lesson, "video-verified").includes("lessons/one/video-shot-review.md"));
    assert.deepEqual(validateLessonArtifacts(root, lesson, "video-verified"), []);
  });
});

test("new lessons reject missing preview shots and unresolved video reviews", () => {
  withLesson(({ root, lesson, write }) => {
    write("storyboard-preview.html", '<main><section data-shot-id="S01">Before</section></main>');
    assert.match(shotMappingIssues(root, lesson.id, true).join(" "), /identifiers or order differ/);
    write("storyboard-preview.html", '<main><section data-shot-id="S01">Before</section><section data-shot-id="S02">After</section></main>');
    write("video-shot-review.md", "| Shot S01 | 00:00:00.250 | Pass | Before is readable. |\n| Shot S02 | 00:00:00.750 | Fail | Needs correction. |\n");
    const issues = validateLessonArtifacts(root, lesson, "video-verified");
    assert(issues.some((item) => item.code === "VIDEO_SHOT_REVIEW" && /Pass result/.test(item.message)));
  });
});

test("older records remain valid without the new shot mapping marker", () => {
  withLesson(({ root, lesson, write }) => {
    delete lesson.records["script-draft"].shotMappingRequired;
    write("storyboard.md", "| S01 | P01 | 00:00:00.000 --> 00:00:01.000 | Result |\n");
    fs.rmSync(path.join(root, "lessons", "one", "video-shot-review.md"));
    assert(!requiredLessonFiles(lesson, "video-verified").includes("lessons/one/video-shot-review.md"));
    assert.deepEqual(validateLessonArtifacts(root, lesson, "video-verified"), []);
  });
});

test("shot mapping reports a missing preview explicitly", () => {
  withLesson(({ root, lesson }) => {
    fs.rmSync(path.join(root, "lessons", "one", "storyboard-preview.html"));
    assert.match(shotMappingIssues(root, lesson.id).join(" "), /missing visual storyboard preview/);
  });
});
