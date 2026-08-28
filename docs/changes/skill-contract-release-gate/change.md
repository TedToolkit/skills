# Add an offline Skill contract release gate

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: in-progress -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

One offline repository-wide gate rejects structurally malformed Skills and plugin metadata before
release. Equivalent checks are currently scattered or absent, so name, link, manifest, alias, UI,
YAML, or JSON drift can survive focused evals.

<!-- section: scope -->
## Scope and non-goals

- In scope: tracked plugin Skills and relevant repository config; deterministic diagnostics;
  malformed fixture variants; harness integration and README command.
- The gate checks directory/frontmatter name equality, relative Markdown links, Codex/Claude
  marketplace plugin-set agreement, paired plugin name/version agreement, canonical
  `agents/openai.yaml`, explicit-only declared aliases pointing to canonical skills, and parseability
  of tracked Skill/agent/eval/manifest/marketplace YAML and JSON.
- Non-goals: network, model calls, plugin installation, cache inspection, rewriting files, guessing
  aliases from prose, or applying project-development-only policy to every plugin.
- Preserved: every currently valid tracked contract remains accepted and focused eval semantics do
  not change.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Offline release validation | Structural relationships are checked inconsistently | One command accepts the real repository and rejects each bounded malformed relationship with an actionable diagnostic and non-zero exit | Valid plugin schemas and plugin-specific policies remain unchanged |

<!-- acceptance-case: AC-01 -->
### AC-01 — Accept the valid repository offline

```gherkin
Scenario: Validate the tracked marketplace
  Given the repository satisfies every declared Skill contract
  When the static gate runs without Codex, network, plugin installation, or cache access
  Then it exits successfully and reports no contract violation
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Reject each malformed contract independently

```gherkin
Scenario: Validate one malformed fixture variant
  Given exactly one checked name, link, manifest, alias, UI, YAML, or JSON relationship is invalid
  When the static gate runs
  Then it exits non-zero and identifies the violated file and contract without rewriting the fixture
```

## Constraints and risks

- Canonical/alias classification comes from an explicit repository contract, never a prose guess.
- Fixture mutation is isolated from the real checkout; the gate itself is read-only and deterministic.
- Diagnostics must not print secrets or arbitrary file contents beyond bounded parse context.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: PRE-01 source=../project-development-release-contract/change.md contract=AC-02 -->
<!-- change-prerequisite: PRE-02 source=../project-development-release-contract/change.md contract=AC-03 -->

| ID | Required input or guarantee | Source change outcome | Required readiness evidence |
| --- | --- | --- | --- |
| PRE-01 | Deprecated project-development aliases have their final explicit-only declaration | Release contract AC-02 | Source change completed on the selected implementation baseline |
| PRE-02 | `continue-change` has its canonical Codex interface metadata | Release contract AC-03 | Source change completed on the selected implementation baseline |

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target area: repository contract checker, static fixture group, harness entry, and
  `tests/README.md` command.
- Other start conditions: completed prerequisites and Python 3.10 with PyYAML.
- Likely touchpoints (non-binding): a repository-level checker under `tests/`, static eval metadata,
  harness self-tests, and testing documentation.
- Private choices left open: checker decomposition and malformed-fixture generation strategy.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=component -->
<!-- primary-proof: AC-02 purpose=boundary shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | The real repository passes while a Codex-unavailable sentinel proves no model/plugin preflight occurs | Focused static contract-gate command plus `py -3.10 tests/test_run_evals.py` |
| AC-02 | Primary | Each malformed relationship fails alone for its intended reason and leaves the fixture digest unchanged | Same checker self-test matrix |

<!-- section: completion-criteria -->
## Completion

AC-01 and every AC-02 malformed variant pass on the exact candidate; the gate is offline, read-only,
deterministic, documented, and integrated into static repository verification; no valid plugin or
Skill contract is reclassified.
