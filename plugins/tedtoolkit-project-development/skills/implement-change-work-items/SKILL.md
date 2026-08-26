---
name: implement-change-work-items
description: >-
  Deprecated compatibility alias for explicit $implement-change-work-items invocations. Route the
  original request to orchestrate-work-items; do not select this alias for ordinary orchestration.
---

# Deprecated Work-Item Implementation Alias

Begin by stating that `implement-change-work-items` is deprecated and its canonical replacement is
`orchestrate-work-items`. This visible handoff prevents a legacy invocation from silently becoming
a different workflow. Then read and follow the canonical
[orchestrate-work-items skill](../orchestrate-work-items/SKILL.md) for the original request. Do not
stop after naming the replacement. Keep all scheduling, isolation, integration, and review rules in
the canonical skill.
