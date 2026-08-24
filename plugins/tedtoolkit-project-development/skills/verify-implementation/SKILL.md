---
name: verify-implementation
description: >-
  Execute an approved candidate's authoritative build, test, analyzer, structural, or bounded manual
  verification and bind the observed result to the exact candidate. Use when implementation or
  review needs independently reproducible execution results. Do not change source, fix failures,
  judge test adequacy, or issue the final merge conclusion.
---

# Verify Implementation

Produce a candidate-bound verification result. This skill observes execution; `review-tests` judges
whether tests are adequate and `review-implementation` owns the delivery conclusion.

Read [testing-strategy.md](../../references/testing-strategy.md) for proof definitions and result
requirements. Read repository guidance, CI configuration, the approved proof plan, and the exact
candidate before running anything. Read
[tool-state-layout.md](../../references/tool-state-layout.md) when the delivery owner has authorized
persistent local verification state.

## Bind the candidate

For independent, cross-context, asynchronous, reusable, or CI verification, prefer a full candidate
commit SHA. When a candidate commit was not authorized, bind the run to `HEAD` plus a cryptographic
digest of the complete tracked diff and every in-scope untracked blob; freeze and recheck that bundle.
For synchronous compact review in the same workspace, the review coordinator may instead supply its
complete raw working-tree snapshot. Recompare it after execution; this result must be synthesized
immediately and cannot be reused across contexts. Declare ordinary build/test output paths outside
the candidate input. Do not invent a second revision counter. Stop stale if any reviewed source,
test, configuration, generated input, or dependency declaration changes before completion.

Verification may create ordinary build/test output, but must not edit source, tests, configuration,
contracts, status records, Git history, external systems, or production state. A manual or external
procedure still requires its normal explicit authorization.

## Select and execute proof

Use the repository's authoritative commands and the approved proof definition. Run the narrowest
primary command first, then only applicable boundary, regression, analyzer, structural, migration,
or journey gates. Prefer existing CI output for the exact candidate when it exposes equivalent raw
results and environment; do not rerun expensive proof merely to create a second record.

For each command or procedure capture:

- exact command or bounded procedure and working directory;
- candidate identity and relevant environment/tool versions;
- intended contract or risk and execution shape;
- exit status and observable result;
- discovered, passed, failed, and skipped counts when available;
- filter/selection, resource prerequisites, and raw-result location when one exists; and
- limitations or unverified external prerequisites.

Treat a command that discovers zero intended tests as failed verification. Do not silently accept
unexpected skips, a wrong filter, unrelated compilation/infrastructure failure, or results from a
different revision. Do not diagnose or fix a failure beyond identifying which command and observable
condition failed; return it to `implement-change` or the appropriate owner.

## Return a verification manifest

Return the manifest to the delivery owner by default. Do not write it merely because verification
ran. When persistent local state is already authorized, the delivery owner may store the returned
manifest under `.tedtoolkit/runs/<workflow-id>/verification/`; the verification lane remains
read-only and raw authoritative results stay in their owning CI or tool location.

```md
# Verification Result

## Candidate
- Identity:
- Independence: independent executor | implementation context | existing CI
- Environment:

## Results
| Purpose/contract | Command or procedure | Selection | Observed result/counts | Status |
| --- | --- | --- | --- | --- |

## Overall status
passed | failed | blocked | stale

## Raw results and limitations
- Locations:
- External prerequisites:
- Not verified:
```

Complete only when every requested gate has an observed disposition and the candidate remained
unchanged. The manifest is an execution result, not permission to merge and not proof that the test
scope was sufficient.
