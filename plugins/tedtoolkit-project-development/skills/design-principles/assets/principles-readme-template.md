# Repository design principles

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
| <ID> |  | Required / Default / Advisory | Draft / Active / Retired |  |  | This file |

Use exactly one lifecycle value in each Status cell. Do not include Git state or any delivery
stage (for example, "pending commit"); an approved, in-force principle is `Active`.

## Principles

### <ID>: <Principle title>

- Status: Draft | Active | Retired
- Strength: Required | Default | Advisory
- Scope:
- Owner:
- Review trigger:

#### Default

State the recurring decision and default direction.

#### Rationale

Explain the long-term cost or quality this default protects.

#### Practical implications

State the smallest implementation and review consequences.

#### Exception route

State what evidence and approval a deviation requires.

## Exception route

State how to propose, approve, and record a deviation. A `Required` exception needs an accepted
ADR before implementation. A `Default` exception is recorded with its delivery and needs an ADR
when it is enduring or difficult to reverse. Link only durable exception records from this index.

## Maintenance

- Principle-set owner:
- Review cadence or objective review triggers:
- Last reviewed:
