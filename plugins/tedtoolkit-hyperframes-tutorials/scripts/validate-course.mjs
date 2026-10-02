#!/usr/bin/env node

import { formatValidationReport, validateCourse } from "./course-state-lib.mjs";

function usage() {
  console.error("usage: validate-course.mjs <course-root> [--json]");
  process.exit(2);
}

const args = process.argv.slice(2);
if (args.length < 1 || args.length > 2 || (args[1] && args[1] !== "--json")) usage();

try {
  const report = await validateCourse(args[0]);
  if (args[1] === "--json") process.stdout.write(`${JSON.stringify(report, null, 2)}\n`);
  else process.stdout.write(formatValidationReport(report));
  process.exitCode = report.valid ? 0 : 1;
} catch (error) {
  const failure = { valid: false, errors: [{ code: "COURSE_LOAD", message: error.message }] };
  if (args[1] === "--json") process.stdout.write(`${JSON.stringify(failure, null, 2)}\n`);
  else console.error(`Course validation: FAIL\n- COURSE_LOAD: ${error.message}`);
  process.exitCode = 1;
}
