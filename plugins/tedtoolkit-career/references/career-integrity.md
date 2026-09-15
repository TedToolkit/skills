# Career Integrity

This is the authoritative source for factual integrity, research provenance, privacy, fairness, and
artifact-write authorization across candidate career workspaces, target research, resumes, job
matching, and interview preparation. Skills may
describe how their output uses these rules, but must not redefine them.

## Evidence provenance and support

Classify source material before using it:

- **Candidate-asserted:** stated by the person, user, resume, or personal notes. It is usable with
  that attribution, but is not independently verified merely because it appears in a profile.
- **Corroborated:** supported by another supplied artifact or authoritative record, with the source
  and scope preserved.
- **Derived:** a conservative rephrasing or synthesis that preserves candidate-asserted or
  corroborated meaning without strengthening it.
- **Unsupported:** plausible but absent from supplied evidence, including guessed metrics, dates,
  tools, seniority, ownership, business impact, and proficiency.

Use candidate-asserted, corroborated, and derived material while preserving provenance and
attribution. Never present unsupported material as fact or silently upgrade a personal assertion to
corroborated evidence. Ask for missing high-impact facts; otherwise record them as unresolved gaps
outside final career materials.

Candidate-asserted is provenance, not a quality endorsement. A vague self-rating or superlative may
still lack visible support; replace it with concrete evidence or omit it from a submitted artifact
without calling the underlying capability false.

For every material claim, preserve its support class, person attribution, chronology, scope,
causality, and limitations. In a career profile, a fact explicitly confirmed by the user may stand
as the canonical fact without retaining an external source pointer. Keep a sanitized source pointer
inside the owning record when a fact remains imported, unconfirmed, automatically corroborated, or
in conflict; no central evidence registry is required. “Not demonstrated” means only that the
supplied material does not demonstrate a requirement; it is not evidence that the person lacks the
capability or that a claim is false.

## Career-profile integrity

- Keep one identified person per profile root. Never merge facts from different people.
- Store career-relevant facts, not every personal fact. Separate sensitive contact or
  private material from records used for matching and writing.
- Treat the profile as a factual source, not polished resume copy. Preserve useful facts even when
  they are not relevant to the current target role.
- Keep project records descriptive rather than evaluative. Record supported context, responsibility
  boundaries, work performed, deliverables, outcomes, evidence, chronology, technologies, and open
  questions; do not add recommendations, praise, criticism, or inferred significance.
- Do not silently delete conflicting or superseded facts. Mark the conflict, retain its necessary
  source pointers in the owning record, and ask for a correction when it materially affects later
  use.
- A profile entry does not become corroborated merely because it was written by this skill.
- Do not copy secrets, government identifiers, compensation, health information, or unrelated
  protected-trait data into the profile unless the user explicitly requests a legitimate use.

## Target-research integrity

- Keep candidate facts, company facts, and role requirements in separate owning records. A company
  claim never becomes employment history, and a role requirement never becomes candidate evidence.
- For every material public claim, retain a source URL or supplied source description, retrieval
  date, confidence, and whether the statement is directly supported or an inference.
- Record contradictions and unknowns explicitly. Missing or inaccessible public evidence is an
  unknown, not permission to guess, fill a template, or silently rely on model memory.
- Browse current authoritative sources when real-world facts may have changed. A supplied dated
  fixture, snapshot, or document may be used without live browsing, but its date and limitations
  remain visible.
- Prefer the employer's official pages and job posting for identity and requirements. Use secondary
  sources only to supplement or challenge them, and do not hide disagreement between sources.
- Do not store scraped webpage copies. Persist concise attributable Markdown facts and links only.

## Editing rules

- Preserve chronology, scope, attribution, and causality.
- Quantify only with supplied numbers. Do not convert adjectives into invented percentages.
- Distinguish personal contribution from team or company outcomes.
- Prefer specific action and outcome evidence over unsupported superlatives.
- Use job-description terminology only when it truthfully describes the person's experience.
- Never add credentials, employers, titles, education, awards, clearances, or technologies that
  the sources do not support.
- Preserve material nuance when translating or compressing content.

### Project and outcome claims

A named project may be retained when the source verifies at least one useful form of evidence:

- an observable outcome such as release, adoption, acceptance, migration, measured change,
  publication, patent, or award;
- a concrete delivered capability or supported scope; or
- a truthful current state for ongoing, research, open-source, or confidential work, paired with the
  person's supported contribution.

Do not imply production success or business impact from a prototype, implementation, or ongoing
effort. A missing metric does not invalidate a concrete deliverable or truthful current state. An
unsupported claim blocks that claim, not the rest of the artifact.

## Privacy and fairness

- Minimize exposure of addresses, personal identifiers, compensation, references, and contact data
  not needed for the task.
- Do not infer sensitive or protected traits from names, photos, dates, locations, or affiliations.
- Keep hiring analysis and interview questions tied to job-related evidence and published role
  requirements.
- Require authoritative current local guidance before making a jurisdiction-specific employment-law
  conclusion.

For interviewer content, exclude non-job-related questions about protected traits, family status,
health, religion, ethnicity, age, pregnancy, disability, or other sensitive personal matters.
Replace them with a job-related way to assess the underlying published requirement when one exists.

## Deliverable ownership and write authorization

Each named deliverable or mutation scope has one owner. Supporting analysis may be consumed
internally, but a skill must not emit or modify another owner's scope unless the user separately
requested it.

| Deliverable or mutation scope | Sole owner | Named output |
| --- | --- | --- |
| Career-profile creation, structure, import, and general maintenance | `maintain-career-profile` | Authorized profile root |
| Guided incremental enrichment of explicitly selected existing project records | `enrich-career-project` | Selected project records |
| One researched target company | `research-company` | `companies/<company-id>/company.md` |
| One researched company-role target | `research-company-role` | `applications/<company-id>/<role-id>/role.md` |
| New, revised, translated, shortened, or tailored resume Markdown | `write-resume` | Resume copy |
| Findings or intrinsic critique without rewritten copy | `review-resume` | `# Resume Review` |
| Candidate/job requirement comparison without copy or questions | `match-job-description` | `# Job Match` |
| Candidate interview preparation | `prepare-for-interview` | `# Interview Preparation` |

A compound request may sequence these owners, but emits each requested deliverable once and creates
no undeclared report or companion file.

A clear request for finished Markdown in the conversation authorizes that response immediately and
authorizes no filesystem mutation. A clear request to create a named absent file or profile root
authorizes only that destination. A clear request to update an identified existing career profile
authorizes changes needed to record the supplied facts, but not deletion, unrelated reorganization,
or modification of another person's profile. A clear request to interview the candidate about
explicitly selected existing project records and write after each answer authorizes
`enrich-career-project` to make only those incremental record updates. Require explicit approval
before overwriting an existing resume or broadly restructuring an existing profile.

## Output boundaries

- Do not infer filesystem authority from conversational-output approval.
- Do not browse for personal information or contact third parties unless the user separately asks
  and the action is authorized.
- Mask unnecessary sensitive values in reviews and comparisons.
- If the user requests a score, disclose its evidence and weighting; do not imply false precision.
- Keep unresolved fact questions outside artifacts that may be submitted to an employer.
