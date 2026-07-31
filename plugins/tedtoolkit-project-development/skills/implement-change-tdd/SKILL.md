---
name: implement-change-tdd
description: >-
  Implement one approved work item through Red-Green-Refactor. Use when an approved feature, fix,
  refactor, or migration has behavior cases, delivery constraints, and proof standards that must be
  realized with test-driven development.
---

# Implement Change with TDD

Keep the loop **red**: implement one observable behavior at a time, then improve structure while its
tests preserve the approved contract.

This skill owns implementation and verification of one approved work item. Read
[change-development-workflow.md](../../references/change-development-workflow.md) before
classifying a discovery or test-framework handoff. Its boundaries are authoritative: return
contract changes to `change-design`, delivery-boundary defects to `plan-work-items`, and keep
private implementation choices here. A behavior-changing production edit requires its approved
proportionate design.

## Establish the implementation boundary

1. Read repository guidance, the approved change record and selected work item, relevant
   production code, adjacent tests, build configuration, and public API compatibility rules. The
   approved change is the behavioral design contract; the selected work item is the authorized
   delivery boundary. Do not reopen principles or architecture records to reinterpret either.
2. Confirm that the document names one independently implementable delivery. If it is a change record
   or mixes several independent migrations, implementations, or API families, stop and invoke
   `plan-work-items`; select one approved work item before writing code.
3. Confirm that the selected item states one outcome, its applicable behavior cases, delivery
   constraints, real prerequisites, verification criteria, and definition of done. Run
   `bash "${CLAUDE_PLUGIN_ROOT}"/scripts/validate-work-items.sh <parent-change-directory>` before
   implementation. Return missing outcome, scope, public contract, prerequisite, or verification
   decisions to `plan-work-items`; do not require an exact private-file list or implementation steps.
4. Confirm that the selected item names the expected target-delivery area or exact public contract.
   Research, review, approval, and external operational actions are not implementable work items;
   return them to `change-design` or the appropriate operational owner instead of treating them as
   TDD work.
5. For a work item, confirm its parent change and prerequisite work items are approved and
   complete. A missing prerequisite is a blocker, not a reason to silently expand the current change.
6. Confirm that the work item states every material governing constraint explicitly. If it only
   links principles, architecture records, or ADRs, stop and invoke `plan-work-items`; do not retrieve
   and reinterpret those documents during implementation.
7. Confirm that the proposed production-code modification is covered by the approved design,
   including its intended behavior, boundary, and compatibility constraints. If no approved design
   exists, the behavior cases are ambiguous, the change exceeds a concise design's boundary, or the
   implementation requires a material design change, stop and invoke `change-design`. If approved
   behavior lacks an outcome, delivery constraint, prerequisite, or proof standard, stop and invoke
   `plan-work-items`. Do not invent behavior or reclassify it as maintenance merely to keep coding.
8. Inspect the current code and choose concrete tests, internal files, private symbols, algorithms,
   and behavior slices. These are implementation decisions, not missing design. Prefer repository
   conventions and the smallest design that can satisfy the approved behavior.
9. Map every behavior case to a concrete test or approved manual proof. Identify the test level,
   location, setup, observable assertion, and focused command from the current implementation
   context. A behavior case without credible proof is a verification blocker.
10. Present the behavior slices, anticipated files, verification commands, and remaining risk. Make
    clear that this is a local working plan that may evolve during Red-Green-Refactor without
    reapproval while the approved behavior, public contracts, delivery scope, and constraints remain
    unchanged. Wait for explicit approval before modifying code or tests.

## Execute Red-Green-Refactor

For each smallest behavior slice, complete the full loop before moving on:

1. **Red** — add or adjust one focused test expressing the approved observable behavior. Run the
   narrowest test command and confirm it fails for the intended missing behavior, not a broken
   fixture or compile error.
2. **Green** — write the smallest production change that makes that test pass. Avoid speculative
   abstractions, unrelated cleanup, and unrequested API expansion.
3. **Refactor** — improve naming, duplication, and structure only while the relevant tests remain
   green. Preserve behavior and public compatibility unless the approved design says otherwise.
4. Re-run the narrow test after each meaningful change. Freely revise private files, symbols,
   algorithms, test organization, and edit order when the tests and approved constraints remain
   intact. Record the actual choices in completion evidence.
5. Stop for renewed approval only when discovery materially changes observable behavior, delivery
   scope, a public API or data contract, security, a real dependency, migration, rollout, or an
   enduring architecture decision. A different internal implementation is not a design deviation.

## Test rules

Use the repository's existing testing framework, conventions, and authoritative test command.
When it uses TUnit and `tunit-unit-testing` is available, invoke that skill for test layout,
lifecycle, isolation, data, assertions, and mocks while this skill retains work-item ownership.
Choose test levels deliberately:

- Unit tests for deterministic domain behavior and edge cases.
- Integration tests for boundaries such as persistence, network, serialization, or DI wiring.
- Contract tests when a public API or external integration needs compatibility protection.

Do not turn the test suite into a mirror of private implementation. Test the behavior named in the
design, including invalid input and boundary cases when they are part of the contract.

## Finish and verify

1. Confirm every approved behavior case has a passing test or a documented, user-approved
   reason it cannot be automated.
2. Run the narrowest affected tests, then the repository's required build and broader regression
   checks proportional to the change. Use the pinned SDK and authoritative project commands.
3. Update the current change or work item's status and implementation notes. Record actual
   changed artifacts, deliberate scope or constraint deviations, new risks, migration steps,
   verification commands, actual effort, and material estimate variance; do not silently rewrite
   the parent change or approved intent.
4. Report changed behavior, tests run and their results, files changed, and any remaining manual
   verification or rollout action. Flag any likely documentation extraction, retention, deletion, or
   archival question for `review-implementation`; do not move or delete documentation as an implicit
   completion step.

Complete when every approved behavior case has passing evidence, all required regression gates pass,
the diff stays within the approved delivery boundary, debug or temporary artifacts are absent, and
completion evidence records the actual result.
