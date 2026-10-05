#!/usr/bin/env bash
set -euo pipefail

repo_root=${1:-}
if [[ -z $repo_root ]]; then
    repo_root=$(git rev-parse --show-toplevel)
fi
repo_root=$(cd "$repo_root" && pwd -P)
validator="$repo_root/plugins/tedtoolkit-hyperframes-tutorials/scripts/validate-series.mjs"
course_skill="$repo_root/plugins/tedtoolkit-hyperframes-tutorials/skills/plan-tutorial-course/SKILL.md"
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT

series="$fixture/series"
mkdir -p "$series/course-briefs" "$series/01-core"
printf '# Series charter\n' >"$series/README.md"
printf '# Core brief\n' >"$series/course-briefs/01-core.md"
printf '# Lighting brief\n' >"$series/course-briefs/02-lighting.md"
printf '# Soil brief\n' >"$series/course-briefs/03-soil.md"
printf '# Greenhouse brief\n' >"$series/course-briefs/04-greenhouse.md"
cat >"$series/01-core/course.config.json" <<'EOF'
{
  "courseId": "01-core",
  "title": "Core",
  "slug": "core",
  "contentLanguage": "en",
  "outline": "course-outline.md"
}
EOF
cat >"$series/course-series.json" <<'EOF'
{
  "formatVersion": 1,
  "seriesId": "workflow-series",
  "title": "Workflow series",
  "contentLanguage": "en",
  "charter": "README.md",
  "outcomes": [
    { "id": "SO-01", "tier": "graduation", "description": "Complete the baseline route." },
    { "id": "SO-02", "tier": "extension", "description": "Compare lighting choices using observations." },
    { "id": "SO-03", "tier": "extension", "description": "Measure soil and watering conditions." },
    { "id": "SO-04", "tier": "extension", "description": "Plan protected growing from observed conditions." }
  ],
  "courses": [
    {
      "id": "01-core",
      "title": "Core",
      "tier": "graduation",
      "path": "01-core",
      "brief": "course-briefs/01-core.md",
      "requires": [],
      "outcomes": ["SO-01"]
    },
    {
      "id": "02-lighting",
      "title": "Lighting choices",
      "tier": "extension",
      "path": "02-lighting",
      "brief": "course-briefs/02-lighting.md",
      "requires": [
        { "courseId": "01-core", "capability": "A documented balcony-garden baseline." }
      ],
      "outcomes": ["SO-02"]
    },
    {
      "id": "03-soil",
      "title": "Soil and watering",
      "tier": "extension",
      "path": "03-soil",
      "brief": "course-briefs/03-soil.md",
      "requires": [
        { "courseId": "01-core", "capability": "A repeatable plant-observation routine." }
      ],
      "outcomes": ["SO-03"]
    },
    {
      "id": "04-greenhouse",
      "title": "Greenhouse planning",
      "tier": "extension",
      "path": "04-greenhouse",
      "brief": "course-briefs/04-greenhouse.md",
      "requires": [
        { "courseId": "02-lighting", "capability": "A method for comparing lighting arrangements." },
        { "courseId": "03-soil", "capability": "Soil and watering measurements." }
      ],
      "outcomes": ["SO-04"]
    }
  ],
  "cases": [
    {
      "id": "case-main",
      "title": "Balcony planters",
      "purpose": "Carry one garden through new conditions.",
      "courses": ["01-core", "02-lighting", "03-soil", "04-greenhouse"]
    }
  ],
  "releaseWaves": [
    { "id": "wave-1", "courses": ["01-core"] },
    { "id": "wave-2", "courses": ["02-lighting", "03-soil"] },
    { "id": "wave-3", "courses": ["04-greenhouse"] }
  ]
}
EOF

node "$validator" "$series" --json >"$fixture/series-valid.json"
node -e '
const report=require(process.argv[1]);
if (!report.valid) process.exit(1);
const expected=JSON.stringify([["01-core"],["02-lighting","03-soil"],["04-greenhouse"]]);
if (JSON.stringify(report.learningWaves) !== expected) process.exit(2);
' "$fixture/series-valid.json"

cp "$series/course-series.json" "$fixture/course-series.saved"
node -e '
const fs=require("fs"), file=process.argv[1], series=JSON.parse(fs.readFileSync(file,"utf8"));
series.courses[0].requires=[{courseId:"02-lighting",capability:"An advanced course."}];
fs.writeFileSync(file,JSON.stringify(series,null,2)+"\n");
' "$series/course-series.json"
graduation_dependency_output=$(node "$validator" "$series" 2>&1 || true)
grep -Fq 'GRADUATION_DEPENDS_ON_EXTENSION' <<<"$graduation_dependency_output"
grep -Fq 'COURSE_DEPENDENCY_CYCLE' <<<"$graduation_dependency_output"
cp "$fixture/course-series.saved" "$series/course-series.json"

node -e '
const fs=require("fs"), file=process.argv[1], series=JSON.parse(fs.readFileSync(file,"utf8"));
series.releaseWaves=[
  {id:"wave-1",courses:["04-greenhouse"]},
  {id:"wave-2",courses:["01-core","02-lighting","03-soil"]}
];
fs.writeFileSync(file,JSON.stringify(series,null,2)+"\n");
' "$series/course-series.json"
release_dependency_output=$(node "$validator" "$series" 2>&1 || true)
grep -Fq 'RELEASE_BEFORE_PREREQUISITE' <<<"$release_dependency_output"
cp "$fixture/course-series.saved" "$series/course-series.json"
node "$validator" "$series" >/dev/null

grep -Fq 'optional outcome must be reachable through its named Extension route.' "$course_skill"
grep -Fiq 'required outcome that exists only in Extension lessons' "$course_skill"
grep -Fiq 'optional outcome that has no complete Extension route' "$course_skill"

outside="$fixture/outside"
mkdir -p "$outside"
printf '# Escaped brief\n' >"$outside/escaped.md"
if ln -s "$outside/escaped.md" "$series/course-briefs/escaped.md" 2>/dev/null; then
    node -e '
const fs=require("fs"), file=process.argv[1], series=JSON.parse(fs.readFileSync(file,"utf8"));
series.courses[1].brief="course-briefs/escaped.md";
fs.writeFileSync(file,JSON.stringify(series,null,2)+"\n");
' "$series/course-series.json"
    symlink_escape_output=$(node "$validator" "$series" 2>&1 || true)
    grep -Fq 'UNSAFE_PATH' <<<"$symlink_escape_output"
    grep -Fq 'escapes the series root through a symbolic link' <<<"$symlink_escape_output"
    cp "$fixture/course-series.saved" "$series/course-series.json"
fi

echo "OK: tutorial series workflow regressions passed"
