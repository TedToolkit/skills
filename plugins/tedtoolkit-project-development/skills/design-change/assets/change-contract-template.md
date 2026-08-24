# <Outcome-oriented title>

<!-- change-format: 3 -->
<!-- workflow-profile: standard | controlled -->
<!-- change-kind: behavior-change | bug-fix | behavior-preserving-refactor | maintenance | migration | experiment -->
<!-- change-status: draft | approved | in-progress | candidate-ready | implemented | completed | superseded -->
<!-- delivery-shape: single | multi-item -->

- Priority: Unknown | P0 | P1 | P2 | P3
<!-- approval-source: none -->
<!-- candidate-binding: none -->

<!-- section: goal-rationale -->
## Goal and rationale

State one observable result, who benefits, the evidenced problem or opportunity, its consequence,
and why it is worth doing now. Keep only the current reason; do not narrate the conversation.

<!-- section: scope -->
## Scope and non-goals

- In scope:
- Non-goals:
- Compatibility or deliberately preserved behavior:

<!-- section: behavior-contract -->
## Behavior contract

For a behavior change, bug fix, or migration, state current, expected, and preserved behavior.

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 |  |  |  |  |

<!-- acceptance-case: AC-01 -->
### AC-01 — <Principal observable result>

```gherkin
Scenario: <Principal observable result>
  Given <observable precondition>
  When <one observable action occurs>
  Then <one pass-or-fail result is visible>
```

For a behavior-preserving refactor, remove the delta and acceptance-case blocks above and state
observable invariants instead:

<!-- section: invariants -->
## Preserved invariants

<!-- preserved-invariant: INV-01 -->
- INV-01: <observable behavior that must remain unchanged>.

For maintenance, remove the behavior and invariant blocks and state the target structural result:

<!-- section: structural-contract -->
## Structural outcome

<!-- structural-outcome: STR-01 -->
- STR-01: <observable build, analyzer, documentation, configuration, or repository state>.

For an experiment, remove both behavior and invariant blocks above and define the evidence contract:

<!-- section: experiment-contract -->
## Experiment contract

<!-- experiment: EXP-01 -->
- Decision question or hypothesis:
- Evidence method and representative boundary:
- Success or falsification signal:
- Stop condition and expiry:
- Evidence owner and downstream decision:
- Production authority: None; a separate approved change is required.

## Constraints and risks

- Public, persisted, security, migration, governing, or operational constraints:
- Material risks and recovery or rollback:
- Escalation triggers:

Omit this paragraph from the generated record. A Controlled change expands this section only for
applicable governing records, alternatives, compatibility, migration/recovery, or operational
handoffs. Link durable sources and restate the implementation-facing constraint; do not copy their
rationale.

<!-- section: start-conditions -->
## Start conditions

For no cross-change prerequisite, keep exactly:

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

For each concrete upstream outcome, remove `none`, add one stable marker and one matching row. The
source is relative to this `change.md`, remains inside `docs/changes/`, and names the upstream
contract that supplies the guarantee. State required evidence, not an observed runtime result.

<!-- change-prerequisite: PRE-01 source=../<source-slug>/change.md contract=AC-01 -->
| ID | Required input or guarantee | Source change outcome | Required readiness evidence |
| --- | --- | --- | --- |
| PRE-01 |  | `../<source-slug>/change.md`, AC-01 | Source contract is completed on the selected Git baseline |

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target delivery area:
- Other real start conditions or resource prerequisites:
- Likely touchpoints (non-binding):
- Private implementation choices left open:

For a multi-item Controlled change, replace the embedded brief with the delivery disposition and
state that `plan-work-items` will create the separately approved map.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01, INV-01, STR-01, or EXP-01 | Primary |  |  |

The marker is the sole machine-readable source for the contract, proof purpose, and execution shape;
use the actual lowercase identifiers. Add exactly one marker and one concise Primary row per
contract. The row owns only the observable assertion and command or bounded procedure. Add
conditional rows only when the actual boundary or risk requires them; do not repeat marker metadata
or add rows merely to represent test layers.

<!-- section: completion-criteria -->
## Completion

State the objective proof, required migration or documentation state, and operational handoff
closure needed to complete this one goal.

Remove every instruction, placeholder, empty heading, and inapplicable optional section before
presenting the record. A Standard result should normally remain within one or two screens.
