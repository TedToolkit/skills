---
name: write-resume
description: >-
  Create or revise final resume copy in Markdown. Use when the requested deliverable is a new,
  tailored, shortened, translated, or restructured resume, including a resume targeted to a supplied
  job description. Do not use for feedback-only review, a resume-to-job evidence comparison without
  rewritten copy, or interview questions. Produces Markdown, not PDF or DOCX.
---

# Write Resume

Create a concise resume whose target fit is clear and whose claims are defensible. Read
[resume-integrity.md](../../references/resume-integrity.md) and
[resume-standard.md](references/resume-standard.md). Use
[resume-template.md](assets/resume-template.md) as a flexible starting point.

This skill solely owns final resume copy. Emit no `# Resume Review`, `# Job Match`, or `# Interview
Pack` unless the user separately requested that deliverable; apply the shared conversation,
new-file, overwrite, companion-file, and legal-source gates exactly once.

## Establish the assignment

Choose `Create` or `Revise`. Identify the target role, seniority, audience, locale, language, and
desired detail from the supplied context. For a technical role, plan explicitly for both the
recruiter or hiring-manager scan and the technical reader's evidence check. If no target exists,
position the resume around the candidate's strongest coherent value and say that it is a general
version.

Use two pages as the default target when the role expects roughly five or more years, the candidate
has enough relevant evidence, and both recruiter and technical readers need meaningful depth. Keep
one page for early-career or evidence-limited candidates. Never pad weak evidence to reach a page
count or compress strong evidence into vague claims merely to force one page.

Ask one focused question only when the answer would materially change positioning or make the
requested copy unsafe to produce under the shared integrity rules. Route feedback-only requests to
`review-resume`, comparison-only requests to `match-job-description`, and interview preparation to
`generate-interview-questions`.

## Build an evidence ledger

Read all supplied sources and build the claim ledger defined by `resume-integrity.md`. Track source,
provenance/support class, role, dates, contribution ownership, context, constraints, deliverable or
current state, observable result, metric, target relevance, and the material requirement or
positioning theme the evidence supports. When both candidate evidence and a job description are
present, use `match-job-description` to prioritize supported evidence before writing.

Treat repository names, commit hashes, file paths, internal type names, method names, and issue
numbers as verification evidence, not as default resume language. Keep them in the ledger unless a
name is externally meaningful or the technical reader genuinely needs it to validate the claim.

## Evaluate project evidence

Apply the shared project-and-outcome claim rules. Rank retained projects by target relevance and
evidence strength. Retain a project only when it supports at least one material responsibility,
qualification, domain need, or truthful differentiator for the target; make that relevance visible
in its bullets. Merge, compress, or remove projects whose only merit is general technical interest.

Require each retained project to carry at least one supported outcome, delivered capability, reuse
signal, verified defect removal, release or migration state, test/acceptance result, or bounded
current state. Ask about a missing outcome only when it would materially affect selection;
otherwise recommend omission or compression in the strategy. A quantified metric is preferable
when supplied, but it is not a license to invent one.

## Plan or present the strategy

Before writing the complete resume, build this strategy:

1. target positioning and audience;
2. section order, page budget, and whether one or two pages are justified;
3. requirement-to-project mapping and evidence to emphasize;
4. recruiter-scan message and technical-reader proof;
5. evidence-backed technical signature or working style to surface;
6. content to remove, merge, or de-emphasize;
7. outcome gaps, material fact gaps, or contradictions; and
8. one sample rewrite when tone is subjective.

For a planning-only request or when final-copy authority is absent, present it as `# Resume Strategy`
and wait. When the user directly requests exact final conversational copy or an authorized file,
apply the strategy internally and emit only the requested resume deliverable; do not add a competing
strategy artifact or another gate. Strategy approval covers listed selection and omissions, but
never authorizes a claim that fails the shared integrity rules.

## Write

Make the strongest relevant evidence visible in the first third. Prefer reverse chronology and
retain only sections that improve the hiring decision.

- Keep the summary to two to four evidence-led lines.
- Group skills by useful capability; remove ratings and undifferentiated inventories.
- Write bullets as action plus object or constraint plus outcome, deliverable, or current state.
- Translate repository evidence into reader-facing engineering language before drafting each bullet:
  `system or user problem + personal action + relevant technical method + supported result`.
  The project name may provide context, but the bullet must remain understandable when the reader
  has never seen the repository.
- Layer technical bullets for two readers: make the first clause legible to a recruiter, then add
  enough implementation detail, constraint, or failure mode for a technical reader to validate the
  claim. Do not split the resume into separate recruiter and engineer sections.
- Surface one or two recurring, supported engineering patterns as the candidate's technical
  signature, such as root-cause repair, contract-first design, difficult integration boundaries,
  or reusable tooling. Express personality through demonstrated choices and working style, not
  unsupported adjectives, hobbies, slogans, or self-ratings.
- Give every retained project a visible target reason and at least one outcome or current-state
  proof. Prefer fewer relevant projects with stronger proof over a broad portfolio inventory.
- Use repeated **Responsibilities and implementation** / **Outcome or current state** labels only
  when they make several named projects easier to scan; compact achievement bullets are also valid.
- Remove filler, self-praise, repetition, and detail that belongs in an interview.

Apply an outsider-comprehension gate to every project bullet:

1. Can a recruiter identify what capability, defect, risk, or delivery problem was addressed?
2. Can a technical reader identify the relevant platform, mechanism, constraint, or trade-off?
3. Can both readers identify what changed as a result?

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

Aim for one page with limited experience. For experienced technical candidates, especially roles
that ask for five or more years, default to a deliberate two-page information budget when relevant
evidence supports it: page one establishes fit and strongest recent proof; page two completes the
remaining relevant proof, differentiators, and concise education or credentials. Longer output
requires an explicit academic, publication, portfolio, or jurisdiction-specific need.

## Verify and deliver

Check every final claim against the shared integrity ledger, then verify links, tense, language,
target terminology, duplication, and unsupported skills. Confirm that every retained project maps
to a material target need, every project has outcome/current-state evidence, the first third works
for a recruiter scan, and the technical detail is sufficient without becoming implementation
transcript. Also confirm that no bullet requires familiarity with a private repository, internal
class hierarchy, or commit history to understand its problem, action, technology, and result.

Deliver rendered Markdown or a `.md` file when requested. Keep the resume artifact limited to final
resume copy. Put unresolved fact questions and the revision summary after the artifact in the
conversational response, or in a separately approved companion file, so notes cannot be submitted as
resume content.
