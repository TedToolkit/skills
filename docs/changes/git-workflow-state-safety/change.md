# Preserve user-owned Git state during merge and grouped commits

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: bug-fix -->
<!-- change-status: completed -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User explicitly approved all 12 reviewed optimization contracts in the Codex task on 2026-08-26. -->
<!-- candidate-binding: workspace:1b9c12508c57c495c320ecad0ce54ec5375a03b8:sha256:56cbc51185a774aa36caa285a1c63ff616d1d81b7c85f1f8bb3dfe5ae1bfe33e -->

<!-- section: goal-rationale -->
## Goal and rationale

Git workflow skills modify history and the index only for paths and actions the user explicitly
authorizes, while preserving all other staged and unstaged state across successful and failed
grouped commits. Today a merge request implicitly authorizes committing the entire dirty tree, and
`commit_group.sh` clears the whole index before committing one group, so unrelated staged work or a
sensitive untracked file can be committed, unstaged, or otherwise disturbed without consent.

<!-- section: scope -->
## Scope and non-goals

- In scope: dirty-tree handling in `merge-default-branch`; explicit authorization for pre-merge
  commit choices; untracked-content boundaries; transactional index
  preservation in grouped commits; deterministic success and failure-injection proof; existing
  merge and commit-message regressions.
- Non-goals: changing conflict-resolution semantics, Release verification, push authorization,
  commit-message style, introducing a secret scanner, purging already committed secrets, defining
  a stash lifecycle, or implementing cross-shell helper portability.
- Compatibility or deliberately preserved behavior: clean-tree merges still fetch, reconcile,
  verify, and create the merge commit; a general explicit commit request still authorizes the exact
  groups presented by `generate-commit-message` when its candidate snapshot is unchanged; each
  approved group remains one atomic commit; all pushes remain separately authorized.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | Merge with pre-existing Git state | The merge request implicitly authorizes committing all dirty tracked and untracked content, and grouped commits reset the whole index | Merge and grouping mutate only explicitly authorized paths and actions; all other index and worktree state is preserved on success and failure | Clean merges, atomic approved groups, merge verification, conflict reconciliation, and push gates |

<!-- acceptance-case: AC-01 -->
### AC-01 — A merge request does not authorize pre-merge commits

```gherkin
Scenario: Merge while the worktree or index is dirty
  Given tracked, staged, unstaged, or untracked work exists before a default-branch merge request
  When the merge workflow reaches its preservation gate
  Then it leaves HEAD, the index, and worktree unchanged and requests a separate exact-path commit authorization or a user-cleaned tree before continuing
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Sensitive and untracked paths fail closed

```gherkin
Scenario: Dirty state includes an untracked path
  Given inspection and possible inclusion of that exact path have not been explicitly authorized
  When a merge or grouped-commit workflow inventories local work
  Then it reads only path metadata, neither stages nor commits the path, does not expose its contents, and reports the path-specific authorization blocker while preserving its original state
```

<!-- acceptance-case: AC-03 -->
### AC-03 — A successful grouped commit isolates the approved group

```gherkin
Scenario: Commit one group while unrelated staged and unstaged work exists
  Given exact group paths and a commit message are supplied to commit_group
  When the grouped commit succeeds
  Then the new commit contains exactly the group paths and every out-of-group index entry, staged blob and mode, unstaged file, deletion, rename, and untracked path retains its pre-call state
```

<!-- acceptance-case: AC-04 -->
### AC-04 — A failed grouped commit restores user-owned state

```gherkin
Scenario: Git fails after grouped-commit preparation begins
  Given the index contains unrelated staged state and failure is injected into staging or commit creation
  When commit_group returns failure
  Then no unintended commit remains and the complete pre-call index and all staged, unstaged, deleted, renamed, and untracked state are restored without changing worktree bytes
```

## Constraints and risks

- The Git index and untracked content are user-owned persisted state. Safety comparisons must cover
  both porcelain status columns, staged blob identity and mode, worktree bytes, deletions, renames,
  intent-to-add or equivalent index state when supported, and untracked presence without printing
  sensitive contents.
- Authorization follows one state machine. A request to merge or sync authorizes no pre-merge
  commit, stage, reset, stash, delete, normalization, or untracked-content read. The workflow may
  inventory status and untracked path metadata, then stops. Only a separately authorized commit of
  exact disclosed groups, or a tree the user cleans outside the workflow, permits fetch; staging
  alone is always insufficient because the pre-merge tree remains dirty.
- A general explicit commit request authorizes tracked-diff inspection and, after the exact paths and
  complete messages are shown, the unchanged disclosed commit plan. Every untracked path is
  content-sensitive by default: before reading it, the workflow must name the path and obtain
  explicit authorization to inspect and possibly include that path. Authorization to inspect is not
  authorization to commit unless the same response also says to include/commit it.
- Bind each plan to HEAD plus the path list and content/index identities used to form it. A change to
  any planned path or the addition of a new path invalidates the plan; re-inventory and re-present
  before committing. Out-of-group state is never included implicitly and is preserved by the helper.
- Failure handling must be tested after mutation has begun, not only through argument validation.
  Recovery must not depend on destructive worktree reset, rewriting unrelated commits, or silently
  discarding an index restoration error.
- The concurrent `shared-helper-portability` change may touch the same shared helper or launcher
  surface. That is an implementation collision to serialize or reconcile during integration, not
  a semantic prerequisite: this change consumes none of its contract outcomes.
- Any need to change public invocation syntax, introduce persistent backup state, or weaken exact
  state restoration is a renewed-approval trigger.

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from approved baseline `d3ddb70db54ba3d78a848e995b940f944a6cc7d6`.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target delivery area: shared Git workflow Skill instructions, the grouped-commit
  helper boundary, and hermetic Git eval fixtures establish one authorization and state-preservation
  guarantee.
- Other real start conditions or resource prerequisites: Git and Git Bash; a disposable repository
  capable of representing mixed staged/unstaged state, untracked and sensitive candidates, commit
  hooks or equivalent failure injection, and local bare-remote merge histories.
- Likely touchpoints (non-binding): `merge-default-branch`, `generate-commit-message`,
  `scripts/commit_group.sh`, `references/commit-style.md`, and their focused eval fixtures.
- Private implementation choices left open: index snapshot mechanism, restoration strategy,
  failure-injection seam, candidate-binding serialization, and whether shared mechanics use an
  existing or new helper after collision reconciliation.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=regression shape=integration -->
<!-- primary-proof: AC-02 purpose=boundary shape=integration -->
<!-- primary-proof: AC-03 purpose=acceptance shape=integration -->
<!-- primary-proof: AC-04 purpose=regression shape=integration -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | A dirty merge request creates no pre-merge commit or state mutation, does not fetch/build, and stops at an exact authorization gate; staging-only authorization still does not advance | `py -3.10 tests/run_evals.py --plugin tedtoolkit-shared merge-default-branch` |
| AC-02 | Primary | An unapproved untracked canary remains unread, uncommitted, byte-identical, absent from output, and absent from audited model command inputs | Focused merge eval plus `py -3.10 tests/run_evals.py --plugin tedtoolkit-shared generate-commit-message commit-group-state` |
| AC-03 | Primary | A successful helper run commits only its named group and an exact before/after state manifest matches for every out-of-group path | `py -3.10 tests/run_evals.py --plugin tedtoolkit-shared commit-group-state` |
| AC-04 | Primary | Injected stage and commit failures create no unintended commit and restore the exact pre-call index and worktree manifest | Same focused helper eval command |
| AC-01–AC-04 | Conditional regression | Existing clean, conflict-preserving, merge-build-repair, atomic grouping, and message-only behavior remains green; the old dirty-auto-commit scenario is deliberately replaced by AC-01 because its expectation was the defect | `py -3.10 tests/run_evals.py --plugin tedtoolkit-shared merge-default-branch generate-commit-message` |

Implementation evidence on 2026-08-27:

- AC-01 and merge regressions: the complete `merge-default-branch` suite passed 5/5 in
  `tests/.results/20260827-194254-428521-f294df77`. The result binds source HEAD
  `1b9c12508c57c495c320ecad0ce54ec5375a03b8` to 30 selected input files with digest
  `64696c4927081402f86d8732630cde5560ffc615415e367537c132984e5a093a`. The dirty scenario
  preserved HEAD, index, worktree, canary, fetch, and build boundaries; clean, conflict, and
  combined-build-repair scenarios all produced the required Release output. Every model scenario's
  command audit was complete; the dirty boundary retained two metadata-only command inputs.
- AC-02 and commit regressions: all three `generate-commit-message` scenarios passed in
  `tests/.results/20260827-193514-506402-f737890b`, bound to 29 selected files with digest
  `e3eb7940968820601447a55446944e7531d4b15cbc317bff8b45e9bbf0e0a3d0`. Atomic commit,
  message-only, and untracked authorization retained 58, 6, and 12 recognized command inputs,
  respectively; every audit was complete and none targeted or read the canary.
- AC-03 and AC-04: the expanded transactional helper eval passed 1/1 in
  `tests/.results/20260827-193536-024878-eb3dd07e`, bound to 29 input files with digest
  `fa6d99792e65cdfedd367d28319f906d71297f9a003d7542e88e258b4db9f3fa`. It covers ordinary
  and unborn-repository success; staging failure; an executed hook that mutates approved, staged,
  unstaged, and untracked paths; a successful hook that attempts to expand the commit; failures
  after the HEAD update with reflogs enabled and disabled; final-index synchronization failure; and
  a no-reflog external HEAD collision with the same parent and subject but a different tree. Every
  failure compares exact group and out-of-group index/worktree state, and recovery rewrites HEAD
  only when it still equals the exact commit object created by the transaction.
- Eval isolation and evidence identity: the runner installs a uniquely named candidate plugin,
  targets that Skill, ignores host execpolicy rules, and grants `workspace-write` only to the
  fixture and ephemeral plugin copy. Git-metadata writes use automatic approval review rather than
  full filesystem access. Each result records the selected input roots, source HEAD, file count,
  and deterministic SHA-256 identity; command-audit assertions fail closed when no recognized
  command input is captured.
- Conditional gates: `tests/test_run_evals.py` passed 15/15; all six candidate shell scripts passed
  `bash -n`; YAML and Python parsing, scoped `git diff --check`, and the metadata-only premerge guard
  passed. The runner retains command text only for explicitly marked synthetic fixtures and never
  persists command output. No cache, marketplace entry, credential, or temporary/debug artifact is
  in the candidate.

For workspace review, the bundle digest covers exactly 16 files: this `change.md`;
`plugins/tedtoolkit-shared/references/commit-style.md`; `scripts/commit_group.sh` and
`scripts/premerge_guard.sh`; both changed shared Skill files; `tests/run_evals.py` and
`tests/test_run_evals.py`; `tests/README.md`; both files in
`tests/tedtoolkit-shared/commit-group-state/`; both files in
`tests/tedtoolkit-shared/generate-commit-message/`; and all three files in
`tests/tedtoolkit-shared/merge-default-branch/`. Sort repository-relative UTF-8 paths ordinally,
then hash each path, exactly one byte `0x00`, the eight-byte big-endian content length, and raw
content bytes with SHA-256. Normalize only this change's `candidate-binding` marker to `none` before
hashing so the binding is non-recursive; a two-character backslash-plus-zero sequence is not the
separator.

<!-- section: completion-criteria -->
## Completion

AC-01 through AC-04 pass from the stated baseline, failure injection demonstrates restoration after
mutation begins, the dirty-auto-commit expectation is replaced, and clean/conflict/build merge plus
message-only and approved-commit regressions remain green. The exact
candidate receives independent Controlled implementation review; no sensitive fixture content is
printed or committed, no unrelated Git state changes, and the shared-helper collision is reconciled
without adding a cross-change prerequisite. No durable documentation extraction or operational
handoff is required beyond the updated canonical Skill and helper contract.
