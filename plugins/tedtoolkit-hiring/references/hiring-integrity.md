# Hiring Integrity

This is the authoritative policy for evidence, privacy, fairness, source integrity, decision
ownership, and writes made by this plugin. Skills may link these rules but must not weaken or
redefine them.

## Evidence and provenance

Classify every job-related claim before using it:

- **Candidate-asserted:** supplied by the candidate, user, resume, application, or notes.
- **Corroborated:** supported by another supplied record, with both source and scope preserved.
- **Derived:** a conservative synthesis that does not strengthen the supported meaning.
- **Unsupported:** plausible but absent from the selected evidence, including guessed skills,
  dates, ownership, seniority, impact, proficiency, motives, and identity.

Use only candidate-asserted, corroborated, or conservatively derived claims. Cite the selected
source record for each material claim. `Not demonstrated` means only that the selected evidence does
not demonstrate a requirement; it is not evidence that the candidate lacks the capability. Keep
contradictions and material unknowns visible rather than resolving them by inference.

## Candidate isolation and minimization

- Select one company, role, candidate, and role application before assessment or interview design.
- Read only that company's selected role, selected candidate, selected application, and evidence
  already selected by that application. Do not scan sibling companies, roles, candidates,
  applications, or private files.
- Keep one canonical candidate record per company. Reuse its identifier through explicit role
  applications; never copy assessments or interview plans into the candidate record.
- Do not merge similarly named candidates or reuse a company-scoped candidate record in another
  company. Ask when an identifier or ownership boundary is ambiguous.
- Minimize contact details and unrelated personal information. Do not browse for personal
  information or contact a candidate or third party without a separate explicit request and
  authorization.

Never infer, record in an assessment, score, compare, or ask about protected or sensitive traits,
including age, race, ethnicity, nationality, religion, sex, gender identity, sexual orientation,
pregnancy, disability, health, genetic information, marital or family status, or other locally
protected traits. Exclude supplied protected-trait values entirely from normalized resumes,
assessments, interview plans, and scoring. If a user requests a related question, label it
`Excluded as non-job-related` without repeating the sensitive value and substitute a neutral
question only when an explicit job requirement provides a legitimate target.

Require current authoritative local guidance before making a jurisdiction-specific employment-law
conclusion. Complete separable neutral work that does not depend on that conclusion.

## Immutable sources

Treat supplied resumes, career profiles, portfolios, transcripts, and other candidate source files
as read-only. Never edit, move, rename, delete, or overwrite them. A normalized resume record is a
new Markdown record at an explicitly authorized canonical destination; it preserves a sanitized
source pointer and never changes the source. Stop if the destination already exists unless the user
explicitly authorizes overwriting that exact file.

## Human decision ownership

The plugin may organize evidence, identify gaps or contradictions, provide transparent job-related
weights when requested, and define interview evidence anchors. It must never issue a final hiring
verdict, rank candidates, select a candidate, or recommend hire, reject, advance, or eliminate.
State that the accountable human owns the decision. A numeric score, when explicitly requested,
must expose its job-related requirements, evidence, and weighting and remains decision support only.

## Deliverables and authorization

| Deliverable or mutation scope | Sole owner | Canonical output |
| --- | --- | --- |
| Company, role, canonical candidate, normalized resume, and application records | `maintain-hiring-workspace` | Selected canonical paths |
| Evidence comparison for one explicit role application | `assess-candidate` | `# Candidate Assessment` or that application's `assessment.md` |
| Interviewer questions and evidence anchors for one explicit role application | `design-interview` | `# Interview Plan` or that application's `interview-plan.md` |

A compound request may sequence these owners, but each deliverable is emitted once. Conversation
output authorizes no filesystem write. Before a write, resolve and state the selected root plus the
exact company, role, candidate, application, and destination file. A clear request that names these
identifiers and asks to create their canonical absent records authorizes only those calculated
paths. Otherwise ask for the missing boundary or authorization. Never infer authority for a sibling
candidate, another role application, a broad workspace rewrite, or an existing-file overwrite.

Evidence named after an application was established is not selected merely because it is supplied
in the assessment or interview request. Route it to `maintain-hiring-workspace` for an explicitly
authorized, bounded update of that application's `evidence` list before either downstream skill
reads or uses it.

Write only UTF-8 Markdown under the selected workspace root. Do not create databases, JSON, YAML,
indexes, caches, hidden state, or companion reports. Preserve unrelated files byte-for-byte.
