#!/usr/bin/env node

import { formatValidationReport, validateCourse } from "./course-state-lib.mjs";

function usage() {
  console.error("usage: validate-course.mjs <course-root> [--json|--summary] [--lesson <lesson-id>]");
  process.exit(2);
}

const args = process.argv.slice(2);
if (args.length < 1) usage();
let mode = "text";
let lessonId;
for (let index = 1; index < args.length; index += 1) {
  const arg = args[index];
  if (arg === "--json" || arg === "--summary") {
    if (mode !== "text") usage();
    mode = arg.slice(2);
  } else if (arg === "--lesson") {
    if (lessonId || !args[index + 1]) usage();
    lessonId = args[++index];
  } else usage();
}
if (lessonId && mode !== "summary") usage();

function summarize(report) {
  const selectedLesson = lessonId ? report.lessons.find((lesson) => lesson.id === lessonId) : undefined;
  const errors = [...report.errors];
  if (lessonId && !selectedLesson) {
    errors.push({ code: "LESSON_NOT_FOUND", lessonId, message: `lesson ${lessonId} is not in this course` });
  }
  return {
    courseId: report.courseId,
    valid: report.valid && errors.length === 0,
    releaseStatus: report.releaseStatus,
    errors,
    staleLessons: report.lessons.filter((lesson) => lesson.staleStage)
      .map(({ id, staleStage, effectiveStatus }) => ({ id, staleStage, effectiveStatus })),
    nextWave: report.nextWave,
    ...(lessonId ? { selectedLesson: selectedLesson ?? null } : {}),
  };
}

try {
  const report = await validateCourse(args[0]);
  if (mode === "json") process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
  else if (mode === "summary") process.stdout.write(`${JSON.stringify(summarize(report))}\n`);
  else process.stdout.write(formatValidationReport(report));
  process.exitCode = report.valid && (!lessonId || report.lessons.some((lesson) => lesson.id === lessonId)) ? 0 : 1;
} catch (error) {
  const failure = { valid: false, errors: [{ code: "COURSE_LOAD", message: error.message }] };
  if (mode === "json" || mode === "summary") process.stdout.write(`${JSON.stringify(failure)}\n`);
  else console.error(`Course validation: FAIL\n- COURSE_LOAD: ${error.message}`);
  process.exitCode = 1;
}
