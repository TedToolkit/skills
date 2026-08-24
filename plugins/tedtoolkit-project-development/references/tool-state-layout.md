# TedToolkit repository-local state

Use one repository-local `.tedtoolkit/` namespace for state created by TedToolkit workflows. Keep
product artifacts and ordinary ecosystem output in their owning locations; this namespace is not a
general replacement for `docs/`, `build/`, `bin/`, `obj/`, test-result directories, or user-selected
deliverable paths.

## Provision the namespace

Run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}"/scripts/ensure-tool-state.sh <preparations|runs|worktrees>
```

The helper creates the requested directory and maintains the tracked `.tedtoolkit/.gitignore` with
exactly the required transient-directory rules:

```gitignore
/worktrees/
/runs/
```

It preserves other existing namespace-local rules, never edits the repository root `.gitignore`,
and never substitutes a global ignore file or `.git/info/exclude`. Do not ignore all of
`.tedtoolkit/`; tracked preparation records and future approved configuration must remain possible.

Provision only an area an authorized workflow actually needs. Creating or updating a named tracked
preparation authorizes its namespace setup. An explicit continuation of an approved multi-item
implementation authorizes its worker-worktree setup. `runs/` remains optional: create it only when the user requested persistent
orchestration or approved local control-state persistence. Ordinary same-context handoffs stay in
the conversation and create no run directory.

For review or verification of an exact candidate, the canonical `.tedtoolkit/.gitignore` must
already be tracked on the bound baseline. If provisioning would change candidate content, a
write-authorized delivery owner must provision and record it before candidate binding, then bind the
new baseline. A read-only lane must instead return its report in the conversation; it never dirties
or invalidates the candidate merely to persist a result.

## Place state by ownership

```text
.tedtoolkit/
|-- .gitignore                         tracked namespace rules
|-- preparations/<slug>/preparation.md tracked multi-change preparation truth
|-- worktrees/<change-and-item-id>/     ignored worker checkout
`-- runs/<workflow-id>/                 ignored temporary local control state
```

`preparations/` contains the approved source partition, evidence index, lane status, and approval
source needed by humans and future repository sessions. It is temporary delivery control but is
version-controlled while active. New records use this path. Treat
`docs/change-preparations/<slug>/preparation.md` as a deprecated compatibility input: read it in
place when no write is needed; on the next authorized update to that preparation, move the complete
slug directory to `.tedtoolkit/preparations/<slug>/` before editing, update affected authorized
links, and stop on a destination collision rather than merging two records.

`runs/<workflow-id>/` may hold only approved local recovery material such as compact coordinator
state, frozen uncommitted candidate bundles and digests, and returned verification or review
manifests. Group candidate, verification, and review material beneath the one owning workflow
directory when separation helps; do not create empty subdirectories or a fixed schema that the run
does not need. A review or verification lane remains read-only and returns its report to the
delivery owner; the authorized delivery owner, not the specialist lane, persists it when needed.

`worktrees/` contains only worktrees created by the multi-item orchestration lifecycle. The
work-item protocol defines their naming, reachability checks, and cleanup.

## Preserve authority and clean up

Never put secrets, credentials, product source, ordinary build/test output, user deliverables, or
the only copy of approval or verification evidence in ignored state. A run manifest may point to
authoritative CI/raw-result locations but does not replace them. Git commits, approved human
records, and authoritative status remain outside ignored state.

After successful completion, remove the owning `runs/<workflow-id>/` only when every accepted
candidate is reachable or otherwise preserved and no required recovery evidence exists solely
there. Retain blocked, stale, dirty, or sole-recovery state and report its exact path and reason.
Preparation cleanup follows the repository documentation-retention policy because it is tracked.
Do not pre-create `cache/`, `logs/`, `tmp/`, locks, leases, receipts, or transaction state.
