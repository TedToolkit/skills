# <Change title>

## 📌 Status

Draft | Approved | In progress | Completed | Superseded

- Change owner:
- Approval owner:

## 🚦 Change priority

- Priority: P0 | P1 | P2 | P3
- Rationale: state the user, deadline, risk, or delivery impact that justifies this priority.
- Directory: `docs/changes/<Priority>-<change-slug>/`; the prefix must match this priority.

## 🎯 Intended outcome and scope

Describe the intended outcome, scope, explicit non-goals, and compatibility expectations. Do not
describe how the change request originated. Link applicable principles, architecture records, and
ADRs rather than duplicating their rationale.

## 🧾 Source intent and hard constraints

- Source request, issue, or brief:
- User or business outcome:
- External hard constraints: compliance, deadline, budget, or None.

## 🧩 Governing principles and decisions

- Applicable principles and revision: `docs/principles/<topic>.md@<full Git commit SHA>`, or none.
- Related ADRs and status: `docs/adr/ADR-<number>-<slug>.md`, or none.
- Related architecture records and revision: `docs/architecture/<topic>.md@<full Git commit SHA>`, or none.
- Reapproval trigger: a governing record changes before this change completes.

List the resulting implementation constraints in each work package. Links provide traceability;
they do not substitute for an implementation constraint.

## 🧭 Planned approach

Describe how the change will achieve the outcome: affected boundaries, the intended component or data
flow changes, compatibility strategy, and how work packages fit together. Keep detailed API and
test contracts in the work items.

## ✅ Completion criteria

State the observable conditions under which every work package is complete and the change can close.

## ⏱️ Workload estimate

- Person-month basis: state the team's capacity definition; do not assume one.
- Work-package range total: <lower>–<upper> person-months.
- Coordination, verification, migration, and rollout: <lower>–<upper> person-months.
- Contingency: <lower>–<upper> person-months, with risk rationale.
- Total planning range: <lower>–<upper> person-months.
- Confidence: Low | Medium | High.
- Assumptions and excluded work:
- Re-estimation trigger and approval threshold:

## 🚧 Plan blockers

| ID | Blocking item | Blocks | Next action | Status |
| --- | --- | --- | --- | --- |
| PB-01 |  |  |  | Open |

List only unresolved items that prevent work from starting. Link an ADR or issue when applicable;
do not record alternatives or decision rationale here.

## 🗺️ Delivery map

Keep all planned dependencies inside this change. Order rows by executable priority: unmet
prerequisites first, then `P0` through `P3`.

| ID | Work package | Outcome | Priority and rationale | Estimate | Prerequisites | Status | Document |
| --- | --- | --- | --- | --- | --- | --- | --- |
| <PREFIX>-001 |  |  | P1 —  | <lower>–<upper> person-months |  | Planned | `work-items/<PREFIX>-001-<slug>.md` |

## ⚠️ Risks and coordination

| Item | Impact | Next action |
| --- | --- | --- |
|  |  |  |
