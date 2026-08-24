---
name: implement-change
description: >-
  Implement one approved Fast plan, Standard change, single-delivery Controlled change, or selected
  Controlled work item with proof scaled to its change kind and risk. Use for behavior changes, bug
  fixes, behavior-preserving refactors, maintenance, migrations, and bounded experiments. Choose the
  loop that matches the change kind rather than forcing TDD or fixed test layers.
---

# Implement a Change with Proportionate Proof

Implement one approved delivery boundary and preserve its contract. Read
[change-development-workflow.md](../../references/change-development-workflow.md) for profile,
authorization, and escalation rules. Read [testing-strategy.md](../../references/testing-strategy.md)
for proof purpose, execution shape, and change-kind loops.

This skill owns private implementation choices and concrete verification for:

- an explicitly approved Fast plan;
- one approved Standard `change.md` with an embedded delivery brief;
- one approved single-delivery Controlled `change.md`; or
- one selected approved work item in a multi-item Controlled change.

Do not demand a work item for Standard or single-delivery Controlled work. Do not implement directly
from a multi-delivery change record without one selected approved item.

## Establish the boundary

Read repository guidance, the approved plan/change/item, relevant production code, adjacent tests,
build configuration, and public compatibility rules.

Confirm:

1. the profile, change kind, one outcome, scope, non-goals, and constraints;
2. that the selected document is the authorized boundary for this profile;
3. real prerequisites are completed and evidenced;
4. every owned `AC-<number>`, `INV-<number>`, `STR-<number>`, or `EXP-<number>` has credible primary proof;
5. conditional boundary, migration, structural, or regression evidence follows actual risk; and
6. implementation does not require a material escalation.

For a format-3 multi-item change, run
`bash "${CLAUDE_PLUGIN_ROOT}"/scripts/validate-work-items.sh <parent-change-directory>` and require
completed integrated prerequisites. For an explicit, already-approved `change-format: 2` embedded
map, select the deprecated compatibility path and preserve the contract unchanged. Any scope,
contract, proof, map, or renewed-approval change must migrate to format 3.
For Standard or a single-delivery Controlled change, validate its supported format and use its
embedded delivery brief directly.

For every format-3 implementation boundary, capture the full implementation baseline SHA before
changing lifecycle status or target artifacts, then run:

```text
bash "${CLAUDE_PLUGIN_ROOT}"/scripts/validate-acceptance-specification.sh \
  --require-ready --baseline <full-implementation-baseline-sha> <change.md>
```

Use `--allow-approved-prerequisite-legacy <known-approved-base-sha>` only for an unchanged active
format-3 record that predates prerequisite markers; record that compatibility choice in the
handoff. For a multi-item parent, pass the same explicit option to `validate-work-items.sh` before
running candidate-bound readiness; never let the structural preflight silently drop it. A nonzero
validation or readiness result blocks implementation, does not change the approved status, and
returns the exact unmet source contract to `scope-changes` or `design-change`. Never accept an
uncommitted upstream status edit, another worker's message, priority, or preferred sequence as
readiness evidence.

Inspect the code and choose concrete tests, files, private symbols, algorithms, and behavior slices.
Treat evidence-backed likely touchpoints as helpful, non-binding orientation. Prefer repository
conventions and the smallest design that satisfies the approved result.

Present a concise local plan containing the loop, primary proof, conditional gates, likely files,
shared resources, and risks. After implementation was already authorized, this preflight is
informative: continue without another approval unless it reveals a workflow escalation trigger.

## Justify the implementation shape

Use the smallest design that clearly satisfies the approved result and repository conventions, not
the design with mechanically fewest lines. Before adding or retaining a production type, member, or
abstraction, identify its present responsibility, caller, or boundary and compare it with a direct
change to the existing design:

- Add a class, record, module, or similar type only when it owns a cohesive responsibility, state,
  lifecycle, policy, or boundary that does not fit an existing owner without materially weakening
  cohesion. Do not create a single-use wrapper or data carrier when the existing design already has
  a natural owner.
- Extract a function or method when it names a meaningful operation, removes real duplication,
  isolates a non-trivial decision or side effect, or serves an actual caller. Keep simple one-use
  logic inline when extraction would only add navigation or forwarding.
- Add an interface, base type, factory, adapter, or other indirection only for an evidenced boundary,
  substitutability need, lifecycle, dependency rule, or integration constraint. Neither a possible
  future use nor the current number of implementations decides this by itself.
- Choose the narrowest accessibility supported by real callers and required tooling. Do not widen
  production visibility solely for tests. A new or widened public or protected surface must already
  belong to the approved contract; otherwise stop on the public-contract escalation trigger.

After proof is Green, remove superseded helpers, forwarding layers, duplicated paths, and speculative
extension points. Do not split or combine code to satisfy arbitrary size, type-count, or method-count
thresholds.

## Use the change-kind loop

### Behavior change

1. Establish the primary proof Red for one observable result.
2. Use the smallest useful Unit, Component, Contract, or Integration inner Red when it helps localize
   deterministic behavior or a real boundary.
3. Make the smallest production change that turns it Green.
4. Refactor while relevant proof remains Green.
5. Run conditional proof and affected regression.

The primary proof may itself be a Unit- or Contract-shaped test through a stable public boundary;
do not duplicate it into a separate Acceptance suite.

### Bug fix

1. Reproduce the root cause with the narrowest reliable failing proof.
2. Confirm the failure represents the approved defect rather than unrelated compilation or
   infrastructure failure.
3. Make the smallest fix.
4. Run the reproduction and affected regression Green.

### Behavior-preserving refactor

1. Establish existing characterization or named invariants Green.
2. Add focused characterization only where current behavior is material and unprotected.
3. Refactor in small steps while the proof remains Green.
4. Run affected structural and regression gates.

Do not manufacture a failing test for behavior that must remain unchanged.

### Maintenance

Verify the relevant build, analyzer, formatter, link, documentation, generated output, or structure
state; make the mechanical change; verify again. Do not invent a behavioral test when the approved
result is completely structural.

### Migration

Establish transition, compatibility, and recovery proof; implement the smallest migration slice;
verify old/new states and rollback or recovery as approved. Stop if real data or operational
authority is missing.

### Experiment

Run the approved bounded method against its representative evidence, thresholds, and stop condition.
Record the result and downstream decision without modifying production behavior. A successful
experiment still requires a separate approved behavior-changing change before adoption.

## Select evidence without layers for their own sake

Use one primary proof per owned contract row. Add:

- regression proof for a bug or materially touched existing behavior;
- Contract or Integration proof only for a changed real boundary;
- Unit proof only when deterministic logic benefits from focused protection;
- End-to-end proof only for a critical deployed journey that narrower proof cannot establish;
- structural verification required by the repository or affected artifact; and
- bounded manual procedure only when automation is disproportionate or cannot observe the result.

Default to the repository's existing test project. Do not create separate Unit, Integration, or
Acceptance projects unless their environment, lifecycle, resources, cadence, isolation, or
ownership materially differs. When the repository uses TUnit and `tunit-testing` is available,
invoke it for framework-specific layout and mechanics. Otherwise follow evidenced repository
conventions, keep the proof framework-neutral, and report the missing specialist coverage.

## Work as an isolated parallel worker

When dispatched by `orchestrate-work-items`, read
[agent-orchestration.md](../../references/agent-orchestration.md) and
[work-item-agent-protocol.md](../../references/work-item-agent-protocol.md), then obey their branch,
worktree, baseline, context, and coordinator-ownership rules. Own one item only. Read prerequisites
from the verified integration baseline, not another worker's message or branch.

In read-only preflight mode, return the loop, primary/conditional proof, anticipated artifacts,
shared contracts/resources, commands, risks, and escalation blockers. In execute mode, require the
approved item/map and integration constraints; a redundant second approval of unchanged private
implementation detail is not required. Conflict rework needs renewed approval only when its delta
crosses a workflow escalation trigger.

Return a provisional candidate handoff with baseline and candidate revisions, actual artifacts,
proof definitions, implementation-context verification results, scope deviations or None,
migration/documentation state, and temporary-artifact check. This handoff does not establish review
independence or test adequacy. `review-implementation` selects compact or independent specialist
lanes; after candidate-bound verification and required review pass, the coordinator may mark the
item `Implemented`. Only verified integration on the authoritative revision may mark it `Verified`
and unlock dependents. The coordinator updates status only in `work-items.md`.

## Finish

Run the narrowest primary proof first, then required conditional gates, repository build, and
broader regression proportional to impact. When a selected test command is expected to discover
tests, treat zero discovered intended tests as failure. Structural-only maintenance does not require
a test command when its approved proof is a build, analyzer, formatter, documentation, or structure
check.

Record actual changed artifacts, proof purpose and execution shape, command or procedure, observable
assertion, candidate-bound results/counts, resource prerequisites, migration/documentation state, and
remaining risks. Keep process narration out of the human change/item; update only current completion
truth and put only necessary candidate or integration state in coordinator-owned control state.
When that state is persisted with approval, use `.tedtoolkit/runs/<workflow-id>/` through the shared
tool state layout; do not make the worker or reviewer a second status owner.

Stop for renewed approval only on a workflow escalation trigger. For a single delivery, set the
change to `in-progress` when target work starts. After primary and conditional proof pass, the diff
stays inside the approved boundary, and temporary/debug artifacts are absent, return the exact
candidate to `review-implementation`; do not mark it `implemented` yet. The user-facing delivery
owner sets `implemented` only after candidate-bound verification and required review pass, then sets
`completed` after operational handoffs and durable documentation disposition close on that exact
revision. Under parallel execution, return the candidate for review and verified integration; do
not update the parent status independently.
