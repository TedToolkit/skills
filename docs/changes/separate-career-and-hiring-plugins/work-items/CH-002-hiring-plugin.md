# CH-002: Deliver the interviewer-facing hiring plugin

<!-- work-item-format: 2 -->
<!-- work-item-id: CH-002 -->

<!-- approval-source: User approved the complete CH-001 through CH-003 map and requested continuation in the Codex conversation on 2026-09-15. -->

## Outcome

`tedtoolkit-hiring` `0.1.0` independently organizes multiple companies, roles, candidates, and
applications and produces job-related candidate assessments and interviewer plans without mutating
source resumes or making final hiring decisions.

<!-- work-item: scope -->
## Scope and non-goals

- Target delivery area or exact public/persisted contract: hiring plugin and the
  `hiring-workspace/` ownership rows in the parent contract.
- In scope:
  - paired hiring plugin manifests;
  - hiring integrity and workspace schemas;
  - `maintain-hiring-workspace`, `assess-candidate`, and migrated `design-interview` Skills;
  - company-, role-, candidate-, resume-, and application-scoped writes;
  - protected-trait exclusion, source immutability, human decision ownership, and focused evals.
- Non-goals: candidate resume editing, personal career-profile maintenance, candidate interview
  preparation, applicant tracking automation, root marketplace entries, or final hiring verdicts.
- Likely touchpoints (non-binding): `plugins/tedtoolkit-hiring/` and
  `tests/tedtoolkit-hiring/`.

<!-- work-item: start-conditions -->
## Start conditions

| Prerequisite or blocker | Concrete input or guarantee | Evidence |
| --- | --- | --- |
| None | Ready from the approved parent baseline; the existing interviewer Skill is readable migration evidence. | Parent change has no cross-change prerequisite. |

<!-- work-item: contract-coverage -->
## Contract responsibility

| Parent contract | Responsibility | Contribution or supplied input |
| --- | --- | --- |
| AC-04 | Owns | Canonical company candidate and role-application isolation. |
| AC-05 | Owns | Protected-trait exclusion, immutable candidate sources, and no final automated verdict. |
| AC-01 | Supports | Supplies one independently valid persona plugin with the sole `design-interview` owner. |
| AC-06 | Supports | Supplies the replacement interviewer entry point for migration guidance. |

<!-- work-item: delivery-constraints -->
## Constraints

- `hiring-workspace/` is the default selected root; another user-selected root directly owns the
  same relative contents and never receives an extra `hiring-workspace/` prefix.
- Candidate facts are canonical within one company and reused by explicit role applications;
  assessments and interview plans never become candidate facts.
- Every read and write is bounded to the selected company, role, candidate, application, and exact
  authorized destination. Creating a normalized resume record never overwrites its source.
- Protected traits, unrelated sensitive data, and non-job-related requirements are excluded from
  assessment and scoring. Missing evidence means not demonstrated, not absence of ability.
- The plugin may provide evidence matrices and interview anchors but never the final hiring verdict.
- The plugin is self-contained and has no required runtime dependency on `tedtoolkit-career`.
- Private choices deliberately left to the implementer: record heading wording, internal evidence
  ledger representation inside a response, and eval fixture prose that preserves the public paths
  and output boundaries.

<!-- work-item: proof-plan -->
## Proof

<!-- primary-proof: AC-04 purpose=acceptance shape=end-to-end -->
<!-- primary-proof: AC-05 purpose=boundary shape=end-to-end -->
| Contract or gate | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-04 | Primary | Multi-role candidate organization and application outputs remain in their canonical scopes without cross-candidate leakage. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-hiring --tier smoke` |
| AC-05 | Primary | Hiring scenarios exclude protected traits, keep source resume/profile bytes unchanged, and emit no final hiring verdict. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-hiring --tier full` |

<!-- work-item: definition-of-done -->
## Done

- AC-04 and AC-05 have passing primary proof.
- The hiring plugin is independently valid at `0.1.0`, owns the only new `design-interview`
  implementation, and has complete integrity, schema, Skill metadata, and eval coverage.
- The item supplies the verified hiring plugin and interviewer replacement entry point to CH-003.

<!-- work-item: completion-evidence -->
## Verification result requirements

Record the candidate revision, actual changed artifacts, AC-04 and AC-05 proof purpose and execution
shape, exact commands, discovered/passed/failed/skipped counts, resource prerequisites, source-file
hash or clean-worktree evidence, privacy/fairness results, and verified outputs supplied to CH-003.

## Risks and implementation notes

Hiring fixtures must use synthetic candidates. Test output and archived results must not contain real
third-party resumes, contact details, or protected-trait values beyond minimal synthetic labels.
