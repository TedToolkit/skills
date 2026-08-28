# Preserve candidate isolation in serial orchestration

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: bug-fix -->
<!-- change-status: completed -->
<!-- delivery-shape: single -->

- Priority: P1
<!-- approval-source: User authorized batching the remaining changes and newly discovered bugs in this Codex task on 2026-08-28. -->
<!-- candidate-binding: commit:6ebb1182415ab2079a0a168efd55d6e6b6a06d96 -->

<!-- section: goal-rationale -->
## Goal and rationale

Keep authoritative integration refs immutable until proof and review accept a serial candidate, and
make orchestration cleanup work under either supported plugin-root environment variable. The current
one-item shortcut writes directly on the authoritative ref and some cleanup commands assume only the
Claude runtime variable, weakening rollback and Codex portability.

<!-- section: scope -->
## Scope and non-goals

- In scope: serial-wave candidate isolation, authoritative-ref advancement, safe recorded-branch
  cleanup, Codex/Claude plugin-root resolution, and focused orchestration regression proof.
- Non-goals: changing dependency scheduling, parallel worker topology, acceptance contracts,
  review independence, force-deleting branches, or adding worktrees for a serial wave.
- Preserved: one coordinator owns integration and map status; only Verified outcomes unlock
  dependents; branches with unique commits or active checkouts are retained and reported.

<!-- section: behavior-contract -->
## Behavior contract

<!-- behavior-change: OB-01 -->
| ID | Observable boundary | Current | Expected | Preserved |
| --- | --- | --- | --- | --- |
| OB-01 | A dependency-ready wave has one writer | The writer may commit directly on the authoritative integration branch before candidate review | The coordinator uses one disposable candidate branch in the existing integration worktree, keeps the authoritative ref fixed through proof and review, then fast-forwards it after acceptance | No worker or additional worktree is created; central status remains coordinator-owned |
| OB-02 | Orchestration invokes packaged helpers | Cleanup instructions require `CLAUDE_PLUGIN_ROOT` | The installed root resolves from `CLAUDE_PLUGIN_ROOT` or `TEDTOOLKIT_PLUGIN_ROOT` and missing runtime location fails closed | No cache version or developer checkout is guessed |

<!-- acceptance-case: AC-01 -->
### AC-01 — Isolate and integrate serial candidates

```gherkin
Scenario: Execute a two-item dependency chain
  Given each ready wave contains exactly one writer
  When the coordinator implements and reviews each item
  Then main remains fixed until that candidate passes
  And main is fast-forwarded before the dependent item starts
  And each safe recorded candidate branch is removed after integration
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Resolve either supported installed root

```gherkin
Scenario: Run orchestration under Codex
  Given TEDTOOLKIT_PLUGIN_ROOT identifies the installed plugin and CLAUDE_PLUGIN_ROOT is unset
  When orchestration validates and cleans its temporary resources
  Then it invokes the packaged helpers from that installed root
  And it does not guess another location
```

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

The approved batch authorization, a clean integration worktree, and no overlapping writer on the
orchestration Skill, protocol, or focused eval are required before implementation.

<!-- section: delivery-brief -->
## Delivery brief

- Outcome and target area: align `orchestrate-work-items` and its protocol with candidate-first
  integration while preserving the existing parallel path.
- Other start conditions: approved batch authorization, clean candidate-owned paths, Git, Bash,
  Python 3.10, and Codex credentials for the focused model scenarios.
- Likely touchpoints: orchestration Skill, agent protocol, and orchestration eval.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: AC-01 purpose=regression shape=end-to-end -->
<!-- primary-proof: AC-02 purpose=boundary shape=end-to-end -->
| Contract | Role | Observable assertion | Command or bounded procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Sequential dependency orchestration preserves candidate isolation, verified ordering, fast-forward integration, and safe branch cleanup | Run the exact `Coordinate a sequential dependency chain through verified integration` scenario on the candidate |
| AC-02 | Primary | Orchestration completes its helper-backed lifecycle with the Codex-provided root and no Claude root | Run the focused orchestration execution scenarios through the eval harness under its Codex environment |

<!-- section: completion-criteria -->
## Completion

AC-01 and AC-02 pass on the exact candidate, the independent parallel scenario remains green, local
independent review finds no blocking defect, and no pre-existing or unique temporary branch is
deleted.
