# <Work-package ID>: <Title>

## 📌 Status

Draft | Approved | Implementing | Implemented | Superseded

## 🚦 Delivery priority

- Priority: P0 | P1 | P2 | P3
- Rationale: state the user, deadline, risk, or delivery impact that justifies this priority.
- Blocking prerequisite: none, or link the unmet work package, decision gate, ADR, or architecture
  record. Priority does not override prerequisites.

## 🔗 Delivery context

- Parent change: `<path or ID>`
- Prerequisites: work packages, plan blockers, ADRs, or architecture records.
- Applicable principles: `docs/principles/<topic>.md`, or none.

## 🧩 Explicit governing constraints

State the exact constraints inherited from the approved change: boundaries, compatibility,
dependency direction, security, migration, rollout, and non-functional requirements when material.
Do not use links alone. This section is the implementation-facing form of the governing principles,
architecture records, and ADRs.

## 🎯 Outcome, scope, and non-goals

Describe one independently observable outcome. State what this package deliberately does not
change, especially adjacent work packages.

## 🔍 Current behavior and impact boundary

Link the current code, tests, documentation, or observable behavior that this package changes.
State the affected interfaces or flows and the adjacent behavior that must remain unchanged.

## 🧪 Behavior cases

| ID | Preconditions and input | Action | Expected observable behavior |
| --- | --- | --- | --- |
| BC-1 |  |  |  |

## 🛠️ Implementation contract

Describe the required component, API, data/control-flow, and compatibility changes. State values,
error behavior, invariants, schema changes, or performance limits only when material. Link, rather
than restate, parent or architectural decisions.

| Boundary or artifact | Required change | Compatibility or invariant |
| --- | --- | --- |
|  |  |  |

## ✅ Verification plan

| Behavior case | Test level and location | Setup and action | Observable assertion | Command |
| --- | --- | --- | --- | --- |
| BC-1 | Unit/integration/contract |  |  |  |

## ⏱️ Workload estimate

- Planning range: <lower>–<upper> person-months.
- Confidence: Low | Medium | High.
- Assumptions:
- Excluded work:
- Actual effort on completion: <person-months> or Not completed.
- Material variance and reason:

## 📋 Completion evidence

Record the commands run, their result, and any required manual verification when implementation is
complete. A package is not complete merely because its code was changed.

## 🔄 Migration and rollback

Include only when this package changes public compatibility, persistent state, or deployment.

## ⚠️ Risks and open questions

| Item | Impact | Owner or next decision |
| --- | --- | --- |
|  |  |  |
