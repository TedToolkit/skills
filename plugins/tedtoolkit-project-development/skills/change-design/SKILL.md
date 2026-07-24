---
name: change-design
description: >-
  Discover and specify a product or library change before delivery planning or implementation. Use
  when a user asks to add, fix, refactor, migrate, plan, scope, design, or estimate a change; turn
  an issue or request into an approval-ready outcome, scope, behavior cases, constraints, approach,
  risks, and completion criteria. Do not create work items or implementation steps; hand an approved
  change to plan-work-items for executable delivery planning.
---

# Change Design

Define what must become true and why, not how to divide or implement the work. This skill owns the
approved behavioral contract for one delivery. `plan-work-items` owns the later delivery map and
work packages; `implement-change-tdd` owns implementation.

Every change has exactly one **change goal**: a result-oriented statement of the observable value
the completed delivery creates. It answers why the change exists; it is not an API name, file edit,
or implementation task. Scope, behavior cases, completion criteria, and later work items must all
serve this goal. If a proposed result is independently releasable or cannot contribute to one goal,
split it into another change with its own goal. Work items have bounded **outcomes**, never goals.

Treat the originating request, user outcome, deadline, and external hard constraints as inputs to a
change; they are not replaced by technical principles. Consume product intent, principles,
architecture records, and ADRs without redefining them. Hand a repositioned library to
`library-product-intent`, a recurring technical default to `design-principles`, and an enduring
technical decision to `architecture-design`.

## Keep dependencies inside one change

All planned delivery dependencies belong in one change. Do not create a change that requires another
planned or in-progress change: merge their intended outcomes into one change, or defer the later
outcome until the earlier change is complete. Completed behavior, approved ADRs, stable architecture
records, and applicable principles are context, not change prerequisites.

## Name every change by priority

Assign one change-level priority before creating its directory. Use `P0` for an active critical
outage, security exposure, or hard external deadline; `P1` for material user, delivery, or risk
impact; `P2` for planned valuable work; and `P3` for a deferrable improvement.

Use `docs/changes/<P0-P3>-<change-slug>/`. When priority is unknown, create an early Draft at
`docs/changes/Draft-<change-slug>/`, set priority to `Unknown`, and ask the first clarification
question with a recommended priority and rationale. Record the decision, rename to `P0`–`P3`, and
keep the folder name and content traceable.

## Inspect and clarify before drafting

1. Read repository guidance, applicable design principles, current architecture records, and
   `docs/product/README.md` when public positioning, scope, target users, or a stated product
   boundary may change. Inspect affected API, callers, tests, documentation, dependencies, and
   adjacent changes.
2. Copy `assets/change-design-template.md`, mark it `Draft`, and fill known fields with evidence.
   Mark unknowns explicitly; the draft is not implementation approval.
3. State the user outcome, scope, non-goals, compatibility expectations, constraints, status quo,
   and smallest credible alternatives.
4. Resolve material ambiguity one question at a time. Explain why it matters, recommend an answer,
   record the user's decision immediately, and revise all dependent sections. Report minor
   assumptions explicitly.
5. Classify the change. A small reversible internal change may use a concise design. A public,
   cross-cutting, stateful, security-sensitive, or difficult-to-reverse change needs fuller
   migration and rollback treatment.
6. Pin every applicable governing record to its full approved Git SHA and restate its resulting
   implementation constraint. A link alone is not a constraint.

## Complete the change design

Write the Draft at `docs/changes/<P0-P3|Draft>-<change-slug>/README.md`. Use the nearest existing
documentation convention and the user's requested language. Preserve fixed semantic emoji prefixes
when translating headings. Do not create `work-items/`, a delivery map, implementation steps, file
lists, test commands, or work-package estimates in this skill.

The document must contain:

1. One change goal, intended outcome, scope, non-goals, compatibility expectations, planned
   approach, and observable change completion criteria.
2. Behavior cases that state the expected observable success, failure, and boundary behavior.
3. Governing constraints, material risks, migration or rollback needs, unresolved questions, and a
   change-level planning range.

Keep detailed implementation, verification, sequencing, and work-package completion definitions out
of the change design. After the design is approved, invoke `plan-work-items`; it may not alter the
approved goal, outcome, scope, behavior cases, or governing constraints. A mismatch returns to this
skill for an approved revision.

When the proposed approach makes a material, enduring, or difficult-to-reverse technical choice,
invoke `architecture-design` before this change can be approved. Link the accepted ADR from the
change and restate only its resulting implementation constraints; do not duplicate its alternatives
or rationale. Do not defer a required ADR to implementation review.

## Estimate workload

Estimate the change before approval as a planning range, not a delivery promise. Declare the local
person-month basis, confidence, assumptions, exclusions, contingency, and re-estimation trigger.
Do not invent a conversion to working days or hours. `plan-work-items` refines the approved range
into work-package ranges and flags material variance for renewed approval.

Add a short documentation-disposition forecast when the design may leave durable records. State
whether product intent, code documentation or tests, principles, architecture records, ADRs, or the
change record itself may need later disposition. This forecast does not authorize deletion or moves.

## Design-review and approval gate

Before creating delivery plans, work items, production code, tests, packages, infrastructure, or
project structure, hand the completed Draft to `review-change-design`. Resolve its blocking findings
through this skill; the review does not approve or edit the document. Then present the reviewed
design draft with:

1. Scope and non-goals.
2. Behavior cases and change completion criteria.
3. Proposed component/API changes and significant alternatives rejected.
4. Applicable governing records and every deliberate exception.
5. Change-level estimate, assumptions, confidence, and exclusions.
6. Risks, migration or rollback, and unresolved questions.

Wait for explicit approval. Approval authorizes `plan-work-items` to produce a delivery plan, not
implementation. Material changes to the approved behavioral contract require a revised design,
design review, and approval.
