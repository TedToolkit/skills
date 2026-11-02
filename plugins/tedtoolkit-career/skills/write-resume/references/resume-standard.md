# Resume Standard

## What a good resume does

A good resume is:

- **Targeted:** it makes fit for one role family clear while covering the candidate's supported
  professional capabilities and projects.
- **Specific:** it shows ownership, action, constraints, scale, and results instead of self-ratings.
- **Weighted:** it gives more space to target-relevant evidence while preserving meaningful breadth.
- **Scannable:** the first third communicates role, level, domain, and differentiating evidence.
- **Consistent:** dates, titles, terminology, tense, punctuation, and link style agree throughout.
- **Layered:** a recruiter can find fit quickly while a technical reader can verify depth from the
  same evidence.
- **Distinctive:** recurring, supported engineering choices make the candidate memorable without
  relying on slogans or personality adjectives.

## Dual-audience reading order

Technical resumes normally serve two passes:

1. **Recruiter or hiring-manager pass:** target title, domain fit, required technologies, scope,
   chronology, and outcomes must be visible without decoding implementation jargon.
2. **Technical pass:** ownership, constraints, architecture, failure modes, trade-offs, tests, and
   delivery state must make the claims credible.

Write one layered resume, not two parallel versions inside the same artifact. Lead each important
bullet with the business or system capability, defect, or delivered scope; follow with the minimum
technical mechanism that proves the candidate did substantive work.

## Content hierarchy

Use this default order and change it only when another order better supports the target role:

1. Name, target title, location, contact details, and professional links.
2. Professional summary: two to four lines connecting domain, level, strengths, and proof.
3. Core skills grouped by recognizable capabilities, with the most relevant group first; each
   skill name is followed by a business-value sentence and a technical-capability sentence.
4. Professional experience in reverse chronology.
5. Projects beyond employment, including independent and open-source work.
6. Patents, publications, awards, or certifications when supported.
7. Education, normally concise after professional experience.

Remove empty, generic, unsupported, or duplicated material. Keep supported capabilities
and projects even when the target role does not explicitly request them; use concise placement for
less relevant material. An academic CV may use a different order and length when requested.

## Professional summary contract

Use the summary to establish the candidate's primary professional identity, not to compress every
skill into an introduction. In two to four evidence-led lines, make the following legible in this
order when supported and relevant:

1. **Experience and direction:** relevant experience span plus the principal role family, technical
   direction, or domain being pursued.
2. **Primary capability and stack:** the candidate's strongest job-relevant capability and the core
   technologies that enable it.
3. **Application and ownership scope:** the systems, products, domains, or lifecycle stages where
   those technologies have been applied; include the current remit or another important role when
   it materially establishes level, ownership, or breadth.
4. **Proof:** one or two strongest supported outcomes, delivered capabilities, scale signals, or
   recurring engineering patterns that distinguish the candidate for the target.

Make one primary theme unmistakable; subordinate supporting technologies and secondary strengths
to it. Connect technologies to their application rather than listing names, and describe role
scope through owned decisions, systems, delivery stages, or collaboration boundaries instead of a
title alone. Prefer current work scope when it is both supported and target-relevant; otherwise use
the most relevant demonstrated scope.

Before accepting the summary, compare it with the main supported product and delivery streams in
the evidence inventory. A compact description may group related work, but should still tell the
reader which substantial business applications the candidate has worked on. Preserve the main remit
while weighting it for the target; do not replace a substantial application with a generic noun
such as “3D processing” merely to save words. This does not require every project name in the summary.

State years only from supported chronology, do not double-count overlapping work, and distinguish
overall experience from experience in a particular stack or domain. If a required summary fact is
missing, ask only when it would materially change positioning; otherwise omit it rather than infer
seniority, tenure, ownership, or results.

## Core skills and practical breadth

Write each item for HR and technical readers using this structure:

`**Skill name:** Business or company value sentence. Concrete technical capability and evidence sentence.`

- **Before the colon:** name the skill directly, for example “Windows desktop development,”
  “C++ integration,” or “Performance analysis and testing.” Use a concise capability label; do not
  turn it into a benefit sentence or slogan.
- **First sentence after the colon:** explain in plain language what useful work, decision or
  outcome this capability supports for a user, customer or company team. HR should be able to
  understand this sentence without decoding the stack.
- **Second sentence:** explain the candidate's concrete capability through personal methods,
  relevant technologies, constraints and supported project application or result. A technical reader
  should be able to assess the claim from this sentence.

Keep these as two sentences within one bullet, without “For HR” / “For technical readers” labels.
Semicolons may connect closely related technical evidence inside the second sentence. Name
technologies where they help prove the capability, rather than turning the sentence into a stack
inventory. The skill label may itself be technical; the plain-language value sentence belongs after
its colon.

A value statement identifies who can use the work and what useful workflow, decision or action it
supports. A delivered operational capability can establish value without a monetary metric.
“Integrate algorithms,” “define boundaries,” and “build components” only describe engineering work;
connect them to their supported use. Do not assume that adding “support,” “enable” or “improve”
makes an engineering task a business benefit.

Check each item before delivery:

1. Does the label name a recognizable skill rather than a promised benefit?
2. Read only the first sentence after the colon, hiding the label and second sentence. Can HR
   identify a useful user or company outcome without specialist knowledge?
3. Does the second sentence explain personal capability and relevant technical depth, with a
   concrete supported application, result or bounded current state?
4. Does the value sentence stay within that evidence? When only a capability is established,
   describe what it makes possible without inventing savings, adoption or measured improvement.

If the value sentence says only that an interface, module or library was built, translate it to the
evidenced use of that artifact. Keep the actual source domain, personal scope and delivery state.
Technology names and self-ratings such as “strong,” “excellent” or “expert” do not establish ability.
Leave the full project account in project experience.

Business value follows the same integrity rules as technical claims. Do not turn an implementation
into invented revenue, cost savings, efficiency, reliability improvement or company-wide impact,
or claim an unevidenced need at a future employer.

Order capability groups by hiring relevance while covering every supported capability and practical breadth, including
strengths beyond the posting. Group related skills and vary technical detail by evidence strength;
do not imply equal depth in every technology or omit a distinct supported capability solely because
it is not requested. Omit tools that were only encountered and cannot be connected to practice.

Fictional examples, usable only when the underlying facts are supplied:

- **Device communication and recovery:** Operators can resume data collection after a device
  interruption. Implemented C# connection-state tracking and automatic reconnection, verified by
  disconnect regression tests.
- **Inspection application development:** Inspection staff can review measurements and export a
  pass/fail report. Connected a C++ analysis library to a C# desktop workflow and verified the
  measurement/report path with the supplied test cases.

The labels name capabilities, the first sentences explain their use, and the second sentences show
how the candidate delivers them. A library wrapper alone would not establish an inspection or
reporting capability, and recovery tests alone do not establish a measured reduction in downtime.

## Evidence-led bullets

Build each bullet from the strongest available combination of:

`action + object or problem + method or constraint + observable result`

Prefer evidence such as shipped scope, users, team or system scale, latency, throughput, accuracy,
reliability, cost, adoption, acceptance, downloads, patents, or delivery time.

Strong bullets distinguish contribution from result. Weak bullets merely say "responsible for,"
list technologies, or claim expertise without showing its application.

When metrics are absent, use the strongest supported non-numeric result instead of inventing scale:

1. measured outcome or verified scale;
2. release, adoption, acceptance, migration, or downstream reuse;
3. defect removed with regression proof, reliability boundary, or compatibility restored;
4. concrete delivered capability or bounded current state.

Do not label an implementation as a result when the source does not establish delivery or use.

### Public package download evidence

Use official registry data for public distribution statistics, with live retrieval when the metric
may have changed. Verify actual owner identity and included package IDs; author metadata and a
matching name alone do not establish ownership. Keep retrieval date, exact scope and calculation
in the claim ledger and date the resume metric. A short as-of date attached to a metric is measurement
context, not project chronology.

For NuGet, discover the SearchQueryService endpoint from the official service index and use the
[official search API contract](https://learn.microsoft.com/en-us/nuget/api/search-query-service-resource).
Include prerelease/SemVer scope where relevant, retrieve all result pages and deduplicate package IDs.
Each result's totalDownloads already includes its versions: sum it once per included ID, without
adding version-level downloads again. Search excludes unlisted packages, so describe the count as
searchable/listed scope when completeness matters. Exclude unrelated packages and legacy prefixes
from a narrower family total; a separately stated legacy cohort is allowed only when verified and
clearly labeled. Do not rely on a stale cached web snippet when live official data is available.

Describe the result as package downloads or a distribution signal. It does not establish unique
users, independent organizations, installations, production adoption, revenue or time savings.
Support reuse separately with actual downstream references or verified operational evidence. A
multi-package ecosystem is one project family for presentation purposes; its package count does
not establish an equal number of projects or products.

### Sentence patterns and engineering judgment

For project experience, use the concise reasoning of system-architecture project papers in every
bullet: connect an actual problem, objective or constraint to a personal design/action, the
relevant technical approach, and a supported result, verification or bounded current state. Keep
this reasoning in resume-length prose rather than expanding it into an examination essay.

Useful Chinese patterns include:

- “针对……问题，设计/采用……方案，通过……实施或验证，形成/实现……。”
- “在……约束下，将……职责分离，采用……组织协作，完成……接入或交付。”
- “为满足……需求，承担……职责，运用……实现……，成果已用于/目前处于……。”
- “通过……定位……原因，将……调整为……，经……对照验证，结果为……。”

Adapt these patterns to the evidence and language, varying openings and sentence length. Make
personal responsibility and the connection between clauses clear; avoid task lists held together
only by technology names. For a research, support or early-stage item, the strongest defensible
endpoint may be a prototype, document, submitted implementation or known contribution.

For architectural decisions, explain the constraint and why the approach fits only when the
sources establish them. Include compared alternatives and accepted trade-offs only when they were
actually considered. Using a technology does not itself establish authorship of its algorithm,
a comparative selection process, full-system ownership or a production outcome. A writing style
does not change the candidate's actual job title or qualifications.

Keep one main claim per bullet. Do not invent a problem, rationale, causal benefit, verification or
metric to fill a pattern, and do not turn team outcomes into personal implementation claims.
If only the contribution is known, state that scope and current deliverable precisely.

Fictional example, usable only when the facts are supplied:

- Supplied facts: a single-process application must support a second device; the candidate separated
  protocol parsing behind an adapter and added that device without changing the business workflow.
- Resume wording: “在保持单进程部署的约束下，将设备协议解析与业务流程分离，通过适配接口接入第二种设备，完成既有业务流程的兼容扩展。”

[Architecture-paper writing reference](https://www.educity.cn/rk/5540657.html): its original guidance
connects project context, constraints, choices and verified results. The patterns above are concise
resume adaptations; source evidence remains authoritative for every claim.

## Repository evidence translation

Code repositories are evidence sources, not the intended audience's shared context. Translate raw
repository evidence through four layers before it reaches the resume:

1. **Context:** the recognizable product or engineering domain, such as inspection desktop software,
   device SDK integration, geometry processing, or build tooling.
2. **Problem:** the capability to deliver or the defect, risk, constraint, or repeated cost to remove.
3. **Contribution and method:** the candidate's action and only the public technologies or technical
   mechanisms needed to establish depth.
4. **Result:** a measured outcome, delivered capability, verified defect removal, compatibility
   boundary, reusable asset, release state, or bounded current state.

A bullet should still make sense without a repository name. Give employer/client projects
recognizable business or system names, and remove private repository aliases, namespaces and code
names from titles and prose. Keep them in the evidence ledger. Authorized, established public
portfolio names and links may remain, with a self-contained explanation of their contribution.

Prefer recognizable descriptions over private code vocabulary:

- “strongly typed identifiers for domain entities” over a private generic type name;
- “compile-time validation and source generation for domain values” over analyzer/generator class
  names;
- “composable geometry and process pipeline” over internal handler or interface names;
- “managed ownership and release contracts for native memory” over wrapper base-class names;
- “background calculation with cancellation and UI-thread coordination” over patched method names.

Use public technology names when they add material technical proof after the plain-language
meaning is clear. Keep private identifiers, commit hashes, file paths, issue numbers and internal
module lists out of submitted copy, along with long sequences of implementation symbols.

Do not include provenance defenses such as “I am not claiming the whole system” in the resume.
Scope ownership with a concrete verb and object, and keep audit limitations in the evidence ledger
or delivery notes.

## Cross-industry terminology

When the candidate's source industry differs from the target industry, make transferable capability
visible before source-industry vocabulary. Translate a specific industry object, workflow, device,
or internal role into the closest truthful higher-level concept a general hiring reader can
understand, such as:

- the system or product capability being delivered;
- the business or operational problem being solved;
- the integration, data, reliability, safety, or lifecycle boundary being handled; or
- the decisions, coordination, and delivery scope the candidate owned.

Use the broad term in the first clause. Retain the precise source-industry term afterward, often in
parentheses or a short qualifier, only when it provides material context, establishes technical
difficulty, or is likely to be recognized by the target reader. Do not replace a precise term with a
generic phrase such as “business system” when that would erase meaningful engineering depth.

Abstract the vocabulary, not the evidence. Preserve the actual source domain, personal contribution,
technical method, constraints, and results. Never rename a source-industry process or product with a
target-industry term merely because the functions appear analogous; that would falsely imply direct
target-domain experience. The final wording should let a target-industry reader see both what the
candidate actually did and why the capability transfers.

## Project coverage and emphasis

Inventory all supported records and capabilities, but draft around actual products, projects and
coherent project families. Current requirements determine which projects lead and receive more
detail; lower relevance alone is not a reason to erase a distinct supported contribution.

Before drafting, classify each evidence record as a product/project, component, version/stage,
integration adapter, supporting tool, test/benchmark, or shared asset. Map it to the actual
initiative using business purpose, users, deliverables, ownership and dependencies. A separate
repository, package ID, worktree or fact record does not establish a separate project.

- Combine the application, its model adapter and its migration work when they are parts of one
  product. Keep technical depth through a few problem/action/result bullets within that entry.
- Combine an open-source package ecosystem under one project-family account. Lead with verified
  distribution or adoption results, then group components by useful capabilities. Package count is
  package count, not project count, and dependencies are not separate end-user outcomes.
- Preserve material version or product boundaries. An older product's field use does not prove a
  new architecture shipped; an accepted component does not establish whole-platform acceptance.
- Shared libraries may serve several products. Explain that relationship once, avoiding duplicate
  delivery counts. Related but distinct products may share a clearly labeled family heading when
  their purposes, contribution boundaries and current states remain identifiable.
- Do not merge solely because records share technology, employer or customer. Keep unrelated
  support deliverables and experiments identifiable in a compact support group rather than
  inventing one continuous product lifecycle.

Complete coverage means preserving distinct capability, contribution and outcome; it does not
require one heading per source record or repeating every implementation detail. Remove repeated
claims and allocate evidence across the portfolio, for example desktop delivery, native integration,
system design, reliability, domain algorithms and reusable tooling.

## Technical signature

Derive one or two memorable strengths from substantial evidence, including an exceptional
capability beyond current requirements or a recurring engineering pattern. Good
signatures are observable working choices, for example:

- turning recurring defects into regression tests and explicit contracts;
- building reusable analyzers, generators, or libraries after seeing repeated manual work;
- stabilizing native, device, data, or threading boundaries;
- tracing failures to their root cause instead of accumulating local workarounds.

Place the signature in the summary, a focused core-skill line, or achievement bullets. Do not add a
generic personality profile, unsupported superlatives, hobby list, or slogan solely to appear
distinctive.

## Project presentation

Use this repeated structure when several named projects benefit from explicit scanning labels:

1. Project heading and its own time range, following the rules below.
2. **Responsibilities and implementation:** personal ownership, problem, method, or constraint.
3. **Outcome or current state:** supported delivery, use, acceptance, scale, measurement, patent,
   publication, award, or bounded ongoing state.

Translate labels consistently for the resume locale. Compact achievement bullets are also valid;
do not force labels when they add ceremony without clarity. Never add empty labels merely to make
the layout look complete.

Use a `####` project heading when several projects belong to one `###` employer-role entry. Use a
`###` heading for a standalone project. Keep role-wide achievements outside individual projects and
label them clearly so they are not mistaken for an unstructured project bullet.

### Project time ranges

Give each named work project a supported start and end, including compact/grouped entries. Place
the range beside the business-facing project name or on the next line, once only. Employment tenure
is a separate fact. Keep calendar dates, intermediate milestones, elapsed durations and
participation timelines out of project prose and bullets. An as-of date attached to a changing
statistical metric is permitted as measurement context.

- Prefer actual project start through acceptance when both are established. Label an acceptance,
  development, delivery or maintenance endpoint according to what the evidence proves; do not
  replace an available start-to-end range with a single acceptance date.
- For an affirmatively ongoing project, use “start - Present.” Unknown status does not justify
  Present, and the latest commit alone does not establish project completion or acceptance.
- If the full project lifecycle is unknown, use a verified personal development/maintenance period
  or an observed work-record interval, labeling that basis explicitly. First/last relevant personal
  commits and corroborating work records can bound the observed interval; they do not prove the
  candidate participated in the whole project or that no work occurred outside the records.
- Preserve source precision. If work is evidenced within one month or year, both displayed
  boundaries may be the same month or year, labeled as the known work-record interval when the full
  period is unknown. Do not invent months from an annual summary or treat file modification and
  repository creation timestamps alone as development/acceptance evidence.
- For a genuine consolidated project or explicitly labeled family, show the supported initiative
  or family range. Modules do not need separate project entries and dates solely because they
  have separate records. Keep distinct support projects identifiable with their own ranges and
  do not imply continuous participation across gaps.
- Resolve gaps first through authorized canonical facts, Git authorship/history, GitLab activity and
  work documents/messages, separating personal contribution from imports, bots and colleagues.
  When the user requests record-based investigation without questions, search those sources and
  report residual gaps instead of asking the person to reconstruct dates from memory.
- If neither a project range nor a defensible participation/record interval can be established,
  retain only supported time information and report the unresolved boundary outside the resume.
  Do not fill it with employment dates, invented endpoints or submission placeholders.

## Length and coverage

- Treat two pages as a recommendation, not a hard limit; tenure and seniority do not determine page
  count.
- Use one page when every supported capability and project remains clear and readable.
- Use two pages when that is enough for complete, readable coverage.
- Use three or more pages when the candidate's supported capabilities and projects require them.

Shorten by removing unsupported and repeated claims before compressing strong evidence into vague
prose. Do not omit supported capabilities or projects merely to meet a page target.
Do not repeat the same achievement in the summary, employment, project, and achievement sections.

When using multiple pages, budget them deliberately:

- **Page one:** identity, target, evidence-led summary, core requirements, and the strongest recent
  experience or project proof.
- **Later pages:** remaining projects and capabilities, technical signature evidence, open-source
  work and achievements, and education or credentials, with a clear order and consistent scanning
  structure.

Do not let later pages become an unstructured portfolio appendix. Do not pad to two pages when the
evidence fits one.

## Markdown style

Use semantic headings and simple bullets in a single column. Keep contact details compact. Put the
company and role in one heading, then location and dates on the following line. Use consistent field
labels inside every named project. Keep one bullet to one main claim; split a bullet that makes
several unrelated claims.

Avoid tables because they copy poorly and can obscure reading order. Avoid images, sidebars, skill
bars, icons, emoji, and decorative timelines. Use bold sparingly for labels, not whole paragraphs.
Prefer readable link labels for GitHub, portfolios, publications, patents, and package profiles.

## Locale and ATS presentation

Use the target locale's spelling and date conventions. A China-platform export, international
resume, academic CV, and internal company profile are different artifacts; select fields for the
target artifact rather than copying a platform schema.

Ensure conventional section names, linear reading order, plain text availability, and consistent
dates. Content relevance and evidence quality take priority over keyword repetition.
