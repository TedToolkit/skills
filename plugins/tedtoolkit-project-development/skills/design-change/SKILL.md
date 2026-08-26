---
name: design-change
description: >-
  Clarify, classify, and design exactly one coherent product or library change. Use directly when a
  request already expresses one bounded change, after scope-changes establishes a candidate, or
  when resuming or revising one explicitly identified existing change. Investigate repository
  evidence, ask high-impact contract questions, choose
  Fast, Standard, or Controlled without asking the user to classify it, define proportionate proof,
  and produce the shortest approval-ready human handoff. Do not use as the default intake for a raw
  development request; redirect unscoped or multi-outcome requests to scope-changes.
---

# Design One Change

Turn one coherent candidate into the shortest safe implementation contract. This skill owns the
goal, behavior or invariant, scope, constraints, risk profile, change kind, proof, delivery shape,
artifact, and first implementation authorization for exactly one change.

Read [change-development-workflow.md](../../references/workflow/change-development-workflow.md) for
the authoritative profile, kind, lifecycle, and approval rules. Read
[requirements-clarification.md](../../references/workflow/requirements-clarification.md) in
`contract` mode before interviewing. Read
[testing-strategy.md](../../references/workflow/testing-strategy.md) before defining proof.

## 1. Validate the candidate

Inspect repository guidance, affected behavior, callers, tests, documentation, dependencies,
adjacent work, and governing records. Separate evidence from assumptions.

Confirm that the input expresses one result-oriented goal. Redirect to `scope-changes` only when
evidence reveals another independently valuable outcome, overlap, missing source ownership, or a
changed completion or release boundary. Report the exact boundary evidence. Do not redirect because
behavior, edge cases, compatibility, or proof remain unclear; clarifying those is this skill's job.

## 2. Clarify the contract

Build current truth from repository evidence before asking the user. Establish only what can change
the contract:

1. problem, affected actor, value, and one completion outcome;
2. current, expected, failure, boundary, and deliberately preserved behavior;
3. scope, non-goals, public or persisted contracts, and reversibility;
4. security, migration/recovery, operations, compatibility, architecture, and external effects;
5. real prerequisites, concrete outcomes supplied by another change, and whether one bounded
   delivery can implement and prove the goal; and
6. the narrowest credible primary proof plus risk-driven conditional proof.

Ask one highest-impact question at a time. When repository evidence supports a recommendation,
offer it with the main trade-off. After each answer, update the owning current-truth section,
re-check contradictions and downstream questions, then continue. Do not use a fixed questionnaire,
ask the user to choose a workflow profile, or create a repository Draft merely to collect answers.

Stop interviewing when remaining unknowns are private implementation choices or explicit owned
assumptions with validation triggers. A material unresolved contract question blocks approval.

## 3. Classify and present the route

Apply the workflow reference's exact definitions and choose the lightest evidenced route. The user
does not classify the work.

```text
Workflow profile: Fast | Standard | Controlled
Change kind: behavior-change | bug-fix | behavior-preserving-refactor | maintenance | migration | experiment
Evidence: <why this is the lightest safe route>
Delivery shape: single | multi-item
Artifacts: <none, one change.md, or change.md plus a separately approved work-item map>
Primary proof: <role=primary, purpose, execution shape, observable assertion, known command>
Approval gate: <what contract approval records; state that continuation is separate unless combined>
Escalation triggers: <facts that would expand the contract or risk>
```

File count, document length, or a desire to use agents is not risk evidence. Use `multi-item` only
for a Controlled change that genuinely needs at least two independently verifiable delivery
boundaries; otherwise keep one embedded delivery brief.
An experiment is always `single`; split independent evidence questions into separate changes.

## 4. Write the human contract

For Fast, present one concise pre-write plan and create no `docs/changes/` record by default. Use
Standard when the user requires an @-addressable record or cross-conversation recovery, even if the
implementation is otherwise small. For Standard or Controlled, write
`docs/changes/<stable-slug>/change.md` from
[change-contract-template.md](assets/change-contract-template.md) only when the user explicitly requests
the Draft or approves creating it. Remove inapplicable sections and make it pass the workflow
reference's five-minute handoff test.

Record current truth, not the interview. Leave private types, algorithms, test files, and
edit order open unless one is itself a public or persisted contract. Use stable `AC-*` results for
behavior changes, bug fixes, and migrations; `INV-*` for behavior-preserving refactors;
`STR-*` target structural outcomes for maintenance; and `EXP-*` questions, method, thresholds, stop condition,
owner, and downstream decision for experiments. Give every contract exactly one stable
`primary-proof` marker as the canonical contract/purpose/shape mapping and one concise human row for
its observable assertion and command; add conditional proof only for an applicable risk.

Give every format-3 Draft a `start-conditions` section. Declare exactly
`<!-- change-prerequisite: none -->` or one or more stable `PRE-*` markers from the template. A
concrete prerequisite names the relative source `change.md`, the source `AC-*`, `INV-*`, `STR-*`,
or `EXP-*` outcome, the supplied guarantee, and the readiness evidence required on an explicit Git
baseline. Record an expected criterion, not a claim that it already passed. Keep the dependent
change standalone and return an unscoped dependency or possible inseparability to `scope-changes`.

Run `bash "${CLAUDE_PLUGIN_ROOT}"/scripts/validate-acceptance-specification.sh <change.md>` for a
format-3 record. Invoke `architecture-design` when an enduring technical choice is required. Before
Controlled approval, dispatch `review-change-design` in a fresh read-only context against the
current Draft. If independence cannot be established, keep the change Draft and report the blocker.
Resolve blocking findings before presenting approval.

## 5. Approve and hand off

Before modifying a delivery artifact, present the complete contract, proof, risks, escalation
triggers, and exact authorization boundary. Wait for explicit approval. Record the explicit human
approval source and update status; a Git SHA or digest may bind technical inputs but never proves
human authorization. Approval accepts the contract only and stops unless the same user request
explicitly says to approve and continue. A Fast approval binds the exact plan stated in the
approval context and remains resumable only there.

After approval, report one derived next action and ask the user to say `continue` rather than asking
them to choose a skill. An explicit continuation routes an approved Fast, Standard, or
single-delivery Controlled change to `implement-change`, and an approved multi-item Controlled
change to `plan-work-items`. Use `continue-change` when a persisted record is referenced or the
conversation may differ from the one that created it. Planning produces a Draft map that receives
separate approval and continuation.

Seek renewed approval only for a workflow escalation trigger. Private implementation choices inside
the approved boundary do not require another design round.
