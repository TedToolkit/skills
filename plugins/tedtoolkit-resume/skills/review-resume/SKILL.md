---
name: review-resume
description: >-
  Audit an existing resume and return findings without rewriting it. Use for feedback, critique,
  grading, intrinsic ATS-readability review, credibility issues, or a prioritized improvement list.
  Do not use when the deliverable is revised resume copy, a requirement-by-requirement comparison
  with a job description, or interview questions.
---

# Review Resume

Review how well claims are supported by the text actually present; do not treat a candidate-authored
assertion as independently verified. Read
[resume-integrity.md](../../references/resume-integrity.md) before evaluating.

## Set the review frame

Identify the resume's intended role, seniority, locale, and audience when known. A review without a
job description assesses intrinsic quality; label role fit `Not assessed` rather than guessing. If
the primary request is requirement-by-requirement role fit and both artifacts are supplied, route to
`match-job-description`. Route requests for edited copy to `write-resume`.

If extraction or formatting obscures text, state the limitation and apply the shared integrity
rules to every claim.

## Audit the resume

Inspect:

- factual clarity, chronology, scope, and internal consistency;
- evidence of ownership, action, scale, and outcomes;
- relevance and prioritization for the stated target;
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
