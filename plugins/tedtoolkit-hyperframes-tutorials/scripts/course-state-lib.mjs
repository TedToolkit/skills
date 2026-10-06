import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

export const LESSON_STAGES = [
  "planned",
  "outline-draft",
  "outline-approved",
  "script-draft",
  "script-approved",
  "narration-final",
  "storyboard-final",
  "video-verified",
  "cover-verified",
];

export const NEXT_SKILL = {
  planned: "outline-tutorial-lesson",
  "outline-draft": "outline-tutorial-lesson",
  "outline-approved": "design-tutorial",
  "script-draft": "review-tutorial-script",
  "script-approved": "generate-tutorial-narration",
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

function isLegacyScriptLesson(lesson) {
  return Boolean(lesson.records?.["script-draft"] &&
    !lesson.records?.["outline-draft"] && !lesson.records?.["outline-approved"]);
}

export function lessonContractSha256(lesson, stage) {
  const outlineStage = stage === "outline-draft" || stage === "outline-approved";
  const contract = JSON.stringify({
    id: lesson.id,
    type: lesson.type,
    requires: lesson.requires,
    ...(!outlineStage ? { sourcePaths: lesson.sourcePaths } : {}),
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

export function videoStyleIssues(root) {
  const relativePath = "video-style.md";
  const stylePath = safeCoursePath(root, relativePath).absolute;
  if (!fs.existsSync(stylePath) || !fs.statSync(stylePath).isFile()) {
    return [`course video style is missing or empty: ${relativePath}`];
  }
  const content = fs.readFileSync(stylePath, "utf8");
  if (content.trim() === "") return [`course video style is missing or empty: ${relativePath}`];
  const problems = [];
  for (const match of content.matchAll(/!?\[[^\]]*\]\(([^)]+)\)/g)) {
    const raw = match[1].trim();
    const target = raw.startsWith("<") ? raw.slice(1, raw.indexOf(">")) : raw.split(/\s+/)[0];
    if (!target || target.startsWith("#") || /^([a-z][a-z0-9+.-]*:|\/\/)/i.test(target)) continue;
    try {
      const localPath = decodeURIComponent(target.split(/[?#]/)[0]);
      const resolved = safeCoursePath(root, localPath);
      if (!fs.existsSync(resolved.absolute) || !fs.statSync(resolved.absolute).isFile()) {
        problems.push(`course video style reference is missing: ${resolved.relative}`);
      }
    } catch (error) {
      problems.push(`course video style reference is invalid: ${error.message}`);
    }
  }
  return problems;
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
  if (index < stageIndex("outline-draft")) return [];
  const base = `lessons/${lesson.id}`;
  const files = index >= stageIndex("script-draft") && isLegacyScriptLesson(lesson)
    ? [] : [`${base}/lesson-outline.md`];
  if (index >= stageIndex("script-draft")) {
    files.push(`${base}/lesson.md`, `${base}/narration.txt`, ...(lesson.sourcePaths || []));
  }
  if (index >= stageIndex("narration-final")) {
    files.push(`${base}/narration.wav`);
  }
  if (index >= stageIndex("storyboard-final")) {
    files.push(`${base}/storyboard.md`);
  }
  if (index >= stageIndex("video-verified")) {
    files.push(`${base}/video.mp4`, `${base}/captions.txt`);
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
  if (config.learnerDocuments !== undefined &&
      (!Array.isArray(config.learnerDocuments) ||
       config.learnerDocuments.some((item) => typeof item !== "string" || item.trim() === "") ||
       new Set(config.learnerDocuments).size !== config.learnerDocuments.length)) {
    errors.push(issue("LEARNER_DOCUMENTS", "learnerDocuments must be an array of distinct course-relative paths"));
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

export function extractVisualDescriptions(markdown) {
  const normalized = markdown.replace(/^\uFEFF/, "").replace(/\r\n?/g, "\n");
  const matches = [...normalized.matchAll(/^##[ \t]+Visual descriptions[ \t]*$/gm)];
  if (matches.length > 1) {
    throw new Error("lesson.md must contain at most one ## Visual descriptions section");
  }
  if (matches.length === 0) return null;
  const remainder = normalized.slice(matches[0].index + matches[0][0].length);
  const nextSection = /^#{1,2}[ \t]+\S.*$/m.exec(remainder);
  const descriptions = remainder
    .slice(0, nextSection?.index ?? remainder.length)
    .replace(/<!--[\s\S]*?-->/g, "")
    .trim();
  if (!descriptions || normalizeSpokenText(descriptions) === "") {
    throw new Error("## Visual descriptions must contain learner-facing text");
  }
  return descriptions;
}

function releaseVisibleText(html) {
  return normalizeSpokenText(
    html
      .replace(/<!--[\s\S]*?-->/g, " ")
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

function markedSectionVisibleText(html, attribute, lessonId) {
  const markup = html
    .replace(/<!--[\s\S]*?-->/g, " ")
    .replace(/<(script|style|template)\b[^>]*>[\s\S]*?<\/\1>/gi, " ");
  const openings = /<([A-Za-z][\w:-]*)\b([^>]*)>/g;
  const marker = new RegExp(`(?:^|\\s)${escapeRegularExpression(attribute)}\\s*=\\s*(["'])${escapeRegularExpression(lessonId)}\\1`, "i");
  const matches = [...markup.matchAll(openings)].filter((match) => marker.test(match[2]));
  if (matches.length !== 1) return null;
  const opening = matches[0];
  if (/(?:^|\s)hidden(?:\s|=|$)|(?:^|\s)aria-hidden\s*=\s*["']?true\b|display\s*:\s*none/i.test(opening[2])) {
    return null;
  }
  const tag = opening[1];
  const boundary = new RegExp(`<\\/?${escapeRegularExpression(tag)}\\b[^>]*>`, "gi");
  const start = opening.index + opening[0].length;
  const remainder = markup.slice(start);
  let depth = 1;
  for (const match of remainder.matchAll(boundary)) {
    depth += match[0].startsWith("</") ? -1 : 1;
    if (depth === 0) {
      return releaseVisibleText(remainder.slice(0, match.index));
    }
  }
  return null;
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

export function parseCaptionText(contents) {
  const normalized = contents.replace(/^\uFEFF/, "").replace(/\r\n?/g, "\n");
  const blocks = normalized.trim().split(/\n{2,}/);
  const cues = [];
  const identifiers = new Set();
  for (const block of blocks) {
    const lines = block.split("\n").filter((line) => line.length > 0);
    if (lines.length === 0) continue;
    const identifier = lines[0].trim();
    if (!/^[A-Za-z][A-Za-z0-9_-]*$/.test(identifier) || identifiers.has(identifier)) {
      throw new Error(`caption cue needs a unique identifier: ${identifier}`);
    }
    identifiers.add(identifier);
    const timingIndex = lines.findIndex((line) => line.includes("-->"));
    if (timingIndex !== 1) throw new Error(`caption cue needs a timing line after ${identifier}`);
    const match = /^(\S+)\s+-->\s+(\S+)(?:\s+.*)?$/.exec(lines[timingIndex]);
    if (!match) throw new Error(`invalid caption timing line: ${lines[timingIndex]}`);
    const start = parseVttTimestamp(match[1]);
    const end = parseVttTimestamp(match[2]);
    if (!Number.isFinite(start) || !Number.isFinite(end) || end <= start) {
      throw new Error(`invalid caption cue range: ${lines[timingIndex]}`);
    }
    if (lines.length !== 3) throw new Error(`caption cue must have one text line: ${identifier}`);
    const text = lines[2].trim();
    if (!text) throw new Error(`caption cue has no text: ${lines[timingIndex]}`);
    cues.push({ start, end, text });
  }
  if (cues.length === 0) throw new Error("captions.txt contains no cues");
  for (let index = 1; index < cues.length; index += 1) {
    if (cues[index].start < cues[index - 1].end - 0.001) {
      throw new Error(`caption cues overlap or are out of order at cue ${index + 1}`);
    }
  }
  return cues;
}

export function parseStoryboardTiming(contents) {
  const normalized = contents.replace(/^\uFEFF/, "").replace(/\r\n?/g, "\n");
  const pattern = /((?:\d{2,}:)?\d{2}:\d{2}\.\d{3})\s+-->\s+((?:\d{2,}:)?\d{2}:\d{2}\.\d{3})/g;
  const shots = [];
  let hasBeatRows = false;
  for (const line of normalized.split("\n")) {
    const matches = [...line.matchAll(pattern)];
    if (matches.length === 0) continue;
    if (matches.length !== 1) throw new Error("storyboard timing line must contain exactly one audio range");
    const match = matches[0];
    const range = {
      start: parseVttTimestamp(match[1]),
      end: parseVttTimestamp(match[2]),
      source: match[0],
    };
    if (!Number.isFinite(range.start) || !Number.isFinite(range.end) || range.end <= range.start) {
      throw new Error(`invalid storyboard audio range: ${range.source}`);
    }
    if (/^\s*(?:\|\s*)?Beat\b/i.test(line)) {
      hasBeatRows = true;
      const shot = shots.at(-1);
      if (!shot) throw new Error("storyboard beat appears before its shot");
      if (range.start < shot.start - 0.001 || range.end > shot.end + 0.001) {
        throw new Error("storyboard beat must stay inside its shot audio range");
      }
      const previous = shot.beats.at(-1);
      if (Math.abs(range.start - (previous?.end ?? shot.start)) > 0.001) {
        throw new Error("storyboard beat ranges must be ordered and gapless within each shot");
      }
      shot.beats.push(range);
    } else {
      const previous = shots.at(-1);
      if (previous && range.start < previous.end - 0.001) {
        throw new Error(`storyboard audio ranges overlap or are out of order at range ${shots.length + 1}`);
      }
      shots.push({ ...range, beats: [] });
    }
  }
  if (shots.length === 0) {
    throw new Error("final storyboard.md contains no audio ranges; use HH:MM:SS.mmm --> HH:MM:SS.mmm");
  }
  if (hasBeatRows) {
    for (const shot of shots) {
      if (shot.beats.length === 0 || Math.abs(shot.beats.at(-1).end - shot.end) > 0.001) {
        throw new Error("storyboard beat ranges must cover every shot without gaps");
      }
    }
  }
  return shots;
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

  if (stageIndex(stage) >= stageIndex("outline-draft") && !isLegacyScriptLesson(lesson)) {
    const outlinePath = safeCoursePath(root, `lessons/${id}/lesson-outline.md`).absolute;
    if (fs.readFileSync(outlinePath, "utf8").trim() === "") {
      errors.push(issue("EMPTY_OUTLINE", "lesson-outline.md must contain a reviewable teaching arc", id));
    }
  }

  if (stageIndex(stage) >= stageIndex("script-draft")) {
    const lessonPath = safeCoursePath(root, `lessons/${id}/lesson.md`).absolute;
    const lessonCard = fs.readFileSync(lessonPath, "utf8");
    try {
      extractPostLessonQuestion(lessonCard);
    } catch (error) {
      errors.push(issue("POST_LESSON_QUESTION", error.message, id));
    }
    try {
      extractVisualDescriptions(lessonCard);
    } catch (error) {
      errors.push(issue("VISUAL_DESCRIPTIONS", error.message, id));
    }
  }

  if (stageIndex(stage) >= stageIndex("storyboard-final")) {
    const base = `lessons/${id}`;
    try {
      const storyboardPath = safeCoursePath(root, `${base}/storyboard.md`).absolute;
      const storyboardRanges = parseStoryboardTiming(fs.readFileSync(storyboardPath, "utf8"));

      if (stageIndex(stage) >= stageIndex("video-verified")) {
        const captionsPath = safeCoursePath(root, `${base}/captions.txt`).absolute;
        const cues = parseCaptionText(fs.readFileSync(captionsPath, "utf8"));
        // Subtitle copy is edited for reading; exact equality with the spoken script is not a gate.
        // Meaning and technical terms require audio review by the lesson producer.
        if (cues.some((cue) => /^\s*(?:#{1,6}\s|P\d{2}(?:-\d+)?\s|\|)/m.test(cue.text))) {
          throw new Error("caption text contains an authoring label or Markdown formatting");
        }
        if (cues[0].start < storyboardRanges[0].start - 0.25) {
          throw new Error("captions begin before the final storyboard timeline");
        }
        if (cues.at(-1).end > storyboardRanges.at(-1).end + 0.75) {
          throw new Error("captions extend beyond the final storyboard timeline");
        }
      }
    } catch (error) {
      errors.push(issue("STORYBOARD_TIMING_OR_CAPTIONS", error.message, id));
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
  if (record.videoStylePath !== undefined) {
    if (record.videoStylePath !== "video-style.md") {
      errors.push("video style reference must be video-style.md");
    } else {
      errors.push(...videoStyleIssues(root));
    }
  }
  if (lesson && record.lessonContractSha256 !== lessonContractSha256(lesson, stage)) {
    errors.push(stage === "outline-draft" || stage === "outline-approved"
      ? "lesson identity, type, or prerequisites changed"
      : "lesson identity, type, prerequisites, or source paths changed");
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

function outlineDraftExists(root, lesson) {
  try {
    const outline = safeCoursePath(root, `lessons/${lesson.id}/lesson-outline.md`).absolute;
    return fs.existsSync(outline) && fs.statSync(outline).isFile() &&
      fs.readFileSync(outline, "utf8").trim() !== "";
  } catch {
    return false;
  }
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
  for (const documentPath of Array.isArray(config.learnerDocuments) ? config.learnerDocuments : []) {
    try {
      const document = safeCoursePath(root, documentPath);
      if (!fs.existsSync(document.absolute) || !fs.statSync(document.absolute).isFile()) {
        errors.push(issue("LEARNER_DOCUMENTS", `learner document does not exist: ${documentPath}`));
      }
    } catch (error) {
      errors.push(issue("LEARNER_DOCUMENTS", error.message));
    }
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
      if (isLegacyScriptLesson(lesson) &&
          (stage === "outline-draft" || stage === "outline-approved")) continue;
      if ((stage === "outline-approved" || stage === "script-approved") &&
          (typeof record?.approvalSource !== "string" || record.approvalSource.trim() === "")) {
        staleStage = stage;
        recordProblems.push(`${stage}: approvalSource is missing`);
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
        if (stage === "outline-draft" && outlineDraftExists(root, lesson)) effectiveStatus = "outline-draft";
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
    lesson.blockedBy = lesson.effectiveStatus === "outline-approved"
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
        const learnerLinks = [...indexHtml.matchAll(/<a\b[^>]*?\bhref\s*=\s*["']([^"']+)["'][^>]*>/gi)]
          .map((match) => match[1].split(/[?#]/, 1)[0]);
        for (const lesson of lessons.filter((item) => item.effectiveStatus === "cover-verified")) {
          for (const filename of ["video.mp4", "captions.txt", "cover.png"]) {
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
          const lessonCard = fs.readFileSync(
            safeCoursePath(root, `lessons/${lesson.id}/lesson.md`).absolute,
            "utf8",
          );
          const question = extractPostLessonQuestion(lessonCard);
          const questionText = markedSectionVisibleText(indexHtml, "data-post-lesson-question", lesson.id);
          if (!questionText?.includes(normalizeSpokenText(question))) {
            errors.push(
              issue(
                "RELEASE_COVERAGE",
                "index.html does not expose the current static post-lesson question",
                lesson.id,
              ),
            );
          }
          const descriptions = extractVisualDescriptions(lessonCard);
          if (descriptions !== null) {
            const descriptionText = markedSectionVisibleText(indexHtml, "data-visual-descriptions", lesson.id);
            if (!descriptionText?.includes(normalizeSpokenText(descriptions))) {
              errors.push(
                issue(
                  "RELEASE_COVERAGE",
                  "index.html does not expose the current visual descriptions",
                  lesson.id,
                ),
              );
            }
          }
        }

        for (const documentPath of Array.isArray(config.learnerDocuments) ? config.learnerDocuments : []) {
          const sourceHash = await hashFile(safeCoursePath(root, documentPath).absolute);
          const packagedPaths = Object.entries(current)
            .filter(([, value]) => value === sourceHash)
            .map(([relativePath]) => path.posix.relative(releaseDirectory.relative, relativePath));
          if (packagedPaths.length === 0) {
            errors.push(issue("RELEASE_COVERAGE", `release does not contain current learner document ${documentPath}`));
          } else if (!packagedPaths.some((relativePath) => learnerLinks.includes(relativePath))) {
            errors.push(issue("RELEASE_COVERAGE", `index.html does not reference current learner document ${documentPath}`));
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
