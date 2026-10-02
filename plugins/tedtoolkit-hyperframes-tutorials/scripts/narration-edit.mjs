#!/usr/bin/env node

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";
import { spawnSync } from "node:child_process";

const PLAN_KIND = "tutorial-narration-edit-plan";
const PLAN_VERSION = 1;
const TOKEN_PATTERN = /[\p{Script=Han}]|[\p{L}\p{N}]+(?:['’][\p{L}\p{N}]+)?/gu;

function usage() {
  console.error(`usage:
  narration-edit.mjs template <narration.txt> <edit-plan.json> --source <wav> [--source <wav> ...] [--delivery <narration.wav>] [--replace]
  narration-edit.mjs check <edit-plan.json> [--json]
  narration-edit.mjs render <edit-plan.json> [--ffmpeg <path>] [--dry-run] [--replace] [--json]
  narration-edit.mjs verify <edit-plan.json> <transcript.json> [--strict] [--json] [--min-script-coverage <0..1>] [--min-script-precision <0..1>]
`);
  process.exit(2);
}

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function writeJsonAtomic(file, value, replace = true) {
  if (!replace && fs.existsSync(file)) throw new Error(`refusing to overwrite existing file: ${file}`);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const temporary = path.join(path.dirname(file), `.${path.basename(file)}.${process.pid}.tmp`);
  fs.writeFileSync(temporary, `${JSON.stringify(value, null, 2)}\n`, "utf8");
  fs.renameSync(temporary, file);
}

function sha256Text(text) {
  return crypto.createHash("sha256").update(text).digest("hex");
}

function normalizeNewlines(text) {
  return text.replace(/\r\n?/g, "\n");
}

function tokens(text) {
  return [...normalizeNewlines(String(text ?? "")).toLocaleLowerCase().matchAll(TOKEN_PATTERN)]
    .map((match) => match[0].replaceAll("’", "'"));
}

function scriptUnits(text) {
  const paragraphs = normalizeNewlines(text)
    .split(/\n\s*\n/u)
    .map((item) => item.trim())
    .filter(Boolean);
  return paragraphs.map((paragraph, paragraphIndex) => ({
    id: `P${String(paragraphIndex + 1).padStart(2, "0")}`,
    text: paragraph,
  }));
}

function planDirectory(planPath) {
  return path.dirname(path.resolve(planPath));
}

function safePlanPath(planPath, relative, label) {
  if (typeof relative !== "string" || relative.trim() === "") throw new Error(`${label} path is missing`);
  if (path.isAbsolute(relative)) throw new Error(`${label} path must be relative to the edit plan`);
  const root = planDirectory(planPath);
  const absolute = path.resolve(root, relative);
  const relation = path.relative(root, absolute);
  if (relation === ".." || relation.startsWith(`..${path.sep}`) || path.isAbsolute(relation)) {
    throw new Error(`${label} path escapes the edit-plan directory`);
  }
  return absolute;
}

function relativeInside(planPath, inputPath, label) {
  const root = planDirectory(planPath);
  const absolute = path.resolve(inputPath);
  const relative = path.relative(root, absolute);
  if (relative === ".." || relative.startsWith(`..${path.sep}`) || path.isAbsolute(relative)) {
    throw new Error(`${label} must be inside the edit-plan directory`);
  }
  return relative.split(path.sep).join("/");
}

function finiteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

function rounded(value, digits = 4) {
  return Number(Number(value).toFixed(digits));
}

function parseFlags(args, allowed) {
  const positional = [];
  const flags = new Map();
  for (let index = 0; index < args.length; index += 1) {
    const item = args[index];
    if (!item.startsWith("--")) {
      positional.push(item);
      continue;
    }
    if (!allowed.has(item)) usage();
    if (allowed.get(item) === "boolean") flags.set(item, true);
    else {
      if (index + 1 >= args.length || args[index + 1].startsWith("--")) usage();
      if (allowed.get(item) === "multi") {
        flags.set(item, [...(flags.get(item) ?? []), args[index + 1]]);
      } else flags.set(item, args[index + 1]);
      index += 1;
    }
  }
  return { positional, flags };
}

function createTemplate(scriptPath, sourcePaths, outputPath, delivery, replace) {
  const absolutePlan = path.resolve(outputPath);
  const absoluteScript = path.resolve(scriptPath);
  const absoluteSources = sourcePaths.map((item) => path.resolve(item));
  if (!fs.existsSync(absoluteScript)) throw new Error(`missing narration script: ${absoluteScript}`);
  if (!absoluteSources.length) throw new Error("at least one narration WAV is required");
  if (new Set(absoluteSources).size !== absoluteSources.length) throw new Error("each narration WAV must be supplied only once");
  for (const source of absoluteSources) {
    if (!fs.existsSync(source)) throw new Error(`missing narration source: ${source}`);
    if (path.extname(source).toLocaleLowerCase() !== ".wav") throw new Error(`narration source must be WAV: ${source}`);
  }
  const text = normalizeNewlines(fs.readFileSync(absoluteScript, "utf8"));
  const units = scriptUnits(text);
  if (!units.length) throw new Error("narration script contains no spoken paragraphs");
  const plan = {
    kind: PLAN_KIND,
    formatVersion: PLAN_VERSION,
    script: {
      path: relativeInside(absolutePlan, absoluteScript, "narration script"),
      sha256: sha256Text(text),
      units,
    },
    sources: absoluteSources.map((source, index) => ({
      id: `source-${String(index + 1).padStart(2, "0")}`,
      path: relativeInside(absolutePlan, source, "narration source"),
    })),
    delivery: {
      path: delivery ?? "narration-semantic.wav",
      sampleRate: 48000,
      channels: 1,
      codec: "pcm_s24le",
    },
    clips: [],
  };
  safePlanPath(absolutePlan, plan.delivery.path, "delivery");
  writeJsonAtomic(absolutePlan, plan, replace);
  return plan;
}

function validatePlan(planPath) {
  const absolutePlan = path.resolve(planPath);
  const errors = [];
  const warnings = [];
  let plan;
  try {
    plan = readJson(absolutePlan);
  } catch (error) {
    return { valid: false, errors: [`cannot read edit plan: ${error.message}`], warnings, plan: null };
  }
  if (plan.kind !== PLAN_KIND) errors.push(`kind must be ${PLAN_KIND}`);
  if (plan.formatVersion !== PLAN_VERSION) errors.push(`formatVersion must be ${PLAN_VERSION}`);

  let scriptPath;
  const sourcePaths = [];
  const sourceIds = new Set();
  const absoluteSourcePaths = new Set();
  let deliveryPath;
  try { scriptPath = safePlanPath(absolutePlan, plan.script?.path, "script"); }
  catch (error) { errors.push(error.message); }
  if (!Array.isArray(plan.sources) || !plan.sources.length) errors.push("sources must contain at least one conditioned WAV");
  else {
    for (let index = 0; index < plan.sources.length; index += 1) {
      const source = plan.sources[index];
      const prefix = `sources[${index}]`;
      if (!source || typeof source !== "object") {
        errors.push(`${prefix} must be an object`);
        continue;
      }
      if (typeof source.id !== "string" || !source.id.trim()) errors.push(`${prefix}.id is required`);
      else if (sourceIds.has(source.id)) errors.push(`duplicate source id: ${source.id}`);
      else sourceIds.add(source.id);
      try {
        const absolute = safePlanPath(absolutePlan, source.path, `${prefix}`);
        sourcePaths.push({ id: source.id, path: absolute });
        if (absoluteSourcePaths.has(absolute)) errors.push(`duplicate source path: ${source.path}`);
        else absoluteSourcePaths.add(absolute);
        if (path.extname(absolute).toLocaleLowerCase() !== ".wav") errors.push(`${prefix}.path must name a WAV file`);
        if (!fs.existsSync(absolute)) errors.push(`missing source: ${source.path}`);
      } catch (error) { errors.push(error.message); }
    }
  }
  try { deliveryPath = safePlanPath(absolutePlan, plan.delivery?.path, "delivery"); }
  catch (error) { errors.push(error.message); }

  let expectedUnits = [];
  if (scriptPath && !fs.existsSync(scriptPath)) errors.push(`missing script: ${plan.script.path}`);
  else if (scriptPath) {
    const text = normalizeNewlines(fs.readFileSync(scriptPath, "utf8"));
    expectedUnits = scriptUnits(text);
    if (plan.script?.sha256 !== sha256Text(text)) errors.push("script changed after the edit plan was created");
    if (JSON.stringify(plan.script?.units ?? []) !== JSON.stringify(expectedUnits)) {
      errors.push("plan paragraphs do not match the current narration.txt");
    }
  }
  if (deliveryPath && sourcePaths.some((source) => source.path === deliveryPath)) {
    errors.push("delivery must not overwrite a conditioned source WAV");
  }
  if (deliveryPath && path.extname(deliveryPath).toLocaleLowerCase() !== ".wav") {
    errors.push("delivery.path must name a WAV file");
  }
  if (scriptPath && deliveryPath && scriptPath === deliveryPath) errors.push("delivery path collides with the script");

  if (!Number.isInteger(plan.delivery?.sampleRate) || plan.delivery.sampleRate < 8000 || plan.delivery.sampleRate > 192000) {
    errors.push("delivery.sampleRate must be an integer from 8000 to 192000");
  }
  if (plan.delivery?.channels !== 1) errors.push("delivery.channels must be 1 for the tutorial narration master");
  if (!["pcm_s24le", "pcm_s16le"].includes(plan.delivery?.codec)) {
    errors.push("delivery.codec must be pcm_s24le or pcm_s16le");
  }

  if (!Array.isArray(plan.clips) || !plan.clips.length) errors.push("clips must contain at least one selected source range");
  const clipIds = new Set();
  const assigned = [];
  const knownUnits = new Set(expectedUnits.map((item) => item.id));
  const clips = Array.isArray(plan.clips) ? plan.clips : [];
  for (let index = 0; index < clips.length; index += 1) {
    const clip = clips[index];
    const prefix = `clips[${index}]`;
    if (!clip || typeof clip !== "object") {
      errors.push(`${prefix} must be an object`);
      continue;
    }
    if (typeof clip.id !== "string" || !clip.id.trim()) errors.push(`${prefix}.id is required`);
    else if (clipIds.has(clip.id)) errors.push(`duplicate clip id: ${clip.id}`);
    else clipIds.add(clip.id);
    if (typeof clip.unit !== "string" || !clip.unit.trim()) errors.push(`${prefix}.unit is required`);
    else {
      if (!knownUnits.has(clip.unit)) errors.push(`${prefix} references unknown paragraph: ${clip.unit}`);
      assigned.push(clip.unit);
    }
    if (typeof clip.sourceId !== "string" || !sourceIds.has(clip.sourceId)) {
      errors.push(`${prefix}.sourceId must name one of sources[]`);
    }
    if (!finiteNumber(clip.start) || clip.start < 0) errors.push(`${prefix}.start must be a non-negative number`);
    if (!finiteNumber(clip.end) || !finiteNumber(clip.start) || clip.end <= clip.start) {
      errors.push(`${prefix}.end must be greater than start`);
    }
    const duration = finiteNumber(clip.start) && finiteNumber(clip.end) ? clip.end - clip.start : 0;
    for (const field of ["fadeIn", "fadeOut"]) {
      const value = clip[field] ?? 0.005;
      if (!finiteNumber(value) || value < 0 || value > duration / 2) errors.push(`${prefix}.${field} is invalid for this range`);
    }
    const gap = clip.gapAfter ?? 0;
    if (!finiteNumber(gap) || gap < 0) errors.push(`${prefix}.gapAfter must be a non-negative number`);
    else if (gap > 2) warnings.push(`${prefix}.gapAfter is longer than 2 seconds; confirm it is intentional`);
    if (typeof clip.selectionReason !== "string" || !clip.selectionReason.trim()) {
      errors.push(`${prefix}.selectionReason is required for an auditable take choice`);
    }
  }

  const expectedIds = expectedUnits.map((item) => item.id);
  const counts = new Map();
  for (const unit of assigned) counts.set(unit, (counts.get(unit) ?? 0) + 1);
  for (const unit of expectedIds) {
    if (!counts.has(unit)) errors.push(`missing paragraph coverage: ${unit}`);
    else if (counts.get(unit) !== 1) errors.push(`paragraph must be covered exactly once: ${unit}`);
  }
  if (assigned.length === expectedIds.length && assigned.some((item, index) => item !== expectedIds[index])) {
    errors.push("clips must follow the approved paragraph order exactly");
  }

  for (let left = 0; left < clips.length; left += 1) {
    for (let right = left + 1; right < clips.length; right += 1) {
      const a = clips[left];
      const b = clips[right];
      if (![a?.start, a?.end, b?.start, b?.end].every(finiteNumber)) continue;
      if (a.sourceId !== b.sourceId) continue;
      const overlap = Math.min(a.end, b.end) - Math.max(a.start, b.start);
      if (overlap > 0.02) {
        const allowed = b.allowSourceOverlap === true && typeof b.overlapReason === "string" && b.overlapReason.trim();
        if (!allowed) errors.push(`source ranges ${a.id ?? left} and ${b.id ?? right} overlap by ${rounded(overlap)}s`);
        else warnings.push(`source overlap retained for ${b.id}: ${b.overlapReason.trim()}`);
      }
    }
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings,
    plan,
    paths: { plan: absolutePlan, script: scriptPath, sources: sourcePaths, delivery: deliveryPath },
    summary: {
      scriptUnits: expectedIds.length,
      sources: sourcePaths.length,
      clips: clips.length,
      selectedSeconds: rounded(clips.reduce((sum, clip) => sum + (finiteNumber(clip?.end) && finiteNumber(clip?.start) ? clip.end - clip.start : 0), 0)),
      insertedSilenceSeconds: rounded(clips.reduce((sum, clip) => sum + (finiteNumber(clip?.gapAfter) ? clip.gapAfter : 0), 0)),
    },
  };
}

function formatPlanReport(report) {
  const lines = [`Narration edit plan: ${report.valid ? "PASS" : "FAIL"}`];
  if (report.summary) {
    lines.push(`- ${report.summary.scriptUnits} paragraphs; ${report.summary.sources} WAV sources; ${report.summary.clips} clips; ${report.summary.selectedSeconds}s selected; ${report.summary.insertedSilenceSeconds}s inserted silence`);
  }
  for (const error of report.errors) lines.push(`- ERROR: ${error}`);
  for (const warning of report.warnings) lines.push(`- WARNING: ${warning}`);
  return `${lines.join("\n")}\n`;
}

function ffmpegPlan(report, executable, temporaryOutput) {
  const { plan } = report;
  const sampleRate = plan.delivery.sampleRate;
  const sourceIndex = new Map(report.paths.sources.map((source, index) => [source.id, index]));
  const stages = [];
  const concatInputs = [];
  for (let index = 0; index < plan.clips.length; index += 1) {
    const clip = plan.clips[index];
    const duration = clip.end - clip.start;
    const fadeIn = clip.fadeIn ?? 0.005;
    const fadeOut = clip.fadeOut ?? 0.005;
    const filters = [
      `atrim=start=${rounded(clip.start)}:end=${rounded(clip.end)}`,
      "asetpts=PTS-STARTPTS",
      `aresample=${sampleRate}`,
      "aformat=sample_fmts=fltp:channel_layouts=mono",
    ];
    if (fadeIn > 0) filters.push(`afade=t=in:st=0:d=${rounded(fadeIn)}`);
    if (fadeOut > 0) filters.push(`afade=t=out:st=${rounded(duration - fadeOut)}:d=${rounded(fadeOut)}`);
    stages.push(`[${sourceIndex.get(clip.sourceId)}:a]${filters.join(",")}[c${index}]`);
    concatInputs.push(`[c${index}]`);
    const gap = clip.gapAfter ?? 0;
    if (gap > 0) {
      stages.push(`anullsrc=r=${sampleRate}:cl=mono:d=${rounded(gap)}[g${index}]`);
      concatInputs.push(`[g${index}]`);
    }
  }
  stages.push(`${concatInputs.join("")}concat=n=${concatInputs.length}:v=0:a=1[outa]`);
  const args = ["-hide_banner", "-loglevel", "error", "-y"];
  for (const source of report.paths.sources) args.push("-i", source.path);
  args.push(
    "-filter_complex", stages.join(";"),
    "-map", "[outa]",
    "-ar", String(sampleRate),
    "-ac", "1",
    "-c:a", plan.delivery.codec,
    temporaryOutput,
  );
  return { executable, args, filterComplex: stages.join(";"), output: report.paths.delivery };
}

function renderPlan(planPath, options) {
  const report = validatePlan(planPath);
  if (!report.valid) throw new Error(formatPlanReport(report).trim());
  const output = report.paths.delivery;
  const extension = path.extname(output) || ".wav";
  const base = output.slice(0, output.length - extension.length);
  const temporary = `${base}.tmp-${process.pid}${extension}`;
  const command = ffmpegPlan(report, options.ffmpeg ?? "ffmpeg", temporary);
  if (options.dryRun) return { status: "dry-run", ...command, args: [...command.args.slice(0, -1), output] };
  if (fs.existsSync(output) && !options.replace) throw new Error(`delivery exists; pass --replace to preserve it as a backup: ${output}`);
  fs.mkdirSync(path.dirname(output), { recursive: true });
  const result = spawnSync(command.executable, command.args, { encoding: "utf8" });
  if (result.error) throw new Error(`failed to launch ffmpeg: ${result.error.message}`);
  if (result.status !== 0) {
    if (fs.existsSync(temporary)) fs.rmSync(temporary);
    throw new Error(`ffmpeg failed (${result.status}): ${(result.stderr || result.stdout || "unknown error").trim()}`);
  }
  let backup;
  if (fs.existsSync(output)) {
    const stamp = new Date().toISOString().replaceAll(":", "-");
    backup = `${base}.backup-${stamp}${extension}`;
    fs.renameSync(output, backup);
  }
  fs.renameSync(temporary, output);
  return { status: "rendered", output, ...(backup ? { backup } : {}) };
}

function transcriptEntries(payload) {
  const rows = Array.isArray(payload)
    ? payload
    : Array.isArray(payload?.segments)
      ? payload.segments
      : Array.isArray(payload?.transcription)
        ? payload.transcription
        : [];
  if (!rows.length) throw new Error("transcript must be a non-empty array, segments[], or transcription[]");
  return rows.map((row, index) => {
    const offset = row?.offsets;
    const start = finiteNumber(row?.start) ? row.start : finiteNumber(offset?.from) ? offset.from / 1000 : NaN;
    const end = finiteNumber(row?.end) ? row.end : finiteNumber(offset?.to) ? offset.to / 1000 : NaN;
    const text = String(row?.text ?? "").trim();
    if (!finiteNumber(start) || !finiteNumber(end) || end <= start) {
      throw new Error(`transcript entry ${index + 1} has invalid start/end`);
    }
    if (!text) throw new Error(`transcript entry ${index + 1} has no text`);
    return { id: row.id ?? index + 1, start, end, text, tokens: tokens(text) };
  });
}

function lcsLength(left, right) {
  if (!left.length || !right.length) return 0;
  let previous = new Uint32Array(right.length + 1);
  for (let i = 1; i <= left.length; i += 1) {
    const current = new Uint32Array(right.length + 1);
    for (let j = 1; j <= right.length; j += 1) {
      current[j] = left[i - 1] === right[j - 1]
        ? previous[j - 1] + 1
        : Math.max(previous[j], current[j - 1]);
    }
    previous = current;
  }
  return previous[right.length];
}

function editDistance(left, right) {
  let previous = Uint32Array.from({ length: right.length + 1 }, (_, index) => index);
  for (let i = 1; i <= left.length; i += 1) {
    const current = new Uint32Array(right.length + 1);
    current[0] = i;
    for (let j = 1; j <= right.length; j += 1) {
      current[j] = Math.min(
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + (left[i - 1] === right[j - 1] ? 0 : 1),
      );
    }
    previous = current;
  }
  return previous[right.length];
}

function displayTokens(items) {
  return items.join(items.some((item) => /\p{Script=Han}/u.test(item)) ? "" : " ");
}

function exactBoundaryRepeat(previous, current, minimum = 4, maximum = 16) {
  for (let size = Math.min(previous.length, current.length, maximum); size >= minimum; size -= 1) {
    if (previous.slice(-size).every((item, index) => item === current[index])) return current.slice(0, size);
  }
  return [];
}

function internalRepeats(items, minimum = 4, maximum = 16) {
  const matches = [];
  for (let index = 0; index + minimum * 2 <= items.length; index += 1) {
    for (let size = Math.min(maximum, Math.floor((items.length - index) / 2)); size >= minimum; size -= 1) {
      const left = items.slice(index, index + size);
      if (left.every((item, offset) => item === items[index + size + offset])) {
        matches.push(left);
        index += size * 2 - 1;
        break;
      }
    }
  }
  return matches;
}

function verifyTranscript(planPath, transcriptPath, minimumCoverage, minimumPrecision) {
  const planReport = validatePlan(planPath);
  const blockers = planReport.errors.map((message) => ({ kind: "edit_plan", message }));
  const warnings = [...planReport.warnings];
  if (!planReport.plan) return { ready: false, blockers, warnings };
  let entries;
  try { entries = transcriptEntries(readJson(path.resolve(transcriptPath))); }
  catch (error) {
    blockers.push({ kind: "transcript", message: error.message });
    return { ready: false, blockers, warnings };
  }

  for (let index = 1; index < entries.length; index += 1) {
    const previous = entries[index - 1];
    const current = entries[index];
    if (current.start < previous.end - 0.02) {
      blockers.push({ kind: "timestamp_overlap", message: `transcript entries ${previous.id} and ${current.id} overlap`, start: current.start });
    }
    const gap = current.start - previous.end;
    if (gap > 2) warnings.push(`transcript gap before ${current.id} is ${rounded(gap, 3)}s; confirm it is intentional`);
    const repeated = exactBoundaryRepeat(previous.tokens, current.tokens);
    if (repeated.length) {
      blockers.push({
        kind: "boundary_repeat",
        message: `repeated speech crosses entries ${previous.id} and ${current.id}: ${displayTokens(repeated)}`,
        start: previous.start,
        end: current.end,
      });
      continue;
    }
    if (Math.min(previous.tokens.length, current.tokens.length) >= 5) {
      const lengthRatio = Math.min(previous.tokens.length, current.tokens.length) / Math.max(previous.tokens.length, current.tokens.length);
      const similarity = 1 - editDistance(previous.tokens, current.tokens) / Math.max(previous.tokens.length, current.tokens.length);
      if (lengthRatio >= 0.6 && similarity >= 0.9) {
        blockers.push({
          kind: "adjacent_near_duplicate",
          message: `entries ${previous.id} and ${current.id} are near-duplicate takes (${rounded(similarity, 3)})`,
          start: previous.start,
          end: current.end,
        });
      }
    }
  }
  for (const entry of entries) {
    for (const repeated of internalRepeats(entry.tokens)) {
      blockers.push({
        kind: "internal_repeat",
        message: `entry ${entry.id} contains an immediate repeat: ${displayTokens(repeated)}`,
        start: entry.start,
        end: entry.end,
      });
    }
  }

  const expected = (planReport.plan.script?.units ?? []).flatMap((unit) => tokens(unit.text));
  const actual = entries.flatMap((entry) => entry.tokens);
  const aligned = expected.length && actual.length ? lcsLength(expected, actual) : 0;
  const coverage = expected.length ? aligned / expected.length : 0;
  const precision = actual.length ? aligned / actual.length : 0;
  if (coverage < minimumCoverage) {
    blockers.push({
      kind: "script_coverage",
      message: `final transcript covers only ${rounded(coverage * 100, 1)}% of approved script tokens; inspect for missing or changed speech`,
    });
  } else if (coverage < Math.max(minimumCoverage, 0.85)) {
    warnings.push(`script/transcript token coverage is ${rounded(coverage * 100, 1)}%; inspect low-confidence or technical terms against the audio`);
  }
  if (precision < minimumPrecision) {
    blockers.push({
      kind: "off_script_content",
      message: `only ${rounded(precision * 100, 1)}% of transcript tokens align with the approved script; required minimum is ${rounded(minimumPrecision * 100, 1)}%; inspect for false starts, production remarks, or unapproved speech`,
    });
  }

  for (const unit of planReport.plan.script?.units ?? []) {
    const unitTokens = tokens(unit.text);
    if (unitTokens.length < 4) continue;
    const ratio = lcsLength(unitTokens, actual) / unitTokens.length;
    if (ratio < minimumCoverage) {
      blockers.push({
        kind: "script_unit_coverage",
        message: `${unit.id} has only ${rounded(ratio * 100, 1)}% transcript coverage; inspect the complete paragraph for missing, changed, or unusable speech`,
      });
    }
  }
  for (const entry of entries) {
    if (entry.tokens.length < 4) continue;
    const ratio = lcsLength(expected, entry.tokens) / entry.tokens.length;
    if (ratio < 0.45) {
      blockers.push({
        kind: "off_script_entry",
        message: `entry ${entry.id} aligns poorly with the approved script (${rounded(ratio * 100, 1)}%): ${entry.text}`,
        start: entry.start,
        end: entry.end,
      });
    }
  }

  return {
    kind: "tutorial-narration-verification",
    formatVersion: 1,
    ready: blockers.length === 0,
    plan: path.resolve(planPath),
    transcript: path.resolve(transcriptPath),
    summary: {
      transcriptEntries: entries.length,
      expectedTokens: expected.length,
      transcriptTokens: actual.length,
      scriptCoverage: rounded(coverage, 4),
      scriptPrecision: rounded(precision, 4),
      blockers: blockers.length,
      warnings: warnings.length,
    },
    blockers,
    warnings,
    reminder: "Passing this report does not replace listening to every edit boundary and the complete narration at normal speed.",
  };
}

function formatVerification(report) {
  const lines = [`Narration verification: ${report.ready ? "PASS" : "FAIL"}`];
  if (report.summary) lines.push(`- script coverage: ${rounded(report.summary.scriptCoverage * 100, 1)}%; script precision: ${rounded(report.summary.scriptPrecision * 100, 1)}%; ${report.summary.transcriptEntries} transcript entries`);
  for (const blocker of report.blockers) lines.push(`- BLOCKER [${blocker.kind}]: ${blocker.message}`);
  for (const warning of report.warnings) lines.push(`- WARNING: ${warning}`);
  if (report.reminder) lines.push(`- ${report.reminder}`);
  return `${lines.join("\n")}\n`;
}

async function main() {
  const [command, ...rest] = process.argv.slice(2);
  if (!command) usage();
  if (command === "template") {
    const { positional, flags } = parseFlags(rest, new Map([
      ["--source", "multi"], ["--delivery", "value"], ["--replace", "boolean"],
    ]));
    if (positional.length !== 2 || !(flags.get("--source")?.length)) usage();
    const plan = createTemplate(positional[0], flags.get("--source"), positional[1], flags.get("--delivery"), flags.has("--replace"));
    console.log(`Created narration edit plan with ${plan.script.units.length} paragraphs and ${plan.sources.length} WAV sources: ${path.resolve(positional[1])}`);
    return;
  }
  if (command === "check") {
    const { positional, flags } = parseFlags(rest, new Map([["--json", "boolean"]]));
    if (positional.length !== 1) usage();
    const report = validatePlan(positional[0]);
    process.stdout.write(flags.has("--json") ? `${JSON.stringify(report, null, 2)}\n` : formatPlanReport(report));
    process.exitCode = report.valid ? 0 : 1;
    return;
  }
  if (command === "render") {
    const { positional, flags } = parseFlags(rest, new Map([
      ["--ffmpeg", "value"], ["--dry-run", "boolean"], ["--replace", "boolean"], ["--json", "boolean"],
    ]));
    if (positional.length !== 1) usage();
    const result = renderPlan(positional[0], {
      ffmpeg: flags.get("--ffmpeg"), dryRun: flags.has("--dry-run"), replace: flags.has("--replace"),
    });
    process.stdout.write(flags.has("--json") ? `${JSON.stringify(result, null, 2)}\n` : `${result.status}: ${result.output}\n`);
    return;
  }
  if (command === "verify") {
    const { positional, flags } = parseFlags(rest, new Map([
      ["--strict", "boolean"], ["--json", "boolean"], ["--min-script-coverage", "value"],
      ["--min-script-precision", "value"],
    ]));
    if (positional.length !== 2) usage();
    const minimumCoverage = flags.has("--min-script-coverage") ? Number(flags.get("--min-script-coverage")) : 1;
    const minimumPrecision = flags.has("--min-script-precision") ? Number(flags.get("--min-script-precision")) : 1;
    if (!Number.isFinite(minimumCoverage) || minimumCoverage < 0 || minimumCoverage > 1) usage();
    if (!Number.isFinite(minimumPrecision) || minimumPrecision < 0 || minimumPrecision > 1) usage();
    const report = verifyTranscript(positional[0], positional[1], minimumCoverage, minimumPrecision);
    process.stdout.write(flags.has("--json") ? `${JSON.stringify(report, null, 2)}\n` : formatVerification(report));
    if (flags.has("--strict") && !report.ready) process.exitCode = 2;
    return;
  }
  usage();
}

main().catch((error) => {
  console.error(`narration-edit: ${error.message}`);
  process.exitCode = 1;
});
