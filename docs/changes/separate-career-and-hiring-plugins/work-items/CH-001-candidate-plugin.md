# CH-001: Deliver the candidate-facing career plugin

<!-- work-item-format: 2 -->
<!-- work-item-id: CH-001 -->

<!-- approval-source: User approved the complete CH-001 through CH-003 map and requested continuation in the Codex conversation on 2026-09-15. -->

## Outcome

`tedtoolkit-career` `0.4.0` independently supports one candidate's factual career workspace,
company and company-role research, evidence matching, mandatory target-specific resume writing and
review, and candidate interview preparation without exposing interviewer-owned Skills.

<!-- work-item: scope -->
## Scope and non-goals

- Target delivery area or exact public/persisted contract: candidate plugin and the
  `career-workspace/` ownership rows in the parent contract.
- In scope:
  - candidate integrity and workspace schemas;
  - `research-company` and `research-company-role`;
  - `interview-career-project` replacement by `enrich-career-project` without an alias;
  - target-dossier support in `match-job-description`;
  - company-and-role gate in `write-resume`;
  - candidate-side routing updates, paired plugin manifests, and focused evals;
  - removal of interviewer-owned entry points and tests from the career plugin.
- Non-goals: hiring workspace, candidate assessment for an employer, interviewer scoring, root
  marketplace entries, repository-wide migration guidance, or automatic user-data migration.
- Likely touchpoints (non-binding): `plugins/tedtoolkit-career/` and
  `tests/tedtoolkit-career/`.

<!-- work-item: start-conditions -->
## Start conditions

| Prerequisite or blocker | Concrete input or guarantee | Evidence |
| --- | --- | --- |
| None | Ready from the approved parent baseline | Parent change has no cross-change prerequisite. |

<!-- work-item: contract-coverage -->
## Contract responsibility

| Parent contract | Responsibility | Contribution or supplied input |
| --- | --- | --- |
| AC-02 | Owns | Candidate research, canonical workspace scopes, matching, and targeted resume behavior. |
| AC-03 | Owns | Observable block when company identity or role identity and attributable requirements are missing. |
| AC-01 | Supports | Supplies one independently valid persona plugin and removes interviewer ownership. |
| AC-06 | Supports | Supplies final replacement paths and removes both obsolete career Skill directories. |

<!-- work-item: delivery-constraints -->
## Constraints

- `career-workspace/` is the default selected root; another user-selected root directly owns the
  same relative contents and never receives an extra `career-workspace/` prefix.
- Existing explicitly supplied legacy profile roots remain readable without automatic movement or
  rewriting.
- Target-company facts never become employment history, and role requirements never become
  candidate facts.
- Current public research records source URL or description, retrieval date, confidence,
  contradictions, inference, and unknowns; unavailable evidence is not guessed.
- `write-resume` emits no final copy unless both one company and one role are identified and the
  supplied requirements are attributable to them.
- Existing factual-integrity, Markdown-only, privacy, and exact-destination authorization rules
  remain effective.
- Private choices deliberately left to the implementer: heading wording, internal instruction
  ordering, eval fixture prose, and how shared candidate references are factored without changing
  their public ownership.

<!-- work-item: proof-plan -->
## Proof

<!-- primary-proof: AC-02 purpose=acceptance shape=end-to-end -->
<!-- primary-proof: AC-03 purpose=regression shape=end-to-end -->
| Contract or gate | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-02 | Primary | Candidate research, target normalization, matching, and targeted resume smoke scenarios preserve canonical scopes and supported claims. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-career --tier smoke` |
| AC-03 | Primary | Target-free, company-unattributed, and role-unattributed requests create no resume artifact. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-career write-resume --tier full` |
| Candidate plugin regression | Conditional | Existing profile, review, matching, and preparation scenarios still satisfy their candidate-only contracts. | `py -3.10 tests/run_evals.py --plugin tedtoolkit-career --tier full` |

<!-- work-item: definition-of-done -->
## Done

- AC-02 and AC-03 have passing primary proof.
- The career plugin contains only candidate-owned Skills, its paired manifests agree at `0.4.0`,
  and every Skill and reference link validates.
- Existing user data is untouched, obsolete career entry-point directories are absent, and the
  item supplies the verified candidate plugin to CH-003.

<!-- work-item: completion-evidence -->
## Verification result requirements

Record the candidate revision, actual changed artifacts, AC-02 and AC-03 proof purpose and execution
shape, exact commands, discovered/passed/failed/skipped counts, resource prerequisites, legacy-root
compatibility result, and the verified candidate-plugin output supplied to CH-003.

## Risks and implementation notes

Research behavior must be testable from supplied fixture sources without live-network dependence,
while the Skill must still require current browsing when real-world facts may have changed.
