# Resume Standard

## What a good resume does

A good resume is:

- **Targeted:** it makes fit for one role family clear instead of cataloguing an entire life.
- **Specific:** it shows ownership, action, constraints, scale, and results instead of self-ratings.
- **Selective:** it gives space according to relevance and evidence strength, not chronology alone.
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
3. Core skills grouped by capability, with the most relevant group first.
4. Professional experience in reverse chronology.
5. Selected projects when they add evidence beyond employment.
6. Open-source work, patents, publications, awards, or certifications when material.
7. Education, normally concise after professional experience.

Remove empty, generic, outdated, duplicated, or target-irrelevant sections. An academic CV may use
a different order and length, but only when the user explicitly requests a CV rather than a
professional resume.

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

A bullet should still make sense if the repository name is hidden. Repository names may remain as
project labels when useful for chronology or interview reference, but they cannot carry the burden
of explaining the work.

Prefer recognizable descriptions over private code vocabulary:

- “strongly typed identifiers for domain entities” over a private generic type name;
- “compile-time validation and source generation for domain values” over analyzer/generator class
  names;
- “composable geometry and process pipeline” over internal handler or interface names;
- “managed ownership and release contracts for native memory” over wrapper base-class names;
- “background calculation with cancellation and UI-thread coordination” over patched method names.

Use a private symbol only after the plain-language meaning is clear and only when the symbol adds
material technical proof. Avoid commit hashes, file paths, issue numbers, internal module lists, and
long sequences of class or method names in submitted resume copy.

Do not include provenance defenses such as “I am not claiming the whole system” in the resume.
Scope ownership with a concrete verb and object, and keep audit limitations in the evidence ledger
or delivery notes.

## Project relevance gate

For a targeted resume, every retained project must visibly support at least one material job
responsibility, required or preferred qualification, domain context, or defensible differentiator.
Remove or compress a technically impressive project when the reader must guess why it matters.

Across retained projects, cover the target's highest-priority themes without repeating the same
proof. A useful portfolio often assigns each project a primary role, such as desktop delivery,
device or native integration, concurrency, system design, test/reliability, or domain algorithms.

## Technical signature

Derive one or two memorable engineering patterns from repeated evidence across projects. Good
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

1. Project heading.
2. **Responsibilities and implementation:** personal ownership, problem, method, or constraint.
3. **Outcome or current state:** supported delivery, use, acceptance, scale, measurement, patent,
   publication, award, or bounded ongoing state.

Translate labels consistently for the resume locale. Compact achievement bullets are also valid;
do not force labels when they add ceremony without clarity. Never add empty labels merely to make
the layout look complete.

Use a `####` project heading when several projects belong to one `###` employer-role entry. Use a
`###` heading for a standalone project. Keep role-wide achievements outside individual projects and
label them clearly so they are not mistaken for an unstructured project bullet.

## Length and selection

- Early career or limited relevant evidence: aim for one page of content.
- Experienced technical candidates, especially when the target asks for roughly five or more years:
  default to two pages when enough relevant proof exists for both recruiter and technical readers.
- Senior specialists: keep two pages unless additional detail changes the hiring decision.
- Academic, research, publication, or regulated CVs: allow longer formats only by explicit choice.

Shorten by removing weak and repeated evidence before compressing strong evidence into vague prose.
Do not repeat the same achievement in the summary, employment, project, and achievement sections.

For a two-page technical resume, budget the pages deliberately:

- **Page one:** identity, target, evidence-led summary, core requirements, and the strongest recent
  experience or project proof.
- **Page two:** remaining target-relevant projects, technical signature evidence, selected
  open-source/achievements, and concise education or credentials.

Do not let page two become a catch-all portfolio appendix. Do not pad to two pages when the evidence
fits one.

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
