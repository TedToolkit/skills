# Resume Integrity

This is the single authoritative source for factual integrity, privacy, fairness, and artifact-write
authorization across every resume, job-description, and interview workflow. Skills may describe how
their own output uses these rules, but must not redefine them.

## Evidence provenance and support

Classify source material before using it:

- **Candidate-asserted:** stated by the user or candidate, or present in their resume or notes. It is
  usable with that attribution, but is not independently verified merely because it appears in a
  candidate-authored source.
- **Corroborated:** supported by another supplied artifact or authoritative record, with the source
  and scope preserved.
- **Derived:** a conservative rephrasing or synthesis that preserves candidate-asserted or
  corroborated meaning without strengthening it.
- **Unsupported:** plausible but absent from the supplied evidence, including guessed metrics,
  dates, tools, seniority, ownership, business impact, and proficiency.

Use candidate-asserted, corroborated, and derived material in final content while preserving its
provenance and attribution. Never present unsupported material as fact or silently upgrade a
candidate assertion to corroborated evidence. Ask for missing high-impact facts; otherwise mark them
as unresolved suggestions outside the resume.

Candidate-asserted is provenance, not a quality endorsement. A vague self-rating or superlative may
still lack visible support in the resume; replace it with concrete candidate evidence or omit it
without calling the underlying capability false.

For every material claim, preserve the source, provenance/support class, candidate attribution, chronology,
scope, causality, and any limitation. “Not demonstrated” means only that the supplied material does
not demonstrate a requirement; it is not evidence that the candidate lacks the capability or that a
claim is false.

## Editing rules

- Preserve chronology, scope, attribution, and causality.
- Quantify only with supplied numbers. Do not convert adjectives into invented percentages.
- Distinguish personal contribution from team or company outcomes.
- Prefer specific action and outcome evidence over unsupported superlatives.
- Use job-description terminology only when it truthfully describes the candidate's experience.
- Never add credentials, employers, titles, education, awards, security clearances, or technologies
  that the sources do not support.
- Preserve material nuance when translating or compressing content.

### Project and outcome claims

A named project may be retained when the source verifies at least one useful form of evidence:

- an observable outcome such as release, adoption, acceptance, migration, measured change,
  publication, patent, or award;
- a concrete delivered capability or supported scope; or
- a truthful current state for ongoing, research, open-source, or confidential work, paired with the
  candidate's supported contribution.

Do not imply production success or business impact from a prototype, implementation, or ongoing
effort. A missing metric does not invalidate a concrete deliverable or truthful current state. An
unsupported claim blocks that claim, not the rest of the artifact.

## Privacy and fairness

- Minimize exposure of addresses, personal identifiers, compensation, references, and contact data
  not needed for the task.
- Do not infer sensitive or protected traits from names, photos, dates, locations, or affiliations.
- Keep hiring analysis and interview questions tied to job-related evidence and published role
  requirements.
- Apply the legal-source boundary below before any jurisdiction-specific employment-law conclusion.

For interview content, exclude non-job-related questions about protected traits, family status,
health, religion, ethnicity, age, pregnancy, disability, or other sensitive personal matters.
Replace them with a job-related way to assess the underlying published requirement when one exists.

## Deliverable ownership and output authorization

Each requested named deliverable has one owner. Supporting analysis may be consumed internally but
must not emit another owner's report unless the user also requested it:

| Deliverable | Sole owner | Named output |
| --- | --- | --- |
| New, revised, translated, shortened, or tailored resume Markdown | `write-resume` | Resume copy |
| Findings or intrinsic critique without rewritten copy | `review-resume` | `# Resume Review` |
| Candidate/job requirement comparison without copy or questions | `match-job-description` | `# Job Match` |
| Interviewer or candidate-practice questions | `generate-interview-questions` | `# Interview Pack` |

A compound request may sequence these owners, but emits each requested deliverable once and creates
no undeclared report or companion file.

A clear request for finished Markdown in the conversation authorizes that response immediately and
authorizes no filesystem mutation. A clear request to create one named `.md` path authorizes only
that creation when the path is absent. If it exists, require explicit permission to overwrite,
replace, or update that exact path; preserve it byte-for-byte until then. An ambiguous destination
or approval for one artifact never authorizes companion files.

## Legal-source boundary

For a jurisdiction-specific legal conclusion, identify the jurisdiction and verify a current
official source applicable there, such as legislation, a regulator, or a court publication. Search
summaries, model memory, and undated secondary guidance are insufficient. When jurisdiction or
current authority is unavailable, state the limitation, make no legal conclusion, and invent no
citation. Continue only separable neutral job-related editing, comparison, or question replacement;
if the deliverable depends on deciding the law, stop that affected deliverable.

Neutral fairness handling excludes or replaces non-job-related protected-trait content without
claiming what any jurisdiction's law permits or forbids.

## Output discipline

- Use the user's requested language and target locale; otherwise preserve the source language.
- Separate candidate assertions, corroborating sources, interpretations, recommendations, and final
  copy.
- State material limitations when documents are incomplete or parsing is uncertain.
- Do not claim a universal ATS score. If scoring is useful, disclose the rubric and evidence.
- Apply the artifact-specific creation and overwrite gates above; never infer filesystem authority
  from conversational-output approval.
