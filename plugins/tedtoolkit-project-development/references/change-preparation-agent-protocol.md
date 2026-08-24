# Change-preparation agent protocol

This protocol prepares one genuinely multi-outcome request into independent changes without loading
the whole request and every agent conversation into every context. Read
[agent-orchestration.md](agent-orchestration.md) first; its scheduling, context, ownership, review,
and recovery rules are authoritative. Read [tool-state-layout.md](tool-state-layout.md) before
creating or resuming a persistent preparation.

## Boundary and roles

Preparation stops before implementation. It may investigate, partition, draft approved candidate
changes, and route each change through design and planning.

| Role | Owns | Does not own |
| --- | --- | --- |
| Preparation coordinator | User dialogue, source coverage, ready queue, `preparation.md`, partition decisions, approvals, and lane status | Change content, independent review, or implementation |
| Outcome investigator | One candidate outcome and one evidence question | Writes, user intent, or sibling-wide synthesis |
| Partition challenger | One overlap, dependency, coverage, or release-boundary question across at most two candidates | Writes, grouping decisions, or approval |
| Change author | One candidate's `change.md` after its creation is authorized | Sibling changes, scheduling, review, or implementation |

Only the coordinator contacts the user. Use flat short-lived workers and one writer per artifact.
Different change files may be written concurrently when their write sets are disjoint; the
coordinator is the only writer of `preparation.md`.

## Decide whether preparation is worth its cost

Use this protocol only when evidence suggests at least two independently valuable outcomes, a
material partition ambiguity, or a real need to recover several concurrent lanes. Route one clear
goal through the no-artifact `scope-changes` fast path to `design-change`. Do not create a one-lane
preparation record merely to use agents.

Before dispatch, identify at least two ready bounded questions. If every next step depends on one
user answer, ask it directly. Stop fan-out when existing evidence covers the partition decision or
remaining uncertainty needs user authority.

## Persist only useful control state

Create `.tedtoolkit/preparations/<slug>/preparation.md` only after the user explicitly requests
persistent preparation or approves that artifact. Provision it with `ensure-tool-state.sh
preparations`. New records never use `docs/change-preparations/`; apply the legacy read/migrate rule
in the tool state layout when an existing preparation uses that path. The preparation contains:

- repository baseline for technical investigation and the explicit human approval source;
- source intent and hard constraints;
- compact material decisions and evidence paths;
- candidate outcomes and their source coverage;
- semantic relationships and collision notes;
- proposed change set, lane state, and blockers; and
- partition approval when one is required.

Do not store writer leases, receipts, transaction envelopes, copied agent reports, local revision
counters, or lane-local change prose. Persist a user answer once in the artifact that owns the
current truth. The coordinator updates preparation-level truth; a change author updates one
change-local truth. Verify the write before scheduling work that depends on it.

When the user supplies a material lane-local answer and names its change, make updating and
verifying that change's affected current-truth sections the sole next workflow action. Use one
bounded change author when useful, or perform the same isolated write sequentially when agents add
no value. Do not mirror the answer or manufacture synchronization metadata in `preparation.md`.

## Investigate with bounded context

Use the shared minimum-sufficient dispatch packet. An outcome investigator receives only its
candidate, relevant source decisions, governing-record paths, and bounded repository area. A
partition challenger receives at most two candidates and one relationship question.

Each worker returns evidence IDs with source paths, the material gap or contradiction, and a
question candidate when user authority is needed. The coordinator deduplicates the result into the
preparation artifact; later workers read that artifact or the cited source rather than the prior
worker's transcript.

## Partition by independent value

1. Identify observable outcomes, affected actors, value, completion signals, and hard constraints.
2. Map every material part of the source request exactly once to a proposed change, deferral, or
   evidenced no-change disposition.
3. Classify each material relationship as `Independent`, `Inseparable`, `Depends on completed
   outcome`, `Overlap or possible merge`, or `Runtime collision`, citing evidence.
4. Keep inseparable behavior under one honest goal. Split outcomes only when each can be approved,
   completed, proven, and, when relevant, released and recovered independently.
5. Treat shared files as collision evidence, not automatically as a semantic dependency.
6. Defer a later independent outcome when it genuinely consumes a predecessor's completed result;
   do not create simultaneous planned changes that cannot complete independently.
7. Challenge source coverage, duplicate ownership, umbrella goals, hidden dependencies, public-
   contract conflicts, migration atomicity, and release collisions once per material concern.

Require explicit partition approval only when the proposed split, merge, deferral, priority, release
boundary, or no-change disposition makes a material choice not already authorized by the user's
request. Record the exact proposed Change IDs and explicit human approval source. Do not treat a Git
blob or digest as approval evidence, and do not require a second partition confirmation for an exact
grouping the user already directed.

## Prepare each approved change independently

Partition authorization approves grouping only. A change author may create a candidate Draft only
when the user also requested that named Draft or the authorization explicitly includes its path.
Its packet contains only that candidate's goal boundary, included source decisions, evidence paths,
governing constraints, explicit non-overlap, and relevant predecessor or collision facts.

Each author invokes `design-change`, which clarifies the candidate and chooses Fast, Standard, or
Controlled without asking the user to classify it. A candidate remains a standalone contract and
does not cite sibling drafts as authority. Run design review and approval per change. A response may
batch the same gate across explicitly enumerated artifacts.

After one change is approved, it may enter planning without waiting for unrelated lanes. Invoke
`plan-work-items` only for a Controlled change with at least two necessary delivery boundaries. Work
items never cross parent changes.

Reopen only affected partition rows when later evidence changes candidate ownership, source
coverage, independence, public-contract compatibility, or migration atomicity. Unrelated lanes
continue unless a real dependency blocks them.

## Complete and recover

Preparation completes when every source intent has an approved or explicit disposition, every
selected change has the correct approved delivery boundary, required multi-item maps are approved,
and no preparation lane remains unresolved. Report which implementation skill can continue each
lane; do not modify target delivery artifacts.

Resume from Git status, the preparation artifact, current change files, approvals, and evidence
paths. For an obsolete agent baseline, re-run only that bounded task. If the control artifact is
missing, reconstruct the smallest source-coverage and lane index from current repository evidence;
do not recreate agent conversations or invent approval.
