import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import {
  checkFingerprintRecord,
  fingerprintVideoSources,
  videoSourceIssues,
} from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/course-state-lib.mjs";

async function withSource(callback) {
  const tempRoot = fs.realpathSync(os.tmpdir());
  const root = fs.mkdtempSync(path.join(tempRoot, "tedtoolkit-video-source-"));
  if (path.dirname(fs.realpathSync(root)) !== tempRoot) throw new Error("test fixture escaped temp root");
  const lesson = path.join(root, "lessons", "one");
  const source = path.join(lesson, "composition");
  fs.mkdirSync(source, { recursive: true });
  fs.mkdirSync(path.join(root, "visual"));
  fs.writeFileSync(path.join(root, "video-style.md"), "[Shared CSS](visual/style.css)\n");
  fs.writeFileSync(path.join(root, "visual", "style.css"), ":root { --paper: white; }\n");
  fs.writeFileSync(path.join(lesson, "video-source.json"), '{"htmlEntries":["composition/index.html"]}\n');
  fs.writeFileSync(path.join(lesson, "storyboard.md"), '| Shot S01 | P01 | 00:00:00.000 --> 00:00:01.000 | Lesson |\n');
  fs.writeFileSync(path.join(source, "index.html"), '<link rel="stylesheet" href="../../../visual/style.css"><main data-shot-id="S01">Lesson</main>\n');
  try {
    return await callback({ root, lesson, source });
  } finally {
    if (path.dirname(fs.realpathSync(root)) !== tempRoot) throw new Error("test cleanup escaped temp root");
    fs.rmSync(root, { recursive: true });
  }
}

test("editable source uses declared shared CSS and fingerprints every source file", async () => {
  await withSource(async ({ root, source }) => {
    fs.writeFileSync(path.join(source, "motion.js"), "export const duration = 2;\n");
    assert.deepEqual(videoSourceIssues(root, "one"), []);
    const before = await fingerprintVideoSources(root, "one");
    assert.deepEqual(Object.keys(before), [
      "lessons/one/composition/index.html",
      "lessons/one/composition/motion.js",
      "lessons/one/video-source.json",
    ]);
    fs.appendFileSync(path.join(source, "motion.js"), "export const changed = true;\n");
    const after = await fingerprintVideoSources(root, "one");
    assert.notEqual(before["lessons/one/composition/motion.js"], after["lessons/one/composition/motion.js"]);
  });
});

test("editable source rejects undeclared HTML entries and local CSS", async () => {
  await withSource(({ root, source }) => {
    fs.writeFileSync(path.join(source, "second.html"), "<main>Second</main>\n");
    assert.match(videoSourceIssues(root, "one").join(" "), /must list every editable composition HTML file/);
    fs.rmSync(path.join(source, "second.html"));
    fs.writeFileSync(path.join(source, "local.css"), "body { color: red; }\n");
    assert.match(videoSourceIssues(root, "one").join(" "), /instead of keeping local CSS files/);
  });
});

test("editable source rejects external and undeclared stylesheets", async () => {
  await withSource(({ root, source }) => {
    const entry = path.join(source, "index.html");
    fs.appendFileSync(entry, '<link rel="stylesheet" href="https://example.com/style.css">\n');
    assert.match(videoSourceIssues(root, "one").join(" "), /must load only declared shared CSS/);
    fs.writeFileSync(entry, '<link rel="stylesheet" href="../../../other.css">\n');
    assert.match(videoSourceIssues(root, "one").join(" "), /must load only declared shared CSS/);
  });
});

test("editable source must retain the storyboard shot mapping", async () => {
  await withSource(({ root, source }) => {
    const entry = path.join(source, "index.html");
    fs.writeFileSync(entry, '<link rel="stylesheet" href="../../../visual/style.css"><main data-shot-id="S02">Lesson</main>\n');
    assert.match(videoSourceIssues(root, "one").join(" "), /shot identifiers or order differ from storyboard.md/);
  });
});

test("editable source accepts only tracked static resources outside its source tree", async () => {
  await withSource(({ root, lesson, source }) => {
    const entry = path.join(source, "index.html");
    const original = fs.readFileSync(entry, "utf8");
    fs.writeFileSync(entry, `${original}<img src="../sources/result.png">\n`);
    assert.match(videoSourceIssues(root, "one").join(" "), /untracked resource/);
    fs.mkdirSync(path.join(lesson, "sources"));
    fs.writeFileSync(path.join(lesson, "sources", "result.png"), "fixture image");
    assert.deepEqual(videoSourceIssues(root, "one", ["lessons/one/sources/result.png"]), []);
    fs.writeFileSync(entry, `${original}<script src="https://example.com/scene.js"></script>\n`);
    assert.match(videoSourceIssues(root, "one").join(" "), /resource must be local/);
  });
});

test("video source validation rejects local palette overrides", async () => {
  await withSource(({ root, source }) => {
    const entry = path.join(source, "index.html");
    const original = fs.readFileSync(entry, "utf8");
    fs.writeFileSync(entry, `${original}<section style="color: red"></section>\n`);
    assert.match(videoSourceIssues(root, "one").join(" "), /overrides shared visual property color/);
    fs.writeFileSync(entry, original);
    fs.writeFileSync(path.join(source, "motion.js"), 'node.style.backgroundColor = "red";\n');
    assert.match(videoSourceIssues(root, "one").join(" "), /overrides shared visual property backgroundColor/);
  });
});

test("malformed visual dependency records become stale without crashing validation", async () => {
  await withSource(async ({ root, lesson }) => {
    fs.writeFileSync(path.join(root, "video-style.md"),
      "[Shared CSS](visual/style.css)\n[Example](visual/example.html)\n");
    fs.writeFileSync(path.join(root, "visual", "example.html"),
      '<link rel="stylesheet" href="style.css">\n');
    fs.writeFileSync(path.join(lesson, "storyboard-preview.html"),
      '<link rel="stylesheet" href="../../visual/style.css"><main data-shot-id="S01">Lesson</main>\n');
    const checked = await checkFingerprintRecord(root,
      { fingerprints: {}, visualDependencies: null }, [],
      { id: "one", type: "core", requires: [], sourcePaths: [], records: {} }, {}, "video-verified");
    assert.equal(checked.fresh, false);
    assert(checked.errors.includes("visual dependency set or workspace changed"));
  });
});
