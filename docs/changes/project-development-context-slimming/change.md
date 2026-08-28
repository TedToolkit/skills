# Reduce project-development workflow context

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-preserving-refactor -->
<!-- change-status: in-progress -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

Project-development's common routes retain the same lifecycle, authorization, routing, review, and
quality-policy decisions while loading less duplicated normative context. The current Skill and
reference closures repeatedly load overlapping rules, increasing cost and drift risk.

<!-- section: scope -->
## Scope and non-goals

- In scope: progressively disclose common workflow guidance; assign every retained rule one
  authoritative owner; measure six representative context closures before and after; update links
  and complete affected regression proof.
- Non-goals: change lifecycle/status semantics, approval, continuation, candidate binding,
  prerequisite, cleanup, orchestration, review independence, public invocation, quality policy,
  eval-runner CLI, lint policy, plugin versions, or the current dirty feasibility-preflight files
  before their writer is released.
- Preserved: every externally observable workflow result and every release/quality contract supplied
  by the prerequisites below.

<!-- section: invariants -->
## Preserved invariants

<!-- preserved-invariant: INV-01 -->
- INV-01: `scope-changes`, `design-change`, `implement-change`, `continue-change`, and
  `orchestrate-work-items` make the same lifecycle transition, authorization, escalation,
  prerequisite, cleanup, and persisted-state decisions for the same repository evidence.

<!-- preserved-invariant: INV-02 -->
- INV-02: `review-implementation` remains the sole aggregate conclusion owner; material Controlled
  risks require independent read-only review; specialist lanes remain distinct; candidate changes
  invalidate stale conclusions.

<!-- preserved-invariant: INV-03 -->
- INV-03: canonical skills, deprecated explicit-only aliases, `continue-change`, orchestration, and
  review lanes retain the completed release-contract routing and interface behavior.

<!-- preserved-invariant: INV-04 -->
- INV-04: implementation and review retain the completed repository-authoritative Cognitive
  Complexity rules, including advisory-only `15` when no repository policy exists.

## Context measurement contract

At audit baseline `d3ddb70db54ba3d78a848e995b940f944a6cc7d6`, concatenate each route's
unique required root `SKILL.md` and references, normalize line endings to LF, and count UTF-8 bytes.
De-duplicate inside a route and count files again across routes.

| Representative route | Required files | Audit baseline bytes |
| --- | ---: | ---: |
| `scope-changes` intake without agent orchestration | 3 | 32,457 |
| `design-change` contract design | 4 | 45,575 |
| `implement-change` bounded delivery | 3 | 48,170 |
| `continue-change` persisted routing | 2 | 28,740 |
| `orchestrate-work-items` full isolated delivery | 6 | 67,552 |
| `review-implementation` aggregate review | 4 | 56,051 |
| Equal-weight route total | 22 route-file loads | 278,545 |

After prerequisites stabilize, capture the same table at the exact pre-refactor SHA. Every route and
the total must shrink. Moving required prose outside the measured closure, or making a conditional
rule undiscoverable, fails the refactor.

## Constraints and risks

- Short roots retain enough local decision context to know exactly when a focused reference is
  required; they cannot depend on prior conversation or undocumented model knowledge.
- Missing credentials or model budget cannot downgrade complete affected-regression proof to a
  limitation; candidate readiness remains blocked.
- The existing dirty feasibility-preflight writer must release `implement-change/SKILL.md` and its
  eval before project-quality calibration begins. This refactor starts only after that approved
  quality change completes and a stable SHA is captured.
- Escalate if any reduction requires a behavior, authorization, routing, review, quality-policy, or
  public-interface change.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: PRE-01 source=../project-development-release-contract/change.md contract=AC-01 -->
<!-- change-prerequisite: PRE-02 source=../project-development-release-contract/change.md contract=AC-02 -->
<!-- change-prerequisite: PRE-03 source=../project-development-release-contract/change.md contract=AC-03 -->
<!-- change-prerequisite: PRE-04 source=../project-development-release-contract/change.md contract=AC-04 -->
<!-- change-prerequisite: PRE-05 source=../project-quality-policy-calibration/change.md contract=AC-01 -->
<!-- change-prerequisite: PRE-06 source=../project-quality-policy-calibration/change.md contract=AC-02 -->

| ID | Required input or guarantee | Source change outcome | Required readiness evidence |
| --- | --- | --- | --- |
| PRE-01 | Unique synchronized project-development release identity | Release contract AC-01 | Source change completed on implementation baseline |
| PRE-02 | Explicit-only compatibility aliases | Release contract AC-02 | Source change completed on implementation baseline |
| PRE-03 | Canonical persisted-change router | Release contract AC-03 | Source change completed on implementation baseline |
| PRE-04 | Coherent orchestration and review ownership | Release contract AC-04 | Source change completed on implementation baseline |
| PRE-05 | Repository thresholds override advisory defaults | Quality policy AC-01 | Source change completed and overlapping writer released |
| PRE-06 | No-policy `15` remains advisory | Quality policy AC-02 | Source change completed and overlapping writer released |

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target area: smaller, focused project-development Skill/reference closures with the
  same decisions.
- Other start conditions: completed prerequisites, no overlapping writer, stable exact-SHA baseline,
  Python 3.10 with PyYAML, and Codex credentials for complete affected model regressions.
- Likely touchpoints (non-binding): the six route roots and workflow/orchestration/review references.
- Private choices left open: reference partition names and measurement-helper decomposition.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: INV-01 purpose=regression shape=component -->
<!-- primary-proof: INV-02 purpose=regression shape=component -->
<!-- primary-proof: INV-03 purpose=regression shape=component -->
<!-- primary-proof: INV-04 purpose=regression shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| INV-01 | Primary | Every project-development eval consumer of the changed roots/references retains lifecycle, authorization, escalation, prerequisite, cleanup, and persisted-state outcomes | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development` on the exact candidate |
| INV-02 | Primary | The same complete plugin suite retains aggregate/specialist ownership, independence, lane, and stale-candidate outcomes | Same complete project-development plugin command |
| INV-03 | Primary | Release-contract positive and near-miss scenarios remain green on the exact refactor candidate | Same complete project-development plugin command, including the release-contract focused groups |
| INV-04 | Primary | Complexity-policy positive and near-miss scenarios remain green on the exact refactor candidate | Same complete project-development plugin command, including project-quality AC-01 and AC-02 scenarios |

Conditional structural proof records pre/post exact SHAs, route path manifests, normalized byte
counts, deltas, link validity, and the complete diff.

<!-- section: completion-criteria -->
## Completion

INV-01 through INV-04 and the complete project-development plugin eval suite pass on the exact candidate; all six
stable route closures and the total shrink with reproducible SHA-bound deltas; missing model proof
blocks completion; no workflow, review, release, quality, runner, plugin, cache, or unrelated dirty
state changes.
