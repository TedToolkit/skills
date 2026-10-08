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
fake_fish_url=$(node -p 'require("node:url").pathToFileURL(process.argv[1]).href' "$narration/fake-fish.mjs")
failing_fish_url=$(node -p 'require("node:url").pathToFileURL(process.argv[1]).href' "$narration/failing-fish.mjs")
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
' "$narration/fish-dry-run.json"
printf 'existing output fixture\n' >"$narration/narration.wav"
node "$scripts/fish-tts.mjs" \
    "$narration/narration.txt" "$narration/narration.wav" --dry-run >"$narration/fish-existing.json"
node -e 'if (!require(process.argv[1]).outputExists) process.exit(1)' "$narration/fish-existing.json"
node "$scripts/fish-tts.mjs" \
    "$narration/narration.txt" "$narration/narration.wav" --replace --dry-run >"$narration/fish-existing-dry-run.json"
node "$scripts/fish-tts.mjs" \
    "$narration/narration.txt" "$narration/narration.wav" \
    --model s2.1-pro-free --replace --dry-run >"$narration/fish-free-dry-run.json"
node -e '
const report=require(process.argv[1]);
if (report.model !== "s2.1-pro-free") process.exit(1);
' "$narration/fish-free-dry-run.json"
invalid_model_output=$(node "$scripts/fish-tts.mjs" \
    "$narration/narration.txt" "$narration/narration.wav" \
    --model s2.1-pro-fre --dry-run 2>&1 || true)
grep -Fq 'unsupported Fish TTS model: s2.1-pro-fre' <<<"$invalid_model_output"

cat >"$narration/fake-fish.mjs" <<'EOF'
import fs from "node:fs";
globalThis.fetch = async (_url, request) => {
  if (process.env.FISH_FETCH_MARKER) fs.appendFileSync(process.env.FISH_FETCH_MARKER, "fetch\n");
  if (process.env.EXPECT_ENV_PROXY === "1" &&
      !process.execArgv.includes("--use-env-proxy")) {
    throw new Error("environment proxy was not enabled before the request");
  }
  if (process.env.EXPECT_ENV_PROXY === "0" &&
      process.execArgv.includes("--use-env-proxy")) {
    throw new Error("environment proxy was enabled unexpectedly");
  }
  const body = JSON.parse(request.body);
  if (body.sample_rate !== 44100 || body.format !== "wav") {
    throw new Error("unexpected Fish request format");
  }
  const audio = Buffer.alloc(48);
  audio.write("RIFF", 0);
  audio.writeUInt32LE(0x7fffffff, 4);
  audio.write("WAVEfmt ", 8);
  audio.writeUInt32LE(16, 16);
  audio.writeUInt16LE(1, 20);
  audio.writeUInt16LE(1, 22);
  audio.writeUInt32LE(44100, 24);
  audio.writeUInt32LE(88200, 28);
  audio.writeUInt16LE(2, 32);
  audio.writeUInt16LE(16, 34);
  audio.write("data", 36);
  audio.writeUInt32LE(0x7fffffff, 40);
  audio.writeInt16LE(100, 44);
  audio.writeInt16LE(-100, 46);
  return { ok: true, arrayBuffer: async () => audio };
};
EOF
if node -e 'process.exit(process.allowedNodeEnvironmentFlags.has("--use-env-proxy") ? 0 : 1)'; then
    env -u NODE_USE_ENV_PROXY HTTPS_PROXY=http://127.0.0.1:9 \
        EXPECT_ENV_PROXY=1 FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
        node --import "$fake_fish_url" \
        "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/narration.wav" \
        --replace >"$narration/fish-generated.json"
else
    FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
        node --import "$fake_fish_url" \
        "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/narration.wav" \
        --replace >"$narration/fish-generated.json"
fi
env -u HTTPS_PROXY -u https_proxy -u NODE_USE_ENV_PROXY \
    EXPECT_ENV_PROXY=0 FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
    node --import "$fake_fish_url" \
    "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/narration.wav" \
    --replace >"$narration/fish-no-proxy.json"
NODE_USE_ENV_PROXY=0 HTTPS_PROXY=http://127.0.0.1:9 \
    EXPECT_ENV_PROXY=0 FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
    node --import "$fake_fish_url" \
    "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/narration.wav" \
    --replace >"$narration/fish-proxy-disabled.json"
FISH_FETCH_MARKER="$narration/reuse-fetch-marker" \
    FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
    node --import "$fake_fish_url" \
    "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/narration.wav" \
    >"$narration/fish-reused.json"
node -e 'if (require(process.argv[1]).reused !== true) process.exit(1)' "$narration/fish-reused.json"
test ! -e "$narration/reuse-fetch-marker"
node -e '
const fs=require("node:fs"), record=require(process.argv[1]);
if (record.attempts.length !== 3 || record.attempts.some((a)=>a.status!=="complete")) process.exit(1);
const raw=fs.readFileSync(process.argv[1],"utf8");
if (raw.includes("fixture-voice") || raw.includes("先说今天的问题")) process.exit(2);
' "$narration/narration.wav.fish-request.json"

cat >"$narration/failing-fish.mjs" <<'EOF'
globalThis.fetch = async () => { throw new Error("connection lost after send"); };
EOF
uncertain_output=$(FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
    node --import "$failing_fish_url" \
    "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/uncertain.wav" 2>&1 || true)
grep -Fq 'connection lost after send' <<<"$uncertain_output"
test ! -e "$narration/uncertain.wav"
blocked_retry_output=$(FISH_FETCH_MARKER="$narration/blocked-fetch-marker" \
    FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
    node --import "$fake_fish_url" \
    "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/uncertain.wav" 2>&1 || true)
grep -Fq 'previous Fish request has no confirmed WAV' <<<"$blocked_retry_output"
test ! -e "$narration/blocked-fetch-marker"
FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
    node --import "$fake_fish_url" \
    "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/uncertain.wav" \
    --retry-uncertain >"$narration/fish-retried.json"
node -e '
const record=require(process.argv[1]);
if (record.attempts.length!==2 || record.attempts[0].status!=="pending" ||
    record.attempts[1].status!=="complete") process.exit(1);
' "$narration/uncertain.wav.fish-request.json"
mv "$narration/uncertain.wav" "$narration/uncertain.saved.wav"
missing_completed_output=$(FISH_FETCH_MARKER="$narration/missing-fetch-marker" \
    FISH_API_KEY=fixture-key FISH_VOICE_ID=fixture-voice \
    node --import "$fake_fish_url" \
    "$scripts/fish-tts.mjs" "$narration/narration.txt" "$narration/uncertain.wav" 2>&1 || true)
grep -Fq 'same Fish request completed before, but its WAV is missing' <<<"$missing_completed_output"
test ! -e "$narration/missing-fetch-marker"
mv "$narration/uncertain.saved.wav" "$narration/uncertain.wav"
node -e '
const fs=require("node:fs");
const audio=fs.readFileSync(process.argv[1]);
if (audio.readUInt32LE(4) !== audio.length - 8) process.exit(1);
if (audio.readUInt32LE(40) !== audio.length - 44) process.exit(2);
if (audio.readUInt32LE(24) !== 44100) process.exit(3);
if (audio.readInt16LE(44) !== 100 || audio.readInt16LE(46) !== -100) process.exit(4);
' "$narration/narration.wav"

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
  "learnerDocuments": ["practice.md"],
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
cat >"$course/practice.md" <<'EOF'
# Core practice

## Chapter checkpoint

Predict the output, run the example, and explain any mismatch.

## Final Core completion task

Change the example and verify the result with the stated acceptance conditions.
EOF
printf '# Lesson 01\n' >"$course/lessons/lesson-01/lesson.md"
printf 'Hello world.\n' >"$course/lessons/lesson-01/narration.txt"

node "$scripts/validate-course.mjs" "$course" --json >"$fixture/planned.json"
node "$scripts/validate-course.mjs" "$course" --summary --lesson lesson-01 >"$fixture/planned-summary.json"
node -e '
const report=require(process.argv[1]);
if (!report.valid || report.selectedLesson?.id !== "lesson-01" || report.nextWave[0]?.nextSkill !== "outline-tutorial-lesson") process.exit(1);
if ("lessons" in report || report.staleLessons.length !== 0) process.exit(2);
' "$fixture/planned-summary.json"
if node "$scripts/validate-course.mjs" "$course" --summary --lesson missing-lesson >"$fixture/missing-lesson.json"; then
    echo "summary accepted an unknown lesson" >&2
    exit 1
fi
node -e '
const report=require(process.argv[1]);
if (report.valid || report.selectedLesson !== null || !report.errors.some(e => e.code === "LESSON_NOT_FOUND")) process.exit(1);
' "$fixture/missing-lesson.json"
node -e '
const report=require(process.argv[1]);
if (!report.valid) process.exit(1);
if (report.nextWave.length !== 1 || report.nextWave[0].id !== "lesson-01" || report.nextWave[0].nextSkill !== "outline-tutorial-lesson") process.exit(2);
' "$fixture/planned.json"
mv "$course/practice.md" "$fixture/practice.saved"
missing_practice_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'LEARNER_DOCUMENTS: learner document does not exist: practice.md' <<<"$missing_practice_output"
mv "$fixture/practice.saved" "$course/practice.md"

printf '# Lesson outline\n\nA problem leads to an observation and a usable conclusion.\n' >"$course/lessons/lesson-01/lesson-outline.md"
node "$scripts/record-course-stage.mjs" "$course" lesson-01 outline-draft >/dev/null
if node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft >/dev/null 2>&1; then
    echo "script draft advanced before lesson outline approval" >&2
    exit 1
fi
if node "$scripts/record-course-stage.mjs" "$course" lesson-01 outline-approved >/dev/null 2>&1; then
    echo "lesson outline advanced without explicit approval evidence" >&2
    exit 1
fi
node "$scripts/validate-course.mjs" "$course" --json >"$fixture/outline-draft.json"
node -e '
const report=require(process.argv[1]);
if (!report.valid || report.nextWave[0]?.nextSkill !== "outline-tutorial-lesson") process.exit(1);
' "$fixture/outline-draft.json"
node "$scripts/record-course-stage.mjs" "$course" lesson-01 outline-approved \
    --approval-source "Fixture owner approved the lesson outline" >/dev/null
node "$scripts/validate-course.mjs" "$course" --json >"$fixture/outline-approved.json"
node -e '
const report=require(process.argv[1]);
if (!report.valid || report.nextWave[0]?.nextSkill !== "design-tutorial") process.exit(1);
' "$fixture/outline-approved.json"
printf 'demonstration evidence\n' >"$course/evidence.txt"
node -e '
const fs=require("fs"), file=process.argv[1], state=JSON.parse(fs.readFileSync(file,"utf8"));
state.lessons[0].sourcePaths=["evidence.txt"];
fs.writeFileSync(file, JSON.stringify(state,null,2)+"\n");
' "$course/course-state.json"
node "$scripts/validate-course.mjs" "$course" >/dev/null
node -e '
const fs=require("fs"), file=process.argv[1], state=JSON.parse(fs.readFileSync(file,"utf8"));
state.lessons[0].sourcePaths=[];
fs.writeFileSync(file, JSON.stringify(state,null,2)+"\n");
' "$course/course-state.json"
rm "$course/evidence.txt"

question_gate_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'lesson.md must contain exactly one ## Post-lesson question section' <<<"$question_gate_output"
cat >>"$course/lessons/lesson-01/lesson.md" <<'EOF'

## Post-lesson question

EOF
empty_question_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq '## Post-lesson question must contain learner-facing text' <<<"$empty_question_output"
cat >>"$course/lessons/lesson-01/lesson.md" <<'EOF'

What did this lesson demonstrate?

## Visual descriptions

The result panel shows Hello followed by world.
EOF
cp "$course/lessons/lesson-01/lesson.md" "$fixture/lesson.saved"
cat >>"$course/lessons/lesson-01/lesson.md" <<'EOF'

## Post-lesson question

Why would this duplicate be invalid?
EOF
duplicate_question_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'lesson.md must contain exactly one ## Post-lesson question section' <<<"$duplicate_question_output"
cp "$fixture/lesson.saved" "$course/lessons/lesson-01/lesson.md"
cat >>"$course/lessons/lesson-01/lesson.md" <<'EOF'

## Visual descriptions

This duplicate should fail validation.
EOF
duplicate_visual_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'lesson.md must contain at most one ## Visual descriptions section' <<<"$duplicate_visual_output"
cp "$fixture/lesson.saved" "$course/lessons/lesson-01/lesson.md"
missing_storyboard_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'missing provisional storyboard: lessons/lesson-01/storyboard.md' <<<"$missing_storyboard_output"
cat >"$course/lessons/lesson-01/storyboard.md" <<'EOF'
# Provisional storyboard

| Shot S01 | P01 | Show the code before the result |
| Shot S02 | P01 | Reveal the verified result |
EOF
missing_preview_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'missing visual storyboard preview: lessons/lesson-01/storyboard-preview.html' <<<"$missing_preview_output"
printf '<!doctype html><title>Shot preview</title><main><section data-shot-id="S01"><figure>Code panel</figure></section><section data-shot-id="S02"><figure>Result panel</figure></section></main>\n' >"$course/lessons/lesson-01/storyboard-preview.html"
missing_style_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'course video style is missing or empty: video-style.md' <<<"$missing_style_output"
printf '# Course video style\n\nUse a clear shared visual grammar with lesson-specific scenes.\n\n[Reference frame](style-reference.svg)\n' >"$course/video-style.md"
missing_style_reference_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'course video style reference is missing: style-reference.svg' <<<"$missing_style_reference_output"
printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 9"/>\n' >"$course/style-reference.svg"
missing_visual_assets_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'course video style must link a reusable local CSS file' <<<"$missing_visual_assets_output"
grep -Fq 'course video style must link a reusable local HTML example' <<<"$missing_visual_assets_output"
mkdir -p "$course/visual"
printf '\n[Course CSS](visual/style.css)\n[HTML example](visual/examples.html)\n' >>"$course/video-style.md"
printf ':root { --course-paper: white; }\n' >"$course/visual/style.css"
printf '<!doctype html><title>Course visual examples</title>\n' >"$course/visual/examples.html"
missing_example_css_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'course HTML example must load the declared reusable CSS' <<<"$missing_example_css_output"
printf '<link href="style.css" rel="stylesheet">\n' >>"$course/visual/examples.html"
missing_preview_css_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'storyboard preview must load the declared reusable CSS' <<<"$missing_preview_css_output"
printf '<!-- <link rel="stylesheet" href="../../visual/style.css"> -->\n' >>"$course/lessons/lesson-01/storyboard-preview.html"
commented_css_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'storyboard preview must load the declared reusable CSS' <<<"$commented_css_output"
printf '<link rel=stylesheet href=../../visual/style.css>\n' >>"$course/lessons/lesson-01/storyboard-preview.html"
cp "$course/lessons/lesson-01/storyboard-preview.html" "$fixture/preview.shared-css.saved"
printf '<link rel="stylesheet" href="../../rogue.css">\n' >>"$course/lessons/lesson-01/storyboard-preview.html"
extra_preview_css_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'storyboard preview must load only declared reusable CSS' <<<"$extra_preview_css_output"
mv "$fixture/preview.shared-css.saved" "$course/lessons/lesson-01/storyboard-preview.html"
mkdir -p "$course/visual/fonts"
printf '@import "type.css";\n' >>"$course/visual/style.css"
printf '@font-face { font-family: Fixture; src: url("fonts/fixture.ttf"); }\n' >"$course/visual/type.css"
missing_font_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'visual CSS dependency is missing or empty: visual/fonts/fixture.ttf' <<<"$missing_font_output"
printf 'fixture font bytes\n' >"$course/visual/fonts/fixture.ttf"
printf 'fixture font license\n' >"$course/visual/fonts/LICENSE.txt"
printf '\n[Font license](visual/fonts/LICENSE.txt)\n' >>"$course/video-style.md"
cp "$course/lessons/lesson-01/storyboard-preview.html" "$fixture/shot-preview.saved"
sed -i 's/data-shot-id="S02"/data-shot-id="S03"/' "$course/lessons/lesson-01/storyboard-preview.html"
shot_mismatch_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'shot identifiers or order differ between storyboard.md and storyboard-preview.html' <<<"$shot_mismatch_output"
cp "$fixture/shot-preview.saved" "$course/lessons/lesson-01/storyboard-preview.html"
node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-draft >/dev/null
node -e '
const state=require(process.argv[1]);
if (state.lessons[0].records["script-draft"].shotMappingRequired !== true) process.exit(1);
' "$course/course-state.json"
legacy_visual="$fixture/legacy-visual"
cp -R "$course" "$legacy_visual"
node -e '
const fs=require("fs"), p=process.argv[1];
const state=JSON.parse(fs.readFileSync(p,"utf8"));
delete state.lessons[0].records["script-draft"].visualAssetsRequired;
fs.writeFileSync(p,JSON.stringify(state));
' "$legacy_visual/course-state.json"
printf '# Legacy course style\n' >"$legacy_visual/video-style.md"
node "$scripts/validate-course.mjs" "$legacy_visual" >/dev/null
shared_series="$fixture/shared-visual-series"
mkdir -p "$shared_series"
cp -R "$course" "$shared_series/course"
mv "$shared_series/course/visual" "$shared_series/series-standards"
printf '{"courses":[{"path":"course"}]}\n' >"$shared_series/course-series.json"
node -e '
const fs=require("fs"), root=process.argv[1];
const style=root+"/course/video-style.md", preview=root+"/course/lessons/lesson-01/storyboard-preview.html";
fs.writeFileSync(style,fs.readFileSync(style,"utf8").replaceAll("(visual/","(../series-standards/"));
fs.writeFileSync(preview,fs.readFileSync(preview,"utf8").replaceAll("../../visual/","../../../series-standards/"));
' "$shared_series"
node "$scripts/record-course-stage.mjs" "$shared_series/course" lesson-01 script-draft >/dev/null
node "$scripts/validate-course.mjs" "$shared_series/course" >/dev/null
printf '@import "../../outside.css";\n' >>"$shared_series/series-standards/style.css"
escaped_shared_css_output=$(node "$scripts/record-course-stage.mjs" "$shared_series/course" lesson-01 script-draft 2>&1 || true)
grep -Fq 'path escapes the course root' <<<"$escaped_shared_css_output"
if node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-approved >/dev/null 2>&1; then
    echo "script approval advanced without explicit approval evidence" >&2
    exit 1
fi
mv "$course/lessons/lesson-01/storyboard.md" "$fixture/storyboard.saved"
missing_approved_storyboard_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-approved \
    --approval-source "Fixture owner approved version 1" 2>&1 || true)
grep -Fq 'missing provisional storyboard: lessons/lesson-01/storyboard.md' <<<"$missing_approved_storyboard_output"
mv "$fixture/storyboard.saved" "$course/lessons/lesson-01/storyboard.md"
node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-approved \
    --approval-source "Fixture owner approved version 1" >/dev/null
mv "$course/video-style.md" "$fixture/video-style.saved"
node "$scripts/validate-course.mjs" "$course" --json >"$fixture/missing-style.json" || true
node -e '
const report=require(process.argv[1]);
if (!report.errors.some(x=>x.code==="STALE_STAGE" && x.lessonId==="lesson-01" && x.message.includes("course video style is missing or empty"))) process.exit(1);
' "$fixture/missing-style.json"
mv "$fixture/video-style.saved" "$course/video-style.md"
mv "$course/style-reference.svg" "$fixture/style-reference.saved"
node "$scripts/validate-course.mjs" "$course" --json >"$fixture/missing-style-reference.json" || true
node -e '
const report=require(process.argv[1]);
if (!report.errors.some(x=>x.code==="STALE_STAGE" && x.lessonId==="lesson-01" && x.message.includes("course video style reference is missing"))) process.exit(1);
' "$fixture/missing-style-reference.json"
mv "$fixture/style-reference.saved" "$course/style-reference.svg"
printf '\nA visual-only refinement does not change approved narration.\n' >>"$course/video-style.md"
node "$scripts/validate-course.mjs" "$course" >/dev/null
mv "$course/lessons/lesson-01/storyboard-preview.html" "$fixture/storyboard-preview.saved"
missing_approved_preview_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 script-approved \
    --approval-source "Fixture owner approved version 1" 2>&1 || true)
grep -Fq 'missing visual storyboard preview: lessons/lesson-01/storyboard-preview.html' <<<"$missing_approved_preview_output"
mv "$fixture/storyboard-preview.saved" "$course/lessons/lesson-01/storyboard-preview.html"

printf 'final audio\n' >"$course/lessons/lesson-01/narration.wav"
node "$scripts/record-course-stage.mjs" "$course" lesson-01 narration-final >/dev/null
printf '<!-- visual refinement after audio -->\n' >>"$course/lessons/lesson-01/storyboard-preview.html"

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

| Shot S01 | P01 | 00:00:00.000 --> 00:00:01.000 | Hello world. |
| Beat B01 | Hello | 00:00:00.000 --> 00:00:00.400 | Show code |
| Beat B02 | world. | 00:00:00.500 --> 00:00:01.000 | Show result |
EOF
beat_gap_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 storyboard-final 2>&1 || true)
grep -Fq 'storyboard beat ranges must be ordered and gapless' <<<"$beat_gap_output"
cat >"$course/lessons/lesson-01/storyboard.md" <<'EOF'
# Storyboard

| Shot S01 | P01 | 00:00:00.000 --> 00:00:01.000 | Hello world. |
| Beat B01 | Hello | 00:00:00.000 --> 00:00:01.100 | Show result |
EOF
beat_boundary_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 storyboard-final 2>&1 || true)
grep -Fq 'storyboard beat must stay inside its shot audio range' <<<"$beat_boundary_output"
cat >"$course/lessons/lesson-01/storyboard.md" <<'EOF'
# Storyboard

## Final timing

| Shot S01 | P01 | 00:00:00.000 --> 00:00:00.500 | Hello |
| Beat B01 | Hello | 00:00:00.000 --> 00:00:00.200 | Show code |
| Beat B02 | Hello | 00:00:00.200 --> 00:00:00.500 | Hold code |
| Shot S02 | P01 | 00:00:00.500 --> 00:00:01.000 | world. |
| Beat B03 | world. | 00:00:00.500 --> 00:00:01.000 | Show result |
EOF
node "$scripts/record-course-stage.mjs" "$course" lesson-01 storyboard-final >/dev/null
printf 'video\n' >"$course/lessons/lesson-01/video.mp4"
cat >"$course/lessons/lesson-01/captions.txt" <<'EOF'
P01-01
00:00:00.000 --> 00:00:01.000
Hello world.
EOF
missing_shot_review_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified 2>&1 || true)
grep -Fq 'missing required artifact: lessons/lesson-01/video-shot-review.md' <<<"$missing_shot_review_output"
cat >"$course/lessons/lesson-01/video-shot-review.md" <<'EOF'
# Encoded shot review

| Shot | Encoded frame checked | Result | Notes |
| --- | --- | --- | --- |
| Shot S01 | 00:00:00.250 | Pass | Code is readable; motion interval checked. |
| Shot S02 | 00:00:00.750 | Pass | Result is readable; transition checked. |
EOF
missing_video_source_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified 2>&1 || true)
grep -Fq 'missing required artifact: lessons/lesson-01/video-source.json' <<<"$missing_video_source_output"
mkdir -p "$course/lessons/lesson-01/composition"
printf '{"htmlEntries":["composition/index.html"]}\n' >"$course/lessons/lesson-01/video-source.json"
printf '<main data-shot-id="S01">Hello</main><main data-shot-id="S02">world</main>\n' >"$course/lessons/lesson-01/composition/index.html"
missing_composition_css_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified 2>&1 || true)
grep -Fq 'editable composition HTML must load only declared shared CSS' <<<"$missing_composition_css_output"
printf '<link rel="stylesheet" href="../../../visual/style.css">\n' >>"$course/lessons/lesson-01/composition/index.html"
cp "$course/lessons/lesson-01/video-shot-review.md" "$fixture/video-shot-review.saved"
sed -i 's/Shot S02/Shot S03/' "$course/lessons/lesson-01/video-shot-review.md"
wrong_shot_review_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified 2>&1 || true)
grep -Fq 'video-shot-review.md must cover storyboard shots in order' <<<"$wrong_shot_review_output"
cp "$fixture/video-shot-review.saved" "$course/lessons/lesson-01/video-shot-review.md"
sed -i 's/| Pass | Result/| Fail | Result/' "$course/lessons/lesson-01/video-shot-review.md"
failed_shot_review_output=$(node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified 2>&1 || true)
grep -Fq 'video-shot-review.md needs an encoded-frame time, Pass result, and observation' <<<"$failed_shot_review_output"
cp "$fixture/video-shot-review.saved" "$course/lessons/lesson-01/video-shot-review.md"
cat >"$course/lessons/lesson-01/captions.txt" <<'EOF'
P01-01
00:00:00.000 --> 00:00:00.800
Hello

P01-02
00:00:00.700 --> 00:00:01.000
world.
EOF
if node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified >/dev/null 2>&1; then
    echo "overlapping caption cues were incorrectly accepted" >&2
    exit 1
fi
cat >"$course/lessons/lesson-01/captions.txt" <<'EOF'
P01-01
00:00:00.000 --> 00:00:00.500
Hello
again

P01-02
00:00:00.500 --> 00:00:01.000
world.
EOF
if node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified >/dev/null 2>&1; then
    echo "two-line caption cue was incorrectly accepted" >&2
    exit 1
fi
cat >"$course/lessons/lesson-01/captions.txt" <<'EOF'
P01-01
00:00:00.000 --> 00:00:00.500
Hi

P01-02
00:00:00.500 --> 00:00:01.000
world.
EOF
node "$scripts/record-course-stage.mjs" "$course" lesson-01 video-verified >/dev/null
node "$scripts/validate-course.mjs" "$course" >/dev/null
cp "$course/lessons/lesson-01/composition/index.html" "$fixture/composition.saved.html"
printf '<!-- changed editable video source -->\n' >>"$course/lessons/lesson-01/composition/index.html"
changed_source_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'editable composition source changed: lessons/lesson-01/composition/index.html' <<<"$changed_source_output"
mv "$fixture/composition.saved.html" "$course/lessons/lesson-01/composition/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null
cp "$course/lessons/lesson-01/video-shot-review.md" "$fixture/video-shot-review.verified"
printf '\nChanged review observation.\n' >>"$course/lessons/lesson-01/video-shot-review.md"
stale_shot_review_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'video-verified: fingerprint changed: lessons/lesson-01/video-shot-review.md' <<<"$stale_shot_review_output"
cp "$fixture/video-shot-review.verified" "$course/lessons/lesson-01/video-shot-review.md"
node "$scripts/validate-course.mjs" "$course" >/dev/null
cp "$course/visual/style.css" "$fixture/style.saved.css"
printf ':root { --course-paper: ivory; }\n' >>"$course/visual/style.css"
node "$scripts/validate-course.mjs" "$course" --json >"$fixture/changed-visual.json" || true
node -e '
const report=require(process.argv[1]), lesson=report.lessons.find(x=>x.id==="lesson-01");
if (report.valid || lesson.staleStage!=="video-verified" || lesson.effectiveStatus!=="storyboard-final") process.exit(1);
if (!report.errors.some(x=>x.message.includes("visual dependency changed: visual/style.css"))) process.exit(2);
' "$fixture/changed-visual.json"
mv "$fixture/style.saved.css" "$course/visual/style.css"
cp "$course/visual/fonts/fixture.ttf" "$fixture/font.saved.ttf"
printf 'changed font bytes\n' >>"$course/visual/fonts/fixture.ttf"
node "$scripts/validate-course.mjs" "$course" --json >"$fixture/changed-font.json" || true
node -e '
const report=require(process.argv[1]), lesson=report.lessons.find(x=>x.id==="lesson-01");
if (lesson.staleStage!=="video-verified" || lesson.effectiveStatus!=="storyboard-final") process.exit(1);
if (!report.errors.some(x=>x.message.includes("visual dependency changed: visual/fonts/fixture.ttf"))) process.exit(2);
' "$fixture/changed-font.json"
mv "$fixture/font.saved.ttf" "$course/visual/fonts/fixture.ttf"
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
cp "$course/practice.md" "$course/release/practice.md"
cat >"$course/release/index.html" <<'EOF'
<!doctype html>
<img src="course-cover.png" alt="Workflow fixture course cover">
<a href="practice.md">Core practice and final task</a>
<video controls poster="lessons/lesson-01/cover.png">
  <source src="lessons/lesson-01/video.mp4" type="video/mp4">
</video>
<section data-transcript-source="lessons/lesson-01/captions.txt">Hi world.</section>
<section data-post-lesson-question="lesson-01">
  <h2>Post-lesson question</h2>
  <p>What did this lesson demonstrate?</p>
</section>
<section data-visual-descriptions="lesson-01">
  <h2>Visual descriptions</h2>
  <p>The result panel shows Hello followed by world.</p>
</section>
EOF
node "$repo_root/tests/tedtoolkit-hyperframes-tutorials/zip-fixture.mjs" "$course/release" "$course/workflow-fixture.zip"
missing_release_captions_output=$(node "$scripts/record-course-release.mjs" "$course" release workflow-fixture.zip 2>&1 || true)
if ! grep -Fq 'release does not contain current lessons/lesson-01/captions.txt' <<<"$missing_release_captions_output"; then
    echo "release without its referenced caption text was incorrectly accepted" >&2
    exit 1
fi
cp "$course/lessons/lesson-01/captions.txt" "$course/release/lessons/lesson-01/captions.txt"
node "$repo_root/tests/tedtoolkit-hyperframes-tutorials/zip-fixture.mjs" "$course/release" "$course/workflow-fixture.zip"
node "$scripts/record-course-release.mjs" "$course" release workflow-fixture.zip >/dev/null
node "$scripts/validate-course.mjs" "$course" >/dev/null
cp "$course/workflow-fixture.zip" "$fixture/release-archive.saved.zip"
mv "$course/release/practice.md" "$fixture/practice.saved"
node "$repo_root/tests/tedtoolkit-hyperframes-tutorials/zip-fixture.mjs" "$course/release" "$course/workflow-fixture.zip"
mv "$fixture/practice.saved" "$course/release/practice.md"
archive_mismatch_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_ARCHIVE: ZIP differs from release directory: missing practice.md' <<<"$archive_mismatch_output"
mv "$fixture/release-archive.saved.zip" "$course/workflow-fixture.zip"
node "$scripts/validate-course.mjs" "$course" >/dev/null
cp "$course/lessons/lesson-01/video-source.json" "$course/release/lessons/lesson-01/video-source.json"
authoring_source_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_AUTHORING_SOURCE: release contains authoring artifact: lessons/lesson-01/video-source.json' <<<"$authoring_source_output"
mv "$course/release/lessons/lesson-01/video-source.json" "$fixture/release-video-source.saved"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's#lessons/lesson-01/video.mp4#https://example.invalid/video.mp4#' "$course/release/index.html"
network_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'NETWORK_MEDIA' <<<"$network_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's/data-visual-descriptions/data-omitted-descriptions/' "$course/release/index.html"
visual_marker_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE [lesson-01]: index.html does not expose the current visual descriptions' <<<"$visual_marker_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's/data-visual-descriptions/data-omitted-descriptions/' "$course/release/index.html"
cat >>"$course/release/index.html" <<'EOF'
<!-- <section data-visual-descriptions="lesson-01">The result panel shows Hello followed by world.</section> -->
EOF
commented_marker_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE [lesson-01]: index.html does not expose the current visual descriptions' <<<"$commented_marker_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's/The result panel shows Hello followed by world./Different visual claim./' "$course/release/index.html"
visual_text_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE [lesson-01]: index.html does not expose the current visual descriptions' <<<"$visual_text_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i 's/The result panel shows Hello followed by world./Different visual claim.<!-- The result panel shows Hello followed by world. -->/' "$course/release/index.html"
hidden_visual_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE [lesson-01]: index.html does not expose the current visual descriptions' <<<"$hidden_visual_output"
cp "$fixture/index.saved" "$course/release/index.html"
node "$scripts/validate-course.mjs" "$course" >/dev/null

cp "$course/release/index.html" "$fixture/index.saved"
sed -i '/href="practice.md"/d' "$course/release/index.html"
practice_link_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'RELEASE_COVERAGE: index.html does not reference current learner document practice.md' <<<"$practice_link_output"
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

cp "$course/lessons/lesson-01/lesson-outline.md" "$fixture/outline.saved"
printf '# Changed lesson outline\n' >"$course/lessons/lesson-01/lesson-outline.md"
stale_outline_output=$(node "$scripts/validate-course.mjs" "$course" 2>&1 || true)
grep -Fq 'outline-draft: fingerprint changed: lessons/lesson-01/lesson-outline.md' <<<"$stale_outline_output"
grep -Fq 'STALE_RELEASE' <<<"$stale_outline_output"
cp "$fixture/outline.saved" "$course/lessons/lesson-01/lesson-outline.md"
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
if (Object.keys(lesson.records).some((key) => !["outline-draft", "outline-approved", "script-draft"].includes(key))) process.exit(2);
if (state.release.status !== "not-packaged") process.exit(3);
' "$course/course-state.json"
node "$scripts/validate-course.mjs" "$course" >/dev/null

legacy="$fixture/legacy-course"
cp -a "$course" "$legacy"
node -e '
const fs=require("fs"), file=process.argv[1], state=JSON.parse(fs.readFileSync(file,"utf8"));
const lesson=state.lessons[0];
delete lesson.records["outline-draft"];
delete lesson.records["outline-approved"];
delete lesson.records["script-draft"].fingerprints["lessons/lesson-01/lesson-outline.md"];
fs.writeFileSync(file, JSON.stringify(state,null,2)+"\n");
' "$legacy/course-state.json"
rm "$legacy/lessons/lesson-01/lesson-outline.md"
node "$scripts/validate-course.mjs" "$legacy" >/dev/null
node "$scripts/record-course-stage.mjs" "$legacy" lesson-01 script-draft >/dev/null
node "$scripts/validate-course.mjs" "$legacy" >/dev/null

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
