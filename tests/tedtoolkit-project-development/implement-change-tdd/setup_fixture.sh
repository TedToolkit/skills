#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  unapproved-design)
    mkdir -p docs/changes/P2-temperature-parse
    cat > docs/changes/P2-temperature-parse/change.md <<'EOF'
# Temperature parsing

## Status

Draft

## Acceptance criteria

`Temperature.TryParse` accepts Celsius decimal input and rejects invalid values.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    ;;
  change-index)
    mkdir -p docs/changes/P2-geometry-rebuild
    cat > docs/changes/P2-geometry-rebuild/change.md <<'EOF'
# Geometry rebuild

## Status

Approved

| ID | Work package | Status |
| --- | --- | --- |
| GEOM-001 | Equality model | Planned |
| GEOM-002 | Bounds rename | Planned |
EOF
    ;;
  implementation-freedom)
    mkdir -p docs/changes/P1-temperature-parse/work-items
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing

## Status

Approved

## Change goal

Callers can parse invariant Celsius text without accepting invalid values.

## Behavior cases

| ID | Preconditions and input | Action | Expected observable behavior |
| --- | --- | --- | --- |
| BC-01 | `"12.5"` | Call `TryParse` | Returns true and a 12.5 Celsius value. |
| BC-02 | Invalid text | Call `TryParse` | Returns false. |

<!-- delivery-map -->
## Delivery map

| ID | Work item | Outcome | Priority and rationale | Estimate | Logical prerequisites and supplied input | Item-owned verification gate | Status | Document |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TEMP-001 | Parse Celsius text | Callers can parse valid input and reject invalid input. | P1 — public API | 0.1–0.2 person-months | None | Both behavior assertions pass in focused tests. | Approved | `work-items/TEMP-001-parse.md` |
EOF
    cat > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md <<'EOF'
# TEMP-001: Parse Celsius text

## Status

Approved

<!-- work-item: scope -->
## Outcome, scope, and non-goals

| Expected affected area or exact public contract | Authorized outcome | Explicit non-goal |
| --- | --- | --- |
| Public temperature parsing API and its tests | Add invariant parsing behavior. | No formatting API. |

<!-- work-item: start-conditions -->
## Start conditions and blockers

| Start condition or blocker | Evidence or owner | Effect if unmet |
| --- | --- | --- |
| None | Approved parent change | Ready to start. |

<!-- work-item: behavior-cases -->
## Behavior cases

| ID | Preconditions and input | Action | Expected observable behavior |
| --- | --- | --- | --- |
| BC-01 | `"12.5"` | Call `TryParse` | Returns true and a 12.5 Celsius value. |
| BC-02 | Invalid text | Call `TryParse` | Returns false. |

<!-- work-item: delivery-constraints -->
## Delivery constraints

| Observable boundary or governing constraint | Required result | Compatibility or invariant |
| --- | --- | --- |
| Public parsing API | Invariant decimal parsing with non-throwing failure. | Existing constructor remains unchanged. |

<!-- work-item: verification-plan -->
## Verification plan

| Behavior case | Proof intent and appropriate level | Observable assertion | Stable command or bounded manual procedure, if known |
| --- | --- | --- | --- |
| BC-01 | Unit | Valid input produces the expected value. | Repository test command. |
| BC-02 | Unit | Invalid input returns false. | Repository test command. |

<!-- work-item: definition-of-done -->
## Definition of done

| Criterion | Required evidence |
| --- | --- |
| Both behavior cases pass. | Focused test results. |

<!-- work-item: completion-evidence -->
## Completion evidence

Pending implementation.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    cat > Weather.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup><TargetFramework>net10.0</TargetFramework></PropertyGroup>
</Project>
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
