# Requirements clarification

Use this reference to clarify development intent without turning the conversation into a fixed
questionnaire. Investigate first, ask only decision-changing questions, and preserve answers as
current truth rather than interview history.

## Shared clarification loop

1. Read repository guidance, current behavior, tests, documentation, governing records, and active
   delivery artifacts that can answer the question.
2. Separate evidenced facts, user-owned decisions, unsupported assumptions, and private
   implementation choices.
3. Rank unanswered questions by their ability to change the owned decision. Ask one highest-impact
   question at a time; do not dump a checklist on the user.
4. Explain briefly why the answer matters. When evidence supports a preferred answer, recommend it
   and state the main trade-off rather than asking the user to design unaided.
5. After each answer, update the owning current-truth section, re-check contradictions, and
   re-rank the remaining questions before continuing.
6. Stop when remaining unknowns are private implementation choices or explicit assumptions with an
   owner, validation method, and trigger for reopening the decision.

Do not ask for facts available in the repository, ask the user to select an internal workflow
profile, retain a transcript in a human delivery record, or treat an answer as approval of unrelated
scope.

## Scope mode

`scope-changes` uses this mode before candidate design. Ask only when an answer can change the number
of changes, source-intent ownership, independence, dependency, priority, release/recovery grouping,
or an explicit deferral/no-change disposition.

Stop as soon as every material part of the source request maps exactly once and each candidate has
one coherent outcome. Do not explore candidate-local behavior and proof merely because they are not
yet fully designed.

## Contract mode

`design-change` uses this mode after one candidate boundary exists. Ask when an answer can change its
goal, observable behavior or invariant, failure/boundary behavior, scope, non-goals, public or
persisted compatibility, security, migration/recovery, architecture, operational ownership,
delivery shape, or credible proof.

If an answer exposes a new independent outcome, overlap, missing source ownership, or changed
completion/release boundary, return that exact evidence to `scope-changes`. Otherwise keep the
question and answer inside the owning change.

## Coordinated dialogue

When several candidate authors run under one coordinator, semantic question ownership stays with
the skill that owns the decision, but `scope-changes` is the only user-facing speaker. Each author
returns one ranked question and its reason; the coordinator deduplicates, asks it, and returns the
answer only to the owning candidate. For one direct candidate, `design-change` may ask the user
itself.
