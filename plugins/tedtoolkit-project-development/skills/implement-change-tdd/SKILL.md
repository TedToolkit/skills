---
name: implement-change-tdd
description: >-
  Implement an approved change using test-driven development: map approved acceptance criteria to
  tests, iterate Red-Green-Refactor in small behavior slices, and verify the affected system. Use
  when the user asks to implement, build, code, or complete a feature, fix, refactor, migration, or other change under TDD, especially when a
  change design, work package, specification, issue acceptance criteria, or test plan already
  exists. Do not begin production implementation without an approved behavioral contract; invoke
  change-design when one is missing or materially incomplete, and decompose-change-epic when the
  input is an epic rather than one implementation unit.
---

# Implement Change with TDD

Implement one observable behavior at a time. TDD is not writing all tests before all code; it is a
short feedback loop that protects design decisions while code is shaped. Prefer the smallest change
that makes an approved behavior true, then improve the design while the tests preserve it.

## Establish the implementation contract

1. Read repository guidance, the approved change design or work package, relevant production code,
   adjacent tests, build configuration, and public API compatibility rules.
2. Map every acceptance criterion to a concrete test. Identify the test level, test project, input
   setup, and observable assertion. A criterion without a test is either unverified or not yet
   sufficiently specified.
3. Confirm that the document names one independently implementable delivery. If it is an epic index
   or mixes several independent migrations, implementations, or API families, stop and invoke
   `decompose-change-epic`; select one approved work package before writing code.
4. For an epic work package, confirm its parent epic, required ADRs, and prerequisite work packages
   are approved and complete. A missing prerequisite is a blocker, not a reason to silently expand
   the current change.
5. If no approved design exists, acceptance criteria are ambiguous, or the implementation requires
   a material design change, stop and invoke `change-design`. Do not invent behavior merely to keep
   coding.
6. Present the ordered behavior slices, anticipated files, verification commands, and any remaining
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

1. Confirm every approved acceptance criterion has a passing test or a documented, user-approved
   reason it cannot be automated.
2. Run the narrowest affected tests, then the repository's required build and broader regression
   checks proportional to the change. Use the pinned SDK and authoritative project commands.
3. Update the current change or work package's status and implementation notes. Record deliberate
   deviations, new risks, migration steps, and verification commands; do not silently rewrite the
   parent epic, ADR, or approved intent.
4. Report changed behavior, tests run and their results, files changed, and any remaining manual
   verification or rollout action. Flag any likely documentation extraction, retention, deletion, or
   archival question for `review-change`; do not move or delete documentation as an implicit
   completion step.
