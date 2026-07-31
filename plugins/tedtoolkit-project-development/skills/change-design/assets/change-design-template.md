# <Change title>

## 📌 Status

Draft | Approved | In progress | Completed | Superseded

- Approval evidence: user confirmation, issue comment, or other approval source.

## 📝 Clarification and decision log

Record each material user answer as it arrives while this document is `Draft`. Replace unknowns in
the affected sections immediately; retain this short trace only when it explains a consequential
scope, behavior, constraint, or estimate decision.

| ID | Question and why it mattered | Recommended answer | User decision and source | Affected sections | Status |
| --- | --- | --- | --- | --- | --- |
| CD-01 |  |  |  |  | Resolved |

## 🚦 Change priority

- Priority: Unknown | P0 | P1 | P2 | P3
- Rationale: state the user, deadline, risk, or delivery impact that justifies this priority.
- Directory: `docs/changes/<Priority>-<change-slug>/`; use `Draft` while priority is unknown, then
  rename to `P0`–`P3` immediately after the user decides.

## 🎯 Change goal

State exactly one result-oriented goal. It must describe the observable value created for a user or
system, not an API, file, or implementation task.

> When this change is complete, `<user or system>` can `<observable result>`, proven by
> `<measurable condition or observable behavior>`.

This goal is unchanged unless the change is revised and approved again. Every behavior case,
completion criterion, and later work item must contribute to it.

## 🎯 Intended outcome and scope

Describe the intended outcome, scope, explicit non-goals, and compatibility expectations. Do not
describe how the change request originated. Link applicable principles, architecture records, and
ADRs rather than duplicating their rationale. Do not introduce a second goal here.

## 🧾 Source intent and hard constraints

- Source request, issue, or brief:
- User or business outcome:
- External hard constraints: compliance, deadline, budget, or None.

## 🧩 Governing principles and decisions

- Applicable product intent and revision: `docs/product/README.md@<full Git commit SHA>`, or none.
- Applicable principles and revision: `docs/principles/<topic>.md@<full Git commit SHA>`, or none.
- Related accepted ADRs and revision: `docs/adr/ADR-<number>-<slug>.md@<full Git commit SHA>`, or none.
- Related architecture records and revision: `docs/architecture/<topic>.md@<full Git commit SHA>`, or none.
- Reapproval trigger: a governing record changes before this change completes.

State the resulting downstream delivery constraints here. Later work items must copy them into
their explicit governing constraints. Links provide traceability; they do not substitute for a
constraint.

## 🧭 Planned approach

Describe how the change will achieve the outcome: affected boundaries, intended component or data
flow changes, compatibility strategy, and material alternatives rejected. Do not include work
packages, private implementation steps, file lists, or focused verification commands. Work-item
boundaries and proof standards belong to `plan-work-items`; private code and test organization
belong to `implement-change-tdd`. Resolve research, design review, and decisions here. State the
target delivery artifact categories that must change; workflow control records (this change design,
work items, review reports, and status evidence) do not count. If the conclusion is that no target
delivery artifact changes, state that evidence and do not create work items.

## 🔀 Delivery disposition and operational handoffs

- Target delivery artifacts: code | tests | configuration | build automation | documentation | None.
- No-delivery-change evidence and closure criterion: required when target delivery artifacts are None.

| External operational handoff | Owner | Completion evidence | Required before change closure? |
| --- | --- | --- | --- |
| None, or describe a release, deployment, access request, manual configuration, or communication |  |  | Yes / No |

Operational handoffs are tracked outside the work-item flow. They may block change closure, but they
are never delivery-map rows or work items.

## 🧪 Behavior cases

State the observable success, failure, and boundary behavior the completed change must provide.
Do not specify work-item sequence, implementation files, or test commands here.

| ID | Preconditions and input | Action | Expected observable behavior |
| --- | --- | --- | --- |
| BC-01 |  |  |  |

## ✅ Completion criteria

State the observable conditions proving the one change goal is achieved and the change can close.

## ⏱️ Workload estimate

- Person-month basis: state the team's capacity definition; do not assume one.
- Change delivery range: <lower>–<upper> person-months.
- Coordination, verification, migration, and rollout allowance: <lower>–<upper> person-months.
- Contingency: <lower>–<upper> person-months, with risk rationale.
- Total planning range: <lower>–<upper> person-months.
- Confidence: Low | Medium | High.
- Assumptions and excluded work:
- Re-estimation trigger and approval threshold:

## 🚧 Design blockers

| ID | Blocking item | Blocks | Next action | Status |
| --- | --- | --- | --- | --- |
| PB-01 |  |  |  | Open |

List only unresolved items that prevent design approval. Link an ADR or issue when applicable; do
not record alternatives or decision rationale here. After approval, `plan-work-items` records any
delivery blockers and the delivery map.

## ⚠️ Risks and coordination

| Item | Impact | Next action |
| --- | --- | --- |
|  |  |  |
