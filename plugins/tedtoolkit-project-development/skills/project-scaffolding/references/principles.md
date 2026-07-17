# Design principles

Use this reference when creating or revising `docs/principles/`. Principles are the repository's
enduring defaults for recurring design trade-offs. They answer how to choose when a later change has
more than one credible design; they are not a substitute for a specific ADR, an architecture
description, executable coding rules, or a how-to guide.

Create `docs/principles/README.md` first. It must state the scope, precedence, owner or review
cadence, and exception route. Add a topic file only when it improves navigation for a genuinely
independent set of principles.

Each principle must contain:

1. A concise default direction.
2. The rationale and the long-term cost it protects against.
3. Practical implications for design and review.
4. The exception route: when deviation is reasonable and whether it needs an ADR.

Keep principles few, stable, and falsifiable in review. Link an ADR to the principles it applies or
intentionally overrides; do not use a principle to conceal the alternatives and consequences of a
specific decision. Put concrete current boundaries in `docs/architecture/`, and executable rules in
repository guidance or tooling.
