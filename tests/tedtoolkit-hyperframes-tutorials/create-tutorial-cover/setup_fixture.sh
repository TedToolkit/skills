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
  "courseId": "balcony-garden",
  "slug": "balcony-garden",
  "title": "从观察到健康的阳台花园",
  "contentLanguage": "zh-CN",
  "outline": "course-outline.md"
}
JSON

cat > course-outline.md <<'MARKDOWN'
# 从观察到健康的阳台花园

## Audience

想在阳台种植植物、尚不熟悉光照和浇水判断的新手。

## Observable course outcome

学员能够观察阳台环境与植物状态，制定四周养护计划，并根据记录调整浇水和光照。
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
