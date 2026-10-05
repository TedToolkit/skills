#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";

const ID_PATTERN = /^[A-Za-z0-9][A-Za-z0-9._-]*$/;
const TIERS = new Set(["graduation", "extension"]);

function issue(code, message, details = {}) {
  return { code, message, ...details };
}

function safeSeriesPath(root, value, field) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(`${field} must be a non-empty string`);
  }
  if (path.isAbsolute(value) || value.includes("\\")) {
    throw new Error(`${field} must be relative and use forward slashes: ${value}`);
  }
  const normalized = path.posix.normalize(value);
  if (normalized === ".." || normalized.startsWith("../") || normalized.startsWith("/")) {
    throw new Error(`${field} escapes the series root: ${value}`);
  }
  const absolute = path.resolve(root, normalized);
  const prefix = root.endsWith(path.sep) ? root : `${root}${path.sep}`;
  if (absolute !== root && !absolute.startsWith(prefix)) {
    throw new Error(`${field} escapes the series root: ${value}`);
  }

  const realRoot = fs.realpathSync(root);
  let existingAncestor = absolute;
  while (!fs.existsSync(existingAncestor)) {
    const parent = path.dirname(existingAncestor);
    if (parent === existingAncestor) {
      throw new Error(`${field} has no existing ancestor: ${value}`);
    }
    existingAncestor = parent;
  }
  const realAncestor = fs.realpathSync(existingAncestor);
  const realDestination = path.resolve(realAncestor, path.relative(existingAncestor, absolute));
  const realPrefix = realRoot.endsWith(path.sep) ? realRoot : `${realRoot}${path.sep}`;
  if (realDestination !== realRoot && !realDestination.startsWith(realPrefix)) {
    throw new Error(`${field} escapes the series root through a symbolic link: ${value}`);
  }
  return { relative: normalized, absolute };
}

function validateId(errors, value, field, details = {}) {
  if (typeof value !== "string" || !ID_PATTERN.test(value)) {
    errors.push(issue("INVALID_ID", `${field} is invalid: ${String(value)}`, details));
    return false;
  }
  return true;
}

function validateString(errors, value, field, details = {}) {
  if (typeof value !== "string" || value.trim() === "") {
    errors.push(issue("REQUIRED_FIELD", `${field} must be a non-empty string`, details));
    return false;
  }
  return true;
}

function validateStringArray(errors, value, field, details = {}, { nonEmpty = false } = {}) {
  if (!Array.isArray(value) || value.some((item) => typeof item !== "string")) {
    errors.push(issue("INVALID_ARRAY", `${field} must be an array of strings`, details));
    return false;
  }
  if (nonEmpty && value.length === 0) {
    errors.push(issue("EMPTY_ARRAY", `${field} must not be empty`, details));
    return false;
  }
  if (new Set(value).size !== value.length) {
    errors.push(issue("DUPLICATE_REFERENCE", `${field} contains duplicate values`, details));
  }
  return true;
}

function dependencyIds(course) {
  if (!Array.isArray(course?.requires)) return [];
  return course.requires
    .map((dependency) => dependency?.courseId)
    .filter((courseId) => typeof courseId === "string");
}

function validateDependencies(errors, course) {
  const courseId = course?.id;
  if (!Array.isArray(course?.requires)) {
    errors.push(issue("COURSE_REQUIRES", "course.requires must be an array", { courseId }));
    return;
  }
  const seen = new Set();
  for (const dependency of course.requires) {
    if (!dependency || typeof dependency !== "object" || Array.isArray(dependency)) {
      errors.push(issue("COURSE_REQUIRES", "each course prerequisite must be an object", { courseId }));
      continue;
    }
    const prerequisiteId = dependency.courseId;
    validateId(errors, prerequisiteId, "course.requires.courseId", { courseId });
    validateString(errors, dependency.capability, "course.requires.capability", { courseId, prerequisiteId });
    if (seen.has(prerequisiteId)) {
      errors.push(issue("DUPLICATE_PREREQUISITE", `duplicate prerequisite course: ${prerequisiteId}`, { courseId }));
    }
    seen.add(prerequisiteId);
  }
}

function findCycle(coursesById) {
  const visiting = new Set();
  const visited = new Set();
  const stack = [];

  function visit(id) {
    if (visiting.has(id)) {
      const start = stack.indexOf(id);
      return [...stack.slice(start), id];
    }
    if (visited.has(id)) return null;
    visiting.add(id);
    stack.push(id);
    const course = coursesById.get(id);
    for (const dependency of dependencyIds(course)) {
      if (!coursesById.has(dependency)) continue;
      const cycle = visit(dependency);
      if (cycle) return cycle;
    }
    stack.pop();
    visiting.delete(id);
    visited.add(id);
    return null;
  }

  for (const id of coursesById.keys()) {
    const cycle = visit(id);
    if (cycle) return cycle;
  }
  return null;
}

function topologicalWaves(coursesById) {
  const remaining = new Map();
  for (const [id, course] of coursesById) {
    remaining.set(id, new Set(dependencyIds(course).filter((dependency) => coursesById.has(dependency))));
  }
  const completed = new Set();
  const waves = [];
  while (completed.size < coursesById.size) {
    const wave = [...remaining.entries()]
      .filter(([id, dependencies]) => !completed.has(id) && [...dependencies].every((dependency) => completed.has(dependency)))
      .map(([id]) => id)
      .sort();
    if (wave.length === 0) return [];
    waves.push(wave);
    for (const id of wave) completed.add(id);
  }
  return waves;
}

function validateSeries(root, document) {
  const errors = [];
  if (document?.formatVersion !== 1) {
    errors.push(issue("FORMAT_VERSION", "course-series.json formatVersion must be 1"));
  }
  validateId(errors, document?.seriesId, "seriesId");
  validateString(errors, document?.title, "title");
  validateString(errors, document?.contentLanguage, "contentLanguage");

  if (validateString(errors, document?.charter, "charter")) {
    try {
      const charter = safeSeriesPath(root, document.charter, "charter");
      if (!fs.existsSync(charter.absolute) || !fs.statSync(charter.absolute).isFile()) {
        errors.push(issue("MISSING_CHARTER", `charter is not a file: ${charter.relative}`));
      }
    } catch (error) {
      errors.push(issue("UNSAFE_PATH", error.message));
    }
  }

  const outcomes = Array.isArray(document?.outcomes) ? document.outcomes : [];
  if (!Array.isArray(document?.outcomes) || outcomes.length === 0) {
    errors.push(issue("OUTCOMES", "outcomes must be a non-empty array"));
  }
  const outcomesById = new Map();
  for (const outcome of outcomes) {
    const outcomeId = outcome?.id;
    const validId = validateId(errors, outcomeId, "outcome.id", { outcomeId });
    if (validId && outcomesById.has(outcomeId)) {
      errors.push(issue("DUPLICATE_OUTCOME", `duplicate outcome id: ${outcomeId}`, { outcomeId }));
    } else if (validId) {
      outcomesById.set(outcomeId, outcome);
    }
    if (!TIERS.has(outcome?.tier)) {
      errors.push(issue("OUTCOME_TIER", "outcome tier must be graduation or extension", { outcomeId }));
    }
    validateString(errors, outcome?.description, "outcome.description", { outcomeId });
  }

  const courses = Array.isArray(document?.courses) ? document.courses : [];
  if (!Array.isArray(document?.courses) || courses.length === 0) {
    errors.push(issue("COURSES", "courses must be a non-empty array"));
  }
  const coursesById = new Map();
  const paths = new Map();
  const briefs = new Map();
  for (const course of courses) {
    const courseId = course?.id;
    const validId = validateId(errors, courseId, "course.id", { courseId });
    if (validId && coursesById.has(courseId)) {
      errors.push(issue("DUPLICATE_COURSE", `duplicate course id: ${courseId}`, { courseId }));
    } else if (validId) {
      coursesById.set(courseId, course);
    }
    validateString(errors, course?.title, "course.title", { courseId });
    if (!TIERS.has(course?.tier)) {
      errors.push(issue("COURSE_TIER", "course tier must be graduation or extension", { courseId }));
    }
    validateDependencies(errors, course);
    validateStringArray(errors, course?.outcomes, "course.outcomes", { courseId }, { nonEmpty: true });

    for (const [field, seen] of [["path", paths], ["brief", briefs]]) {
      if (!validateString(errors, course?.[field], `course.${field}`, { courseId })) continue;
      try {
        const resolved = safeSeriesPath(root, course[field], `course.${field}`);
        if (field === "path" && resolved.relative === ".") {
          errors.push(issue("COURSE_PATH_ROOT", "a course path cannot be the series root", { courseId }));
        }
        if (seen.has(resolved.relative)) {
          errors.push(issue(`DUPLICATE_${field.toUpperCase()}`, `${field} is shared by ${seen.get(resolved.relative)} and ${courseId}: ${resolved.relative}`, { courseId }));
        } else {
          seen.set(resolved.relative, courseId);
        }
        if (field === "brief") {
          if (!fs.existsSync(resolved.absolute) || !fs.statSync(resolved.absolute).isFile()) {
            errors.push(issue("MISSING_BRIEF", `course brief is not a file: ${resolved.relative}`, { courseId }));
          }
        } else if (fs.existsSync(resolved.absolute)) {
          if (!fs.statSync(resolved.absolute).isDirectory()) {
            errors.push(issue("COURSE_PATH", `course path is not a directory: ${resolved.relative}`, { courseId }));
          } else {
            const configPath = path.join(resolved.absolute, "course.config.json");
            const statePath = path.join(resolved.absolute, "course-state.json");
            if (fs.existsSync(statePath) && !fs.existsSync(configPath)) {
              errors.push(issue("COURSE_CONFIG_MISSING", `course-state.json exists without course.config.json: ${resolved.relative}`, { courseId }));
            }
            if (fs.existsSync(configPath)) {
              try {
                const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
                if (config.courseId !== courseId) {
                  errors.push(issue("COURSE_ID_MISMATCH", `course.config.json courseId must match ${courseId}: ${resolved.relative}`, { courseId }));
                }
              } catch (error) {
                errors.push(issue("COURSE_CONFIG_JSON", `cannot read ${resolved.relative}/course.config.json: ${error.message}`, { courseId }));
              }
            }
          }
        }
      } catch (error) {
        errors.push(issue("UNSAFE_PATH", error.message, { courseId }));
      }
    }
  }

  const coursePaths = [...paths.keys()];
  for (let index = 0; index < coursePaths.length; index += 1) {
    for (let other = index + 1; other < coursePaths.length; other += 1) {
      const left = coursePaths[index];
      const right = coursePaths[other];
      if (left.startsWith(`${right}/`) || right.startsWith(`${left}/`)) {
        errors.push(issue("NESTED_COURSE_PATH", `course roots must not be nested: ${left} and ${right}`));
      }
    }
  }
  for (const brief of briefs.keys()) {
    for (const coursePath of coursePaths) {
      if (brief === coursePath || brief.startsWith(`${coursePath}/`)) {
        errors.push(issue("BRIEF_INSIDE_COURSE", `series brief must stay outside course roots: ${brief}`));
      }
    }
  }

  const outcomeOwners = new Map([...outcomesById.keys()].map((id) => [id, []]));
  for (const course of courses) {
    const courseId = course?.id;
    for (const dependency of dependencyIds(course)) {
      if (!coursesById.has(dependency)) {
        errors.push(issue("UNKNOWN_COURSE", `unknown prerequisite course: ${dependency}`, { courseId }));
      } else if (dependency === courseId) {
        errors.push(issue("SELF_DEPENDENCY", "a course cannot require itself", { courseId }));
      } else if (course.tier === "graduation" && coursesById.get(dependency)?.tier === "extension") {
        errors.push(issue("GRADUATION_DEPENDS_ON_EXTENSION", `graduation course ${courseId} requires extension course ${dependency}`, { courseId }));
      }
    }
    for (const outcomeId of Array.isArray(course?.outcomes) ? course.outcomes : []) {
      if (!outcomesById.has(outcomeId)) {
        errors.push(issue("UNKNOWN_OUTCOME", `unknown outcome: ${outcomeId}`, { courseId, outcomeId }));
      } else {
        outcomeOwners.get(outcomeId).push(course);
      }
    }
  }
  for (const [outcomeId, outcome] of outcomesById) {
    const owners = outcomeOwners.get(outcomeId);
    if (owners.length === 0) {
      errors.push(issue("UNCOVERED_OUTCOME", `outcome has no owning course: ${outcomeId}`, { outcomeId }));
    } else if (outcome.tier === "graduation" && !owners.some((course) => course.tier === "graduation")) {
      errors.push(issue("GRADUATION_OUTCOME_ONLY_IN_EXTENSION", `graduation outcome ${outcomeId} is covered only by extension courses`, { outcomeId }));
    }
  }

  const cycle = findCycle(coursesById);
  if (cycle) {
    errors.push(issue("COURSE_DEPENDENCY_CYCLE", `course dependency cycle: ${cycle.join(" -> ")}`));
  }

  const cases = document?.cases === undefined ? [] : document.cases;
  if (!Array.isArray(cases)) {
    errors.push(issue("CASES", "cases must be an array when provided"));
  } else {
    const caseIds = new Set();
    for (const item of cases) {
      const caseId = item?.id;
      if (validateId(errors, caseId, "case.id", { caseId })) {
        if (caseIds.has(caseId)) errors.push(issue("DUPLICATE_CASE", `duplicate case id: ${caseId}`, { caseId }));
        caseIds.add(caseId);
      }
      validateString(errors, item?.title, "case.title", { caseId });
      validateString(errors, item?.purpose, "case.purpose", { caseId });
      if (validateStringArray(errors, item?.courses, "case.courses", { caseId }, { nonEmpty: true })) {
        for (const courseId of item.courses) {
          if (!coursesById.has(courseId)) errors.push(issue("UNKNOWN_COURSE", `case references unknown course: ${courseId}`, { caseId, courseId }));
        }
      }
    }
  }

  const waves = Array.isArray(document?.releaseWaves) ? document.releaseWaves : [];
  if (!Array.isArray(document?.releaseWaves) || waves.length === 0) {
    errors.push(issue("RELEASE_WAVES", "releaseWaves must be a non-empty array"));
  }
  const waveIds = new Set();
  const waveByCourse = new Map();
  waves.forEach((wave, waveIndex) => {
    const waveId = wave?.id;
    if (validateId(errors, waveId, "releaseWave.id", { waveId })) {
      if (waveIds.has(waveId)) errors.push(issue("DUPLICATE_WAVE", `duplicate release wave id: ${waveId}`, { waveId }));
      waveIds.add(waveId);
    }
    if (validateStringArray(errors, wave?.courses, "releaseWave.courses", { waveId }, { nonEmpty: true })) {
      for (const courseId of wave.courses) {
        if (!coursesById.has(courseId)) {
          errors.push(issue("UNKNOWN_COURSE", `release wave references unknown course: ${courseId}`, { waveId, courseId }));
        } else if (waveByCourse.has(courseId)) {
          errors.push(issue("DUPLICATE_RELEASE_PLACEMENT", `course ${courseId} appears in more than one release wave`, { courseId }));
        } else {
          waveByCourse.set(courseId, waveIndex);
        }
      }
    }
  });
  for (const [courseId, course] of coursesById) {
    if (!waveByCourse.has(courseId)) {
      errors.push(issue("COURSE_MISSING_RELEASE_WAVE", `course is absent from release waves: ${courseId}`, { courseId }));
      continue;
    }
    for (const dependency of dependencyIds(course)) {
      if (waveByCourse.has(dependency) && waveByCourse.get(dependency) > waveByCourse.get(courseId)) {
        errors.push(issue("RELEASE_BEFORE_PREREQUISITE", `course ${courseId} is scheduled before prerequisite ${dependency}`, { courseId }));
      }
    }
  }

  return {
    valid: errors.length === 0,
    seriesId: document?.seriesId ?? null,
    courseCount: courses.length,
    outcomeCount: outcomes.length,
    graduationCourses: courses.filter((course) => course?.tier === "graduation").map((course) => course.id),
    extensionCourses: courses.filter((course) => course?.tier === "extension").map((course) => course.id),
    learningWaves: cycle ? [] : topologicalWaves(coursesById),
    errors,
  };
}

const args = process.argv.slice(2);
const json = args.includes("--json");
const positional = args.filter((arg) => arg !== "--json");
const root = path.resolve(positional[0] || ".");
let report;
try {
  const documentPath = path.join(root, "course-series.json");
  if (!fs.existsSync(documentPath)) throw new Error(`missing ${documentPath}`);
  const document = JSON.parse(fs.readFileSync(documentPath, "utf8"));
  report = validateSeries(root, document);
} catch (error) {
  report = {
    valid: false,
    seriesId: null,
    courseCount: 0,
    outcomeCount: 0,
    graduationCourses: [],
    extensionCourses: [],
    learningWaves: [],
    errors: [issue("LOAD_ERROR", error.message)],
  };
}

if (json) {
  process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
} else if (report.valid) {
  process.stdout.write(`VALID ${report.seriesId}: ${report.courseCount} courses, ${report.outcomeCount} outcomes\n`);
  report.learningWaves.forEach((wave, index) => process.stdout.write(`LEARNING_WAVE ${index + 1}: ${wave.join(", ")}\n`));
} else {
  for (const error of report.errors) {
    const scope = error.courseId ? ` [${error.courseId}]` : error.outcomeId ? ` [${error.outcomeId}]` : "";
    process.stderr.write(`${error.code}${scope}: ${error.message}\n`);
  }
}

process.exitCode = report.valid ? 0 : 1;
