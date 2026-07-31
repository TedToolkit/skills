# Repository design principles

## 📝 Clarification and decision log

While the principle set is `Draft`, record each material user answer immediately and update the
affected principle or index. Retain only entries that explain a consequential scope, strength, or
exception route.

| ID | Question and why it mattered | Recommended answer | User decision and source | Affected sections | Status |
| --- | --- | --- | --- | --- | --- |
| DP-01 |  |  |  |  | Resolved |

## Scope and precedence

- Governed scope:
- External hard constraints that take precedence:
- Product intent: `docs/product/README.md`, or None. Product intent defines the library's purpose
  and boundaries; principles define recurring technical defaults that support it.
- Precedence: approved product intent guides principles; principles guide architecture design;
  approved architecture constrains change design; approved work items constrain implementation.

## Principle index

| ID | Title | Strength | Status | Owner | Review trigger | Document |
| --- | --- | --- | --- | --- | --- | --- |
| <ID> |  | Required / Default / Advisory | Draft / Active / Retired |  |  | `architecture.md` / `engineering.md` |

Use exactly one lifecycle value in each Status cell. Do not include Git state or any delivery
stage (for example, "pending commit"); an approved, in-force principle is `Active`.

## Exception route

State how to propose, approve, and record a deviation. A `Required` exception needs an accepted
ADR before implementation. A `Default` exception is recorded with its delivery and needs an ADR
when it is enduring or difficult to reverse. Link only durable exception records from this index.

## Maintenance

- Principle-set owner:
- Review cadence or objective review triggers:
- Last reviewed:
