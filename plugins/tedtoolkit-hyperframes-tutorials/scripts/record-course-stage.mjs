#!/usr/bin/env node

import fs from "node:fs";

import {
  LESSON_STAGES,
  checkFingerprintRecord,
  fingerprintFiles,
  lessonContractSha256,
  loadCourseDocuments,
  productionContractSha256,
  requiredLessonFiles,
  safeCoursePath,
  stageIndex,
  validateDependencyGraph,
  validateLessonArtifacts,
  validateStateShape,
  videoStyleIssues,
  writeJsonAtomic,
} from "./course-state-lib.mjs";

function usage() {
  console.error(
    "usage: record-course-stage.mjs <course-root> <lesson-id> <stage> [--approval-source <text>]",
  );
  process.exit(2);
}

const args = process.argv.slice(2);
if (args.length < 3) usage();
const [rootInput, lessonId, targetStage] = args;
let approvalSource;
for (let index = 3; index < args.length; index += 1) {
  if (args[index] !== "--approval-source" || index + 1 >= args.length || approvalSource !== undefined) usage();
  approvalSource = args[index + 1];
  index += 1;
}
if (stageIndex(targetStage) < 1) usage();

try {
  const documents = loadCourseDocuments(rootInput);
  const { root, config, state, statePath } = documents;
  const structural = [
    ...validateStateShape(config, state),
    ...validateDependencyGraph(state).errors,
  ];
  if (structural.length) throw new Error(structural.map((item) => item.message).join("; "));
  const lesson = state.lessons.find((item) => item.id === lessonId);
  if (!lesson) throw new Error(`unknown lesson: ${lessonId}`);

  const targetIndex = stageIndex(targetStage);
  const currentIndex = stageIndex(lesson.status);
  if (targetIndex > currentIndex + 1) {
    throw new Error(`cannot skip from ${lesson.status} to ${targetStage}`);
  }
  const legacyScriptRevision = targetStage === "script-draft" &&
    currentIndex >= stageIndex("script-draft") &&
    lesson.records["script-draft"] && !lesson.records["outline-approved"] &&
    !lesson.records["outline-draft"];
  if (targetIndex > 1 && !legacyScriptRevision) {
    const previousStage = LESSON_STAGES[targetIndex - 1];
    const checked = await checkFingerprintRecord(
      root,
      lesson.records[previousStage],
      requiredLessonFiles(lesson, previousStage),
      lesson,
      config,
      previousStage,
    );
    if (!checked.fresh) {
      throw new Error(`cannot record ${targetStage}; ${previousStage} is not fresh: ${checked.errors.join("; ")}`);
    }
  }
  if (["outline-approved", "script-approved"].includes(targetStage) &&
      (!approvalSource || approvalSource.trim() === "")) {
    throw new Error(`${targetStage} requires --approval-source with explicit human approval evidence`);
  }
  const artifactErrors = validateLessonArtifacts(root, lesson, targetStage);
  if (artifactErrors.length) throw new Error(artifactErrors.map((item) => item.message).join("; "));
  if (targetStage === "script-draft" || targetStage === "script-approved") {
    const relativePath = `lessons/${lesson.id}/storyboard.md`;
    const storyboardPath = safeCoursePath(root, relativePath).absolute;
    if (!fs.existsSync(storyboardPath) || !fs.statSync(storyboardPath).isFile()) {
      throw new Error(`missing provisional storyboard: ${relativePath}`);
    }
  }
  if (targetStage === "script-draft" || targetStage === "script-approved") {
    const relativePath = `lessons/${lesson.id}/storyboard-preview.html`;
    const previewPath = safeCoursePath(root, relativePath).absolute;
    if (!fs.existsSync(previewPath) || !fs.statSync(previewPath).isFile() ||
        fs.statSync(previewPath).size === 0) {
      throw new Error(`missing visual storyboard preview: ${relativePath}`);
    }
  }
  if (targetStage === "script-draft") {
    const styleProblems = videoStyleIssues(root);
    if (styleProblems.length) throw new Error(styleProblems.join("; "));
  }
  const fingerprints = await fingerprintFiles(root, requiredLessonFiles(lesson, targetStage));

  for (const stage of Object.keys(lesson.records)) {
    if (stageIndex(stage) >= targetIndex) delete lesson.records[stage];
  }
  lesson.records[targetStage] = {
    recordedAt: new Date().toISOString(),
    lessonContractSha256: lessonContractSha256(lesson, targetStage),
    ...(productionContractSha256(config, targetStage)
      ? { productionContractSha256: productionContractSha256(config, targetStage) }
      : {}),
    ...(["outline-approved", "script-approved"].includes(targetStage)
      ? { approvalSource: approvalSource.trim() } : {}),
    ...(targetStage === "script-draft" ? { videoStylePath: "video-style.md" } : {}),
    fingerprints,
  };
  lesson.status = targetStage;
  state.release = { status: "not-packaged" };
  writeJsonAtomic(statePath, state);
  console.log(`Recorded ${lessonId} as ${targetStage}; downstream records and release state were invalidated.`);
} catch (error) {
  console.error(`record-course-stage: ${error.message}`);
  process.exitCode = 1;
}
