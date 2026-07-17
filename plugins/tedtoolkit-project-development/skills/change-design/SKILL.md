---
name: change-design
description: >-
  Discover, specify, and design a product or library change before implementation. Use when a
  user asks to add, fix, refactor, migrate, plan, scope, design, or estimate a change; turn an issue or request into
  acceptance criteria; define APIs, behavior, migrations, risks, or a test strategy; or requests
  a change record. Use it for any planned delivery, from a small one-work-package change to a
  multi-work-package programme. Decide the work-package boundaries and dependency order within the
  change, then produce an approved implementation-ready design without implementing production
  code in this skill.
---

# Change Design

Turn every planned delivery into a change record with one or more small, reviewable work packages.
The change preserves the outcome, priority, planned approach, and delivery order; each work package
tells an implementer what observable behavior to build and how to prove it. A small change has one
work package, not a separate document format.

Treat the originating request, user outcome, deadline, and external hard constraints as inputs to a
change; they are not replaced by technical principles. Principles are the highest technical
governance layer. Architecture design refines them; this skill refines both into the only design
contract implementation may use.

## Establish the work-package boundaries

Before drafting, decide how many work packages the change needs.

- Use one work package when it has one coherent outcome, a bounded API or behavior surface, and one
  reviewable test map.
- Split work packages by observable outcome when public API families, migrations, foundations and
  consumers, or independently mergeable outcomes need separate review and implementation.

Do not split work packages by source directory, class, or person. Keep a foundation and its first
smallest consumer together only when that is the smallest way to prove the behavior end to end. Put
an enduring architecture or technology decision in an ADR through `architecture-design`, and link it
instead of copying its rationale into every work package.

## Keep dependencies inside one change

All planned dependencies belong in one change's delivery map. Do not create a change that requires
another planned or in-progress change: merge their work packages into one change, or defer the later
outcome until the earlier change is complete. Completed behavior, approved ADRs, stable architecture
records, and applicable principles are context, not change prerequisites.

Give every work package a `P0`–`P3` priority and concise rationale. Priority expresses urgency and
impact; the delivery map determines executable order, so an unmet prerequisite is completed before
its dependent package even when the dependent package has higher priority.

## Name every change by priority

Assign one change-level priority before creating its directory. This describes the urgency of the
change's outcome, not the priority of each individual work package. Use `P0` for an active critical
outage, security exposure, or hard external deadline; `P1` for material user, delivery, or risk
impact; `P2` for planned valuable work; and `P3` for a deferrable improvement.

Use `docs/changes/<P0-P3>-<change-slug>/`. For example, `docs/changes/P1-temperature-parsing/`.
When the request, repository evidence, and known constraints do not establish a priority, ask the
user for it before creating or renaming the change directory. Do not silently assign a priority just
to complete the document. Record the same priority and rationale in the change index so the folder
name and content remain traceable.

## Inspect and clarify before drafting

1. Read repository guidance, applicable design principles, current architecture records, the
   affected public API and its callers, relevant tests, documentation, dependency files, and recent
   adjacent changes when available.
2. State the user outcome, in scope work, explicit non-goals, compatibility expectations, and
   constraints. Ask about any missing point that would materially change behavior, public API,
   persistence, security, or rollout.
3. Identify the status quo and the smallest credible alternatives. Preserve established conventions
   when they meet the need.
4. Classify the change. A small, reversible internal change may use a concise change design.
   A public, cross-cutting, stateful, security-sensitive, or difficult-to-reverse change needs a
   fuller design with migration and rollback.
5. Make every applicable principle and architecture constraint explicit in the change index or
   work package. Record the full Git commit SHA of each approved governing document and restate the
   resulting implementation constraint; do not defer interpretation to implementation or use a link
   alone as a constraint. A document without an approved committed revision cannot be a pinned
   baseline for an approved change.

## Write the design package

Copy `assets/change-design-template.md` to `docs/changes/<P0-P3>-<change-slug>/README.md`, and copy
`assets/work-item-template.md` for each work package to
`docs/changes/<P0-P3>-<change-slug>/work-items/<ID>-<slug>.md`. Use the nearest existing documentation
convention when one exists. Give a one-work-package change the same structure; do not create a
standalone `docs/changes/<type>-<slug>.md` document. Write in the user's requested language, or the
nearest documentation language when none is specified. Preserve the template's fixed semantic emoji
prefixes when translating headings. Use emoji only in headings; do not add decorative emoji to file
names, statuses, table values, commands, identifiers, or prose.

Fill only sections that affect a decision or implementation. The document must contain:

1. Change outcome, scope, non-goals, planned approach, and completion criteria.
2. A dependency-ordered delivery map with every work package's priority, rationale, status, and
   document path.
3. For every work package: current-behavior evidence and impact boundary, one observable outcome,
   scope and non-goals, behavior cases, an implementation contract, a behavior-first verification
   plan, workload estimate, and material migration, rollback, risks, or open questions.

Record the parent change, priority, prerequisite work packages, and linked principles, ADRs, or
architecture records in each work package. Record a plan blocker in the change index only when it
prevents a work package from starting; name the blocked packages and the next action, but do not
duplicate decision rationale or alternatives there.

## Estimate workload

Estimate every change and work package before approval. An estimate is a planning range, not a
delivery promise or elapsed-calendar forecast. Declare the local person-month basis rather than
inventing a conversion to working days or hours.

- Give each work package a lower and upper person-month estimate, confidence, assumptions, and
  excluded work.
- Calculate the change range from the work-package ranges, then add separately estimated
  coordination, verification, migration or rollout work, and explicit contingency. Do not hide
  those costs inside a work package or simply sum likely values.
- Ask for the missing scope, ownership, dependency, quality requirement, or estimation basis when
  it prevents a credible range. Do not mark a change approved with an omitted estimate.
- Record actual effort and the reason for a material variance on completion. Use recurring variance
  as evidence to improve future estimates, not to rewrite past estimates.
- Re-estimate and obtain approval again when scope, dependencies, quality constraints, or the total
  planning range materially changes. Treat an increase beyond the approved upper bound as material
  unless the repository defines a stricter threshold.

Add a short documentation-disposition forecast when the design is likely to leave durable records.
State which current behavior belongs in code documentation or tests, which repository-wide default
may need a principle, which cross-cutting rule may need an architecture record, which difficult-to-
reverse choice may need an ADR, and whether the design itself is likely to be deleted after
implementation. This is a forecast for human reviewers, not authorization to move, archive, or
delete documents.

Use examples, sequence diagrams, or tables only when they remove ambiguity. Keep the design tied to
repository evidence; flag an unknown rather than inventing a dependency, API, performance target,
or operational guarantee.

## Handle technology decisions separately

When the change needs a new package, framework, service, vendor, architectural layer, or another
enduring technical decision, stop treating it as an implementation detail. Invoke
`architecture-design` to create the appropriate ADR and, when needed, its technology-selection
evidence, then link its decision
from the change design. Do not select a technology on intuition alone.

An **Architecture Decision Record (ADR)** is the durable source of truth for an accepted,
difficult-to-reverse architecture or technology decision. It records the context, alternatives
materially considered, the decision, consequences, and status. Do not create an ADR for every local
implementation choice or abandoned sketch. Ordinary discarded change drafts are removed when they
no longer describe planned work; Git history is sufficient. Do not create `docs/history/`. When an
accepted ADR is replaced, retain it with status `Superseded`, link its replacement, and state why the
decision changed.

## Approval gate

Before creating or editing production code, tests, packages, infrastructure, or project structure,
present the design draft with:

1. Scope and non-goals.
2. Behavior cases and their verification mapping.
3. Proposed component/API changes and significant alternatives rejected.
4. Applicable principles and architecture records, including every deliberate exception.
5. Change and work-package workload estimates, assumptions, confidence, and exclusions.
6. Risks, migration or rollback, and unresolved questions.

Wait for explicit user approval. Approval makes the design an input to `implement-change-tdd`; it
does not authorize unrelated changes. If implementation reveals a material mismatch, update the
design and obtain approval again before proceeding.
