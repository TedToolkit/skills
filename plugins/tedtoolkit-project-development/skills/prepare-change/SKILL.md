---
name: prepare-change
description: >-
  Deprecated compatibility alias for explicit $prepare-change invocations. Route the original
  request to scope-changes; do not select this alias for ordinary request scoping.
---

# Deprecated Prepare-Change Alias

Begin by stating that `prepare-change` is deprecated and its canonical replacement is
`scope-changes`. This visible handoff prevents a legacy invocation from silently becoming a
different workflow. Then read and follow the canonical
[scope-changes skill](../scope-changes/SKILL.md) for the original request. Do not stop after naming
the replacement. Keep all partitioning, investigation, and routing rules in the canonical skill.
