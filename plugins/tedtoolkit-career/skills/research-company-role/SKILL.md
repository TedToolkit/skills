---
name: research-company-role
description: >-
  Research one identified role at one identified company for a job candidate and create or update a
  dated, attributable Markdown role dossier with an evidence-linked capability analysis. Use for
  normalizing a job posting, responsibilities, expected work and success context, qualifications,
  operating context, transferable capability groups, interview process evidence, publicly reported
  interview or written-assessment questions, and potentially valuable or emerging capabilities
  before matching, interview preparation, or resume writing. Do not use for generic occupations,
  candidate facts, final resume copy, generated practice-question packs, or employer-side candidate
  assessment.
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

## Research, normalize, and analyze capabilities

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

Explain the capability synthesis in an inspectable form: state each conclusion, the cited signals,
why those signals matter to this role, confidence, and material limitations. Provide this concise
rationale instead of hidden chain-of-thought or an unsupported list of skills.

Abstract concrete tools, tasks, and constraints into a small number of transferable capability
groups when that helps a candidate understand the work. Retain the mapping back to exact posting
terms so an abstraction never hides a specific technology, credential, or priority. Keep these
relationships distinct:

- **Required or preferred:** explicitly stated by the role source, preserving its priority.
- **Responsibility-derived:** a capability needed to perform a stated responsibility, labeled as an
  inference rather than an explicit qualification.
- **Potentially valuable:** an adjacent or differentiating capability supported by company, role,
  or domain evidence but not stated as a requirement.
- **Recently emerging:** a dated change signal that may alter how the work is performed. Treat this
  as a timing tag on a responsibility-derived or potentially valuable capability, never as proof
  that the employer requires it.

For a live target, look for relevant recent signals in dated employer strategy, product,
engineering, and adjacent-role sources, supplemented when useful by authoritative domain sources.
State the time window used and why the signal is relevant. A sibling role, general market trend, or
single company update is contextual evidence, not this role's requirement; preserve that limitation.
If no credible recent or additional signal exists, say so rather than filling the dossier with
generic title expectations. Avoid vague capability labels such as “communication” or “AI skills”
unless the evidence supports the concrete behavior and role value being claimed.

## Research expected work and success context

Turn attributable responsibilities and operating evidence into a practical, source-bounded view of
what the person is expected to do after joining. When evidence supports it, record:

- recurring work, concrete deliverables, and ownership boundaries;
- collaboration interfaces, role-specific reporting or decision dependencies, and relevant
  customer or stakeholder contact;
- operating cadence and conditions such as release cycles, on-call or incident response, shifts,
  travel, time-zone overlap, and hybrid or site expectations;
- stated success measures, performance expectations, or progression criteria; and
- onboarding, probation, or early-tenure expectations, including 30/60/90-day outcomes only when a
  source actually states them.

Distinguish direct role evidence, attributable employee or candidate reports, and labeled
inference. A plausible consequence of a responsibility may be recorded as a likely work implication,
but not as an observed routine, guaranteed condition, or employer requirement. Preserve team,
location, seniority, and time scope. Keep company-wide management practices in the company dossier;
include them here only when evidence shows how they affect this role. Do not manufacture a generic
“day in the life,” onboarding plan, success metric, or career path from the title. Record material
gaps explicitly so a candidate can see what still needs to be asked during interviews.

## Research interview and assessment evidence broadly

For a live target, actively search for publicly available evidence about this company-role's
interview process, interview questions, take-home exercises, online assessments, and written-test
questions. Maximize useful coverage rather than stopping after the first source or an arbitrary
question count. Vary queries across the company name, role-title aliases, seniority, business unit,
location, interview stage, assessment type, and material technologies; search in relevant local
languages as well as the posting language. Check official candidate guidance first, then public
candidate reports, interview-experience sites, job communities, and other attributable sources.
Continue until additional query variants and result pages stop yielding new relevant question
families, or record the concrete access, time, or evidence limitation that ended the search.

Retain as many distinct, role-relevant prompts and tasks as the public evidence supports. Deduplicate
exact and near-duplicate questions, but do not collapse meaningfully different variants merely to
keep the dossier short. Group them by interview stage and topic when known. For every item or
clearly sourced group, preserve the source marker, report or publication date when available,
retrieval date, company-role match, location or team scope when available, and confidence. Keep
these evidence classes explicit:

- **Official sample:** published by the employer as current candidate guidance or an example; do
  not imply that the exact item will be used.
- **Candidate-reported:** publicly recalled by a candidate; treat it as a historical individual
  report, not a verified current question bank.
- **Inferred topic only:** supported by the role or process evidence but not reported as an actual
  question. Record the topic and rationale, never fabricate question wording or count it as a
  found question.

Separate interview questions from written, take-home, coding, and online-assessment tasks. Note
recurrence only when independent reports support it, and retain conflicting process accounts and
date, geography, seniority, sample-size, self-selection, and staleness limitations. Do not bypass
access controls, seek private or leaked assessment material, reproduce proprietary test banks, or
turn generic title-based question lists into company-specific evidence. Paraphrase lengthy source
material while preserving the skill or decision being tested. Generated practice questions belong
to `prepare-for-interview`, which may consume this evidence but must not be silently emitted here.

Exclude protected-trait and other non-job-related criteria from candidate matching under the shared
integrity rules while preserving enough source context to explain the exclusion. Do not make legal
conclusions without current authoritative local guidance.

## Write and hand off

For planning or conversational research, return a source-linked dossier without writing. For an
authorized workspace write, create or update only
`<selected-root>/applications/<company-id>/<role-id>/role.md` using the shared schema. Never copy
role requirements into `profile.md`, `work/`, or the company record.

Re-read the dossier and verify both identities, requirement attribution, retrieval dates, source
ownership, confidence, inference labels, capability-to-signal mappings, separation of published
requirements from potentially valuable capabilities, work-context evidence boundaries, explicit
unknowns about actual work or success, interview-question evidence classes, deduplication, search
coverage and stopping limitations, contradictions, and freshness. Report the exact path and whether
it is ready for `match-job-description` and `prepare-for-interview`; route missing target evidence
back to research rather than allowing final resume copy.
