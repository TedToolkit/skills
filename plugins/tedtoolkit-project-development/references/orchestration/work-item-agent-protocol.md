# Work-item agent protocol

This protocol coordinates an approved multi-item Controlled change. Read
[agent-orchestration.md](agent-orchestration.md) first; its scheduling, context, ownership, review,
and recovery rules are authoritative. Read [tool-state-layout.md](tool-state-layout.md) for the
repository-local namespace, provisioning, and common cleanup rules.

## Boundary and authority

| Role | Owns | Does not own |
| --- | --- | --- |
| Integration coordinator | Ready queue, worktrees, runtime collisions, integration, `work-items.md` status, and combined verification | Production semantics or independent review |
| Implementation worker | One approved item on one branch and worktree | Other items, integration branch, or map status |
| Review specialist | Code correctness, test adequacy, or both as distinct judgments for one exact candidate | Implementation, status, merge, or approval |
| Verification executor | Candidate-bound command/procedure results | Test adequacy, fixes, merge conclusion, or approval |
| Review coordinator | Risk routing, contradiction resolution, and the aggregate conclusion | Implementation, item status, merge, or human approval |

`work-items.md` is the only mutable item-status source. Approved item documents are delivery
contracts; workers record candidate verification results in their handoff or coordinator-owned control state,
not by racing to update shared status.

The integration coordinator is the sole writer of the authoritative integration branch and delivery map. A
worker owns one item, branch, and worktree. Dependents consume prerequisites only from a verified
integration SHA, never another worker's message or unintegrated branch.
The integration coordinator also advances the parent change from `approved` to `in-progress`, `implemented`,
and `completed` at the lifecycle gates defined by the shared workflow.

## Schedule only useful concurrency

Require at least two approved items. Keep one integration coordinator for the whole map. Compute
logical readiness from real prerequisites, then run one
bounded read-only preflight for each ready item when collision information is not already known.

Build a runtime collision graph across source, tests, documentation, configuration, schema,
generated output, shared public contracts, and exclusive test resources. Connected items run in
separate execution groups; this ordering does not create a logical prerequisite.

Parallelize only collision-free items in isolated worktrees. A one-item ready wave remains under the
same coordinator and runs serially. If isolation is unavailable, serialize writes. Keep one
coordinator slot free and prefer breadth across distinct items over duplicate perspectives on one
item.

### Repository-local worktree lifecycle

Use `<repository-root>/.tedtoolkit/worktrees/<change-and-item-id>` for every worker worktree. Before
the first `git worktree add`, provision the directory with `bash
"${CLAUDE_PLUGIN_ROOT}"/scripts/ensure-tool-state.sh worktrees` and record the resulting tracked
`.tedtoolkit/.gitignore` on the authoritative integration branch before pinning worker baselines.
The shared layout owns ignore-file contents and prevents root/global ignore pollution.

Treat worktrees as temporary execution state. After a candidate is accepted, first verify that its
commits are reachable from the authoritative integration ref, its required evidence is recorded
elsewhere, and the worktree is clean; then remove it with `git worktree remove`. After successful
parent completion, remove every remaining clean worktree created for the change, run
`git worktree prune`, and verify none is registered below `.tedtoolkit/worktrees/`. Cleanup needs no
additional approval because it is part of the authorized worktree lifecycle. Never force-remove a
dirty, blocked, stale, or sole-evidence worktree. Retain it and report its exact path and blocking
reason so recovery remains possible. Do not delete temporary branches unless separately authorized.

## Dispatch and handoff

Every worker packet follows the shared context schema and adds:

```text
Parent change and selected work item
Verified integration baseline SHA
Worker branch and worktree
Owned and supported contract IDs
Known runtime collisions or exclusive resources
Approved implementation boundary and escalation triggers
```

Preflight returns the change-kind loop, anticipated write set, primary proof, conditional gates,
shared contracts/resources, commands, and blockers. It is informative after plan approval; seek new
human approval only for changed behavior, scope, public or persisted contracts, security, migration,
real prerequisites, enduring architecture, destructive action, or external side effects.

Execution returns candidate SHA, actual changed artifacts, exact proof commands and results,
deviations or None, migration/documentation state, and temporary-artifact status.

## Review proportionately

Invoke `review-implementation` with `independent` required for a candidate that changes a public or
persisted contract, security, migration, concurrency, a shared cross-item boundary, or another
difficult-to-reverse concern. It dispatches fresh `review-code` and `review-tests` SubAgents only
when additional contexts materially improve expertise, context isolation, or dispute resolution. One
fresh review context may perform both judgments serially and keep their conclusions distinct. It
obtains candidate-bound results from the same reviewer, `verify-implementation`, or equivalent CI,
and synthesizes the only final conclusion. For a bounded low-risk item with direct proof and no
shared boundary, the delivery owner may perform the same checks in `compact` mode.

Specialist lanes receive the exact range and raw contract/artifacts without implementer narration or
sibling findings. Review pins the exact baseline-to-candidate range and approved contract; a change
to either makes the aggregate conclusion stale. A worker declaring success is a candidate, not
integrated completion.

## Integrate from one verified state to the next

1. Start a disposable wave candidate from the current verified integration SHA.
2. Apply accepted item candidates in deterministic order, preserving one identifiable integration
   unit per item.
3. If replay changes a candidate diff or its relevant baseline behavior, return it to the owning
   worker and rerun affected proof and review. A clean replay needs only affected regression checks.
4. After item-level proof and required review pass, mark the item `Implemented` in the disposable
   wave candidate. This state does not satisfy prerequisites.
5. On the combined candidate, run validators, cross-item or shared-boundary proof, and proportional
   change-level regression. Do not blindly rerun every unchanged item proof when its candidate
   evidence is still valid on the combined baseline.
6. Advance the authoritative integration ref only after the combined candidate passes, then record
   included items as `Verified` on that authoritative revision. Only `Verified` items satisfy
   prerequisites. A `Superseded` item does not satisfy dependents unless the approved map names a
    verified replacement and supplied input.

The final integrated review reuses item judgments when their patch, approved contract, and relevant
baseline behavior are unchanged. It concentrates on parent coverage, integration-only differences,
cross-item interaction, combined proof, documentation, and operational handoffs. Integration-only
SHA changes do not invalidate equivalent evidence.

If one candidate fails, omit it and real dependents. Independent accepted candidates may form a
smaller verified wave. Preserve a failed candidate until diagnosis is recorded or cleanup is
authorized.

## Route discoveries

| Discovery | Route |
| --- | --- |
| Private implementation conflict inside one approved boundary | Owning worker adapts through TDD; repeat review only when risk or tracked diff warrants it |
| Changed item outcome, prerequisite, delivery boundary, or proof standard | `plan-work-items` and renewed map approval |
| Changed behavior, public/persisted contract, security, or migration semantics | `design-change` and renewed design approval |
| New enduring technical direction | `architecture-design`, then update affected delivery contracts |
| Individually passing items fail together | Isolate the shared interaction; assign it to an existing owning boundary or replan |

The candidate being integrated owns an ordinary private conflict because accepted integration units
are fixed inputs to its new baseline. The coordinator supplies evidence but does not choose product
semantics.

## Finish and recover

Repeat until every non-superseded item is `Verified` and its authoritative map status and evidence
match repository state. Run final change-level proof, review the integrated parent change, and
confirm operational handoffs and durable documentation disposition before recording the parent
change `Completed`.

Resume from the authoritative integration SHA, `work-items.md`, worker branches, candidate SHAs,
review reports when required, and candidate-bound command results. Apply the repository-local
worktree lifecycle above during both resumed execution and cleanup.
