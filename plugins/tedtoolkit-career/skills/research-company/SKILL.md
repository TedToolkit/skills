---
name: research-company
description: >-
  Research one identified target company for a job candidate and create or update an attributable,
  dated Markdown company dossier. Use for understanding a prospective employer's identity,
  products, customers, engineering context, and candidate-relevant unknowns. Do not use for role
  requirements, candidate facts, job matching, resume copy, or employer-side candidate assessment.
---

# Research Company

Build a current, source-bounded target-company record for one candidate workspace. Read
[career-integrity.md](../../references/career-integrity.md),
[career-profile-schema.md](../../references/career-profile-schema.md), and
[target-research-schema.md](../../references/target-research-schema.md) before researching or
writing.

This skill solely owns `companies/<company-id>/company.md`. It emits no role dossier, candidate
profile fact, match, resume, review, or interview artifact.

## Bound the target

Require one unambiguous company identity. Resolve namesakes using supplied official domains,
locations, products, or legal names. If ambiguity could mix organizations, ask one focused question
and do not research or write. Identify the selected candidate-workspace root and canonical company
path. An explicit request to create that absent record authorizes only that destination; inspect an
existing record and require overwrite/update authority before changing it.

## Research current facts

For real-world research, browse current sources because company information can change. Prefer the
company's official site, official reports, engineering publications, and authoritative registries;
use credible independent sources to supplement or challenge them. When the user supplies dated
fixtures or snapshots for an offline task, use those sources and preserve their date and limitation
without requiring live access.

Collect only facts that can improve a candidate's understanding of the target: identity, products
or services, customers or users, business and engineering context, public technology or operating
constraints, and material recent changes. Do not browse for employees' personal information,
invent culture claims, or infer what an unstated role requires.

For each material fact, record its source marker. Distinguish direct support from labeled inference,
assign confidence, and preserve contradictions and unknowns. If a source is unavailable, record the
gap; do not reconstruct it from memory. Do not store webpage copies.

## Write and verify

For planning or conversational research, return a source-linked dossier without writing. For an
authorized workspace write, create or update only
`<selected-root>/companies/<company-id>/company.md` using the shared schema. Never add company facts
to `profile.md`, `work/`, or another career-history record.

Re-read the result and verify company identity, retrieval dates, source ownership, confidence,
inference labels, contradictions, unknowns, and that every claim is attributable. Report the exact
path and freshness limitations.
