---
name: match-job-description
description: >-
  Compare supplied candidate evidence with a supplied job description and return an evidence matrix
  for each material requirement without rewriting the resume. Use for role-fit analysis, requirement
  coverage, evidence gaps, or truthful terminology opportunities when both sides are available. Do
  not use for final resume copy, intrinsic resume critique, or interview-question packs.
---

# Match Job Description

Compare requirements with demonstrated evidence, not with assumptions. Read
[resume-integrity.md](../../references/resume-integrity.md) first.

Require both candidate evidence and a job description. When either side is absent, return
`Cannot assess: candidate evidence missing` or `Cannot assess: job description missing`, ask for the
missing source, and stop without producing a fit rating.

## Parse the role

Separate the job description into responsibilities, required qualifications, preferred
qualifications, domain context, and stated constraints. Preserve the employer's priority signals;
do not promote generic boilerplate above repeated or outcome-bearing requirements.

Flag ambiguous, contradictory, or potentially inflated requirements rather than silently resolving
them. Apply the shared privacy and fairness rules when deciding which requirements may be assessed.
Label a protected-trait or otherwise non-job-related requirement `Excluded as non-job-related` and
do not use it in fit scoring or a hiring recommendation.

## Map evidence

For each material requirement, cite the strongest resume evidence and classify it as:

- **Supported:** direct, credible evidence is present.
- **Partial:** adjacent evidence exists but scope or recency is unclear.
- **Not demonstrated:** use the shared integrity definition.
- **Not assessable:** the requirement or source material is too ambiguous.
- **Excluded as non-job-related:** the requirement is outside a fair job-related assessment.

Assign confidence based on the clarity of both sources. Treat a claimed equivalence between tools or
domains as evidence only when the supplied sources establish it.

## Deliver the comparison

Present this stable shape:

```md
# Job Match
## Role priorities
## Evidence matrix
## Strongest alignment
## Consequential gaps
## Truthful terminology opportunities
## Fit narrative and limitations
```

The evidence matrix uses only `Supported`, `Partial`, `Not demonstrated`, `Not assessable`, or
`Excluded as non-job-related` and
includes requirement, priority, cited evidence, and confidence. Then present:

1. a short role summary and the highest-priority requirements;
2. an evidence matrix with requirement, priority, status, cited evidence, and confidence;
3. the strongest aligned themes;
4. the most consequential evidence gaps and focused questions for the candidate;
5. truthful terminology or content that could be surfaced more clearly;
6. an overall fit narrative with limitations, not a false-precision hiring prediction.

If the user wants a numerical score, disclose the weighting and calculate it only from the evidence
matrix. Do not let repeated keywords outweigh required capabilities.

For a tailored rewrite, route to `write-resume`; the final-copy request belongs there even when a job
description is supplied. For interview coverage, route to `generate-interview-questions`; do not
turn the evidence matrix itself into an interview pack.
