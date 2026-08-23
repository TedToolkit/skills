---
name: orchestrate-work-items
description: >-
  Coordinate execution and verified integration for every Controlled change with two or more
  approved work items. Run dependency or collision constrained waves serially; parallelize only when
  at least two ready isolated workers provide material value. Scale independent candidate review to
  material Controlled risk. Do not use for Fast, Standard, or single-delivery Controlled changes.
---

# Orchestrate Work Items

Parallelize isolated item ownership and serialize verified integration. This skill owns scheduling,
worktree allocation, collision analysis, integration, central status, and combined verification. It
does not implement production behavior or resolve semantic conflicts.

Read [change-development-workflow.md](../../references/change-development-workflow.md),
[testing-strategy.md](../../references/testing-strategy.md),
[agent-orchestration.md](../../references/agent-orchestration.md), and
[work-item-agent-protocol.md](../../references/work-item-agent-protocol.md).

## Confirm orchestration has value

Require an approved Controlled change, at least two approved work items, and a valid map. This skill
retains coordinator ownership even when only one item is dependency-ready. Run a one-item wave
serially. Parallelize only when at least two ready bounded tasks, isolated agents/worktrees, and
plausible saved time or independent-review value exist. In a shared-worktree fallback, serialize
writers while preserving the same authoritative integration and status path.

For format 3, run `bash "${CLAUDE_PLUGIN_ROOT}"/scripts/validate-work-items.sh
<parent-change-directory>`. For an already approved legacy format-2 embedded map, preserve its
contract and use the scheduler's compatibility path rather than manufacturing `work-items.md`.
Then run `bash "${CLAUDE_PLUGIN_ROOT}"/scripts/schedule-work-items.sh <parent-change-directory>`.
Establish
one clean authoritative integration branch and full SHA. Preserve a dirty baseline and stop rather
than stashing, committing, or mixing unrelated changes.

## Preflight the ready wave

Dispatch at most one read-only `implement-change` preflight per eligible item when collision
information is not already known. Require its change-kind loop, owned/supported contracts, primary
proof, conditional proof, anticipated write set, shared contracts/resources, commands, risks,
and escalation blockers. Keep one coordinator slot free and do not dispatch duplicate perspectives.

Build a runtime collision graph for shared source, tests, configuration, schemas, generated output,
contracts, ports, databases, or other exclusive resources. Collision edges serialize execution but
do not invent logical prerequisites. Partition a deterministic set of collision-free execution
groups. A group with one item is a valid serial wave; it does not leave this coordinator.

Present the wave and material newly disclosed risks. Approved item/map implementation already
authorizes ordinary private worker plans, branches, worktrees, and collision ordering. Seek renewed
approval only for a workflow escalation trigger.

## Execute isolated workers

For each group, pin the latest verified integration SHA and create one branch/worktree per item from
that exact baseline. A worker owns only its item and invokes `implement-change` with the
approved contract. Set the parent change `in-progress` when the first writing worker starts. Workers
read prerequisites from verified repository state, never another worker's message or unintegrated
branch.

Require candidate handoffs with exact revisions, actual artifacts, proof definitions and observed
verification results,
scope deviations or None, migration/documentation state, and temporary-artifact checks. A blocked
worker blocks only itself and real dependents.

## Review and integrate

1. Invoke `review-implementation` with `independent` required for candidates that change public or
   persisted contracts, security, migration, concurrency, shared cross-item boundaries, or another
   difficult-to-reverse concern. It decides which fresh `review-code`, `review-tests`, and
   `verify-implementation` lanes are material and synthesizes their conclusion. For bounded low-risk
   items, permit its `compact` mode.
2. Admit only candidates whose aggregate review passes and whose verification result is bound to the
   exact candidate. A worker success message or passing command alone is insufficient.
3. Assemble reviewed candidates one identifiable item at a time on a disposable wave-candidate
   branch rooted at the current verified SHA.
4. Replay stale candidates against the current candidate head. Any changed candidate, approved
   contract, or relevant baseline invalidates the prior aggregate conclusion; rerun verification and
   affected specialist review. Private conflicts return to the owning worker.
5. Mark an accepted item candidate `Implemented` only after its item-level proof and required review
   pass. This state does not unlock dependents.
6. On the final candidate, run validators, cross-item/shared-boundary proof, and proportional
   change-level regression. Do not blindly rerun unchanged item proof that remains valid.
7. Fast-forward the authoritative integration ref only after the combined result passes, then mark
   included items `Verified`. Only this state unlocks dependents.

## Route discoveries

- Private implementation conflict: owning worker adapts within the approved boundary and receives
  new review when tracked content changes.
- Changed item outcome, real prerequisite, delivery boundary, or proof standard:
  `plan-work-items` and renewed plan approval.
- Changed behavior, public/persisted contract, security, or migration: `design-change` and renewed
  approval.
- Enduring technical direction: `architecture-design`, then update affected delivery contracts.
- Individually passing items fail together: isolate hidden coupling; return to one owning worker
  only when its approved boundary clearly owns the fix, otherwise replan.

## Finish

Repeat until every non-superseded item has its required risk-scaled review, is integrated, verified,
and recorded `Verified` in `work-items.md`.
Run change-level proof, confirm operational handoffs and documentation disposition, and invoke final
`review-implementation` in `integrated-change` mode with the independence level required by the
parent risk, against the parent contract, all non-superseded items, and the authoritative integration
SHA. After the integrated review is `Ready to merge`, set the parent change `implemented` when every
item and change-level gate is Verified on that SHA. Set it `completed` only after closure checks.
Present temporary branches/worktrees for authorized cleanup only after their accepted commits are
reachable and no evidence exists solely there.

Complete when dependency order is respected, combined proof passes at the authoritative SHA,
central status matches repository evidence, and remaining risks/control artifacts are reported.
