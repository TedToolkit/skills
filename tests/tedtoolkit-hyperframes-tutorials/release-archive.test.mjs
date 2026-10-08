import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";

import { compareZipToDirectory, fingerprintZip } from "../../plugins/tedtoolkit-hyperframes-tutorials/scripts/release-archive-lib.mjs";
import { writeZip } from "./zip-fixture.mjs";

function expected(entries) {
  return Object.fromEntries(Object.entries(entries).map(([name, value]) =>
    [name, `sha256:${crypto.createHash("sha256").update(value).digest("hex")}`]));
}

async function withArchive(callback) {
  const tempRoot = fs.realpathSync(os.tmpdir());
  const root = fs.mkdtempSync(path.join(tempRoot, "tedtoolkit-release-archive-"));
  if (path.dirname(fs.realpathSync(root)) !== tempRoot) throw new Error("test fixture escaped temp root");
  try {
    await callback(path.join(root, "course.zip"));
  } finally {
    if (path.dirname(fs.realpathSync(root)) !== tempRoot) throw new Error("test cleanup escaped temp root");
    fs.rmSync(root, { recursive: true });
  }
}

test("stored and deflated ZIP files match release bytes", async () => {
  await withArchive(async (archive) => {
    const entries = { "index.html": "<main>课程</main>", "lessons/one/video.mp4": "video bytes" };
    writeZip(entries, archive);
    await compareZipToDirectory(archive, expected(entries));
    writeZip(entries, archive, { deflate: true });
    await compareZipToDirectory(archive, expected(entries));
  });
});

test("one wrapper folder is accepted but missing or changed files are rejected", async () => {
  await withArchive(async (archive) => {
    writeZip({ "course/index.html": "page", "course/video.mp4": "video" }, archive);
    await compareZipToDirectory(archive, expected({ "index.html": "page", "video.mp4": "video" }));
    await assert.rejects(compareZipToDirectory(archive, expected({ "index.html": "page", "video.mp4": "different" })),
      /changed video.mp4/);
    await assert.rejects(compareZipToDirectory(archive, expected({ "index.html": "page", "video.mp4": "video", "captions.txt": "text" })),
      /missing captions.txt/);
  });
});

test("unsafe paths and non-ZIP archives fail validation", async () => {
  await withArchive(async (archive) => {
    writeZip({ "../outside.txt": "bad" }, archive);
    await assert.rejects(fingerprintZip(archive), /unsafe path/);
    fs.writeFileSync(archive, "not a ZIP");
    await assert.rejects(fingerprintZip(archive), /end-of-central-directory/);
  });
});
