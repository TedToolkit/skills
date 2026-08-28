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

Read [change-development-workflow.md](../../references/workflow/change-development-workflow.md),
[testing-strategy.md](../../references/workflow/testing-strategy.md),
[agent-orchestration.md](../../references/orchestration/agent-orchestration.md), and
[work-item-agent-protocol.md](../../references/orchestration/work-item-agent-protocol.md). Read
[tool-state-layout.md](../../references/orchestration/tool-state-layout.md) before provisioning
worktrees or persistent run state.

## Confirm orchestration has value

Require an approved Controlled change, at least two approved work items, a valid map, and an
explicit current request to orchestrate or continue. Approval alone does not start workers. This
skill retains coordinator ownership even when only one item is dependency-ready. Run a one-item wave
serially on one disposable candidate branch in the clean integration worktree without creating a
worker or additional worktree. Keep the authoritative integration ref fixed until candidate proof
and review pass. Parallelize only when at least two ready bounded tasks, isolated agents/worktrees, and
plausible saved time or independent-review value exist. In a shared-worktree fallback, serialize
writers while preserving the same authoritative integration and status path.

Resolve the packaged [work-item validator](../../scripts/validate-work-items.sh),
[scheduler](../../scripts/schedule-work-items.sh),
[acceptance validator](../../scripts/validate-acceptance-specification.sh),
[state provisioner](../../scripts/ensure-tool-state.sh), and
[branch cleanup helper](../../scripts/cleanup-temporary-branch.sh) relative to this loaded
`SKILL.md` source path. Stop when a linked resource is missing; never require an installation-root
variable or guess/search a cache or developer checkout. For format 3, run
`bash "<resolved validate-work-items.sh>" <parent-change-directory>`. Then run
`bash "<resolved schedule-work-items.sh>" <parent-change-directory>`. For an explicit,
already-approved `change-format: 2` embedded map,
select the deprecated scheduler compatibility path and preserve its contract unchanged. Any scope,
contract, proof, map, or renewed-approval change must migrate to format 3.
Establish one clean authoritative integration branch and full SHA. Preserve a dirty baseline and
stop rather than stashing, committing, or mixing unrelated changes. Before the first worker
worktree is created in a repository, provision the repository-local worktree root as defined by the
work-item agent protocol by running
`bash "<resolved ensure-tool-state.sh>" worktrees`. Record the namespace-local
`.tedtoolkit/.gitignore` on the authoritative branch before pinning worker baselines; do not leave
that coordinator-owned setup as an uncommitted change or modify the root `.gitignore` for this
purpose.

Before dispatching the first writing worker, run the parent format-3 change through
`bash "<resolved validate-acceptance-specification.sh>" --require-ready --baseline
<authoritative-integration-sha> <change.md>`.
Cross-change readiness gates the whole parent change; item readiness cannot bypass it. Leave the
parent approved and report the concrete unmet source outcome when this check is blocked.
If the parent is an unchanged, tracked, active format-3 record that predates prerequisite markers,
the caller must explicitly select its known approved base. Pass
`--allow-approved-prerequisite-legacy <known-approved-base-sha>` to both `validate-work-items.sh`
and `schedule-work-items.sh`, then compose it with `--require-ready --baseline
<authoritative-integration-sha>` for acceptance validation. Resolve and record both full SHAs and
surface the `DEPRECATED` notice. Never infer the compatibility base; block a Draft, untracked
record, material revision, or default validation failure instead of dispatching work.

## Preflight the ready wave

Dispatch at most one read-only `implement-change` preflight per eligible item when collision
information is not already known. Require its change-kind loop, owned/supported contracts, primary
proof, conditional proof, anticipated write set, shared contracts/resources, commands, risks,
and escalation blockers. Keep one coordinator slot free and do not dispatch duplicate perspectives.

Build a runtime collision graph for shared source, tests, configuration, schemas, generated output,
contracts, ports, databases, or other exclusive resources. Collision edges serialize execution but
do not invent logical prerequisites. Partition a deterministic set of collision-free execution
groups. A group with one item is a valid serial wave; it does not leave this coordinator.

Present the wave and material newly disclosed risks. The current explicit orchestration request
authorizes ordinary private worker plans, branches, worktrees, and collision ordering inside the
approved item/map boundaries. Seek renewed approval only for a workflow escalation trigger.

## Execute isolated workers

For a one-item group, pin the latest verified integration SHA, create one exact recorded disposable
candidate branch from it in the clean integration worktree, and execute the bounded slice serially
without a worker or additional worktree. Commit, prove, and review that candidate while the
authoritative integration ref remains fixed. Switch back and fast-forward the authoritative ref only
after the candidate passes. For a group with two or more concurrent writers, create one branch/worktree per
item from that exact baseline. Put every worker worktree under the repository root's ignored
`.tedtoolkit/worktrees/` directory; do not scatter worker directories beside the repository or
directly across its root. A worker owns only its item and invokes `implement-change` with the
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

Preserve still-valid item-level code/test conclusions as inputs to the final integrated review when
the item patch, approved contract, and relevant baseline behavior have not changed. Focus the final
review on parent-contract coverage, integration-only diff, cross-item/shared-boundary interaction,
combined verification, documentation, and operational handoffs. A different commit SHA caused only
by integration does not invalidate equivalent evidence; a changed patch or relevant baseline
semantics invalidates only the affected judgments.

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
and recorded `Verified` in `work-items.md`. Once an accepted worker candidate is reachable from the
authoritative integration ref and its worktree is clean, remove that worktree without seeking a
separate cleanup approval. Never force-remove a dirty, blocked, stale, or evidence-bearing worktree;
retain it and report its exact path and reason.
Run change-level proof, confirm operational handoffs and documentation disposition, and invoke final
`review-implementation` in `integrated-change` mode with the independence level required by the
parent risk, against the parent contract, all non-superseded items, and the authoritative integration
SHA. After the integrated review is `Ready to merge`, set the parent change `implemented` when every
item and change-level gate is Verified on that SHA. Set it `completed` only after closure checks.
Completion does not itself authorize deleting the parent record; report eligibility-checked
post-merge `continue-change` cleanup as its next record-lifecycle action.
At successful completion, remove every remaining clean worktree created by this orchestration, run
`git worktree prune`, and verify that none remains registered beneath `.tedtoolkit/worktrees/`.
Then delete every worker or disposable candidate branch created by this orchestration whose tip is
reachable from the authoritative integration ref and which is no longer checked out, using
`bash "<resolved cleanup-temporary-branch.sh>" <authoritative-ref> <branch>` for each
exact recorded branch. This cleanup is part of the authorized temporary-resource lifecycle and
needs no separate approval. Never pass a pre-existing or unrecorded branch. Retain a branch when the
helper rejects it, and report its exact name and blocker; never force deletion or discard unique
commits merely to finish cleanup.

Complete when dependency order is respected, combined proof passes at the authoritative SHA,
central status matches repository evidence, and remaining risks/control artifacts are reported.
