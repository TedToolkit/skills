---
name: review-resume
description: >-
  Audit an existing resume and return findings without rewriting it. Use for feedback, critique,
  grading, intrinsic ATS-readability review, credibility issues, comparison with a supplied career
  profile, or a prioritized improvement list. Do not use when the deliverable is revised resume
  copy, a requirement-by-requirement comparison with a job description, or interview materials.
---

# Review Resume

Review how well claims are supported by the text actually present; do not treat a candidate-authored
assertion or career-profile entry as independently verified. Read
[career-integrity.md](../../references/career-integrity.md) before evaluating.

This skill solely owns `# Resume Review`. It may consume supporting analysis but emits no rewritten
resume, career-profile update, `# Job Match`, `# Interview Preparation`, or `# Interview Plan` unless
separately requested. Apply the shared artifact and legal-source gates to any requested destination
or jurisdiction-dependent conclusion.

## Set the review frame

Identify the resume's intended role, seniority, locale, and audience when known. A review without a
job description assesses intrinsic quality; label role fit `Not assessed` rather than guessing. If
the primary request is requirement-by-requirement role fit and both artifacts are supplied, route to
`match-job-description`. Route requests for edited copy to `write-resume`.
Route requests to record or correct the underlying career history to `maintain-career-profile`.

When a local career profile is supplied as review evidence, read
[career-profile-schema.md](../../references/career-profile-schema.md). Use relevant records and
their inline provenance where present to check factual alignment and identify important supported
evidence omitted from the resume. Do not treat profile content as independently verified or read
unrelated private data.

If extraction or formatting obscures text, state the limitation and apply the shared integrity
rules to every claim.

## Audit the resume

Inspect:

- factual clarity, chronology, scope, and internal consistency;
- consistency with supplied career-profile evidence and material supported omissions;
- evidence of ownership, action, scale, and outcomes;
- relevance and prioritization for the stated target;
- whether every retained project visibly supports a material target requirement or differentiator;
- whether project outcomes use measured, delivered, reused, regression-proven, or bounded-state
  evidence instead of implementation-only claims;
- whether the first pass works for a recruiter and the same bullets contain enough proof for a
  technical reader;
- whether an evidence-backed technical signature makes the candidate distinctive without generic
  personality adjectives or slogans;
- repository-context leakage: bullets that depend on private project names, file paths, class or
  method names, issue numbers, or unexplained internal architecture before the reader can understand
  the engineering problem and result;
- whether each technical bullet can be paraphrased by an unfamiliar recruiter as “what was improved”
  and by an engineer as “how and under what constraint” without reading the source repository;
- duplication, vagueness, jargon, unsupported superlatives, and keyword stuffing;
- section hierarchy, length, scanability, grammar, tense, and locale consistency;
- parsing risks such as information conveyed only through graphics or complex layout.

## Report findings

Use this stable shape:

```md
# Resume Review
## Review frame
## Factual or credibility risks
## Positioning and evidence gaps
## Clarity and structure
## Copyediting and formatting
## Prioritized actions
```

Lead with the highest-impact findings. For each finding, cite the affected section or a short exact
excerpt, explain the consequence, and give a concrete correction direction. Mask contact details,
addresses, identifiers, compensation, references, and other sensitive values as `[redacted]`; cite
only the field label when its value is unnecessary. Separate:

1. factual or credibility risks;
2. positioning and evidence gaps;
3. clarity and structure issues;
4. copyediting and formatting polish.

If the user requests a score, define a transparent rubric, score each dimension separately, and
show the evidence under the shared scoring rules. Finish with the smallest prioritized action list
that would materially improve the resume. Do not rewrite the full document; route that deliverable
to `write-resume` and apply its artifact gate.
