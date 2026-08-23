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

## Establish the assignment

Choose `Create` or `Revise`. Identify the target role, seniority, audience, locale, language, and
desired detail from the supplied context. If no target exists, position the resume around the
candidate's strongest coherent value and say that it is a general version.

Ask one focused question only when the answer would materially change positioning or make the
requested copy unsafe to produce under the shared integrity rules. Route feedback-only requests to
`review-resume`, comparison-only requests to `match-job-description`, and interview preparation to
`generate-interview-questions`.

## Build an evidence ledger

Read all supplied sources and build the claim ledger defined by `resume-integrity.md`. Track source,
provenance/support class, role, dates, contribution ownership, context, constraints, deliverable or current
state, observable result, metric, and target relevance. When both candidate evidence and a job
description are present, use `match-job-description` to prioritize supported evidence before writing.

## Evaluate project evidence

Apply the shared project-and-outcome claim rules. Rank retained projects by target relevance and
evidence strength. Ask about a missing outcome only when it would materially affect selection;
otherwise recommend omission or compression in the strategy.

## Present the strategy

Before writing the complete resume, present `# Resume Strategy` with:

1. target positioning and audience;
2. section order and approximate length;
3. evidence to emphasize;
4. content to remove, merge, or de-emphasize;
5. material fact gaps or contradictions; and
6. one sample rewrite when tone is subjective.

Wait for approval unless the user already approved this exact artifact and destination. A direct
request for final conversational Markdown may include that approval; do not ask again when the scope
is exact. Strategy approval covers the listed selection and omissions, but never authorizes a claim
that fails the shared integrity rules.

## Write

Make the strongest relevant evidence visible in the first third. Prefer reverse chronology and
retain only sections that improve the hiring decision.

- Keep the summary to two to four evidence-led lines.
- Group skills by useful capability; remove ratings and undifferentiated inventories.
- Write bullets as action plus object or constraint plus outcome, deliverable, or current state.
- Use repeated **Responsibilities and implementation** / **Outcome or current state** labels only
  when they make several named projects easier to scan; compact achievement bullets are also valid.
- Remove filler, self-praise, repetition, and detail that belongs in an interview.

## Format

Return a single-column Markdown resume with one `#` name heading, compact contact links, semantic
`##`/`###` headings, simple bullets, consistent dates, and reverse chronology. Do not use tables,
columns, images, icons, emoji, badges, progress bars, raw HTML, or decorative separators. Do not
create PDF or DOCX in this skill.

Aim for one page with limited experience and no more than two pages for most experienced
candidates. Longer output requires an explicit academic, publication, portfolio, or
jurisdiction-specific need.

## Verify and deliver

Check every final claim against the shared integrity ledger, then verify links, tense, language,
target terminology, project selection, duplication, and unsupported skills.

Deliver rendered Markdown or a `.md` file when requested. Keep the resume artifact limited to final
resume copy. Put unresolved fact questions and the revision summary after the artifact in the
conversational response, or in a separately approved companion file, so notes cannot be submitted as
resume content.
