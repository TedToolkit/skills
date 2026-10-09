---
name: design-tutorial-visual-system
description: >-
  Design, review, or revise the shared visual system for a multi-course animated tutorial series.
  Use when courses need one recognizable video identity, reusable visual assets, consistent motion
  and evidence treatment, or explicit rules for course-specific variation. Do not use for curriculum
  boundaries, one lesson's storyboard or render, or final course and lesson covers.
---

# Design Tutorial Visual System

Establish one visual grammar that authors can apply across courses without making unlike lessons
look identical. Own the series-level visual contract and its reusable authoring assets. Let
`design-tutorial` own each course's `video-style.md` and lesson previews; let
`create-tutorial-cover` adapt the established identity to publication covers.

Read the [tutorial series contract](../../references/tutorial-series-contract.md) for series
boundaries, the [tutorial video style contract](../../references/tutorial-video-style.md) for
inheritance, assets, motion, and review, and the
[tutorial workspace contract](../../references/tutorial-workspace-layout.md) for artifact ownership.
Resolve these links relative to this `SKILL.md`; a missing linked resource is a stop condition.

## Establish scope and authorization

Find the selected series root from the user's path or current workspace. Inspect its README,
`course-series.json` and course briefs when present, existing style and cover contracts, shared
assets, and representative lessons or media. If the series has no formal plan, use only the
available audience, subject, and course evidence; do not invent a curriculum or production state.
Identify existing brand constraints, media types, viewing context, and any courses whose established
visuals would be affected. Ask only for a choice that materially changes the direction and cannot
be inferred or reasonably selected from this evidence.

For a read-only request, report the current visual rules, gaps, affected courses, and a concrete
recommended direction without writing files or making previews. A direct request to create or
revise this series visual system authorizes its draft contract and reusable local assets, including
representative specimens. It does not authorize changing course plans, lesson scripts, approval
records, videos, or covers. Include a course `video-style.md` only when that course is explicitly
within the requested scope. Do not publish or upload assets without separate authorization.

## Design the shared direction

Before writing an open-ended new direction, show a compact proposal with the recognizable series
identity, teaching and evidence treatments, motion functions, and the parts that may vary by
course. Where the user has not delegated the aesthetic choice, show a small number of meaningfully
different directions with viewable specimens and let the user select one before establishing the
shared assets. Keep candidate specimens outside canonical asset paths. If they delegated that
choice, select a direction and explain its fit.

Create or revise one linked series visual file outside the learner-facing README, such as
`series-standards/visual-system.md`. Specify reusable rules by purpose and use, including semantic
color and non-color cues, type roles, diagram and media treatment, source-evidence labeling,
motion continuity, subtitle appearance and safe area, and allowed course variation. Include only
elements the series actually needs; give authors room to choose each lesson's composition. Keep
dimensions and codecs in the production contract, and keep exact lesson content in its source or
storyboard.

Maintain the reusable CSS and HTML example in `series-standards/` under the shared style contract.
The example must load the declared CSS and demonstrate the recurring grammar with representative
content, including subtitle specimens over representative backgrounds at the intended player size.
Keep font files and their source and redistribution terms together when fonts are bundled.
For visual structures that recur across courses, define small semantic markup patterns or reusable
render components when the composition tooling supports them. Show their use in the HTML example;
keep shared styling in CSS and keep lesson content and shot-specific animation in the lesson. Avoid
copying a full example page into every scene or forcing unrelated explanations through one template.
For recurring roles, states, or routes, define meaningful non-color shape cues (such as outlines,
edges, gaps, or connections); keep color from carrying meaning alone. Give the same role consistent
proportions, spacing, and minimum size at player scale, while allowing content to grow. Put repeated
geometry in shared CSS and its HTML example; do not impose one project's shape mapping on another.
Link a few specimens that prove the rules, including a short moving specimen when motion is part of
the identity or teaching meaning. Mark concepts and provisional previews as such; do not present
them as verified lesson frames. Link the visual file from the series README without copying its
rules into learner-facing prose. If no series README exists, report the pending link rather than
creating a curriculum charter as part of visual work.

For requested course styles, link the series contract and shared assets from each course's
`video-style.md`, then state that course's identity, allowed variations, and explicit exceptions.
Do not duplicate series CSS or rules in course directories. `design-tutorial` tests those choices
against the first real lesson preview and adjusts the owning contract if the result exposes a gap.

## Verify and hand off

Open the HTML example and specimens locally. Check actual font glyphs and weights, hierarchy and
readability at the intended player size, evidence labels, and motion at normal speed. Compare
subtitle contrast and clearance over unlike scenes with native player controls visible. Compare
representative situations from different courses when available. Confirm that course variation
remains recognizable as one series and that no shared rule forces an inaccurate demonstration.
Compare rendered instances of recurring shapes: differences should express a declared role or
state, and the same role should stay consistent. Confirm that course previews load and visibly use
the shared CSS; valid paths or class names alone prove neither.
Check Markdown links, CSS imports, fonts, and relative asset paths. A structural validator cannot
certify visual quality.

When revising a system used by produced courses, identify affected previews, videos, and covers;
review them under the [style contract](../../references/tutorial-video-style.md) and hand necessary
rechecks or rebuilds to their owning lesson and cover skills. A visual-only change does not require
new narration. Report the chosen rules, assets, specimens inspected, affected courses, and any
remaining visual decision.
