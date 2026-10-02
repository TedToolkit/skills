#!/usr/bin/env node

import {
  fingerprintDirectory,
  fingerprintFiles,
  loadCourseDocuments,
  validateCourse,
  validateReleaseReferences,
  writeJsonAtomic,
} from "./course-state-lib.mjs";

function usage() {
  console.error("usage: record-course-release.mjs <course-root> <release-directory> <zip-path>");
  process.exit(2);
}

const args = process.argv.slice(2);
if (args.length !== 3) usage();

try {
  const documents = loadCourseDocuments(args[0]);
  const stateWithoutRelease = structuredClone(documents.state);
  stateWithoutRelease.release = { status: "not-packaged" };
  const production = await validateCourse(documents.root, stateWithoutRelease);
  if (!production.valid) {
    throw new Error(`course production state is not valid: ${production.errors.map((item) => item.message).join("; ")}`);
  }
  const incompleteCore = production.lessons.filter(
    (lesson) => lesson.type === "core" && lesson.effectiveStatus !== "video-verified",
  );
  if (incompleteCore.length) {
    throw new Error(`core lessons are not video-verified: ${incompleteCore.map((lesson) => lesson.id).join(", ")}`);
  }
  const referenceErrors = validateReleaseReferences(documents.root, args[1]);
  if (referenceErrors.length) throw new Error(referenceErrors.map((item) => item.message).join("; "));
  const fingerprints = {
    ...(await fingerprintDirectory(documents.root, args[1])),
    ...(await fingerprintFiles(documents.root, [args[2]])),
  };
  const candidate = structuredClone(stateWithoutRelease);
  candidate.release = {
    status: "packaged",
    directory: args[1],
    archive: args[2],
    recordedAt: new Date().toISOString(),
    fingerprints,
  };
  const verified = await validateCourse(documents.root, candidate);
  if (!verified.valid) {
    throw new Error(`release record failed validation: ${verified.errors.map((item) => item.message).join("; ")}`);
  }
  writeJsonAtomic(documents.statePath, candidate);
  console.log(`Recorded packaged release at ${args[1]}.`);
} catch (error) {
  console.error(`record-course-release: ${error.message}`);
  process.exitCode = 1;
}
