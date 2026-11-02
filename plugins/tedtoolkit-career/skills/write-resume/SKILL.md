---
name: write-resume
description: >-
  Create or revise final resume copy in Markdown for one identified role at one identified company.
  Use when the requested deliverable is a new, tailored, shortened, translated, or restructured
  targeted resume backed by candidate evidence and attributable company-role requirements. Do not
  use for general or role-only resumes, target research, profile maintenance, feedback-only review,
  comparison without rewritten copy, or interview preparation. Produces Markdown, not PDF or DOCX.
---

# Write Resume

Create a resume that covers the candidate's supported capabilities and projects, makes target fit
clear, and keeps every claim defensible. Read
[career-integrity.md](../../references/career-integrity.md) and
[resume-standard.md](references/resume-standard.md). When a workspace or target dossier is supplied,
also read [career-profile-schema.md](../../references/career-profile-schema.md) and
[target-research-schema.md](../../references/target-research-schema.md). Use
[resume-template.md](assets/resume-template.md) as a flexible starting point.

This skill solely owns final resume copy. Emit no career-profile update, `# Resume Review`,
`# Job Match` or `# Interview Preparation` unless the user separately requested
that deliverable; apply the shared conversation, file, and legal-source gates exactly once.

## Establish the assignment

Choose `Create` or `Revise`. Require one identified company, one identified role, attributable
material requirements, and supported candidate evidence before producing final copy. A canonical
`role.md` or equivalent sourced dossier satisfies the target side. A generic resume request, role
title alone, unattributed requirements, or company facts without one role does not. In those cases,
state `Cannot write final resume: company-role target missing`, request or route to
`research-company-role`, and emit no resume artifact. Do not create a generic fallback.

After that gate, identify seniority, audience, locale, language, and desired detail from the supplied
context. For a technical role, plan explicitly for both the recruiter or hiring-manager scan and the
technical reader's evidence check.

Choose the page budget from the amount of supported material needed for complete coverage, not from
years of experience alone. Two pages is a recommendation, not a limit: use one page when everything
fits clearly, or more than two when supported capabilities and projects need the space. Never pad
weak evidence to reach a page count or compress or omit supported evidence merely to fit a page
target.

Ask one focused question only when the answer would materially change positioning or make the
requested copy unsafe to produce under the shared integrity rules. Route career-history recording
to `maintain-career-profile`, feedback-only requests to `review-resume`, comparison-only requests to
`match-job-description`, company or role research to the corresponding research Skill, and candidate
interview preparation to `prepare-for-interview`. Interviewer planning belongs to
`tedtoolkit-hiring/design-interview`.

## Build an evidence ledger

Read all supplied sources and build the claim ledger defined by `career-integrity.md`. When a local
career profile is supplied, read
[career-profile-schema.md](../../references/career-profile-schema.md), then use its relevant work and
education records plus any inline provenance needed to resolve uncertainty. Read optional private
contact and portrait-path data only when the requested resume needs it and the user authorized that
source. Track source,
provenance/support class, role, dates, contribution ownership, context, constraints, deliverable or
current state, observable result, metric, target relevance, and the material requirement or
positioning theme the evidence supports. Always perform the `match-job-description` evidence mapping
internally before final writing. Reuse an existing current canonical `match.md` when it covers the
exact candidate evidence and target; otherwise build the same matrix without emitting a separate
`# Job Match` artifact unless requested. Never treat target-company facts or role requirements as
candidate accomplishments.

Use business-facing names for employer and client projects. Do not append private repository names,
namespaces, paths or internal code names to project titles, or repeat them in skill summaries and
project prose. Keep those identifiers, commit hashes and issue references in the evidence ledger.
Established public portfolio names and links may remain when they are authorized application
material; explain the work independently of the name.

## Evaluate project evidence

Apply the shared project-and-outcome claim rules. Inventory all supported evidence before deciding
order and emphasis, then distinguish actual products/projects from their repositories, modules,
packages, versions, integration adapters, tests and supporting tools. A record or repository is an
evidence unit, not automatically a resume project. Build a project-to-component map using the actual
business goal, product ownership, users, deliverable and dependency relationships.

Cover the supported projects and capabilities, including strengths the current role does not
request, through coherent project or project-family entries. Consolidate modules and repositories
of the same product/initiative into one account. Present a maintained library/package ecosystem as
a project family with its strongest outcomes and a few capability themes, not one resume project
per package. Retain identifiable stages, distinct responsibilities and their own verification or
delivery state inside the grouped account. Related but separate products may share a clearly named
family heading; never imply that shared code, technology, employer or customer makes them one
accepted delivery. Give target-relevant work more prominence and detail. Remove unsupported or
genuinely repeated claims without erasing a distinct contribution or inventing future employer need.
Follow the [project-boundary rules](references/resume-standard.md#project-coverage-and-emphasis).

For each covered project, use the strongest supported outcome, delivered capability, reuse signal,
verified defect removal, release or migration state, test/acceptance result, or bounded current
state. If only the contribution is known, describe that scope precisely without implying delivery
or impact. Ask about a missing outcome only when it would materially change the description. A
quantified metric is preferable when verified, but it is not a license to invent one.

When public package downloads can substantiate an open-source result, retrieve current statistics
from the official registry and verify package IDs and actual owner identity. Record the retrieval
date, included IDs/prefix, exclusions and counting method in the evidence ledger. For NuGet, sum
all-version totalDownloads once per distinct included package ID; do not add version download
counts again or use the whole owner's total for a narrower project family. Clearly date the metric
and call it package downloads, not unique users, organizations, production adoption or commercial
impact. Support downstream reuse separately with actual consumer evidence. Follow the
[registry-metric rules](references/resume-standard.md#public-package-download-evidence).

Establish each project's start and end separately from employment tenure, acceptance milestones and
personal participation. Show a complete supported start-to-end range, including compact/grouped
entries, following the [project time-range rules](references/resume-standard.md#project-time-ranges).
Do not replace an available range with a lone acceptance date. When the full project lifecycle is
unknown, a verified personal development/maintenance record range may be used with its basis
explicitly labeled; it is not proof of project closure or acceptance. Investigate authorized Git,
GitLab and work-document evidence before asking for missing dates, and respect an instruction to
resolve dates from records without asking the candidate. Put the range only beside the name or on
the next line; keep chronological information out of project prose and bullets.

## Plan or present the strategy

Before writing the complete resume, build this strategy:

1. target positioning and audience;
2. section order and a page budget that allows complete supported coverage, whether one, two, or
   more pages;
3. requirement-to-project mapping and a coverage map for every supported capability
   and project, including those beyond the current requirements;
4. recruiter-scan message and technical-reader proof;
5. evidence-backed technical signature or working style to surface;
6. content to merge or de-emphasize, and unsupported or repeated claims to remove;
7. outcome gaps, material fact gaps, or contradictions; and
8. one sample rewrite when tone is subjective.

For a planning-only request or when final-copy authority is absent, present it as `# Resume Strategy`
and wait. When the user directly requests exact final conversational copy or an authorized file,
apply the strategy internally and emit only the requested resume deliverable; do not add a competing
strategy artifact or another gate. Strategy approval covers listed selection and omissions, but
never authorizes a claim that fails the shared integrity rules.

## Write

Make the strongest relevant evidence visible in the first third. Prefer reverse chronology. Tailor
the wording, emphasis, order, and space allocated to each item so a recruiter can quickly find the
evidence they seek. Tailoring does not remove supported capabilities or projects because the role
does not mention them.

- Keep the summary to two to four evidence-led lines. Lead with one clear professional identity,
  then cover the supported relevant experience span, principal direction, core stack and where it
  has been applied, the candidate's strongest capability, current or most important role and scope,
  and one or two highest-value outcomes. Rank these facts around what is most distinctive for the
  target or candidate instead of giving every skill equal weight or turning the summary into a keyword list.
  Check the summary against the candidate's main supported product or delivery streams. Preserve a
  compact view of that remit when compressing: broad terms such as “industrial software,” “3D data,”
  or “platform development” must not hide a substantial business application. This is a coverage
  check, not a requirement to list every project or give every stream equal prominence.
- Structure each core-skills item as **Skill name:** followed by two sentences. Keep the label a
  concise, recognizable capability such as desktop development, native integration, or testing.
  The first sentence explains the supported business or company value in plain language for HR;
  the second gives the concrete personal capability, technical methods and project evidence for
  technical readers. Keep the value statement after the colon, not in the skill label, and do not
  add separate “HR” or “technical” sublabels. Follow the
  [core-skills rules](references/resume-standard.md#core-skills-and-practical-breadth).
  Cover every supported capability, including distinctive strengths beyond the posting, while ordering
  groups and allocating detail by target relevance.
- Express personal capabilities through demonstrated engineering practice—such as diagnosis,
  design, integration, delivery, or technical ownership—not unsupported traits or self-ratings.
- Write bullets as action plus object or constraint plus outcome, deliverable, or current state.
- Write every project-experience bullet with the concise reasoning used in system-architecture
  project papers: the actual problem, goal or constraint; the personal design/action and technical
  approach; then a supported result, verification or current state. Use the
  [sentence patterns](references/resume-standard.md#sentence-patterns-and-engineering-judgment)
  naturally and vary the wording. Show selection rationale or trade-offs only when evidenced;
  keep the real role, ownership and delivery stage rather than adopting an architect title or
  inventing a decision merely to complete the sentence.
- Translate repository evidence into reader-facing engineering language before drafting each bullet:
  `system or user problem + personal action + relevant technical method + supported result`.
  The project name may provide context, but the bullet must remain understandable when the reader
  has never seen the repository.
- Layer technical bullets for two readers: make the first clause legible to a recruiter, then add
  enough implementation detail, constraint, or failure mode for a technical reader to validate the
  claim. Do not split the resume into separate recruiter and engineer sections.
- When the source and target industries differ, translate source-industry nouns and local workflow
  names upward into widely recognizable system capabilities, business problems, technical
  boundaries, or delivery responsibilities. Lead with the transferable meaning and retain the
  original industry term only when it adds necessary context or proof. Preserve the actual source
  domain; never substitute target-industry vocabulary in a way that implies experience the
  candidate does not have.
- Surface one or two evidence-backed strengths as the candidate's technical signature, whether
  exceptional capabilities or recurring engineering patterns such as root-cause repair,
  contract-first design, difficult integration boundaries, or reusable tooling. Express personality through demonstrated choices and working style, not
  unsupported adjectives, hobbies, slogans, or self-ratings.
- Cover every supported project and capability at the appropriate boundary. Give each actual
  product/initiative one coherent account, combining its repositories, components and versions;
  group an ecosystem under a project-family heading. State distinct contributions and their
  strongest supported result or state without duplicating the same delivery as multiple projects.
  Use compact descriptions for other work rather than dropping it solely for lower target relevance.
- Use repeated **Responsibilities and implementation** / **Outcome or current state** labels only
  when they make several named projects easier to scan; compact achievement bullets are also valid.
- Remove filler, self-praise, repetition, and detail that belongs in an interview.

Apply an outsider-comprehension gate to every project bullet:

1. Can a recruiter identify what capability, defect, risk, or delivery problem was addressed?
2. Can a technical reader identify the relevant platform, mechanism, constraint, or trade-off?
3. Can both readers identify what changed as a result?
4. When industries differ, can a target-industry reader understand the transferable meaning without
   knowing the source industry's internal terminology?

If any answer depends on knowing the repository, rewrite the bullet. Replace private symbols with
their engineering meaning—for example, “strongly typed entity identifiers” rather than `Id<T>`,
“compile-time validation and code generation for domain values” rather than a private analyzer
class, or “composable geometry-processing pipeline” rather than internal interface names. Retain a
specific symbol only when it is a standard/public technology or adds material proof after the plain
language meaning is already clear.

Do not put audit commentary into the resume. Express ownership positively and narrowly (“implemented
the point-cloud import and report-generation path”) instead of defensively explaining what the
candidate did not own. Keep exclusions and provenance notes in the ledger or delivery summary.

## Format

Return a single-column Markdown resume with one `#` name heading, compact contact links, semantic
`##`/`###` headings, simple bullets, consistent dates, and reverse chronology. Do not use tables,
columns, images, icons, emoji, badges, progress bars, raw HTML, or decorative separators. Do not
create PDF or DOCX in this skill.

Use two pages as a recommended starting point, not a hard limit. Use one page when all supported
capabilities and projects remain clear without over-compression; use three or more when
complete, readable coverage needs the space. Do not infer the page count from tenure or seniority
alone.

## Verify and deliver

Apply the summary remit check and the core-skills value check in
[resume-standard.md](references/resume-standard.md#core-skills-and-practical-breadth) before delivery.
Check skill labels separately from their prose: labels name capabilities; the first sentence after
the colon states supported value; the second provides technical capability and evidence. Rewrite
a value sentence that only names an artifact or engineering task around its supported use.

Check every final claim against the shared integrity ledger, then verify links, tense, language,
target terminology, duplication, and unsupported skills. Confirm that HR can understand the value
in each core-skill item before its technical detail, and that a technical reader can identify the
method and supported application or result behind the claim. Cross-check the resume against the evidence
inventory to confirm that every supported capability and actual project is covered, with
target-relevant items receiving greater prominence and detail. Check the project-to-component map:
a repository, package, adapter, test harness or version must not become a separate project merely
because it has its own record; shared technology or customer must not collapse distinct products
into one delivery. Check public registry counts for verified ownership, deduplicated IDs, dated
scope and truthful interpretation. Verify each project's time range
against its start, acceptance or other supported endpoint, current state, and personal participation
boundary. For a consolidated entry, verify that the range belongs to that initiative or clearly
labeled project family, not a fictional uninterrupted lifecycle; retain separate ranges for distinct
compact projects. Dated statistical measurement context is permitted beside its metric and must not
be mistaken for a project milestone. Check that each work-project entry has both boundaries at the supported precision,
with the basis labeled when it is a participation or record interval. Check that titles and prose
contain no private repository identifiers, and that each project bullet connects its purpose,
personal action and supported outcome/state. Confirm that only the range appears near its name and that the body
contains no chronological time information; report unresolved dates outside the resume. Confirm
that project results and current states are supported where stated, the first third works
for a recruiter scan, and the technical detail is sufficient without becoming implementation
transcript. Also confirm that no bullet requires familiarity with a private repository, internal
class hierarchy, commit history, or source-industry vocabulary to understand its problem, action,
technology, and result, and that cross-industry translation does not imply unsupported target-domain
experience.

Deliver rendered Markdown or a `.md` file when requested. Inside a selected career workspace, the
canonical destination is `applications/<company-id>/<role-id>/resume.md`; writing it requires exact
destination authorization and never modifies `role.md`, `match.md`, or candidate facts. Keep the
resume artifact limited to final resume copy. Put unresolved fact questions and the revision summary after the artifact in the
conversational response, or in a separately approved companion file, so notes cannot be submitted as
resume content.
