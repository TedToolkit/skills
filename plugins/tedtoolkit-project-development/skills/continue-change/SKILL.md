---
name: continue-change
description: >-
  Resume one explicitly identified format-3 change from its persisted state and route exactly one
  user-authorized next phase. Use when the user references or @-mentions a change.md and asks to
  approve it, continue, resume, proceed, or determine the next step. Reconstruct state from the
  change and work-item artifacts rather than prior conversation, and never ask the user to choose
  an internal workflow skill.
---

# Continue One Change

Resume a persisted change without relying on the conversation that created it. This skill owns
state resolution and the user-facing continuation gate; the routed skill still owns its phase.

Read [change-development-workflow.md](../../references/workflow/change-development-workflow.md).
Identify exactly one `change.md` from the user's explicit path, @-mention, or attached repository
artifact. If no unique record can be established, ask for that path instead of guessing among
changes.

## Reconstruct current state

Read the identified change, its parent directory, `work-items.md` when present, referenced work-item
documents, repository guidance, and only the current delivery evidence needed by the resolved
phase. Do not require the originating conversation, copy conversation history into the record, or
infer approval from a Git SHA, an existing Draft, or prior agent claims.

Resolve the packaged [acceptance validator](../../scripts/validate-acceptance-specification.sh),
[work-item validator](../../scripts/validate-work-items.sh), and
[phase resolver](../../scripts/resolve-change-step.sh) relative to this loaded `SKILL.md` source
path. Do not require an installation-root variable or search for the plugin. Validate the change
first, then resolve its phase:

```text
bash "<resolved validate-acceptance-specification.sh>" <change.md>
bash "<resolved resolve-change-step.sh>" <change.md>
```

When `work-items.md` exists, also run
`bash "<resolved validate-work-items.sh>" <change-directory>` before routing.

Treat a nonzero result, contradictory markers, a missing required map, or more than one candidate
record as a blocker. The script derives the next action from persisted facts; never store a
duplicated `next-action` marker in the change.

## Separate approval from continuation

Approval records the contract only. It does not start planning, implementation, review, external
operations, or closure.

- `approve` or equivalent explicit approval: record the human approval source, set the Draft to
  `approved`, validate it, report the derived next action, and stop.
- `approve and continue`: record and validate approval, then execute exactly one derived phase.
- `continue`, `resume`, `proceed`, or a direct request for the resolved phase on an already-approved
  change: execute exactly one derived phase.
- Ambiguous praise, silence, a request to inspect status, or a request for the next action without
  execution does not authorize mutation.
- `continue` on a Draft is not approval. Present the approval boundary and stop.

Every phase ends by reporting current state, one derived next action, and the exact user action
needed. Do not present a menu of internal skills.

## Route exactly one phase

Use the resolver's action without asking the user to classify size or complexity:

| Resolved action | Behavior |
| --- | --- |
| `request-change-approval` | Present the approval-ready contract and ask only whether it is approved. |
| `implement-change` | Invoke `implement-change` for the approved single delivery. |
| `plan-work-items` | Invoke `plan-work-items` for the approved multi-item Controlled change; create a Draft map and stop before map approval. |
| `request-work-item-map-approval` | Present the complete enumerated map and ask only whether it is approved. |
| `orchestrate-work-items` | Invoke `orchestrate-work-items` for the approved map. |
| `review-implementation` | Invoke `review-implementation` against the exact candidate. If Ready, the delivery owner records `implemented`; otherwise retain `candidate-ready` or return to the owning phase. |
| `complete-change` | Verify required review, operational handoffs, durable documentation disposition, and exact candidate identity; then record `completed`, or report the exact blocker. When the same request explicitly authorizes a local commit containing that terminal record, finish the terminal commit-and-cleanup sequence below instead of leaving the record for another continuation. |
| `cleanup-change` | Treat delivery as terminal, inspect repository retention guidance and durable-extraction disposition, and run `cleanup-change.sh` without `--delete`. On an explicit cleanup request or explicit continuation of this already terminal change, rerun it with `--delete`; otherwise report eligibility or the exact blocker. |

If discovery changes behavior, scope, public or persisted contracts, security, migration,
dependencies, architecture, destructive actions, or external effects, stop and return to the
owning design or planning gate. A wrong user-suggested internal skill is not an instruction to
misroute: explain the derived action briefly and continue only when their request clearly
authorizes that action.

## Preserve resumability

For a single delivery, `implement-change` sets `in-progress` when target writes start and
`candidate-ready` after its primary and conditional proof pass and the candidate identity is
captured in `candidate-binding`. A later continuation then resolves to review. `implemented` means
required review passed against that binding; the next continuation owns closure. `completed` and
`superseded` are terminal delivery states whose persisted records route only to safe cleanup.

Cleanup supports structurally valid format-3 records. It never infers authority from completion,
review, approval, or merge alone. Before deletion, name the exact directory, classify repository
guidance as `cleanup` or `retain`, and confirm durable extraction as `captured` or `not needed`.
`Completed` already guarantees the extraction gate; `Superseded` requires the explicit helper flag
after the delivery owner establishes that disposition. Resolve the packaged
[cleanup helper](../../scripts/cleanup-change.sh) relative to this loaded `SKILL.md` source path,
then use:

```text
bash "<resolved cleanup-change.sh>" --retention-policy cleanup [--durable-extraction-confirmed] <change.md>
bash "<resolved cleanup-change.sh>" --retention-policy cleanup [--durable-extraction-confirmed] --delete <change.md>
```

The first command is the eligibility check; the second is allowed only by the explicit cleanup or
terminal-change continuation request. The exact clean target subtree must exist in the current
commit's Git history; it does not need to be reachable from the default branch. Preserve every
reported blocker and never substitute an archive directory.

### Finish a commit-authorized terminal change

An explicit local commit request whose inspected scope contains the identified delivery's terminal
format-3 record also authorizes cleanup of that exact change when repository guidance selects
cleanup. This includes a general request to commit the current changes after the terminal status edit
has been inspected and included. Treat it as one closure sequence with two atomic commits, not as a
reason to ask for another continuation:

1. Before committing, present the exact delivery commit and the deferred cleanup commit, including
   every path. The delivery commit contains the complete terminal record and all other authorized
   delivery paths; it must not delete the change directory.
2. Create and verify the delivery commit with the repository's authorized atomic-commit workflow.
   When no such workflow is available, ordinary non-interactive Git is allowed only if the index
   and worktree contain no unrelated paths; stage and commit only the exact presented delivery
   paths. Revalidate the exact `change.md` from `HEAD` and run the cleanup helper without `--delete`.
3. If eligible, rerun the helper with `--delete`, then immediately create and verify a separate
   cleanup commit containing only the deletion of that exact change directory. Use a concise
   `chore(workflow)` message that names the completed change.
4. Report both commits. If eligibility fails, keep the successful delivery commit and terminal
   directory, report the exact blocker, and do not weaken checks or rewrite history.

Commit authorization covering the terminal record is required for this chained sequence. A plain
`continue`, approval, review, completion, or merge still authorizes no commit and no implicit
deletion. Never sweep sibling changes or preparations into the cleanup commit.

Fast plans have no durable change record and cannot use this cross-conversation route. When the
user requires an @-addressable change or cross-conversation recovery, `design-change` uses a
Standard record even if the implementation is small.
