---
name: implement-change-tdd
description: >-
  Implement an approved change using test-driven development: map approved behavior cases to
  tests, iterate Red-Green-Refactor in small behavior slices, and verify the affected system. Use
  when the user asks to implement, build, code, or complete a feature, fix, refactor, migration, or other change under TDD, especially when a
  change design, work item, specification, issue acceptance criteria, or test plan already exists.
  Do not begin production implementation without an approved behavioral contract and work item;
  invoke change-design when behavior is missing and plan-work-items when delivery planning is
  missing. Select one approved work item before implementation.
---

# Implement Change with TDD

Implement one observable behavior at a time. TDD is not writing all tests before all code; it is a
short feedback loop that protects design decisions while code is shaped. Prefer the smallest change
that makes an approved behavior true, then improve the design while the tests preserve it.

This skill owns implementation and verification of one approved work package. It must not reinterpret
or revise product intent, principles, architecture, ADRs, or the parent change. Hand a material
behavioral or constraint mismatch back to `change-design`; hand a missing or incomplete work-item
delivery contract to `plan-work-items`.

## Establish the implementation contract

1. Read repository guidance, the approved change index and selected work package, relevant
   production code, adjacent tests, build configuration, and public API compatibility rules. The
   approved change is the sole design contract for implementation; do not reopen principles or
   architecture records to reinterpret it.
2. Confirm the work package contains dependency-ordered executable implementation steps. Each step
   must identify its prerequisite, exact artifact or command, bounded action, and required observable
   check. Stop and invoke `plan-work-items` when a step depends on an implied file, setup action, or
   expected result.
3. Map every behavior case to a concrete test. Identify the test level, test project, input setup,
   observable assertion, and command. A behavior case without a test is either unverified or not yet
   sufficiently specified.
4. Confirm that the document names one independently implementable delivery. If it is a change index
   or mixes several independent migrations, implementations, or API families, stop and invoke
   `plan-work-items`; select one approved work item before writing code.
5. For a work package, confirm its parent change and prerequisite work packages are approved and
   complete. A missing prerequisite is a blocker, not a reason to silently expand the current change.
6. Confirm that the work package states every material governing constraint explicitly. If it only
   links principles, architecture records, or ADRs, stop and invoke `plan-work-items`; do not retrieve
   and reinterpret those documents during implementation.
7. If no approved design exists, behavior cases are ambiguous, or the implementation requires
   a material design change, stop and invoke `change-design`. If approved behavior lacks execution
   detail, stop and invoke `plan-work-items`. Do not invent behavior merely to keep coding.
8. Present the ordered behavior slices, anticipated files, verification commands, and any remaining
   risk. Wait for explicit approval before modifying code or tests.

## Execute Red-Green-Refactor

For each smallest behavior slice, complete the full loop before moving on:

1. **Red** — add or adjust one focused test expressing the approved observable behavior. Run the
   narrowest test command and confirm it fails for the intended missing behavior, not a broken
   fixture or compile error.
2. **Green** — write the smallest production change that makes that test pass. Avoid speculative
   abstractions, unrelated cleanup, and unrequested API expansion.
3. **Refactor** — improve naming, duplication, and structure only while the relevant tests remain
   green. Preserve behavior and public compatibility unless the approved design says otherwise.
4. Re-run the narrow test after each meaningful change. Record a design deviation immediately; stop
   for renewed approval when it materially changes scope, API, data, security, dependency, or
   rollout behavior.

## Test rules

Use the repository's existing testing framework and conventions. For a TUnit project, invoke
`tunit-unit-testing` and follow its conventions, including awaited assertions and `dotnet run` as
the test entry point. Choose test levels deliberately:

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
3. Update the current change or work package's status and implementation notes. Record deliberate
   deviations, new risks, migration steps, verification commands, actual effort, and material
   estimate variance; do not silently rewrite the parent change or approved intent.
4. Report changed behavior, tests run and their results, files changed, and any remaining manual
   verification or rollout action. Flag any likely documentation extraction, retention, deletion, or
   archival question for `review-implementation`; do not move or delete documentation as an implicit
   completion step.
