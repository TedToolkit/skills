#!/usr/bin/env bash
set -euo pipefail

scenario="${1:-}"
if [[ "$scenario" != "current-course" ]]; then
  echo "unknown scenario: $scenario" >&2
  exit 2
fi

mkdir -p assets/iconography/light

cat > course.config.json <<'JSON'
{
  "courseId": "evidence-first-csharp",
  "slug": "evidence-first-csharp",
  "title": "从证据到可靠的 C# 程序",
  "contentLanguage": "zh-CN",
  "outline": "course-outline.md"
}
JSON

cat > course-outline.md <<'MARKDOWN'
# 从证据到可靠的 C# 程序

## Audience

已有一般编程经验、正在学习 C# 工程实践的开发者。

## Observable course outcome

学员能够用可复现的证据定位失败，并交付一个具有明确边界和验证结果的无界面 C# 程序。
MARKDOWN

cat > video-style.md <<'MARKDOWN'
# Video style

Use a light visual frame, restrained blue and amber accents, and the local line icon family.
MARKDOWN

cat > assets/iconography/README.md <<'MARKDOWN'
# Course iconography

The light SVG set is the established course visual identity and should be reused before generating
new illustration.
MARKDOWN

cat > assets/iconography/light/evidence-loop.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <circle cx="32" cy="32" r="24" fill="none" stroke="#2563eb" stroke-width="4"/>
  <path d="M20 33l8 8 17-19" fill="none" stroke="#d97706" stroke-width="5"/>
</svg>
SVG
