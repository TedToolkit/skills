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

narration="$fixture/narration-edit"
mkdir -p "$narration"
cat >"$narration/narration.txt" <<'EOF'
先说今天的问题。我们现在开始。

接下来给出解决方法。
EOF
printf 'source audio fixture 1\n' >"$narration/narration-working-01.wav"
printf 'source audio fixture 2\n' >"$narration/narration-working-02.wav"
node "$scripts/narration-edit.mjs" template \
    "$narration/narration.txt" \
    "$narration/narration-edit-plan.json" \
    --source "$narration/narration-working-01.wav" \
    --source "$narration/narration-working-02.wav" >/dev/null
node - "$narration/narration-edit-plan.json" <<'NODE'
const fs = require("fs");
const file = process.argv[2];
const plan = JSON.parse(fs.readFileSync(file, "utf8"));
plan.clips = [
  { id: "take-01", unit: "P01", sourceId: "source-01", start: 1, end: 5, gapAfter: 0.2, selectionReason: "complete opening paragraph" },
  { id: "take-02", unit: "P02", sourceId: "source-02", start: 2, end: 5, gapAfter: 0, selectionReason: "clean final paragraph" },
];
fs.writeFileSync(file, JSON.stringify(plan, null, 2) + "\n");
NODE
node "$scripts/narration-edit.mjs" check "$narration/narration-edit-plan.json" >/dev/null
node "$scripts/narration-edit.mjs" render "$narration/narration-edit-plan.json" --dry-run --json >"$narration/render.json"
node -e '
const report=require(process.argv[1]);
if (report.status !== "dry-run" || !report.filterComplex.includes("concat=n=3")) process.exit(1);
if (!report.args.includes("pcm_s24le")) process.exit(2);
if (!report.filterComplex.includes("[0:a]") || !report.filterComplex.includes("[1:a]")) process.exit(3);
' "$narration/render.json"
if [[ -n ${NARRATION_TEST_FFMPEG:-} && -x ${NARRATION_TEST_FFMPEG:-} ]]; then
    "$NARRATION_TEST_FFMPEG" -hide_banner -loglevel error -y \
        -f lavfi -i 'sine=frequency=440:sample_rate=48000:duration=6' \
        -c:a pcm_s24le "$narration/narration-working-01.wav"
    "$NARRATION_TEST_FFMPEG" -hide_banner -loglevel error -y \
        -f lavfi -i 'sine=frequency=660:sample_rate=48000:duration=6' \
        -c:a pcm_s24le "$narration/narration-working-02.wav"
    node "$scripts/narration-edit.mjs" render \
        "$narration/narration-edit-plan.json" --ffmpeg "$NARRATION_TEST_FFMPEG" >/dev/null
    test -s "$narration/narration-semantic.wav"
fi
cat >"$narration/transcript.json" <<'EOF'
[
  { "id": "w0001", "text": "先说今天的问题。我们现在开始。", "start": 0.0, "end": 3.0 },
  { "id": "w0002", "text": "接下来给出解决方法。", "start": 3.2, "end": 6.0 }
]
EOF
node "$scripts/narration-edit.mjs" verify \
    "$narration/narration-edit-plan.json" "$narration/transcript.json" --strict >/dev/null

cp "$narration/narration-edit-plan.json" "$narration/duplicate-plan.json"
node - "$narration/duplicate-plan.json" <<'NODE'
const fs = require("fs");
const file = process.argv[2];
const plan = JSON.parse(fs.readFileSync(file, "utf8"));
plan.clips[1].unit = "P01";
fs.writeFileSync(file, JSON.stringify(plan, null, 2) + "\n");
NODE
duplicate_plan_output=$(node "$scripts/narration-edit.mjs" check "$narration/duplicate-plan.json" 2>&1 || true)
grep -Fq 'paragraph must be covered exactly once: P01' <<<"$duplicate_plan_output"
grep -Fq 'missing paragraph coverage: P02' <<<"$duplicate_plan_output"

cat >"$narration/repeated-transcript.json" <<'EOF'
[
  { "id": "w0001", "text": "先说今天的问题。我们现在开始。", "start": 0.0, "end": 3.0 },
  { "id": "w0002", "text": "我们现在开始。接下来给出解决方法。", "start": 3.1, "end": 7.0 }
]
EOF
repeat_output=$(node "$scripts/narration-edit.mjs" verify \
    "$narration/narration-edit-plan.json" "$narration/repeated-transcript.json" --strict 2>&1 || true)
grep -Fq 'boundary_repeat' <<<"$repeat_output"

cat >"$narration/missing-transcript.json" <<'EOF'
[
  { "id": "w0001", "text": "先说今天的问题。我们现在开始。", "start": 0.0, "end": 3.0 }
]
EOF
missing_output=$(node "$scripts/narration-edit.mjs" verify \
    "$narration/narration-edit-plan.json" "$narration/missing-transcript.json" --strict 2>&1 || true)
grep -Fq 'script_unit_coverage' <<<"$missing_output"

cat >"$narration/off-script-transcript.json" <<'EOF'
[
  { "id": "w0001", "text": "先说今天的问题。我们现在开始。", "start": 0.0, "end": 3.0 },
  { "id": "w0002", "text": "哎呀，这一句太难读了。", "start": 3.1, "end": 4.0 },
  { "id": "w0003", "text": "接下来给出解决方法。", "start": 4.1, "end": 7.0 }
]
EOF
off_script_output=$(node "$scripts/narration-edit.mjs" verify \
    "$narration/narration-edit-plan.json" "$narration/off-script-transcript.json" --strict 2>&1 || true)
grep -Fq 'off_script_entry' <<<"$off_script_output"

cat >"$narration/one-token-extra-transcript.json" <<'EOF'
[
  { "id": "w0001", "text": "先说今天的问题。我们现在开始。", "start": 0.0, "end": 3.0 },
  { "id": "w0002", "text": "嗯", "start": 3.1, "end": 3.2 },
  { "id": "w0003", "text": "接下来给出解决方法。", "start": 3.3, "end": 6.0 }
]
EOF
one_token_extra_output=$(node "$scripts/narration-edit.mjs" verify \
    "$narration/narration-edit-plan.json" "$narration/one-token-extra-transcript.json" --strict 2>&1 || true)
grep -Fq 'off_script_content' <<<"$one_token_extra_output"

if rg -q 'video-captioned\.mp4' "$repo_root/plugins/tedtoolkit-hyperframes-tutorials"; then
    echo "captioned video derivative is still part of the tutorial workflow" >&2
    exit 1
fi

if rg -q 'storyboard-tutorial' "$repo_root/plugins/tedtoolkit-hyperframes-tutorials"; then
    echo "removed storyboard skill is still referenced by the tutorial workflow" >&2
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
  "outline": "course.md",
  "video": {
    "aspectRatio": "16:9",
    "width": 1920,
    "height": 1080,
    "fps": 30,
    "container": "mp4",
    "videoCodec": "h264",
    "pixelFormat": "yuv420p",
    "audioCodec": "aac",
    "audioSampleRate": 48000
  },
  "cover": {
    "width": 1920,
    "height": 1080,
    "format": "png"
  }
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

question_gate_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'lesson.md must contain exactly one ## Post-lesson question section' <<<"$question_gate_output"
cat >>"$course/lessons/lesson-01/lesson.md" <<'EOF'

## Post-lesson question

EOF
empty_question_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq '## Post-lesson question must contain learner-facing text' <<<"$empty_question_output"
cat >>"$course/lessons/lesson-01/lesson.md" <<'EOF'

What did this lesson demonstrate?
EOF
cp "$course/lessons/lesson-01/lesson.md" "$fixture/lesson.saved"
cat >>"$course/lessons/lesson-01/lesson.md" <<'EOF'

## Post-lesson question

Why would this duplicate be invalid?
EOF
duplicate_question_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'lesson.md must contain exactly one ## Post-lesson question section' <<<"$duplicate_question_output"
cp "$fixture/lesson.saved" "$course/lessons/lesson-01/lesson.md"
missing_storyboard_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'missing provisional storyboard: lessons/lesson-01/storyboard.md' <<<"$missing_storyboard_output"
printf '# Provisional storyboard\n' >"$course/lessons/lesson-01/storyboard.md"
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

node "$scripts/validate-course.mjs" "$course" --json >"$fixture/narration-final.json"
node -e '
const report=require(process.argv[1]);
if (!report.valid) process.exit(1);
if (report.nextWave.length !== 1 || report.nextWave[0].nextSkill !== "design-tutorial") process.exit(2);
' "$fixture/narration-final.json"

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

if node "$scripts/record-course-stage.mjs" "$course" lesson-01 cover-verified >/dev/null 2>&1; then
    echo "cover-verified advanced without the course cover system and lesson cover" >&2
    exit 1
fi
printf '# Cover system\n' >"$course/cover-system.md"
printf 'course cover\n' >"$course/course-cover.png"
printf 'cover\n' >"$course/lessons/lesson-01/cover.png"
node "$scripts/record-course-stage.mjs" "$course" lesson-01 cover-verified >/dev/null
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/lessons/lesson-01/video.mp4" "$course/release/lessons/lesson-01/video.mp4"
cp "$course/lessons/lesson-01/cover.png" "$course/release/lessons/lesson-01/cover.png"
cp "$course/course-cover.png" "$course/release/course-cover.png"
cat >"$course/release/index.html" <<'EOF'
<!doctype html>
<img src="course-cover.png" alt="Workflow fixture course cover">
<video controls poster="lessons/lesson-01/cover.png">
  <source src="lessons/lesson-01/video.mp4" type="video/mp4">
  <track src="lessons/lesson-01/captions.vtt" kind="captions" srclang="en">
</video>
<section data-post-lesson-question="lesson-01">
  <h2>Post-lesson question</h2>
  <p>What did this lesson demonstrate?</p>
</section>
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

cp "$course/release/index.html" "$fixture/index.saved"
sed -i '/course-cover.png/d' "$course/release/index.html"
course_cover_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE: index.html does not reference current course-cover.png' <<<"$course_cover_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's# poster="lessons/lesson-01/cover.png"##' "$course/release/index.html"
cover_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE [lesson-01]: index.html does not reference current lessons/lesson-01/cover.png' <<<"$cover_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's/data-post-lesson-question/data-omitted-question/' "$course/release/index.html"
question_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE [lesson-01]: index.html does not expose the current static post-lesson question' <<<"$question_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's/What did this lesson demonstrate?/Different visible text./' "$course/release/index.html"
question_text_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE [lesson-01]: index.html does not expose the current static post-lesson question' <<<"$question_text_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/course.config.json" "$fixture/config.saved"
node -e '
const fs=require("fs"), file=process.argv[1], config=JSON.parse(fs.readFileSync(file,"utf8"));
config.cover.width=1000;
fs.writeFileSync(file, JSON.stringify(config,null,2)+"\n");
' "$course/course.config.json"
config_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'COVER_ASPECT_RATIO' <<<"$config_output"
cp "$fixture/config.saved" "$course/course.config.json"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/cover-system.md" "$fixture/cover-system.saved"
printf '# Changed cover system\n' >"$course/cover-system.md"
cover_system_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'cover-verified: fingerprint changed: cover-system.md' <<<"$cover_system_output"
grep -Fq 'STALE_RELEASE' <<<"$cover_system_output"
cp "$fixture/cover-system.saved" "$course/cover-system.md"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/course.config.json" "$fixture/config.saved"
node -e '
const fs=require("fs"), file=process.argv[1], config=JSON.parse(fs.readFileSync(file,"utf8"));
config.cover.width=1280;
config.cover.height=720;
fs.writeFileSync(file, JSON.stringify(config,null,2)+"\n");
' "$course/course.config.json"
cover_contract_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'cover-verified: video or cover production contract changed' <<<"$cover_contract_output"
grep -Fq 'STALE_RELEASE' <<<"$cover_contract_output"
cp "$fixture/config.saved" "$course/course.config.json"
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
