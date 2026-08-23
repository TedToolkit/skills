# <Work-item ID>: <Outcome-oriented title>

<!-- work-item-format: 2 -->
<!-- work-item-id: <PREFIX>-001 -->

<!-- approval-source: none -->

## Outcome

State one independently verifiable result and how it contributes to the parent change goal.

<!-- work-item: scope -->
## Scope and non-goals

- Target delivery area or exact public/persisted contract:
- In scope:
- Non-goals:
- Likely touchpoints (non-binding):

<!-- work-item: start-conditions -->
## Start conditions

| Prerequisite or blocker | Concrete input or guarantee | Evidence |
| --- | --- | --- |
| None | Ready from the approved parent baseline |  |

<!-- work-item: contract-coverage -->
## Contract responsibility

| Parent contract | Responsibility | Contribution or supplied input |
| --- | --- | --- |
| AC-01, INV-01, STR-01, or EXP-01 | Owns / Supports |  |

<!-- work-item: delivery-constraints -->
## Constraints

- Public, persisted, compatibility, security, migration, governing, or preserved behavior:
- Private choices deliberately left to the implementer:

<!-- work-item: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
| Contract or gate | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01, INV-01, STR-01, or EXP-01 | Primary |  |  |

The marker is the sole machine-readable source for the owned contract, purpose, and shape; use the
actual lowercase identifiers. Add exactly one marker and one concise Primary row for each owned
contract. The row owns only the observable assertion and command or bounded procedure. Add
conditional proof only when actual boundary or risk requires it.

<!-- work-item: definition-of-done -->
## Done

- The owned contract has passing primary proof.
- Required conditional proof, documentation, migration, and supplied prerequisite outputs are complete.

<!-- work-item: completion-evidence -->
## Verification result requirements

Require the implementation handoff to record candidate revision, actual changed artifacts, contract
IDs, proof purpose, execution shape, command or procedure, observable assertion, result/counts,
resource prerequisites, migration or documentation state, and output supplied to dependents. Keep
mutable runtime status and candidate results in coordinator-owned orchestration state; do not turn
this approved contract into a second status source.

## Risks and implementation notes

Keep only material risks or repository facts that help a human implementer. Remove this section
when none apply. Remove all template instructions and empty content before approval.
