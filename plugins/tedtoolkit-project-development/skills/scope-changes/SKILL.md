---
name: scope-changes
description: >-
  Scope an ambiguous or multi-outcome product or library request into zero, one, or several coherent
  changes before implementation. Use when outcomes, ownership, dependencies, or release boundaries
  are genuinely unclear. Do not use for an already bounded change, a failing named project, or an
  explicit test, documentation, review, or scaffolding task.
---

# Scope Changes

Turn one ambiguous request into the smallest honest set of changes, then coordinate each candidate's
design. This skill owns intake, source-intent coverage, change boundaries, candidate relationships,
partition decisions, and the single user-dialogue channel while several designs are active. It does
not own a candidate's behavior contract, workflow profile, proof, or implementation.

Read [change-development-workflow.md](../../references/change-development-workflow.md) first. Read
[requirements-clarification.md](../../references/requirements-clarification.md) in `scope` mode.
Read [agent-orchestration.md](../../references/agent-orchestration.md) and
[change-preparation-agent-protocol.md](../../references/change-preparation-agent-protocol.md) only
when several bounded investigation or authoring lanes make coordination worthwhile. Read
[tool-state-layout.md](../../references/tool-state-layout.md) before creating or resuming a
persistent preparation.

## Establish the change set

Inspect repository guidance, affected behavior, adjacent work, governing records, and evidence that
can answer the request without asking the user. Identify observable outcomes, affected actors,
value, completion signals, hard constraints, and material relationships.

Ask a boundary question only when its answer could change:

- whether an outcome deserves a change at all;
- whether two outcomes are independent or inseparable;
- which change owns part of the source request;
- a dependency, priority, release, recovery, or deferral boundary; or
- whether a proposed grouping is authorized.

Do not conduct detailed behavior, edge-case, compatibility, migration, or proof interviews here
unless the answer also changes the change set. Those questions belong to `design-change`.

Map every material source intent exactly once to a candidate change, an explicit deferral, or an
evidenced no-change disposition. Split only outcomes that retain independent value and can be
approved, completed, proven, and when relevant released and recovered independently. Keep
inseparable behavior under one honest goal. Shared components or files are collision evidence, not
automatic semantic dependency.

## Choose the lightest route

### Zero changes

Report the evidence or disposition when no target delivery is needed. Do not manufacture a change
record.

### One coherent change

Create no preparation record by default. Form the smallest candidate brief and invoke
`design-change` directly:

```text
Candidate outcome: <one result-oriented goal>
Included source intent: <covered requirements>
Excluded or deferred intent: <explicit disposition>
Relationships and constraints: <only material facts>
Evidence paths: <where current behavior or governing truth was found>
```

An unclear behavior inside one coherent outcome is still one candidate; let `design-change` ask the
contract questions. Do not keep the request here merely because the user has not designed every
edge case.

### Several candidate changes

Classify each relationship as `Independent`, `Inseparable`, `Depends on completed outcome`,
`Overlap or possible merge`, or `Runtime collision`. Ask for partition approval only when the
proposed split, merge, deferral, priority, release boundary, or no-change disposition introduces a
material choice not already authorized.

After the boundary is authorized, route one bounded candidate brief to each `design-change` author.
Partition approval alone does not authorize repository Draft writes; require a request or approval
that explicitly covers each target Draft path.
Different candidates may be designed concurrently only when their contexts and write paths are
independent and the benefit exceeds coordination cost. Each resulting change remains standalone;
never create a cross-change work-item map.

## Coordinate clarification without duplicating it

Question ownership follows decision ownership. `scope-changes` owns boundary questions;
`design-change` owns questions about one candidate's contract. While several authors are active,
this coordinator is the only role that contacts the user: receive one ranked question from the
owning candidate, ask it, then return the answer only to that candidate.

Persist an answer once in the artifact that owns the current truth. Do not copy candidate-local
answers into sibling changes or a preparation record. If a contract answer reveals a new
independently valuable outcome, overlap, missing source ownership, or changed completion/release
boundary, reopen only the affected scoping decision. Ordinary uncertainty inside the candidate
stays with `design-change` and must not bounce back.

## Keep orchestration optional

Create `.tedtoolkit/preparations/<slug>/preparation.md` from
[preparation-template.md](assets/preparation-template.md) only when the user explicitly requests
persistent preparation or approves it for useful multi-change recovery. Never create a one-lane
record. Keep source coverage, candidate relationships, lane state, blockers, and material partition
approval there; exclude transcripts, writer leases, receipts, transaction envelopes, copied change
content, and local revision counters. Provision the namespace with `bash
"${CLAUDE_PLUGIN_ROOT}"/scripts/ensure-tool-state.sh preparations`. New preparations never use
`docs/change-preparations/`; read a legacy record in place when no write is needed and apply the
shared migration rule before its next authorized update.

Use flat, short-lived investigators only when at least two independent bounded questions are ready.
Ask one blocking user question directly instead of spawning workers that cannot progress. Preserve
one coordinator and one writer per path.

## Complete

Complete when every material source intent has exactly one disposition, each selected candidate has
entered `design-change`, material partition choices are approved, and unresolved blockers name an
owner and next decision. Stop before implementation. For an already approved single change, bypass
this skill and route directly to its eligible planning or implementation skill.
