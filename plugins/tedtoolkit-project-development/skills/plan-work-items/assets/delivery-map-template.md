<!-- delivery-map -->
## Delivery map

This map exists only for a Controlled change with at least two necessary delivery
items. Independent rows may run in any order; prerequisites name concrete supplied inputs rather
than preferred sequencing. This file is the only mutable work-item status source.

<!-- approval-source: none -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Status | Document |
| --- | --- | --- | --- | --- | --- |
| <PREFIX>-001 |  | Owns AC-01 / Supports INV-01 / None | None, or `<item>: <input or guarantee>` | Draft | `work-items/<PREFIX>-001-<slug>.md` |

Repeat `Owns` or `Supports` before every contract ID; do not use an unlabeled comma-separated list.
Keep every Outcome, prerequisites, Status, and Document cell non-empty. The item document is the
single source for its proof definition; do not summarize it again in this map.

Keep only material plan decisions in `.tedtoolkit/runs/<workflow-id>/` when recovery requires them
and persistence is approved. The human map shows current delivery truth. Remove these instructions
before approval.

Status values are `Draft`, `Approved`, `In progress`, `Implemented`, `Verified`, and `Superseded`.
`Implemented` is an item candidate that passed item-level proof and required review; only `Verified`
means it is present on the authoritative integration revision and may satisfy another item's
prerequisite. `Superseded` never satisfies a prerequisite without a named verified replacement.
