import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

export function parseTimecode(text) {
  const match = /^(?:(\d{2,}):)?(\d{2}):(\d{2})\.(\d{3})$/.exec(text);
  if (!match || Number(match[2]) > 59 || Number(match[3]) > 59) return Number.NaN;
  return Number(match[1] || 0) * 3600 + Number(match[2]) * 60 + Number(match[3]) + Number(match[4]) / 1000;
}

export function formatTimecode(seconds) {
  const millis = Math.round(seconds * 1000);
  return `${String(Math.floor(millis / 3600000)).padStart(2, "0")}:${String(Math.floor(millis / 60000) % 60).padStart(2, "0")}:${String(Math.floor(millis / 1000) % 60).padStart(2, "0")}.${String(millis % 1000).padStart(3, "0")}`;
}

function cells(line) {
  return line.trim().replace(/^\|\s*/, "").replace(/\s*\|$/, "").split(/(?<!\\)\|/).map((cell) => cell.trim().replace(/\\\|/g, "|"));
}

export function parseVisualBeatRow(line, shotId, range) {
  const fields = cells(line);
  const match = /^Beat (S\d{2,}\.\d+)$/.exec(fields[0]);
  if (!match || !shotId || !match[1].startsWith(`${shotId}.`) || fields.length !== 9 ||
      !["action", "point", "reveal", "hold"].includes(fields[2]) || fields.some((field) => !field)) {
    throw new Error("visual Beat rows need nine cells: Beat S01.1 | audio range | kind | spoken cue | target | before | change | after | observable check");
  }
  if (fields[1] !== range.source) throw new Error(`Beat ${match[1]} must put its audio range in the second cell`);
  const [, , kind, cue, target, before, change, after, check] = fields;
  return { ...range, id: match[1], shotId, kind, cue, target, before, change, after, check };
}

export function sha256File(file) {
  const hash = crypto.createHash("sha256");
  const descriptor = fs.openSync(file, "r");
  try {
    const buffer = Buffer.alloc(1024 * 1024);
    let size;
    while ((size = fs.readSync(descriptor, buffer, 0, buffer.length, null)) > 0) hash.update(buffer.subarray(0, size));
    return `sha256:${hash.digest("hex")}`;
  } finally {
    fs.closeSync(descriptor);
  }
}

export function beatEvidenceWindow(beat, offset, duration, fps) {
  const cue = beat.start + offset;
  const finish = beat.end + offset;
  if (!Number.isFinite(offset) || offset < 0 || !Number.isFinite(duration) || duration <= 0 ||
      !Number.isFinite(fps) || fps <= 0 || cue < 0 || finish > duration + 0.001) {
    throw new Error(`Beat ${beat.id} falls outside the encoded video or has invalid timeline settings`);
  }
  const last = Math.max(0, Math.ceil(duration * fps) - 1);
  const cueFrame = Math.min(last, Math.floor(cue * fps + 1e-7));
  return {
    start: Math.max(0, cue - 0.5),
    end: Math.min(duration, finish + 0.5),
    frames: {
      before: Math.max(0, cueFrame - 1) / fps,
      cue: cueFrame / fps,
      after: Math.min(last, Math.max(cueFrame, Math.ceil(finish * fps - 1e-7) - 1)) / fps,
    },
  };
}

function evidenceFile(lessonRoot, entry, extension) {
  if (!entry || typeof entry.path !== "string" || !entry.path.startsWith("video-review/") ||
      entry.path.includes("\\") || entry.path.split("/").some((part) => !part || part === "." || part === "..") ||
      !entry.path.endsWith(extension)) throw new Error("video review evidence needs a local video-review/ path with the expected media extension");
  const absolute = path.join(lessonRoot, entry.path);
  const realRoot = `${fs.realpathSync(lessonRoot)}${path.sep}`;
  const stat = fs.statSync(absolute);
  if (!fs.realpathSync(absolute).startsWith(realRoot) || !stat.isFile() || stat.size === 0 || sha256File(absolute) !== entry.sha256) {
    throw new Error(`video review evidence is missing, empty, changed, or outside the lesson: ${entry.path}`);
  }
}

export function validateVideoBeatReview(lessonRoot, beats) {
  const manifest = JSON.parse(fs.readFileSync(path.join(lessonRoot, "video-review.json"), "utf8"));
  if (manifest.formatVersion !== 1 || !Array.isArray(manifest.beats) ||
      !Number.isFinite(manifest.offsetSeconds) || manifest.offsetSeconds < 0 ||
      !Number.isFinite(manifest.durationSeconds) || manifest.durationSeconds <= 0 ||
      !Number.isFinite(manifest.fps) || manifest.fps <= 0) throw new Error("invalid video-review.json format or timeline settings");
  for (const [name, field] of [["video.mp4", "videoSha256"], ["storyboard.md", "storyboardSha256"], ["narration.wav", "narrationSha256"]]) {
    if (sha256File(path.join(lessonRoot, name)) !== manifest[field]) throw new Error(`video review evidence is stale for ${name}; prepare and inspect it again`);
  }
  if (manifest.beats.map((beat) => beat.id).join("\n") !== beats.map((beat) => beat.id).join("\n")) {
    throw new Error("video review evidence must cover every storyboard Beat in order");
  }
  const usedPaths = new Set();
  for (let index = 0; index < beats.length; index += 1) {
    const beat = beats[index];
    const evidence = manifest.beats[index];
    const expected = beatEvidenceWindow(beat, manifest.offsetSeconds, manifest.durationSeconds, manifest.fps);
    if (evidence.shotId !== beat.shotId || Math.abs(evidence.start - expected.start) > 0.000001 ||
        Math.abs(evidence.end - expected.end) > 0.000001 || !Number.isFinite(evidence.start) || !Number.isFinite(evidence.end)) {
      throw new Error(`video review interval differs from Beat ${beat.id}`);
    }
    for (const [role, seconds] of Object.entries(expected.frames)) {
      if (!Number.isFinite(evidence.frames?.[role]?.seconds) || Math.abs(evidence.frames[role].seconds - seconds) > 0.000001) {
        throw new Error(`video review ${role} frame differs from Beat ${beat.id}`);
      }
      evidenceFile(lessonRoot, evidence.frames[role], ".png");
    }
    evidenceFile(lessonRoot, evidence.clip, ".mp4");
    for (const entry of [evidence.clip, ...Object.values(evidence.frames)]) {
      if (usedPaths.has(entry.path)) throw new Error(`video review evidence path is reused: ${entry.path}`);
      usedPaths.add(entry.path);
    }
  }
  const review = fs.readFileSync(path.join(lessonRoot, "video-shot-review.md"), "utf8");
  const bindings = [...review.matchAll(/^Evidence manifest: (sha256:[a-f0-9]{64})\s*$/gm)];
  if (bindings.length !== 1 || bindings[0][1] !== sha256File(path.join(lessonRoot, "video-review.json"))) {
    throw new Error("video-shot-review.md must bind its observations to the current evidence manifest; inspect regenerated evidence before carrying judgments forward");
  }
  const rows = review.split(/\r?\n/).filter((line) => /^\s*\|\s*Beat\b/.test(line)).map(cells);
  // Ignore a column heading, but never ignore a malformed or unknown Beat data row.
  const data = rows.filter((row) => row[0] !== "Beat");
  if (data.map((row) => row[0]).join("\n") !== beats.map((beat) => `Beat ${beat.id}`).join("\n")) {
    throw new Error("video-shot-review.md must review every Beat in storyboard order");
  }
  for (let index = 0; index < data.length; index += 1) {
    const row = data[index];
    const evidence = manifest.beats[index];
    const interval = `${formatTimecode(evidence.start)} --> ${formatTimecode(evidence.end)}`;
    if (row.length !== 4 || row[1] !== interval || row[2] !== "Pass" || !row[3]) {
      throw new Error(`${row[0]} needs its encoded interval, Pass after inspection, and an actual observation; Unverified or Fail cannot advance video-verified`);
    }
  }
}

export function videoReviewTemplate(shots, manifest) {
  const binding = `sha256:${crypto.createHash("sha256").update(`${JSON.stringify(manifest, null, 2)}\n`).digest("hex")}`;
  const lines = ["# Encoded video review", "", `Evidence manifest: ${binding}`, "", "Inspect the clips with sound at normal speed and the referenced frames before replacing Unverified. Record observed target, action, and settled evidence against each storyboard check.", "", "| Shot | Encoded frame checked | Result | Observation |", "| --- | --- | --- | --- |"];
  for (const shot of shots) {
    const evidence = manifest.beats.find((beat) => beat.shotId === shot.id);
    lines.push(`| Shot ${shot.id} | ${formatTimecode(evidence.frames.cue.seconds)} | Unverified | Inspect preview match and motion. |`);
  }
  lines.push("", "| Beat | Encoded interval checked | Result | Observation |", "| --- | --- | --- | --- |");
  for (const beat of manifest.beats) lines.push(`| Beat ${beat.id} | ${formatTimecode(beat.start)} --> ${formatTimecode(beat.end)} | Unverified | |`);
  lines.push("", "Evidence paths are relative to the lesson directory:", "");
  for (const beat of manifest.beats) {
    lines.push(`- Beat ${beat.id}: [clip with audio](${beat.clip.path}), [before](${beat.frames.before.path}), [cue](${beat.frames.cue.path}), [after](${beat.frames.after.path}).`);
  }
  return `${lines.join("\n")}\n`;
}
