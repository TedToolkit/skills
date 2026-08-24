# Verify cross-change prerequisites

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: completed -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User approved the complete reviewed contract in the Codex task on 2026-08-24. -->

<!-- section: goal-rationale -->
## Goal and rationale

A standalone change can name concrete outcomes supplied by other changes and cannot begin or pass
review until those outcomes are completed on an explicit Git baseline. Today cross-change
relationships are scoped but implementation readiness is not deterministically enforced.

<!-- section: scope -->
## Scope and non-goals

- In scope: format-3 prerequisite markers and handoff rows; repository-contained graph validation;
  Git-revision-bound readiness; explicit active-record compatibility; owning skill gates and tests.
- Non-goals: a cross-change work-item map, change-set execution or parallel orchestration, a
  `Blocked` lifecycle status, arbitrary external prerequisite commands, cross-repository sources,
  or a format-version bump.
- Preserved: every change remains a standalone approval and delivery boundary; blocked readiness
  does not mutate its lifecycle status.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Format-3 change handoff and implementation readiness | Cross-change dependencies are free-form and not gated | Concrete upstream contracts are structurally validated and must be completed on an explicit Git baseline before implementation or final review | Independent approval boundaries and item-level dependency orchestration remain unchanged |

<!-- acceptance-case: AC-01 -->
### AC-01 — Declare start conditions unambiguously

New or materially revised Drafts declare exactly `none` or unique `PRE-*` prerequisites, with one
complete human row per prerequisite describing the required guarantee, source outcome, and required
readiness evidence.

<!-- acceptance-case: AC-02 -->
### AC-02 — Reject invalid dependency graphs

Validation rejects malformed, missing, duplicate, orphan, self-referential, cyclic, absolute,
outside-repository, symlink-escaped, or undeclared-contract references.

<!-- acceptance-case: AC-03 -->
### AC-03 — Bind readiness to an explicit baseline

`--require-ready --baseline <git-rev>` reads upstream records from that Git tree, succeeds only when
every named source contract is completed, ignores working-tree-only completion edits, reports
blocked evidence on failure, and never changes lifecycle status.

<!-- acceptance-case: AC-04 -->
### AC-04 — Preserve only unchanged active records explicitly

An active format-3 record without prerequisite markers fails by default. An explicit legacy base
accepts only an approved, tracked record whose contract differs from that base only by lifecycle
status, emits a deprecation notice, and composes with readiness validation.

<!-- acceptance-case: AC-05 -->
### AC-05 — Apply the correct workflow gates

Scoping owns dependency boundaries; design and design review require structural validity;
implementation checks readiness before writes; implementation review repeats readiness against its
exact candidate or unchanged implementation baseline.

## Constraints and risks

- Resolve sources relative to the dependent change and contain them under the current repository's
  `docs/changes/**/change.md` namespace.
- Treat only the explicit Git tree as upstream readiness evidence; a source status is meaningful
  under the existing lifecycle contract only when its named contract is present in that tree.
- Compatibility requires a caller-selected legacy base and content comparison so it cannot silently
  absorb a materially revised contract.
- Escalate before changing format version, lifecycle states, repository boundary, external
  prerequisite execution, or adding a change-set scheduler.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. This delivery starts from the approved repository baseline.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome: update the format-3 contract, deterministic validator, owning workflow skills, and proof.
- Likely touchpoints: project-development templates, references, skills, workflow scripts, and evals.
- Private implementation choices left open: shell helper structure and exact fixture organization.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=structural shape=component -->
<!-- primary-proof: AC-02 purpose=structural shape=component -->
<!-- primary-proof: AC-03 purpose=boundary shape=integration -->
<!-- primary-proof: AC-04 purpose=regression shape=integration -->
<!-- primary-proof: AC-05 purpose=acceptance shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Complete none/dependency declarations pass and marker/row defects fail | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts` |
| AC-02 | Primary | Missing, self, cyclic, and escaping dependency graphs fail | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts` |
| AC-03 | Primary | Only completed outcomes in the explicit Git revision unlock readiness | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts` |
| AC-04 | Primary | Only explicit unchanged active legacy records enter compatibility | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts` |
| AC-05 | Primary | Authoring, design review, implementation, and final review use their owning gates | Targeted `design-change`, `review-change-design`, `implement-change`, and `review-implementation` evals |

Conditional proof: shell syntax validation, complete diff inspection, and independent implementation
review because the validator contract is cross-cutting.

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-04 pass offline, AC-05 eval coverage is defined and run where feasible, shell
syntax and the complete diff pass review, and no temporary artifacts remain.
