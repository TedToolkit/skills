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

narration="$fixture/narration-generate"
mkdir -p "$narration"
cat >"$narration/narration.txt" <<'EOF'
先说今天的问题。我们现在开始。

接下来给出解决方法。
EOF
node "$scripts/fish-tts.mjs" \
    "$narration/narration.txt" "$narration/narration.wav" --dry-run >"$narration/fish-dry-run.json"
node -e '
const report=require(process.argv[1]);
if (report.model !== "s2.1-pro") process.exit(1);
if (report.format !== "wav" || report.sampleRate !== 44100) process.exit(2);
if (report.sendsReferenceAudio !== false) process.exit(3);
if (report.apiKeyEnv !== "FISH_API_KEY" || report.voiceIdEnv !== "FISH_VOICE_ID") process.exit(4);
if (!(report.textUtf8Bytes > 0)) process.exit(5);
if (report.outputExists !== false || report.replace !== false) process.exit(6);
' "$narration/fish-dry-run.json"
printf 'existing output fixture\n' >"$narration/narration.wav"
node "$scripts/fish-tts.mjs" \
    "$narration/narration.txt" "$narration/narration.wav" --dry-run >"$narration/fish-existing-dry-run.json"
node -e '
const report=require(process.argv[1]);
if (report.outputExists !== true || report.replace !== false) process.exit(1);
' "$narration/fish-existing-dry-run.json"
node "$scripts/fish-tts.mjs" \
    "$narration/narration.txt" "$narration/narration.wav" \
    --model s2.1-pro-free --dry-run >"$narration/fish-free-dry-run.json"
node -e '
const report=require(process.argv[1]);
if (report.model !== "s2.1-pro-free") process.exit(1);
' "$narration/fish-free-dry-run.json"
invalid_model_output=$(node "$scripts/fish-tts.mjs" \
    "$narration/narration.txt" "$narration/narration.wav" \
    --model s2.1-pro-fre --dry-run 2>&1 || true)
grep -Fq 'unsupported Fish TTS model: s2.1-pro-fre' <<<"$invalid_model_output"

if rg -q 'video-captioned\.mp4' "$repo_root/plugins/tedtoolkit-hyperframes-tutorials"; then
    echo "captioned video derivative is still part of the tutorial workflow" >&2
    exit 1
fi

if rg -q 'storyboard-tutorial' "$repo_root/plugins/tedtoolkit-hyperframes-tutorials"; then
    echo "removed storyboard skill is still referenced by the tutorial workflow" >&2
    exit 1
fi

if rg -q 'transcript\.json' "$repo_root/plugins/tedtoolkit-hyperframes-tutorials"; then
    echo "removed transcript artifact is still referenced by the tutorial workflow" >&2
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

printf 'final audio\n' >"$course/lessons/lesson-01/narration.wav"
node "$scripts/record-course-stage.mjs" "$course" lesson-01 narration-final >/dev/null

node "$scripts/validate-course.mjs" "$course" --json >"$fixture/narration-final.json"
node -e '
const report=require(process.argv[1]);
if (!report.valid) process.exit(1);
if (report.nextWave.length !== 1 || report.nextWave[0].nextSkill !== "design-tutorial") process.exit(2);
' "$fixture/narration-final.json"

printf '# Storyboard\n' >"$course/lessons/lesson-01/storyboard.md"
missing_storyboard_timing_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 storyboard-final 2>&1 || true)
grep -Fq 'final storyboard.md contains no audio ranges' <<<"$missing_storyboard_timing_output"
cat >"$course/lessons/lesson-01/storyboard.md" <<'EOF'
# Storyboard

| S01 | P01 | 00:00:00.000 --> 00:00:00.700 | Hello |
| S02 | P01 | 00:00:00.600 --> 00:00:01.000 | world. |
EOF
overlapping_storyboard_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 storyboard-final 2>&1 || true)
grep -Fq 'storyboard audio ranges overlap or are out of order' <<<"$overlapping_storyboard_output"
cat >"$course/lessons/lesson-01/storyboard.md" <<'EOF'
# Storyboard

## Final timing

| Shot | Paragraph | Audio range | Spoken cue |
| --- | --- | --- | --- |
| S01 | P01 | 00:00:00.000 --> 00:00:00.500 | Hello |
| S02 | P01 | 00:00:00.500 --> 00:00:01.000 | world. |
EOF
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
