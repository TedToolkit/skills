import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

export const LESSON_STAGES = [
  "planned",
  "script-draft",
  "script-approved",
  "narration-final",
  "storyboard-final",
  "video-verified",
  "cover-verified",
];

export const NEXT_SKILL = {
  planned: "design-tutorial",
  "script-draft": "review-tutorial-script",
  "script-approved": "edit-tutorial-narration",
  "narration-final": "design-tutorial",
  "storyboard-final": "build-tutorial",
  "video-verified": "create-tutorial-cover",
  "cover-verified": "package-tutorial-course",
};

const CONFIG_FIELDS = ["courseId", "title", "slug", "contentLanguage", "outline"];

export const DEFAULT_VIDEO_CONFIG = Object.freeze({
  aspectRatio: "16:9",
  width: 1920,
  height: 1080,
  fps: 30,
  container: "mp4",
  videoCodec: "h264",
  pixelFormat: "yuv420p",
  audioCodec: "aac",
  audioSampleRate: 48000,
});

export const DEFAULT_COVER_CONFIG = Object.freeze({
  width: 1920,
  height: 1080,
  format: "png",
});

function issue(code, message, lessonId) {
  return lessonId ? { code, lessonId, message } : { code, message };
}

export function stageIndex(stage) {
  return LESSON_STAGES.indexOf(stage);
}

export function lessonContractSha256(lesson) {
  const contract = JSON.stringify({
    id: lesson.id,
    type: lesson.type,
    requires: lesson.requires,
    sourcePaths: lesson.sourcePaths,
  });
  return `sha256:${crypto.createHash("sha256").update(contract).digest("hex")}`;
}

export function productionContractSha256(config, stage) {
  const index = stageIndex(stage);
  if (index < stageIndex("video-verified")) return undefined;
  const production = effectiveProductionConfig(config);
  const contract = index >= stageIndex("cover-verified")
    ? { video: production.video, cover: production.cover }
    : { video: production.video };
  return `sha256:${crypto.createHash("sha256").update(JSON.stringify(contract)).digest("hex")}`;
}

export function courseRoot(input) {
  return path.resolve(input || ".");
}

export function safeCoursePath(root, relativePath) {
  if (typeof relativePath !== "string" || relativePath.length === 0) {
    throw new Error("path must be a non-empty string");
  }
  if (path.isAbsolute(relativePath) || relativePath.includes("\\")) {
    throw new Error(`path must be relative and use forward slashes: ${relativePath}`);
  }
  const normalized = path.posix.normalize(relativePath);
  if (normalized === ".." || normalized.startsWith("../") || normalized.startsWith("/")) {
    throw new Error(`path escapes the course root: ${relativePath}`);
  }
  const absolute = path.resolve(root, normalized);
  const prefix = root.endsWith(path.sep) ? root : `${root}${path.sep}`;
  if (absolute !== root && !absolute.startsWith(prefix)) {
    throw new Error(`path escapes the course root: ${relativePath}`);
  }
  return { relative: normalized, absolute };
}

export function readJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

export function loadCourseDocuments(rootInput, stateOverride) {
  const root = courseRoot(rootInput);
  const configPath = path.join(root, "course.config.json");
  const statePath = path.join(root, "course-state.json");
  if (!fs.existsSync(configPath)) throw new Error(`missing ${configPath}`);
  if (!stateOverride && !fs.existsSync(statePath)) throw new Error(`missing ${statePath}`);
  return {
    root,
    configPath,
    statePath,
    config: readJson(configPath),
    state: stateOverride ?? readJson(statePath),
  };
}

export async function hashFile(filePath) {
  const hash = crypto.createHash("sha256");
  const stream = fs.createReadStream(filePath);
  for await (const chunk of stream) hash.update(chunk);
  return `sha256:${hash.digest("hex")}`;
}

export function requiredLessonFiles(lesson, stage) {
  const index = stageIndex(stage);
  if (index < 1) return [];
  const base = `lessons/${lesson.id}`;
  const files = [`${base}/lesson.md`, `${base}/narration.txt`, ...(lesson.sourcePaths || [])];
  if (index >= stageIndex("narration-final")) {
    files.push(
      `${base}/narration-source.wav`,
      `${base}/narration.wav`,
      `${base}/transcript.json`,
    );
  }
  if (index >= stageIndex("storyboard-final")) files.push(`${base}/storyboard.md`);
  if (index >= stageIndex("video-verified")) {
    files.push(`${base}/video.mp4`, `${base}/captions.vtt`);
  }
  if (index >= stageIndex("cover-verified")) {
    files.push("cover-system.md", "course-cover.png", `${base}/cover.png`);
  }
  return files;
}

export async function fingerprintFiles(root, relativePaths) {
  const result = {};
  for (const relativePath of [...new Set(relativePaths)].sort()) {
    const resolved = safeCoursePath(root, relativePath);
    const stat = fs.statSync(resolved.absolute);
    if (!stat.isFile()) throw new Error(`required artifact is not a file: ${relativePath}`);
    result[resolved.relative] = await hashFile(resolved.absolute);
  }
  return result;
}

export async function fingerprintDirectory(root, relativeDirectory) {
  const directory = safeCoursePath(root, relativeDirectory);
  if (directory.relative === ".") throw new Error("release directory cannot be the course root");
  const stat = fs.statSync(directory.absolute);
  if (!stat.isDirectory()) throw new Error(`release path is not a directory: ${relativeDirectory}`);
  const files = [];
  function visit(absoluteDirectory) {
    for (const entry of fs.readdirSync(absoluteDirectory, { withFileTypes: true })) {
      const absolute = path.join(absoluteDirectory, entry.name);
      if (entry.isSymbolicLink()) throw new Error(`release contains a symbolic link: ${absolute}`);
      if (entry.isDirectory()) visit(absolute);
      else if (entry.isFile()) files.push(path.relative(root, absolute).split(path.sep).join("/"));
    }
  }
  visit(directory.absolute);
  if (files.length === 0) throw new Error(`release directory is empty: ${relativeDirectory}`);
  return fingerprintFiles(root, files);
}

export function validateStateShape(config, state) {
  const errors = [];
  for (const field of CONFIG_FIELDS) {
    if (typeof config[field] !== "string" || config[field].trim() === "") {
      errors.push(issue("CONFIG_FIELD", `course.config.json requires a non-empty ${field}`));
    }
  }
  if (state?.formatVersion !== 1) {
    errors.push(issue("STATE_VERSION", "course-state.json formatVersion must be 1"));
  }
  if (typeof state?.courseId !== "string" || state.courseId !== config.courseId) {
    errors.push(issue("COURSE_ID", "course-state.json courseId must match course.config.json"));
  }
  errors.push(...validateProductionConfig(config));
  if (!Array.isArray(state?.lessons)) {
    errors.push(issue("LESSONS", "course-state.json lessons must be an array"));
    return errors;
  }
  const ids = new Set();
  for (const lesson of state.lessons) {
    const id = lesson?.id;
    if (typeof id !== "string" || !/^[A-Za-z0-9][A-Za-z0-9._-]*$/.test(id)) {
      errors.push(issue("LESSON_ID", `invalid lesson id: ${String(id)}`));
      continue;
    }
    if (ids.has(id)) errors.push(issue("DUPLICATE_LESSON", `duplicate lesson id: ${id}`, id));
    ids.add(id);
    if (!['core', 'extension'].includes(lesson.type)) {
      errors.push(issue("LESSON_TYPE", "type must be core or extension", id));
    }
    if (!Array.isArray(lesson.requires) || lesson.requires.some((item) => typeof item !== "string")) {
      errors.push(issue("REQUIRES", "requires must be an array of lesson IDs", id));
    }
    if (!Array.isArray(lesson.sourcePaths) || lesson.sourcePaths.some((item) => typeof item !== "string")) {
      errors.push(issue("SOURCE_PATHS", "sourcePaths must be an array of course-relative paths", id));
    } else if (new Set(lesson.sourcePaths).size !== lesson.sourcePaths.length) {
      errors.push(issue("SOURCE_PATHS", "sourcePaths contains a duplicate path", id));
    }
    if (stageIndex(lesson.status) < 0) {
      errors.push(issue("LESSON_STATUS", `unknown status: ${String(lesson.status)}`, id));
    }
    if (!lesson.records || typeof lesson.records !== "object" || Array.isArray(lesson.records)) {
      errors.push(issue("LESSON_RECORDS", "records must be an object", id));
    }
  }
  if (!state.release || !["not-packaged", "packaged"].includes(state.release.status)) {
    errors.push(issue("RELEASE_STATUS", "release.status must be not-packaged or packaged"));
  }
  return errors;
}

function positiveInteger(value) {
  return Number.isInteger(value) && value > 0;
}

export function effectiveProductionConfig(config) {
  return {
    video: { ...DEFAULT_VIDEO_CONFIG, ...(config?.video || {}) },
    cover: { ...DEFAULT_COVER_CONFIG, ...(config?.cover || {}) },
  };
}

export function validateProductionConfig(config) {
  const errors = [];
  for (const section of ["video", "cover"]) {
    if (config?.[section] !== undefined &&
        (!config[section] || typeof config[section] !== "object" || Array.isArray(config[section]))) {
      errors.push(issue("PRODUCTION_CONFIG", `${section} must be an object when provided`));
    }
  }
  if (errors.length) return errors;

  const { video, cover } = effectiveProductionConfig(config);
  if (!positiveInteger(video.width) || !positiveInteger(video.height)) {
    errors.push(issue("VIDEO_DIMENSIONS", "video width and height must be positive integers"));
  }
  if (!positiveInteger(video.fps)) {
    errors.push(issue("VIDEO_FPS", "video fps must be a positive integer"));
  }
  if (!positiveInteger(video.audioSampleRate)) {
    errors.push(issue("AUDIO_SAMPLE_RATE", "video audioSampleRate must be a positive integer"));
  }
  const ratio = /^(\d+):(\d+)$/.exec(video.aspectRatio);
  if (!ratio || Number(ratio[1]) === 0 || Number(ratio[2]) === 0) {
    errors.push(issue("VIDEO_ASPECT_RATIO", "video aspectRatio must use a positive W:H ratio"));
  } else if (positiveInteger(video.width) && positiveInteger(video.height)) {
    const declared = Number(ratio[1]) / Number(ratio[2]);
    const actual = video.width / video.height;
    if (Math.abs(declared - actual) > 0.001) {
      errors.push(issue("VIDEO_ASPECT_RATIO", "video width and height must match aspectRatio"));
    }
  }
  const expectedStrings = {
    container: "mp4",
    videoCodec: "h264",
    pixelFormat: "yuv420p",
    audioCodec: "aac",
  };
  for (const [field, expected] of Object.entries(expectedStrings)) {
    if (video[field] !== expected) {
      errors.push(issue("VIDEO_FORMAT", `video ${field} must be ${expected}`));
    }
  }
  if (!positiveInteger(cover.width) || !positiveInteger(cover.height)) {
    errors.push(issue("COVER_DIMENSIONS", "cover width and height must be positive integers"));
  }
  if (cover.format !== "png") {
    errors.push(issue("COVER_FORMAT", "cover format must be png"));
  }
  if (positiveInteger(video.width) && positiveInteger(video.height) &&
      positiveInteger(cover.width) && positiveInteger(cover.height) &&
      Math.abs(video.width / video.height - cover.width / cover.height) > 0.001) {
    errors.push(issue("COVER_ASPECT_RATIO", "cover dimensions must match the video aspect ratio"));
  }
  return errors;
}

export function validateDependencyGraph(state) {
  const errors = [];
  if (!Array.isArray(state?.lessons)) return { errors, order: [] };
  const byId = new Map(state.lessons.map((lesson) => [lesson.id, lesson]));
  const position = new Map(state.lessons.map((lesson, index) => [lesson.id, index]));
  for (const lesson of state.lessons) {
    if (!Array.isArray(lesson.requires)) continue;
    if (new Set(lesson.requires).size !== lesson.requires.length) {
      errors.push(issue("DUPLICATE_DEPENDENCY", "requires contains a duplicate lesson ID", lesson.id));
    }
    for (const dependency of lesson.requires) {
      if (dependency === lesson.id) {
        errors.push(issue("SELF_DEPENDENCY", "lesson cannot depend on itself", lesson.id));
      } else if (!byId.has(dependency)) {
        errors.push(issue("UNKNOWN_DEPENDENCY", `unknown prerequisite: ${dependency}`, lesson.id));
      } else if (lesson.type === "core" && byId.get(dependency).type === "extension") {
        errors.push(issue("EXTENSION_UNLOCKS_CORE", `core lesson depends on extension ${dependency}`, lesson.id));
      } else if (position.get(dependency) > position.get(lesson.id)) {
        errors.push(issue("VIEWING_ORDER", `prerequisite ${dependency} appears after its lesson`, lesson.id));
      }
    }
  }

  const indegree = new Map(state.lessons.map((lesson) => [lesson.id, 0]));
  const outgoing = new Map(state.lessons.map((lesson) => [lesson.id, []]));
  for (const lesson of state.lessons) {
    for (const dependency of lesson.requires || []) {
      if (!byId.has(dependency) || dependency === lesson.id) continue;
      indegree.set(lesson.id, indegree.get(lesson.id) + 1);
      outgoing.get(dependency).push(lesson.id);
    }
  }
  const queue = state.lessons.filter((lesson) => indegree.get(lesson.id) === 0).map((lesson) => lesson.id);
  const order = [];
  while (queue.length) {
    queue.sort((a, b) => position.get(a) - position.get(b));
    const id = queue.shift();
    order.push(id);
    for (const target of outgoing.get(id) || []) {
      indegree.set(target, indegree.get(target) - 1);
      if (indegree.get(target) === 0) queue.push(target);
    }
  }
  if (order.length !== state.lessons.length) {
    const cyclic = state.lessons.filter((lesson) => !order.includes(lesson.id)).map((lesson) => lesson.id);
    errors.push(issue("DEPENDENCY_CYCLE", `dependency graph contains a cycle: ${cyclic.join(", ")}`));
  }
  return { errors, order };
}

function finiteNonNegative(value) {
  return typeof value === "number" && Number.isFinite(value) && value >= 0;
}

function normalizeSpokenText(value) {
  return value
    .replace(/<[^>]*>/g, "")
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .normalize("NFKC")
    .toLocaleLowerCase("und")
    .replace(/[\p{P}\p{S}\s]/gu, "");
}

export function extractPostLessonQuestion(markdown) {
  const normalized = markdown.replace(/^\uFEFF/, "").replace(/\r\n?/g, "\n");
  const heading = /^##[ \t]+Post-lesson question[ \t]*$/gm;
  const matches = [...normalized.matchAll(heading)];
  if (matches.length !== 1) {
    throw new Error("lesson.md must contain exactly one ## Post-lesson question section");
  }
  const sectionStart = matches[0].index + matches[0][0].length;
  const remainder = normalized.slice(sectionStart);
  const nextSection = /^#{1,2}[ \t]+\S.*$/m.exec(remainder);
  const question = remainder
    .slice(0, nextSection?.index ?? remainder.length)
    .replace(/<!--[\s\S]*?-->/g, "")
    .trim();
  if (!question || normalizeSpokenText(question) === "") {
    throw new Error("## Post-lesson question must contain learner-facing text");
  }
  return question;
}

function releaseVisibleText(html) {
  return normalizeSpokenText(
    html
      .replace(/<(script|style|template)\b[^>]*>[\s\S]*?<\/\1>/gi, " ")
      .replace(/&#x([0-9a-f]+);/gi, (_, value) => String.fromCodePoint(Number.parseInt(value, 16)))
      .replace(/&#([0-9]+);/g, (_, value) => String.fromCodePoint(Number.parseInt(value, 10)))
      .replace(/&quot;/gi, '"')
      .replace(/&apos;|&#39;/gi, "'")
      .replace(/&nbsp;/gi, " "),
  );
}

function escapeRegularExpression(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function parseVttTimestamp(text) {
  const match = /^(?:(\d{2,}):)?(\d{2}):(\d{2})\.(\d{3})$/.exec(text);
  if (!match) return Number.NaN;
  const hours = Number(match[1] || 0);
  const minutes = Number(match[2]);
  const seconds = Number(match[3]);
  const millis = Number(match[4]);
  if (minutes > 59 || seconds > 59) return Number.NaN;
  return hours * 3600 + minutes * 60 + seconds + millis / 1000;
}

export function parseWebVtt(contents) {
  const normalized = contents.replace(/^\uFEFF/, "").replace(/\r\n?/g, "\n");
  if (!normalized.startsWith("WEBVTT")) throw new Error("captions.vtt must start with WEBVTT");
  const blocks = normalized.split(/\n{2,}/).slice(1);
  const cues = [];
  for (const block of blocks) {
    const lines = block.split("\n").filter((line) => line.length > 0);
    if (lines.length === 0 || /^(NOTE|STYLE|REGION)(?:\s|$)/.test(lines[0])) continue;
    const timingIndex = lines.findIndex((line) => line.includes("-->"));
    if (timingIndex < 0) throw new Error(`WebVTT cue has no timing line: ${lines[0]}`);
    const match = /^(\S+)\s+-->\s+(\S+)(?:\s+.*)?$/.exec(lines[timingIndex]);
    if (!match) throw new Error(`invalid WebVTT timing line: ${lines[timingIndex]}`);
    const start = parseVttTimestamp(match[1]);
    const end = parseVttTimestamp(match[2]);
    if (!Number.isFinite(start) || !Number.isFinite(end) || end <= start) {
      throw new Error(`invalid WebVTT cue range: ${lines[timingIndex]}`);
    }
    const text = lines.slice(timingIndex + 1).join("\n").trim();
    if (!text) throw new Error(`WebVTT cue has no text: ${lines[timingIndex]}`);
    cues.push({ start, end, text });
  }
  if (cues.length === 0) throw new Error("captions.vtt contains no cues");
  for (let index = 1; index < cues.length; index += 1) {
    if (cues[index].start < cues[index - 1].end - 0.001) {
      throw new Error(`WebVTT cues overlap or are out of order at cue ${index + 1}`);
    }
  }
  return cues;
}

export function validateLessonArtifacts(root, lesson, stage) {
  const errors = [];
  const id = lesson.id;
  for (const relativePath of requiredLessonFiles(lesson, stage)) {
    try {
      const resolved = safeCoursePath(root, relativePath);
      if (!fs.existsSync(resolved.absolute) || !fs.statSync(resolved.absolute).isFile()) {
        errors.push(issue("MISSING_ARTIFACT", `missing required artifact: ${relativePath}`, id));
      }
    } catch (error) {
      errors.push(issue("ARTIFACT_PATH", error.message, id));
    }
  }
  if (errors.length > 0) return errors;

  if (stageIndex(stage) >= stageIndex("script-draft")) {
    try {
      const lessonPath = safeCoursePath(root, `lessons/${id}/lesson.md`).absolute;
      extractPostLessonQuestion(fs.readFileSync(lessonPath, "utf8"));
    } catch (error) {
      errors.push(issue("POST_LESSON_QUESTION", error.message, id));
    }
  }

  if (stageIndex(stage) >= stageIndex("narration-final")) {
    const base = `lessons/${id}`;
    try {
      const transcript = readJson(safeCoursePath(root, `${base}/transcript.json`).absolute);
      const scriptPath = safeCoursePath(root, `${base}/narration.txt`).absolute;
      if (!Array.isArray(transcript) || transcript.length === 0) throw new Error("transcript must be a non-empty array");
      const ids = new Set();
      let previousEnd = 0;
      for (const word of transcript) {
        if (typeof word.id !== "string" || word.id.length === 0 || ids.has(word.id)) {
          throw new Error("word IDs must be non-empty and unique");
        }
        ids.add(word.id);
        if (typeof word.text !== "string" || word.text.trim() === "") {
          throw new Error(`word ${word.id} has no spoken text`);
        }
        if (!finiteNonNegative(word.start) || !finiteNonNegative(word.end)) {
          throw new Error(`word ${word.id} has an invalid time`);
        }
        if (word.end <= word.start || word.start < previousEnd - 0.001) {
          throw new Error(`word ${word.id} is overlapping or out of order`);
        }
        previousEnd = word.end;
      }
      const narration = fs.readFileSync(scriptPath, "utf8");
      const transcriptText = normalizeSpokenText(transcript.map((word) => word.text).join(" "));
      if (transcriptText !== normalizeSpokenText(narration)) {
        throw new Error("transcript spoken text does not match narration.txt");
      }

      if (stageIndex(stage) >= stageIndex("video-verified")) {
        const captionsPath = safeCoursePath(root, `${base}/captions.vtt`).absolute;
        const cues = parseWebVtt(fs.readFileSync(captionsPath, "utf8"));
        const captionText = normalizeSpokenText(cues.map((cue) => cue.text).join(" "));
        const narrationText = normalizeSpokenText(narration);
        if (captionText !== narrationText) throw new Error("WebVTT spoken text does not match narration.txt");
        const offset = cues[0].start - transcript[0].start;
        if (offset < -0.25) throw new Error("WebVTT begins before the aligned narration timeline");
        if (cues.at(-1).end > transcript.at(-1).end + offset + 0.75) {
          throw new Error("WebVTT extends beyond the aligned narration timeline");
        }
      }
    } catch (error) {
      errors.push(issue("TIMING_OR_CAPTIONS", error.message, id));
    }
  }
  return errors;
}

export async function checkFingerprintRecord(root, record, expectedFiles, lesson, config, stage) {
  const errors = [];
  if (!record || typeof record !== "object" || Array.isArray(record)) {
    return { fresh: false, errors: ["record is missing"] };
  }
  if (!record.fingerprints || typeof record.fingerprints !== "object" || Array.isArray(record.fingerprints)) {
    return { fresh: false, errors: ["fingerprints are missing"] };
  }
  if (lesson && record.lessonContractSha256 !== lessonContractSha256(lesson)) {
    errors.push("lesson identity, type, prerequisites, or source paths changed");
  }
  const expectedProductionContract = config && stage
    ? productionContractSha256(config, stage)
    : undefined;
  const hasExplicitProductionConfig = stage === "video-verified"
    ? config?.video !== undefined
    : stage === "cover-verified"
      ? config?.video !== undefined || config?.cover !== undefined
      : false;
  if (expectedProductionContract &&
      (record.productionContractSha256 !== undefined || hasExplicitProductionConfig) &&
      record.productionContractSha256 !== expectedProductionContract) {
    errors.push("video or cover production contract changed");
  }
  for (const relativePath of expectedFiles) {
    if (typeof record.fingerprints[relativePath] !== "string") {
      errors.push(`fingerprint missing for ${relativePath}`);
    }
  }
  for (const [relativePath, expectedHash] of Object.entries(record.fingerprints)) {
    try {
      const resolved = safeCoursePath(root, relativePath);
      if (!fs.existsSync(resolved.absolute) || !fs.statSync(resolved.absolute).isFile()) {
        errors.push(`recorded file is missing: ${relativePath}`);
        continue;
      }
      const actualHash = await hashFile(resolved.absolute);
      if (actualHash !== expectedHash) errors.push(`fingerprint changed: ${relativePath}`);
    } catch (error) {
      errors.push(error.message);
    }
  }
  return { fresh: errors.length === 0, errors };
}

function draftArtifactsExist(root, lesson) {
  const paths = [
    ...requiredLessonFiles(lesson, "script-draft"),
    `lessons/${lesson.id}/storyboard.md`,
  ];
  return paths.every((relativePath) => {
    try {
      const resolved = safeCoursePath(root, relativePath);
      return fs.existsSync(resolved.absolute) && fs.statSync(resolved.absolute).isFile();
    } catch {
      return false;
    }
  });
}

function validateReleaseReferences(root, releaseDirectory) {
  const errors = [];
  let directory;
  try {
    directory = safeCoursePath(root, releaseDirectory);
  } catch (error) {
    return [issue("RELEASE_PATH", error.message)];
  }
  const indexPath = path.join(directory.absolute, "index.html");
  if (!fs.existsSync(indexPath)) return [issue("RELEASE_INDEX", "packaged release lacks index.html")];
  const html = fs.readFileSync(indexPath, "utf8");
  const tagPattern = /<(?:video|audio|source|track|img|script|link)\b[^>]*?\b(?:src|href)\s*=\s*["']([^"']+)["'][^>]*>/gi;
  for (const match of html.matchAll(tagPattern)) {
    const reference = match[1].trim();
    if (/^(?:https?:|file:|\/)/i.test(reference)) {
      errors.push(issue("NETWORK_MEDIA", `release contains non-local media reference: ${reference}`));
      continue;
    }
    if (/^(?:data:|#)/i.test(reference)) continue;
    const clean = reference.split(/[?#]/, 1)[0];
    const absolute = path.resolve(directory.absolute, clean);
    const prefix = directory.absolute.endsWith(path.sep) ? directory.absolute : `${directory.absolute}${path.sep}`;
    if (!absolute.startsWith(prefix) || !fs.existsSync(absolute)) {
      errors.push(issue("BROKEN_RELEASE_REFERENCE", `release reference is missing or escapes output: ${reference}`));
    }
  }
  return errors;
}

export async function validateCourse(rootInput, stateOverride) {
  const documents = loadCourseDocuments(rootInput, stateOverride);
  const { root, config, state } = documents;
  const errors = validateStateShape(config, state);
  try {
    const outline = safeCoursePath(root, config.outline);
    if (!fs.existsSync(outline.absolute) || !fs.statSync(outline.absolute).isFile()) {
      errors.push(issue("OUTLINE", `outline does not exist: ${config.outline}`));
    }
  } catch (error) {
    errors.push(issue("OUTLINE", error.message));
  }
  const graph = validateDependencyGraph(state);
  errors.push(...graph.errors);
  const lessons = [];

  for (const lesson of Array.isArray(state.lessons) ? state.lessons : []) {
    if (stageIndex(lesson.status) < 0 || !lesson.records || typeof lesson.records !== "object") continue;
    for (const sourcePath of Array.isArray(lesson.sourcePaths) ? lesson.sourcePaths : []) {
      try {
        safeCoursePath(root, sourcePath);
      } catch (error) {
        errors.push(issue("SOURCE_PATH", error.message, lesson.id));
      }
    }
    const declaredIndex = stageIndex(lesson.status);
    let effectiveStatus = "planned";
    let staleStage = null;
    const recordProblems = [];

    for (let index = 1; index <= declaredIndex; index += 1) {
      const stage = LESSON_STAGES[index];
      const record = lesson.records[stage];
      if (stage === "script-approved" &&
          (typeof record?.approvalSource !== "string" || record.approvalSource.trim() === "")) {
        staleStage = stage;
        recordProblems.push("script-approved: approvalSource is missing");
        break;
      }
      const checked = await checkFingerprintRecord(
        root,
        record,
        requiredLessonFiles(lesson, stage),
        lesson,
        config,
        stage,
      );
      if (!checked.fresh) {
        staleStage = stage;
        recordProblems.push(...checked.errors.map((message) => `${stage}: ${message}`));
        if (stage === "script-draft" && draftArtifactsExist(root, lesson)) effectiveStatus = "script-draft";
        break;
      }
      effectiveStatus = stage;
    }

    for (const recordStage of Object.keys(lesson.records)) {
      const index = stageIndex(recordStage);
      if (index < 1) errors.push(issue("UNKNOWN_RECORD", `unknown stage record: ${recordStage}`, lesson.id));
      else if (index > declaredIndex) errors.push(issue("FUTURE_RECORD", `record ${recordStage} is later than declared status`, lesson.id));
    }

    if (staleStage) {
      errors.push(issue("STALE_STAGE", `${staleStage} is stale: ${recordProblems.join("; ")}`, lesson.id));
    }
    errors.push(...validateLessonArtifacts(root, lesson, lesson.status));
    lessons.push({
      id: lesson.id,
      type: lesson.type,
      declaredStatus: lesson.status,
      effectiveStatus,
      staleStage,
      nextSkill: NEXT_SKILL[effectiveStatus],
    });
  }

  const lessonReportById = new Map(lessons.map((lesson) => [lesson.id, lesson]));
  const stateLessonById = new Map((state.lessons || []).map((lesson) => [lesson.id, lesson]));
  for (const lesson of lessons) {
    const stateLesson = stateLessonById.get(lesson.id);
    lesson.blockedBy = lesson.effectiveStatus === "planned"
      ? (stateLesson.requires || []).filter((dependency) => {
          const prerequisite = lessonReportById.get(dependency);
          return !prerequisite || stageIndex(prerequisite.effectiveStatus) < stageIndex("script-approved");
        })
      : [];
  }

  let nextWave = [];
  if (graph.errors.length === 0) {
    const position = new Map(graph.order.map((id, index) => [id, index]));
    const candidates = lessons
      .filter((lesson) => lesson.effectiveStatus !== "cover-verified" && lesson.blockedBy.length === 0)
      .sort((left, right) => {
        const typeOrder = Number(left.type === "extension") - Number(right.type === "extension");
        return typeOrder || stageIndex(left.effectiveStatus) - stageIndex(right.effectiveStatus) ||
          position.get(left.id) - position.get(right.id);
      });
    if (candidates.length) {
      const preferredType = candidates[0].type;
      const earliestStage = stageIndex(candidates[0].effectiveStatus);
      nextWave = candidates
        .filter((lesson) => lesson.type === preferredType && stageIndex(lesson.effectiveStatus) === earliestStage)
        .map((lesson) => ({ id: lesson.id, nextSkill: lesson.nextSkill }));
    }
  }

  if (state.release?.status === "packaged") {
    const invalidProduction = lessons.filter(
      (lesson) => lesson.type === "core" && lesson.effectiveStatus !== "cover-verified",
    );
    if (invalidProduction.length) {
      errors.push(
        issue(
          "STALE_RELEASE",
          `packaged release depends on non-current core lessons: ${invalidProduction.map((lesson) => lesson.id).join(", ")}`,
        ),
      );
    }
    if (typeof state.release.directory !== "string" || typeof state.release.archive !== "string" || !state.release.fingerprints) {
      errors.push(issue("RELEASE_RECORD", "packaged release requires directory, archive, and fingerprints"));
    } else {
      try {
        const current = {
          ...(await fingerprintDirectory(root, state.release.directory)),
          ...(await fingerprintFiles(root, [state.release.archive])),
        };
        const recordedKeys = Object.keys(state.release.fingerprints).sort();
        const currentKeys = Object.keys(current).sort();
        const changes = [];
        if (JSON.stringify(recordedKeys) !== JSON.stringify(currentKeys)) {
          changes.push("release file set changed");
        }
        for (const relativePath of recordedKeys) {
          if (current[relativePath] !== state.release.fingerprints[relativePath]) {
            changes.push(`fingerprint changed: ${relativePath}`);
          }
        }
        if (changes.length) errors.push(issue("STALE_RELEASE", `packaged release is stale: ${changes.join("; ")}`));

        const releaseDirectory = safeCoursePath(root, state.release.directory);
        const indexHtml = fs.readFileSync(path.join(releaseDirectory.absolute, "index.html"), "utf8");
        const visibleReleaseText = releaseVisibleText(indexHtml);
        for (const lesson of lessons.filter(
          (item) => item.type === "core" && item.effectiveStatus === "cover-verified",
        )) {
          for (const filename of ["video.mp4", "captions.vtt", "cover.png"]) {
            const sourcePath = `lessons/${lesson.id}/${filename}`;
            const sourceHash = await hashFile(safeCoursePath(root, sourcePath).absolute);
            const packagedPaths = Object.entries(current)
              .filter(([, value]) => value === sourceHash)
              .map(([relativePath]) => path.posix.relative(releaseDirectory.relative, relativePath));
            if (packagedPaths.length === 0) {
              errors.push(issue("RELEASE_COVERAGE", `release does not contain current ${sourcePath}`, lesson.id));
            } else if (!packagedPaths.some((relativePath) => indexHtml.includes(relativePath))) {
              errors.push(issue("RELEASE_COVERAGE", `index.html does not reference current ${sourcePath}`, lesson.id));
            }
          }
          const marker = new RegExp(
            `\\bdata-post-lesson-question\\s*=\\s*(["'])${escapeRegularExpression(lesson.id)}\\1`,
            "i",
          );
          const lessonCard = fs.readFileSync(
            safeCoursePath(root, `lessons/${lesson.id}/lesson.md`).absolute,
            "utf8",
          );
          const question = extractPostLessonQuestion(lessonCard);
          if (!marker.test(indexHtml) || !visibleReleaseText.includes(normalizeSpokenText(question))) {
            errors.push(
              issue(
                "RELEASE_COVERAGE",
                "index.html does not expose the current static post-lesson question",
                lesson.id,
              ),
            );
          }
        }

        const courseCoverPath = "course-cover.png";
        const courseCoverHash = await hashFile(safeCoursePath(root, courseCoverPath).absolute);
        const packagedCourseCovers = Object.entries(current)
          .filter(([, value]) => value === courseCoverHash)
          .map(([relativePath]) => path.posix.relative(releaseDirectory.relative, relativePath));
        if (packagedCourseCovers.length === 0) {
          errors.push(issue("RELEASE_COVERAGE", `release does not contain current ${courseCoverPath}`));
        } else if (!packagedCourseCovers.some((relativePath) => indexHtml.includes(relativePath))) {
          errors.push(issue("RELEASE_COVERAGE", `index.html does not reference current ${courseCoverPath}`));
        }
      } catch (error) {
        errors.push(issue("STALE_RELEASE", `packaged release is stale: ${error.message}`));
      }
      errors.push(...validateReleaseReferences(root, state.release.directory));
    }
  }

  return {
    courseRoot: root,
    courseId: config.courseId,
    valid: errors.length === 0,
    releaseStatus: state.release?.status,
    topologicalOrder: graph.order,
    nextWave,
    lessons,
    errors,
  };
}

export function formatValidationReport(report) {
  const lines = [`Course validation: ${report.valid ? "PASS" : "FAIL"}`, `Course: ${report.courseId}`];
  for (const lesson of report.lessons) {
    const stale = lesson.staleStage ? ` stale=${lesson.staleStage}` : "";
    const blocked = lesson.blockedBy?.length ? ` blockedBy=${lesson.blockedBy.join(",")}` : "";
    lines.push(
      `${lesson.id}: declared=${lesson.declaredStatus} effective=${lesson.effectiveStatus}${stale}${blocked} next=${lesson.nextSkill}`,
    );
  }
  if (report.nextWave?.length) {
    lines.push(`Next wave: ${report.nextWave.map((item) => `${item.id}:${item.nextSkill}`).join(", ")}`);
  }
  if (report.errors.length) {
    lines.push("Errors:");
    for (const error of report.errors) {
      lines.push(`- ${error.code}${error.lessonId ? ` [${error.lessonId}]` : ""}: ${error.message}`);
    }
  }
  return `${lines.join("\n")}\n`;
}

export function writeJsonAtomic(filePath, value) {
  const temporary = `${filePath}.tmp-${process.pid}`;
  fs.writeFileSync(temporary, `${JSON.stringify(value, null, 2)}\n`, { encoding: "utf8", mode: 0o644 });
  fs.renameSync(temporary, filePath);
}

export { validateReleaseReferences };
