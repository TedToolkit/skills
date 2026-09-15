---
name: research-company-role
description: >-
  Research one identified role at one identified company for a job candidate and create or update a
  dated, attributable Markdown role dossier. Use for normalizing a job posting, responsibilities,
  qualifications, and operating context before matching or resume writing. Do not use for generic
  occupations, candidate facts, final resume copy, or employer-side candidate assessment.
---

# Research Company Role

Build the target contract that candidate matching and final resume writing consume. Read
[career-integrity.md](../../references/career-integrity.md),
[career-profile-schema.md](../../references/career-profile-schema.md), and
[target-research-schema.md](../../references/target-research-schema.md) before researching or
writing.

This skill solely owns `applications/<company-id>/<role-id>/role.md`. It may use the corresponding
company dossier as context but emits no candidate facts, match, resume, review, or interview
artifact.

## Require company and role identity

Require one identified company and one identified role. A title alone, a generic occupation, an
unattributed list of requirements, or company information without a role does not establish the
target. Resolve namesakes and duplicate postings using supplied URL, requisition ID, location,
business unit, or posting text. If either identity remains ambiguous, ask one focused question and
do not write.

Identify the selected candidate-workspace root and canonical role path. An explicit request to
create that absent record authorizes only that destination; inspect an existing record and require
overwrite/update authority before changing it.

## Research and normalize requirements

For a live target, browse current sources because postings and requirements change. Prefer the
employer's official posting and careers site, then authoritative mirrors or supplied recruiter
material. A supplied dated fixture or snapshot is sufficient for an offline task when its date and
limitations remain explicit.

Separate responsibilities, required qualifications, preferred qualifications, domain context, and
operating constraints. Preserve priority signals and source wording where exact terminology matters,
but do not promote generic boilerplate. Mark ambiguous, contradictory, removed, inaccessible, or
stale requirements as such. Record each source's URL or description, retrieval date, owner,
confidence, direct support versus inference, and limitation. Never invent a requirement from the
company dossier or from common expectations for the title.

Exclude protected-trait and other non-job-related criteria from candidate matching under the shared
integrity rules while preserving enough source context to explain the exclusion. Do not make legal
conclusions without current authoritative local guidance.

## Write and hand off

For planning or conversational research, return a source-linked dossier without writing. For an
authorized workspace write, create or update only
`<selected-root>/applications/<company-id>/<role-id>/role.md` using the shared schema. Never copy
role requirements into `profile.md`, `work/`, or the company record.

Re-read the dossier and verify both identities, requirement attribution, retrieval dates, source
ownership, confidence, inference labels, contradictions, unknowns, and freshness. Report the exact
path and whether it is ready for `match-job-description`; route missing target evidence back to
research rather than allowing final resume copy.
