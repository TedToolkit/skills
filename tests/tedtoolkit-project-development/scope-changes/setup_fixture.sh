#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  ambiguous-request)
    cat > CacheConsumer.cs <<'EOF'
namespace Example;

internal sealed class CacheConsumer;
EOF
    ;;
  approved-design)
    mkdir -p docs/changes/P1-temperature-parse/work-items
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing

<!-- change-format: 2 -->

## Status

Draft

- Artifact revision: `CH-r3`.
- Approval evidence and reviewed target: None.

## Change goal

Callers can parse valid invariant Celsius text without accepting invalid or impossible values.

## Problem and value rationale

Several callers duplicate parsing and accept impossible values, producing inconsistent domain
boundaries. The next ingestion API needs one safe parsing contract before release.

## Rationale traceability

| ID | Design claim | Why it is necessary | Evidence or authority | Status |
| --- | --- | --- | --- | --- |
| R-01 | Change goal | Remove inconsistent parsing at the domain boundary. | Approved request PR-17. | Resolved |
| R-02 | AC-01 and AC-02 | Define valid and invalid observable input behavior. | Approved request PR-17. | Resolved |

## Scope and non-goals

Add one non-throwing public parsing API. Do not add formatting or conversion APIs.

## Public contract

Add `public static bool TryParse(string? text, out Temperature result)`. It uses invariant decimal
syntax, returns `false` for invalid or impossible values, and leaves the existing constructor
unchanged.

## Target delivery artifacts

Production code and focused automated tests must change.

## Observable behavior change

| ID | Observable boundary | Current behavior | Expected behavior | Must remain unchanged | Rationale ID |
| --- | --- | --- | --- | --- | --- |
| OB-01 | Public temperature parsing | Callers duplicate parsing. | Valid invariant input parses and invalid or impossible input is rejected. | Existing construction behavior. | R-02 |

## Acceptance specification

<!-- acceptance-case: AC-01 -->
### AC-01 — Parse valid invariant Celsius

- Type: Success
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-02

```gherkin
Scenario: Parse valid invariant Celsius
  Given the text "12.5"
  When a caller attempts to parse it as Celsius
  Then parsing succeeds with a 12.5 Celsius value
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Reject invalid or impossible Celsius

- Type: Failure
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-02

```gherkin
Scenario: Reject invalid or impossible Celsius
  Given null, whitespace, invalid text, or a value below absolute zero
  When a caller attempts to parse it as Celsius
  Then parsing fails without producing an impossible value
```

## Completion criteria

AC-01 and AC-02 pass with focused automated evidence.
EOF
    sed -i 's/^Draft$/Approved/' docs/changes/P1-temperature-parse/change.md
    sed -i 's/`CH-r3`/`CH-r4`/' docs/changes/P1-temperature-parse/change.md
    sed -i "s/^- Approval evidence and reviewed target:.*$/- Approval evidence and reviewed target: PR-17 explicit approval of CH-r3./" docs/changes/P1-temperature-parse/change.md
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests;
EOF
    cat > Weather.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="1.61.35" />
  </ItemGroup>
</Project>
EOF
    ;;
  planning-answer)
    mkdir -p docs/changes/P1-temperature-parse/work-items
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing

## Status

Approved

- Artifact revision: `CH-r5`.
- Approval evidence: Legacy approved and planned change from issue PR-17.

## Change goal

Callers can parse valid invariant Celsius text without accepting invalid or impossible values.

## Problem and value rationale

Several callers duplicate parsing and accept impossible values. The approved request requires one
safe parsing contract before the next ingestion API release.

## Rationale traceability

| ID | Design claim | Why it is necessary | Evidence or authority | Status |
| --- | --- | --- | --- | --- |
| R-01 | Goal and behavior | Remove inconsistent parsing at the domain boundary. | Approved request PR-17. | Resolved |

## Scope and non-goals

Add one non-throwing public parsing API. Do not add formatting or conversion APIs.

## Behavior cases

| ID | Preconditions and input | Action | Expected observable behavior | Rationale ID |
| --- | --- | --- | --- | --- |
| BC-01 | `"12.5"` | Call `TryParse` | Parses invariant decimal Celsius. | R-01 |
| BC-02 | Invalid or impossible input | Call `TryParse` | Returns false. | R-01 |

<!-- delivery-map -->
## 🗺️ Delivery map

| ID | Work item | Outcome | Priority and rationale | Estimate | Logical prerequisites and supplied input | Item-owned verification gate | Status | Document |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TEMP-001 | Add safe parsing | Both behavior cases are delivered. | P1 — required before ingestion API | 0.01–0.02 person-months | Awaiting PCQ.001 | Focused parsing tests | Planned | `work-items/TEMP-001-parse.md` |

## 📝 Planning clarification and approval log

- Plan approval evidence: None.

| ID | Question and why it mattered | Recommended answer | User answer | Source | Supersedes | Affected rows or briefs | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PCQ.001 | Does TEMP-001 consume another item's result? It determines start eligibility. | No prerequisite is currently evidenced. |  | None | None | TEMP-001 | Open |
EOF
    cat > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md <<'EOF'
# TEMP-001: Add safe parsing

## Status

Draft

- Artifact revision: `WI-r1`.

## Outcome

Deliver BC-01 and BC-02 without changing existing construction behavior.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests;
EOF
    ;;
  approved-two-change-partition|ready-unapproved-partition)
    mkdir -p docs/change-preparations/account-request
    cat > docs/change-preparations/account-request/preparation.md <<'EOF'
# Account security and export request

<!-- change-preparation-format: 2 -->

## Status

Draft

- Repository baseline: fixture main, clean before this preparation.
- Exact content approved, when required: None.
- Preparation owner: Fixture coordinator.

## Source intent

The source request asks for immediate leaked-key revocation and a CSV audit export. The outcomes
serve different actors and release independently.

## Material decisions

| ID | Current decision | Source | Affected candidates | Revisit trigger |
| --- | --- | --- | --- | --- |
| PD-01 | Security revocation and audit export serve different users and can release independently. | Fixture user direction | C-01, C-02 | Shared public contract or atomic migration appears |

## Evidence index

| ID | Material claim | Source path or record | Confidence | Affected candidate |
| --- | --- | --- | --- | --- |
| AUTH-EVIDENCE-7K | Leaked keys remain accepted until manually removed. | `AuthBoundary.cs` | High | C-01 |
| EXPORT-EVIDENCE-9Q | Administrators cannot download audit events. | `ExportService.cs` | High | C-02 |

## Candidate outcomes and source coverage

| ID | Observable outcome and value | Completion signal | Evidence/decision IDs | Source coverage | Disposition |
| --- | --- | --- | --- | --- | --- |
| C-01 | Operators revoke leaked keys to contain exposure. | A revoked key fails authentication while unrelated keys remain valid. | AUTH-EVIDENCE-7K, PD-01 | Key-revocation request | Proposed change |
| C-02 | Administrators export audit events for offline review. | A requested range downloads as valid CSV without changing authentication. | EXPORT-EVIDENCE-9Q, PD-01 | Audit-export request | Proposed change |

## Material relationships

| From | To | Relationship | Evidence | Partition consequence |
| --- | --- | --- | --- | --- |
| C-01 | C-02 | Independent | PD-01 | Split |

## Proposed change set

| Change ID | One goal | Included candidates | Explicit non-overlap | Independent proof/release/recovery | Draft path |
| --- | --- | --- | --- | --- | --- |
| CH-01 | Operators can immediately invalidate leaked API keys. | C-01 | Does not own audit export. | PD-01; separate authentication proof and rollback. | `docs/changes/P1-auth/change.md` |
| CH-02 | Administrators can export audit events as CSV. | C-02 | Does not own key revocation. | PD-01; separate reporting proof and rollback. | `docs/changes/P2-export/change.md` |

## Active lanes

| Lane | Artifact | Phase | Baseline/digest | Blocker or next decision |
| --- | --- | --- | --- | --- |
| CH-01 | `docs/changes/P1-auth/change.md` | Partition | None | Partition authorization |
| CH-02 | `docs/changes/P2-export/change.md` | Partition | None | Partition authorization |

## Authorization

- Material partition choice requiring approval: Split two release boundaries.
- Human authorization and exact Change IDs: None.
- Partition approval source and approved Change IDs: None.
EOF
    if [[ "$scenario" == approved-two-change-partition ]]; then
      sed -i 's/^Draft$/Partition authorized/' docs/change-preparations/account-request/preparation.md
      sed -i "s/^- Human authorization and exact Change IDs:.*$/- Human authorization and exact Change IDs: CH-01 and CH-02./" docs/change-preparations/account-request/preparation.md
      sed -i "s/^- Partition approval source.*$/- Partition approval source and approved Change IDs: User explicitly approved CH-01 and CH-02./" docs/change-preparations/account-request/preparation.md
    fi
    cat > AuthBoundary.cs <<'EOF'
namespace Example;

internal sealed class AuthBoundary;
EOF
    cat > ExportService.cs <<'EOF'
namespace Example;

internal sealed class ExportService;
EOF
    ;;
  isolated-change-answer)
    mkdir -p docs/change-preparations/account-request docs/changes/P1-auth docs/changes/P2-export
    cat > docs/change-preparations/account-request/preparation.md <<'EOF'
# Account request

<!-- change-preparation-format: 2 -->

## Status

In design

- Repository baseline: fixture main.
- Exact content approved, when required: 1111111111111111111111111111111111111111.
- Preparation owner: Fixture coordinator.

## Active lanes

| Lane | Artifact | Phase | Baseline/digest | Blocker or next decision |
| --- | --- | --- | --- | --- |
| CH-01 | `docs/changes/P1-auth/change.md` | Design | AUTH_ID | Rationale answer needed |
| CH-02 | `docs/changes/P2-export/change.md` | Design | EXPORT_ID | Audit-range answer needed |
EOF
    cat > docs/changes/P1-auth/change.md <<'EOF'
# Immediate API-key revocation

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: draft -->
<!-- delivery-shape: single -->
<!-- approval-source: none -->

<!-- section: goal-rationale -->
## Goal and rationale

AUTH-EVIDENCE-7K shows leaked keys are not immediately rejected. Material urgency is unresolved.

<!-- section: scope -->
## Scope and non-goals

- In scope: Reject explicitly revoked API keys.
- Non-goals: Audit export.

<!-- section: behavior-contract -->
## Behavior contract

<!-- acceptance-case: AC-01 -->
- AC-01: The required rejection timing is unresolved.
EOF
    cat > docs/changes/P2-export/change.md <<'EOF'
# Audit CSV export

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: draft -->
<!-- delivery-shape: single -->
<!-- approval-source: none -->

<!-- section: goal-rationale -->
## Goal and rationale

EXPORT-EVIDENCE-9Q shows administrators cannot download audit events.
EOF
    auth_blob="$(git hash-object docs/changes/P1-auth/change.md)"
    export_blob="$(git hash-object docs/changes/P2-export/change.md)"
    sed -i "s/AUTH_ID/$auth_blob/" docs/change-preparations/account-request/preparation.md
    sed -i "s/EXPORT_ID/$export_blob/" docs/change-preparations/account-request/preparation.md
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"

if [[ "$scenario" == approved-design ]]; then
  : > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md
fi
