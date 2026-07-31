# <Work-item ID>: <Title>

## 📌 Status

Draft | Approved | Implementing | Implemented | Superseded

## 🚦 Delivery priority

- Priority: P0 | P1 | P2 | P3
- Rationale:

## 🔗 Delivery context

- Parent change: `<path or ID>`
- Logical prerequisites:
- Recommended order, when coordination benefits from one:
- Applicable product intent, principles, ADRs, and architecture records:

## 🧩 Explicit governing constraints

State the implementation-facing constraints inherited from the approved change. Do not use links
alone.

<!-- work-item: scope -->
## 🎯 Outcome, scope, and non-goals

Describe one independently observable outcome. Split independently verifiable outcomes rather than
combining them. This is a delivery outcome that contributes to the parent change goal; do not define
or rename the change goal here. The outcome must modify one or more version-controlled delivery
artifacts (code, tests, configuration, build automation, or documentation); it is never research,
review, discussion, approval, or an external operational action.

Name the expected delivery area and any exact public contract. Internal files and private symbols
are non-binding evidence unless they are themselves part of an approved public or persistence
contract. The parent change, this work-item document, status fields, review reports, and completion
evidence are workflow control records; none can be the sole artifact that justifies this work item.

| Expected affected area or exact public contract | Authorized outcome | Explicit non-goal |
| --- | --- | --- |
|  |  |  |

## 🔍 Current behavior and impact boundary

Link evidence for current observable behavior, affected consumers, and adjacent behavior that must
remain unchanged. Known internal files may illustrate the likely area; they do not prescribe the
implementation.

<!-- work-item: start-conditions -->
## 🚧 Start conditions and blockers

State only a completed prerequisite output, repository state, external decision, or other real
condition needed to begin. Do not turn a preferred implementation order into a prerequisite. A
future work item may consume this item's result, but cannot provide the only proof of this item's
core outcome.

| Start condition or blocker | Evidence or owner | Effect if unmet |
| --- | --- | --- |
|  |  |  |

<!-- work-item: behavior-cases -->
## 🧪 Behavior cases

| ID | Preconditions and input | Action | Expected observable behavior |
| --- | --- | --- | --- |
| BC-01 |  |  |  |

<!-- work-item: delivery-constraints -->
## 🛡️ Delivery constraints

State only constraints the implementation must preserve: public contracts, compatibility,
security, migration, governing rules, and explicitly unchanged observable behavior. Do not prescribe
private types, algorithms, method decomposition, exact internal files, or an edit sequence.

| Observable boundary or governing constraint | Required result | Compatibility or invariant |
| --- | --- | --- |
|  |  |  |

<!-- work-item: verification-plan -->
## ✅ Verification plan

Every behavior case needs a proof intent and observable assertion. Record a stable repository
command when known. The implementer selects exact test files, fixture organization, and focused
commands when those depend on the private implementation. A broad final build alone is insufficient.

| Behavior case | Proof intent and appropriate level | Observable assertion | Stable command or bounded manual procedure, if known |
| --- | --- | --- | --- |
| BC-01 | Unit/integration/contract/manual |  |  |

<!-- work-item: definition-of-done -->
## 🏁 Definition of done

| Criterion | Required evidence |
| --- | --- |
|  |  |

## ⏱️ Workload estimate

- Planning range:
- Confidence:
- Assumptions and excluded work:

<!-- work-item: completion-evidence -->
## 📋 Completion evidence

Record actual commands or manual procedure results, required migration or documentation state,
status update, actual effort, and material variance. Include the starting Git SHA, actual changed
artifacts, and evidence for each behavior case. This evidence unlocks the next delivery row.

| Evidence | Required record |
| --- | --- |
| Delivery-boundary check | Starting SHA and actual changed artifacts; explain scope expansion or constraint deviation. |
| Behavior-case proof | Test/manual procedure, command, result, and assertion for every BC. |
| Migration and documentation | Completed state, or explicit not-applicable rationale. |
| Dependent-item unlock | Prerequisite output or verification result made available to dependent items, or None. |

## ⚠️ Risks and open questions

| Item | Impact | Owner or next decision |
| --- | --- | --- |
|  |  |  |
