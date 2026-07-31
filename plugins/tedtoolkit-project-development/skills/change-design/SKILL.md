---
name: change-design
description: >-
  Design one product or library change as an approval-ready behavioral contract. Use when a feature,
  fix, refactor, migration, or other behavior change needs a goal, scope, behavior cases,
  constraints, approach, risks, completion criteria, or proportionate estimate before delivery.
---

# Change Design

Define the **contract**: what must become true and why. This skill owns the
approved behavioral contract for one delivery. `plan-work-items` owns the later delivery map and
work items; `implement-change-tdd` owns implementation.

Read [change-development-workflow.md](../../references/change-development-workflow.md) before
classifying a delivery artifact, work item, or operational handoff.

Resolve research, design review, alternatives, decisions, and the conclusion that no repository
change is needed here, before delivery planning. Only an approved design that requires a bounded
modification to a **target delivery artifact** proceeds to `plan-work-items`. Required external
execution is an operational handoff, not a development work item.

Every change has exactly one **change goal**: a result-oriented statement of the observable value
the completed delivery creates. It answers why the change exists; it is not an API name, file edit,
or implementation task. Scope, behavior cases, completion criteria, and later work items must all
serve this goal. If a proposed result is independently releasable or cannot contribute to one goal,
split it into another change with its own goal. Work items have bounded **outcomes**, never goals.

## Require a proportionate design before behavior-changing code

Do not modify production code that changes observable behavior without an approved design. Use the
same change-design record and approval path at every size, but make the design proportionate:

- A small, internal, reversible behavior change may use a concise design. It still states the goal,
  affected boundary, current and intended behavior, completion criteria, verification approach, and
  material risks or compatibility constraints.
- A public, cross-cutting, stateful, security-sensitive, migration, compatibility, or difficult-to-
  reverse change needs the full design treatment in this skill.
- Purely mechanical maintenance that demonstrably does not change production behavior—for example
  formatting, spelling, comments, or an equivalent no-behavior configuration update—does not enter
  the change workflow. State the evidence for that classification; when it is uncertain, treat the
  modification as behavior-changing and design it first.

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
4. Classify the proposed modification under the proportionate-design rule. For a behavior-changing
   production-code modification, choose concise or full design treatment before seeking approval;
   do not defer that choice to implementation. For an asserted maintenance exemption, record the
   no-behavior evidence or ask for the missing evidence.
5. Resolve material ambiguity one question at a time. Explain why it matters, recommend an answer,
   record the user's decision immediately, and revise all dependent sections. Report minor
   assumptions explicitly.
6. When the draft exposes a candidate principle—a recurring technical default with a stable
   rationale that could govern future changes—raise it proactively. Ask whether the user wants to
   add or revise a principle, and propose its title, default direction, governed scope, rationale,
   and likely strength. Distinguish it from a one-off change constraint, executable rule, current
   architecture description, or enduring decision that needs an ADR. Do not treat the candidate as
   a governing constraint or create the principle without the user's confirmation; if confirmed,
   hand it to `design-principles` and resume this change with its approved, pinned constraint.
7. Apply the selected design depth. Keep concise designs focused on the required behavioral
   contract; give public, cross-cutting, stateful, security-sensitive, or difficult-to-reverse
   changes fuller migration and rollback treatment.
8. Pin every applicable governing record to its full approved Git SHA and restate its resulting
   implementation constraint. A link alone is not a constraint.

## Complete the change design

Write the Draft at `docs/changes/<P0-P3|Draft>-<change-slug>/change.md`. Never create a
`README.md` anywhere under `docs/changes/`; the explicitly named change record already owns the
context, so another directory index is redundant. Use the nearest existing documentation convention
and the user's requested language. Preserve fixed semantic emoji prefixes when translating headings.
Keep `work-items/`, the delivery map, implementation steps, file lists, test commands, and
work-item estimates in their later owning phases.

The document must contain:

1. One change goal, intended outcome, scope, non-goals, compatibility expectations, planned
   approach, and observable change completion criteria.
2. Behavior cases that state the expected observable success, failure, and boundary behavior.
3. Governing constraints, material risks, migration or rollback needs, unresolved questions, and a
   change-level planning range.

Keep private implementation, focused verification commands, delivery dependencies, and work-item
completion definitions out of the change design. After approval, `plan-work-items` defines delivery
boundaries, real prerequisites, proof standards, and completion; `implement-change-tdd` chooses the
private code and test organization. Neither may alter the approved goal, outcome, scope, behavior
cases, or governing constraints. A mismatch returns to this skill for an approved revision.

If the approved conclusion is that no target delivery artifact changes, record the evidence,
completion criteria, and any operational handoff here, close the design through the normal review
and approval path, and do not create work items. The change-design record itself is a workflow
control record, so creating or updating it does not make a delivery plan necessary.

When the proposed approach makes a material, enduring, or difficult-to-reverse technical choice,
use this Draft only to state the decision question and the product constraints, then invoke
`architecture-design` before this change can be approved. An ADR may be accepted before this change
exists; it does not need this change's delivery plan or future work items. Resume or create the
change after the ADR is accepted and committed, pin that revision, and restate only its resulting
constraints. Do not duplicate the ADR's alternatives or rationale, or defer a required ADR to
implementation review.

## Estimate workload

Estimate the change before approval as a planning range, not a delivery promise. Declare the local
person-month basis, confidence, assumptions, exclusions, contingency, and re-estimation trigger.
Do not invent a conversion to working days or hours. `plan-work-items` refines the approved range
into work-item ranges and flags material variance for renewed approval.

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

Complete when the review has no blocking finding, every required design field is resolved or
explicitly owned, one human-approved contract governs the delivery, and any no-delivery-change
conclusion or operational handoff has objective closure evidence.
