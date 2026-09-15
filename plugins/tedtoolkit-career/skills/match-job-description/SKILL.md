---
name: match-job-description
description: >-
  Compare supplied candidate evidence with requirements attributable to one identified role at one
  identified company and return an evidence matrix without rewriting career materials. Use for
  company-role fit analysis, requirement coverage, evidence gaps, or truthful terminology
  opportunities. Do not use for target research, final resume copy, intrinsic resume critique,
  interview preparation, or employer-side candidate assessment.
---

# Match Job Description

Compare requirements with demonstrated evidence, not with assumptions. Read
[career-integrity.md](../../references/career-integrity.md) first. When a local career workspace is
supplied, read [career-profile-schema.md](../../references/career-profile-schema.md) and
[target-research-schema.md](../../references/target-research-schema.md) before using it.

This skill solely owns `# Job Match`. It may consume supporting analysis but emits no resume copy,
career-profile update, target-research record, `# Resume Review`, or `# Interview Preparation` unless
separately requested. Apply the shared artifact and legal-source gates to any requested destination
or jurisdiction-dependent conclusion.

Require candidate evidence plus requirements attributable to one identified company and one
identified role. A canonical `role.md` satisfies the target side; an equivalent supplied dossier or
job posting is sufficient only when it identifies both and preserves attribution. When candidate
evidence is absent, return `Cannot assess: candidate evidence missing`. When the company, role, or
attributable requirements are absent, return `Cannot assess: company-role target missing`, route to
`research-company-role`, and stop without producing a fit rating.

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

When persisting inside a candidate workspace, write only the explicitly authorized canonical
`applications/<company-id>/<role-id>/match.md`; do not alter `role.md` or candidate evidence.

For a tailored rewrite, route to `write-resume`; the final-copy request belongs there after the
company-role gate is satisfied. Route candidate practice to `prepare-for-interview`. Interviewer
planning belongs to `tedtoolkit-hiring/design-interview`; do not turn this evidence matrix into
either interview artifact.
