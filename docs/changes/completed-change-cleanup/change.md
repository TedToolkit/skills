# Remove completed change records after delivery

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: completed -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved the proposed completed-change cleanup principle and implementation in the Codex task on 2026-08-26. -->
<!-- candidate-binding: workspace:60b9c195589fb173181c718ea380acb72bc01066:sha256:17bdff7fba324aa83daff3503a8ad73937c78eba52d9b254a39d9ca641145af1 -->

<!-- section: goal-rationale -->
## Goal and rationale

`docs/changes/` remains an active-delivery workspace instead of accumulating completed process
records. Today the workflow calls changes temporary but retains them by default and routes terminal
records to no action, contradicting the documented use of Git history for delivery recovery.

<!-- section: scope -->
## Scope and non-goals

- In scope: the default retention rule for completed and superseded changes; safe post-merge cleanup;
  lifecycle routing; prerequisite and preparation-reference protection; review disposition;
  tracked preparation cleanup alignment; documentation and regression proof.
- Non-goals: automatic commits, merges, pushes, scheduled cleanup, a completed-change archive,
  deletion of active or unmerged records, redesign of prerequisite markers, or removal of Git
  history.
- Preserved: change approval and implementation gates, `Completed` as a lifecycle and prerequisite
  readiness state, repository-specific mandatory retention policies, and read-only review ownership.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Change-document lifecycle after delivery | Terminal records have no next action and are retained when no policy exists | Eligible terminal records route to deterministic cleanup and are absent from the current tree after authorized cleanup | Git history remains the recovery source and active workflow evidence is not deleted |

<!-- acceptance-case: AC-01 -->
### AC-01 — Default to cleanup

A structurally valid format-3 completed or superseded change is reported as eligible for deletion
rather than retained by default when its exact current directory is already present on the
authoritative default-branch ref, durable extraction is complete, its own subtree is clean, and no
tracked workflow record references it.

<!-- acceptance-case: AC-02 -->
### AC-02 — Protect required evidence

Cleanup refuses an active, legacy-format, unmerged, target-modified, path-escaping, policy-retained,
or still-referenced change and reports the exact blocking condition without deleting any record.
Any other `docs/changes/*/change.md` prerequisite marker that resolves to the target pins it while
that dependent remains in the current tree, including a terminal dependent. Any tracked
`.tedtoolkit/preparations/**` record containing the target's normalized repository-relative path
also pins it regardless of preparation status. Terminal dependents and preparations are cleaned
before the records they reference.

<!-- acceptance-case: AC-03 -->
### AC-03 — Delete only the authorized change

An explicit cleanup request, or an explicit `continue` on an already terminal identified change,
authorizes removal of exactly the eligible `docs/changes/<stable-slug>/` directory, including its
work-item records, while preserving sibling changes and Git history. Completion, review, approval,
or merge alone does not authorize deletion.

<!-- acceptance-case: AC-04 -->
### AC-04 — Keep workflow ownership coherent

Design, implementation, final review, continuation, orchestration, and preparation guidance agree
that durable knowledge is extracted before cleanup, reviewers only recommend disposition, and the
delivery owner performs post-merge deletion without creating an archive.

## Constraints and risks

- Treat cleanup as a recoverable but destructive tracked-file action: validate the exact target and
  all blockers before removing anything. Cleanup supports structurally valid format-3 records only;
  legacy records require a separately inspected explicit cleanup request.
- A terminal source change remains temporarily while any tracked dependent change or preparation
  references it; this is dependency pinning, not documentation retention. Clean terminal referrers
  first so no record left in the current tree becomes structurally invalid.
- A repository may override deletion only through explicit governing guidance that requires
  retention; absence of policy means cleanup.
- The caller resolves and supplies the authoritative local default-branch ref from repository
  guidance or the remote default. Cleanup requires the target directory's index and working-tree
  contents, including untracked files, to be clean and byte-equivalent to that ref. This supports
  ordinary and squash merges without inferring merge from lifecycle status or commit ancestry.
- Existing unrelated working-tree changes outside the exact target subtree are user-owned, do not
  block cleanup, and must remain untouched.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. This delivery starts from the user-approved repository baseline.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome: make completed-change cleanup the safe default and expose it through the existing
  continuation router.
- Likely touchpoints (non-binding): workflow and state references, continuation and review skills,
  resolver and a deterministic cleanup helper, README/scaffolding guidance, workflow-script and
  skill eval fixtures.
- Private implementation choices left open: helper decomposition, reference scanning mechanics,
  and fixture organization.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=acceptance shape=component -->
<!-- primary-proof: AC-02 purpose=boundary shape=integration -->
<!-- primary-proof: AC-03 purpose=acceptance shape=integration -->
<!-- primary-proof: AC-04 purpose=structural shape=component -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Terminal lifecycle resolves to cleanup and documentation defaults to deletion | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts` |
| AC-02 | Primary | Every unsafe fixture fails without changing its target or siblings | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts` |
| AC-03 | Primary | One eligible fixture loses only its selected change directory | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts` |
| AC-04 | Primary | Owning skills and documentation expose one consistent lifecycle | `py -3.10 tests/run_evals.py --plugin tedtoolkit-project-development workflow-scripts` |

Conditional proof: shell syntax validation, link/reference search, complete diff inspection, and
independent implementation review because deletion behavior crosses several workflow owners.

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-04 pass, unsafe deletion paths are fail-closed, documentation contains no default
retain contradiction, the complete diff receives independent review, and no new temporary artifact
or completed-change archive remains.
