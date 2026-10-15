#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import { parseStoryboardTiming, safeCoursePath, writeJsonAtomic } from "./course-state-lib.mjs";
import { beatEvidenceWindow, sha256File, videoReviewTemplate } from "./visual-beat-review.mjs";

function run(command, args) {
  const result = spawnSync(command, args, { encoding: "utf8", windowsHide: true, timeout: 120000, maxBuffer: 4 * 1024 * 1024 });
  if (result.error || result.status !== 0) throw new Error(`${path.basename(command)} failed: ${result.error?.message || result.stderr?.slice(-2000) || result.status}`);
  return result.stdout;
}

export function prepareVideoReview(rootInput, lessonId, options = {}) {
  const root = path.resolve(rootInput);
  const lessonRoot = safeCoursePath(root, `lessons/${lessonId}`).absolute;
  if (!fs.realpathSync(lessonRoot).startsWith(`${fs.realpathSync(root)}${path.sep}`)) throw new Error("lesson directory escapes course root");
  const input = Object.fromEntries(["video.mp4", "storyboard.md", "narration.wav"].map((name) => [name, sha256File(path.join(lessonRoot, name))]));
  const shots = parseStoryboardTiming(fs.readFileSync(path.join(lessonRoot, "storyboard.md"), "utf8"), { visualBeatsRequired: true });
  const ffmpeg = options.ffmpeg || "ffmpeg";
  const ffprobe = options.ffprobe || "ffprobe";
  const video = path.join(lessonRoot, "video.mp4");
  const probe = JSON.parse(run(ffprobe, ["-v", "error", "-show_streams", "-show_format", "-of", "json", video]));
  const stream = probe.streams?.find((item) => item.codec_type === "video");
  if (!stream || !probe.streams.some((item) => item.codec_type === "audio")) throw new Error("encoded video needs both video and audio streams for listening review");
  const [numerator, denominator = "1"] = String(stream.avg_frame_rate).split("/");
  const fps = Number(numerator) / Number(denominator);
  const duration = Number(stream.duration ?? probe.format?.duration);
  const offset = options.offsetSeconds ?? 0;
  const beats = shots.flatMap((shot) => shot.beats);
  const windows = beats.map((beat) => beatEvidenceWindow(beat, offset, duration, fps));
  const evidenceRoot = path.join(lessonRoot, "video-review");
  fs.mkdirSync(evidenceRoot, { recursive: true });
  if (!fs.realpathSync(evidenceRoot).startsWith(`${fs.realpathSync(lessonRoot)}${path.sep}`)) throw new Error("video-review directory escapes lesson root");
  // New runs preserve earlier review evidence and never overwrite a human review.
  const output = fs.mkdtempSync(path.join(evidenceRoot, "evidence-"));
  const relative = (file) => path.relative(lessonRoot, file).split(path.sep).join("/");
  const media = (file) => ({ path: relative(file), sha256: sha256File(file) });
  const manifest = { formatVersion: 1, videoSha256: input["video.mp4"], storyboardSha256: input["storyboard.md"], narrationSha256: input["narration.wav"], offsetSeconds: offset, durationSeconds: duration, fps, beats: [] };
  for (let index = 0; index < beats.length; index += 1) {
    const beat = beats[index];
    const window = windows[index];
    const clip = path.join(output, `${beat.id}.mp4`);
    run(ffmpeg, ["-v", "error", "-nostdin", "-n", "-i", video, "-ss", window.start.toFixed(6), "-t", (window.end - window.start).toFixed(6), "-map", "0:v:0", "-map", "0:a:0", "-c:v", "libx264", "-preset", "ultrafast", "-crf", "18", "-c:a", "aac", clip]);
    const frames = {};
    for (const [role, seconds] of Object.entries(window.frames)) {
      const file = path.join(output, `${beat.id}-${role}.png`);
      const frame = Math.round(seconds * fps);
      run(ffmpeg, ["-v", "error", "-nostdin", "-n", "-i", video, "-map", "0:v:0", "-vf", `select=eq(n\\,${frame})`, "-frames:v", "1", file]);
      frames[role] = { seconds, ...media(file) };
    }
    manifest.beats.push({ id: beat.id, shotId: beat.shotId, start: window.start, end: window.end, clip: media(clip), frames });
  }
  for (const [name, hash] of Object.entries(input)) {
    if (sha256File(path.join(lessonRoot, name)) !== hash) throw new Error(`${name} changed during extraction; evidence was not published`);
  }
  const templatePath = path.join(output, "review-template.md");
  fs.writeFileSync(templatePath, videoReviewTemplate(shots, manifest), { flag: "wx" });
  const manifestPath = path.join(lessonRoot, "video-review.json");
  writeJsonAtomic(manifestPath, manifest);
  return { manifest: manifestPath, template: templatePath, beats: beats.length, result: "Unverified", note: "Evidence extraction does not verify semantic alignment. Inspect each clip with sound and record observations in video-shot-review.md." };
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2);
  try {
    if (args.length < 2) throw new Error("usage: prepare-video-review.mjs <course-root> <lesson-id> [--offset-seconds <lead-in>] [--ffmpeg <path>] [--ffprobe <path>]");
    const options = {};
    const flags = { "--offset-seconds": "offsetSeconds", "--ffmpeg": "ffmpeg", "--ffprobe": "ffprobe" };
    for (let index = 2; index < args.length; index += 2) {
      const key = flags[args[index]];
      if (!key || args[index + 1] === undefined || options[key] !== undefined) throw new Error("unknown, duplicate, or missing video review option");
      options[key] = key === "offsetSeconds" ? Number(args[index + 1]) : args[index + 1];
    }
    console.log(JSON.stringify(prepareVideoReview(args[0], args[1], options), null, 2));
  } catch (error) {
    console.error(`prepare-video-review: ${error.message}`);
    process.exitCode = 1;
  }
}
