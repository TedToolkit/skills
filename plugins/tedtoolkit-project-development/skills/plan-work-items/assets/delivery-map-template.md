<!-- delivery-map -->
## Delivery map

This map exists only for a Controlled change with at least two necessary delivery
items. Independent rows may run in any order; prerequisites name concrete supplied inputs rather
than preferred sequencing. This file is the only mutable work-item status source.

<!-- approval-source: none -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| <PREFIX>-001 |  | Owns AC-01 / Supports INV-01 / None | None, or `<item>: <input or guarantee>` | <purpose and execution shape> | Draft | `work-items/<PREFIX>-001-<slug>.md` |

Repeat `Owns` or `Supports` before every contract ID; do not use an unlabeled comma-separated list.
Keep every Outcome, prerequisites, Primary proof, Status, and Document cell non-empty.

Keep only material plan decisions in separate control state when recovery requires them. The human
map shows current delivery truth. Remove these instructions before approval.

Status meanings: `Implemented` is an item candidate that passed item-level proof and required
review; only `Verified` means it is present on the authoritative integration revision and may
satisfy another item's prerequisite. `Superseded` never satisfies a prerequisite without a named
verified replacement.
