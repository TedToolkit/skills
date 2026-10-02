#!/usr/bin/env bash
set -euo pipefail

repo_root=${1:-}
if [[ -z $repo_root ]]; then
    repo_root=$(git rev-parse --show-toplevel)
fi
repo_root=$(cd "$repo_root" && pwd -P)
scripts="$repo_root/plugins/tedtoolkit-hyperframes-tutorials/scripts"
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT

if rg -q 'video-captioned\.mp4' "$repo_root/plugins/tedtoolkit-hyperframes-tutorials"; then
    echo "captioned video derivative is still part of the tutorial workflow" >&2
    exit 1
fi

course="$fixture/course"
mkdir -p "$course/lessons/lesson-01" "$course/release/lessons/lesson-01"

cat >"$course/course.config.json" <<'EOF'
{
  "courseId": "workflow-fixture",
  "title": "Workflow fixture",
  "slug": "workflow-fixture",
  "contentLanguage": "en",
  "outline": "course.md"
}
EOF

cat >"$course/course-state.json" <<'EOF'
{
  "formatVersion": 1,
  "courseId": "workflow-fixture",
  "lessons": [
    {
      "id": "lesson-01",
      "type": "core",
      "requires": [],
      "sourcePaths": [],
      "status": "planned",
      "records": {}
    }
  ],
  "release": { "status": "not-packaged" }
}
EOF

printf '# Course\n' >"$course/course.md"
printf '# Lesson 01\n' >"$course/lessons/lesson-01/lesson.md"
printf 'Hello world.\n' >"$course/lessons/lesson-01/narration.txt"

node "$scripts/validate-course.mjs" "$course" --json >"$fixture/planned.json"
node -e '
const report=require(process.argv[1]);
if (!report.valid) process.exit(1);
if (report.nextWave.length !== 1 || report.nextWave[0].id !== "lesson-01" || report.nextWave[0].nextSkill !== "design-tutorial") process.exit(2);
' "$fixture/planned.json"

node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft >/dev/null
if node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-approved >/dev/null 2>&1; then
    echo "script approval advanced without explicit approval evidence" >&2
    exit 1
fi
node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-approved \
    --approval-source "Fixture owner approved version 1" >/dev/null

printf 'source audio\n' >"$course/lessons/lesson-01/narration-source.wav"
printf 'final audio\n' >"$course/lessons/lesson-01/narration.wav"
cat >"$course/lessons/lesson-01/transcript.json" <<'EOF'
[
  { "id": "w0001", "text": "Hello", "start": 0.0, "end": 0.5 },
  { "id": "w0002", "text": "world.", "start": 0.5, "end": 1.0 }
]
EOF
node "$scripts/record-course-stage.mjs" "$course" lesson-01 narration-final >/dev/null

printf '# Storyboard\n' >"$course/lessons/lesson-01/storyboard.md"
node "$scripts/record-course-stage.mjs" "$course" lesson-01 storyboard-final >/dev/null
printf 'video\n' >"$course/lessons/lesson-01/video.mp4"
cat >"$course/lessons/lesson-01/captions.vtt" <<'EOF'
WEBVTT

00:00:00.000 --> 00:00:00.800
Hello

00:00:00.700 --> 00:00:01.000
world.
EOF
if node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified >/dev/null 2>&1; then
    echo "overlapping WebVTT cues were incorrectly accepted" >&2
    exit 1
fi
cat >"$course/lessons/lesson-01/captions.vtt" <<'EOF'
WEBVTT

00:00:00.000 --> 00:00:00.500
Hello

00:00:00.500 --> 00:00:01.000
world.
EOF
node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified >/dev/null
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/lessons/lesson-01/video.mp4" "$course/release/lessons/lesson-01/video.mp4"
cat >"$course/release/index.html" <<'EOF'
<!doctype html>
<video controls>
  <source src="lessons/lesson-01/video.mp4" type="video/mp4">
  <track src="lessons/lesson-01/captions.vtt" kind="captions" srclang="en">
</video>
EOF
printf 'zip fixture\n' >"$course/workflow-fixture.zip"
if node "$scripts/record-course-release.mjs" "$course" release workflow-fixture.zip >/dev/null 2>&1; then
    echo "release without its referenced caption track was incorrectly accepted" >&2
    exit 1
fi
cp "$course/lessons/lesson-01/captions.vtt" "$course/release/lessons/lesson-01/captions.vtt"
node "$scripts/record-course-release.mjs" "$course" release workflow-fixture.zip >/dev/null
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's#lessons/lesson-01/video.mp4#https://example.invalid/video.mp4#' "$course/release/index.html"
network_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'NETWORK_MEDIA' <<<"$network_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

printf 'evidence\n' >"$course/evidence.txt"
node -e '
const fs=require("fs"), file=process.argv[1], state=JSON.parse(fs.readFileSync(file,"utf8"));
state.lessons[0].sourcePaths=["evidence.txt"];
fs.writeFileSync(file, JSON.stringify(state,null,2)+"\n");
' "$course/course-state.json"
contract_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'lesson identity, type, prerequisites, or source paths changed' <<<"$contract_output"
node -e '
const fs=require("fs"), file=process.argv[1], state=JSON.parse(fs.readFileSync(file,"utf8"));
state.lessons[0].sourcePaths=[];
fs.writeFileSync(file, JSON.stringify(state,null,2)+"\n");
' "$course/course-state.json"
node "$scripts/validate-course.mjs" "$course" >/dev/null

printf 'Hello changed world.\n' >"$course/lessons/lesson-01/narration.txt"
stale_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'STALE_STAGE [lesson-01]' <<<"$stale_output"
grep -Fq 'STALE_RELEASE' <<<"$stale_output"

node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft >/dev/null
node -e '
const state=require(process.argv[1]);
const lesson=state.lessons[0];
if (lesson.status !== "script-draft") process.exit(1);
if (Object.keys(lesson.records).some((key) => key !== "script-draft")) process.exit(2);
if (state.release.status !== "not-packaged") process.exit(3);
' "$course/course-state.json"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cycle="$fixture/cycle"
mkdir -p "$cycle"
cp "$course/course.config.json" "$cycle/course.config.json"
cp "$course/course.md" "$cycle/course.md"
cat >"$cycle/course-state.json" <<'EOF'
{
  "formatVersion": 1,
  "courseId": "workflow-fixture",
  "lessons": [
    { "id": "a", "type": "core", "requires": ["b"], "sourcePaths": [], "status": "planned", "records": {} },
    { "id": "b", "type": "core", "requires": ["a"], "sourcePaths": [], "status": "planned", "records": {} }
  ],
  "release": { "status": "not-packaged" }
}
EOF
cycle_output=$(node "$scripts/validate-course.mjs" "$cycle" 2>&1 || true)
grep -Fq 'DEPENDENCY_CYCLE' <<<"$cycle_output"

echo "OK: tutorial workflow script regressions passed"
