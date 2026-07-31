<!-- delivery-map -->
## 🗺️ Delivery map

Added by `plan-work-items` after the parent change is approved. Record logical prerequisites as facts,
and add a recommended order only when it materially helps coordination. Independent rows may be
implemented in any order. The verification gate proves each item before a dependent item starts.
Each row must represent a bounded modification to version-controlled delivery artifacts; design and
operational activities do not belong in this map.

| ID | Work item | Outcome | Priority and rationale | Estimate | Logical prerequisites and supplied input | Item-owned verification gate | Status | Document |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| <PREFIX>-001 |  |  | P1 —  | <lower>–<upper> person-months | None, or `<item>: <output or guarantee supplied>` | <observable assertion and stable command/procedure when known> | Planned | `work-items/<PREFIX>-001-<slug>.md` |
