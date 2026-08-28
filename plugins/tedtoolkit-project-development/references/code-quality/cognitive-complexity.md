# Cognitive complexity

Use cognitive complexity as a maintainability signal for each new or materially changed production
function, method, accessor, local function, or equivalent callable. First resolve the repository's
authoritative threshold from analyzer configuration, quality profile, repository guidance, or CI.
An explicit repository value is authoritative whether stricter or looser than `15`; cite its source
and measured result. If authoritative sources disagree, report a policy blocker instead of choosing.
When no numeric repository policy exists, use `15` only as an advisory starting point, not a hard
gate or a repository exception the project never adopted.

## Establish the score and scope

Use the repository's existing analyzer, quality profile, or CI command as the source of the numeric
score. For Sonar analyzers, this is normally the per-callable Cognitive Complexity rule such as
`S3776`, not a project-, namespace-, type-, or file-level aggregate.

Do not add or reconfigure an analyzer merely to measure one change unless that tooling change is
inside the approved boundary. When no authoritative measurement is available, inspect and simplify
obvious nested or branching control flow, but report that the `15` threshold was not mechanically
verified; never invent a score from visual inspection.

Keep untouched legacy callables outside the delivery scope. When a materially changed callable is
already over the applicable threshold, bring that callable to the threshold as part of the change.
If doing so requires a behavioral, public-contract, architecture, or delivery-boundary expansion,
stop and route that expansion through the governing change workflow instead of silently widening
the implementation.

## Reduce the reasoning burden, not only the score

Prefer the smallest behavior-preserving change that makes each decision easier to follow:

- replace avoidable nesting with clear guard clauses or early exits;
- extract a cohesive operation only when it has a meaningful name and can be understood or tested
  independently;
- consolidate duplicated conditions and make mutually exclusive cases explicit;
- use a decision table, state machine, strategy, or polymorphism only when the domain already owns
  that distinction and the added structure reduces total reasoning cost; and
- preserve observable behavior, including exception precedence and detail, cancellation, ordering,
  side effects, resource ownership, and concurrency semantics.

Do not game the metric by creating trivial forwarding methods, scattering one decision across
unrelated types, moving branches into lambdas or local functions, adding boolean control flags, or
duplicating state. Comments and tests can explain or protect complex behavior, but they do not make
an over-threshold callable conforming. Do not suppress, disable, or lower the severity of the rule
without the explicit exception route required by the repository and delivery workflow.

## Verify implementation and review findings

During implementation, rerun the existing analyzer or quality command after refactoring and require
every in-scope callable to satisfy the explicit repository threshold when one exists. Record the
source, exact command, and result; an analyzer that reports only violations may establish the gate
through a clean result. Without a repository policy or measurable analyzer, report the limitation,
use `15` only to guide maintainability discussion, and never invent a score.

During read-only code review, cite an existing analyzer result when claiming that a callable exceeds
the numeric threshold. Without such evidence, describe the observed control-flow burden and its
concrete maintenance or correctness impact, then request the repository's cognitive-complexity gate
under `Verify`; do not present a guessed number as fact.

When an explicit repository threshold is exceeded, a callable may remain only through that
repository's approved exception route. Keep the exception narrow and visible; approval of the
surrounding feature alone is not approval of a complexity exception. Advisory `15` alone does not
create an exception requirement.

## Primary source

SonarSource's [Cognitive Complexity overview](https://www.sonarsource.com/resources/cognitive-complexity/)
defines the metric as a measure of relative method understandability. Its default threshold of `15`
is an empirical starting point rather than a universal mathematical limit, so the explicit project
rule and exception route remain authoritative.
