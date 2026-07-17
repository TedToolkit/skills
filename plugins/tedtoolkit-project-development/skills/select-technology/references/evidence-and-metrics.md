# Evidence and metrics

## Evidence hierarchy

Prefer, in order: reproducible production data; reproducible PoC or benchmark; primary vendor or project documentation; verified production references; team judgement. Label the evidence type and confidence. Do not represent an assumption or a vendor claim as a measurement.

## Benchmark validity

Record median and tail measurements (for example P50/P95/P99), distribution spread, error rate, throughput, and resource use where relevant. Use equivalent data, versions, host capacity, duration, and warm-up conditions. Report a result as directional rather than conclusive when the workload is synthetic, repetitions are insufficient, or candidates were not comparable.

## Common criteria

Select only criteria that change the decision.

| Category | Examples |
|---|---|
| Performance | Throughput, tail latency, startup, resource efficiency |
| Reliability | Error rate, recovery behavior, fault tolerance, operational maturity |
| Cost | Compute, storage, licensing, support, egress, migration, staffing |
| Security/compliance | CVE response, identity integration, auditability, residency, license |
| Operability | Observability, backup/restore, upgrades, runbook burden, support |
| Ecosystem | Maintenance activity, compatibility, documentation, integrations |
| Migration | Data conversion, coexistence, rollback feasibility, delivery risk |

## Confidence rubric

- High: repeatable result under representative conditions or authoritative primary source.
- Medium: limited PoC, comparable external evidence, or a documented but untested claim.
- Low: assumption, anecdote, stale evidence, or non-representative experiment.

Low-confidence claims that influence the decision require a validation owner and due date in the evaluation matrix.
