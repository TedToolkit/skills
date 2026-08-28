# Make Resume skill routing and authorization boundaries unambiguous

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: completed -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: commit:6ebb1182415ab2079a0a168efd55d6e6b6a06d96 -->

<!-- section: goal-rationale -->
## Goal and rationale

Give every Resume request one unambiguous deliverable owner while separating conversational output,
new-file creation, overwrite authorization, and jurisdiction-specific legal conclusions. At baseline
`d3ddb70db54ba3d78a848e995b940f944a6cc7d6`, the four skills describe adjacent routes, but the
shared rules do not fully define existing-file protection or what remains safe when current legal
authority cannot be obtained. Ambiguity can cause the wrong artifact, an unintended overwrite, or
an unsupported legal assertion.

<!-- section: scope -->
## Scope and non-goals

- In scope: the unique output responsibility of all four Resume skills; direct conversational
  Markdown authority; new-file and overwrite gates; jurisdiction-specific legal-source handling;
  shared integrity wording; routing, write-safety, and legal negative evals.
- Non-goals: providing legal advice; defining or promising universal ATS scores; producing PDF or
  DOCX; changing evidence provenance, claim integrity, privacy, fairness, scoring-rubric, or resume
  formatting rules beyond what the boundary clarification requires.
- Compatibility: existing truthful Markdown, critique, evidence-matrix, and interview-pack output
  shapes remain valid. A compound request may sequence multiple owners, but no skill emits another
  skill's named deliverable as an undeclared extra artifact.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | A request maps to a Resume deliverable | Adjacent skills contain local routing prose, but supporting analysis and final deliverables can overlap | Each requested deliverable has exactly one owner; supporting analysis may be consumed internally without emitting another skill's report | Evidence provenance, privacy, fairness, and source limitations apply in every route |
| OB-02 | The user clearly requests finished Markdown in the conversation | Direct output is permitted, but wording about artifact approval can still invite a redundant planning gate | The clear request authorizes the conversational Markdown immediately and authorizes no filesystem mutation | Missing material facts may still require a focused question or an explicit limitation |
| OB-03 | The user names a file destination | Exact artifact-and-destination approval is required without distinguishing a new path from an existing one | A clear request to create a specific absent Markdown file authorizes that creation; an existing path requires explicit authorization to overwrite, replace, or update that exact file | Ambiguous destinations and companion files remain unauthorized |
| OB-04 | A jurisdiction-specific legal conclusion affects resume or interview work | Current authoritative guidance is required, but the stop boundary and separable continuation are unspecified | The skill verifies a current authoritative source for the named jurisdiction; if that evidence or jurisdiction is unavailable, it stops the legal conclusion and continues only separable neutral job-related work | Neutral fairness handling never masquerades as a statement of law |

The unique deliverable owners are:

| Requested deliverable | Sole owner | Named output |
| --- | --- | --- |
| New, revised, translated, shortened, or tailored final resume Markdown | `write-resume` | Resume copy |
| Findings or intrinsic critique without full rewritten copy | `review-resume` | `# Resume Review` |
| Requirement-by-requirement candidate/job comparison without final copy or questions | `match-job-description` | `# Job Match` |
| Interviewer or candidate-practice questions | `generate-interview-questions` | `# Interview Pack` |

<!-- acceptance-case: AC-01 -->
### AC-01 — Route each deliverable to its sole owner

```gherkin
Scenario: Route by the requested final deliverable
  Given a request that clearly asks for one Resume deliverable
  When the plugin selects and completes the work
  Then only the owning skill's named output is delivered and supporting routes add no competing artifact
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Produce clearly requested conversational Markdown without writing

```gherkin
Scenario: Return final resume copy in the conversation
  Given a clear request for finished Markdown in the conversation and sufficient candidate evidence
  When the owning Resume skill completes the request
  Then it returns the final Markdown without a redundant approval gate and leaves the filesystem unchanged
```

<!-- acceptance-case: AC-03 -->
### AC-03 — Create only a clearly named new file

```gherkin
Scenario: Write to an absent destination
  Given the user directly requests one owner's named Markdown deliverable at one exact path and that path does not exist
  When the owning Resume skill handles the artifact
  Then it creates only that file without requesting a second approval
```

<!-- acceptance-case: AC-04 -->
### AC-04 — Protect an existing destination

```gherkin
Scenario: A named destination already exists without overwrite authority
  Given the user asks to write to a path that already exists but does not explicitly authorize its overwrite, replacement, or update
  When any Resume skill inspects the destination
  Then it leaves the file byte-for-byte unchanged and asks for authorization for that exact path
```

<!-- acceptance-case: AC-05 -->
### AC-05 — Stop unsupported legal judgment and continue neutral work

```gherkin
Scenario: Current jurisdiction-specific authority cannot be obtained
  Given a request combines a legal conclusion with separable job-related resume or interview work
  When the jurisdiction is unknown or a current authoritative source is unavailable
  Then the skill makes no legal conclusion, states the evidence limitation, and completes only the neutral separable work
```

<!-- acceptance-case: AC-06 -->
### AC-06 — Stop an inseparable legally dependent deliverable

```gherkin
Scenario: The requested output depends on an unavailable legal conclusion
  Given a Resume deliverable cannot be completed neutrally without deciding current jurisdiction-specific law
  When the jurisdiction is unknown or a current authoritative source is unavailable
  Then the skill makes no legal conclusion, invents no citation, and does not produce the affected deliverable
```

<!-- acceptance-case: AC-07 -->
### AC-07 — Sequence explicit compound deliverables without duplicates

```gherkin
Scenario: One request clearly asks for multiple named Resume deliverables
  Given each requested deliverable has a different sole owner
  When the owners are sequenced
  Then each requested named output appears exactly once and no undeclared report or companion file is emitted
```

## Governing constraints, alternatives, and risks

- `plugins/tedtoolkit-resume/references/resume-integrity.md` remains the single authority for
  cross-skill integrity, output authorization, privacy, fairness, and legal-source boundaries. Each
  skill states only its unique routing and output behavior.
- A current authoritative legal source is an official source applicable to the named jurisdiction,
  such as current legislation, a regulator, or a court publication. Search summaries, model memory,
  and undated secondary guidance cannot independently support a legal conclusion.
- “Neutral work” means evidence-based editing, comparison, or a job-related replacement that does
  not assert what the law permits or forbids. If the legal decision is inseparable from the requested
  output, stop that output rather than guessing.
- Prefer one shared boundary contract over four duplicated authorization policies; duplication was
  rejected because it can drift. Requiring approval for every new file was rejected because a clear
  create request already supplies destination authority, while silently treating the same wording as
  overwrite authority exposes existing user data.
- Main risks are destructive file writes, accidental multi-artifact output, stale legal claims, and
  over-blocking safe neutral work. Recovery is a revert of the skill/reference/eval changes; no data
  migration or external operation is authorized.
- Escalate if implementation adds another deliverable type, permits non-Markdown artifacts, changes
  evidence or scoring policy, requires legal interpretation without authoritative support, or cannot
  preserve one shared rule across all four skills.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Implement from baseline `d3ddb70db54ba3d78a848e995b940f944a6cc7d6` after approval and
independent Controlled-design review.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target area: align `resume-integrity.md`, the descriptions and bodies of the four
  Resume skills, and their evals around one routing and authorization contract.
- Other start conditions: none; legal-source failure behavior must be testable without live network
  access and must not fabricate an authoritative citation.
- Likely touchpoints (non-binding): `plugins/tedtoolkit-resume/references/resume-integrity.md`, each
  Resume `SKILL.md` and routing metadata when needed, plus the four existing eval suites and their
  filesystem fixtures.
- Private choices left open: wording placement, whether negative cases extend existing scenarios or
  add fixtures, and how compound requests sequence owners without duplicating named outputs.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=integration -->
<!-- primary-proof: AC-02 purpose=acceptance shape=integration -->
<!-- primary-proof: AC-03 purpose=acceptance shape=integration -->
<!-- primary-proof: AC-04 purpose=boundary shape=integration -->
<!-- primary-proof: AC-05 purpose=boundary shape=integration -->
<!-- primary-proof: AC-06 purpose=boundary shape=integration -->
<!-- primary-proof: AC-07 purpose=regression shape=integration -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Positive and adversarial routing prompts yield only the sole owner's named output across all four skills | `py -3.10 tests/run_evals.py --plugin tedtoolkit-resume` |
| AC-02 | Primary | Representative resume, review, match, and interview requests each produce their owner's Markdown immediately and leave the fixture repository clean | Same Resume plugin eval suite |
| AC-03 | Primary | Each of the four owners can satisfy a direct request naming an absent `.md` destination by creating only that path without a second gate | Same Resume plugin eval suite |
| AC-04 | Primary | A pre-existing destination without explicit overwrite wording retains the same digest and content and no companion file appears | Same Resume plugin eval suite |
| AC-05 | Primary | A no-source jurisdiction prompt produces no legal conclusion or invented citation while still returning the separable neutral deliverable | Same Resume plugin eval suite |
| AC-06 | Primary | An inseparable no-source prompt emits no legal conclusion, citation, or affected named deliverable | Same Resume plugin eval suite |
| AC-07 | Primary | An adversarial compound prompt emits each explicitly requested named output once and no undeclared report or file | Same Resume plugin eval suite |
| Shared integrity regression | Conditional | Unsupported claims, protected-trait exclusion, missing-source stops, redaction, and current output shapes continue to pass | Existing Resume plugin scenarios in the same run |

<!-- section: completion-criteria -->
## Completion

Complete when all four skill descriptions and instructions implement the sole-owner matrix, the
shared integrity reference owns the conversation/new-file/overwrite/legal rules, and positive plus
negative evals pass for single and compound routing, every owner's output destination, filesystem
non-authorization, and both separable and inseparable unavailable-legal-authority cases.
Independent candidate-bound review must confirm that existing provenance, privacy, fairness, and
Markdown-only behavior remain intact; no durable extraction beyond the active shared reference is
required.
