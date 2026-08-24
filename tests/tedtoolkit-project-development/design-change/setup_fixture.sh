#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  fast-maintenance)
    cat > Temperature.cs <<'EOF'
namespace Weather;

// Represnts an immutable Celsius temperature.
public readonly record struct Temperature(decimal Celsius);
EOF
    ;;
  standard-internal-fix)
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius)
{
    public Temperature Normalize() => new(Clamp(Celsius));

    private static decimal Clamp(decimal value) => decimal.Round(value);
}
EOF
    cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests;
EOF
    ;;
  temperature-design)
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests;
EOF
    ;;
  large-feature)
    mkdir -p docs/requests
    cat > docs/requests/large-request.md <<'EOF'
# Large request

Several public API families, generator output, equality semantics, and mesh validation must change.
EOF
    ;;
  dependent-change)
    mkdir -p docs/changes/P2-settings-store
    cat > docs/changes/P2-settings-store/change.md <<'EOF'
# Settings store change

This planned change introduces the persistent settings store required by future consumers.
EOF
    ;;
  scoped-dependent-draft)
    mkdir -p docs/changes/settings-store
    cat > docs/changes/settings-store/change.md <<'EOF'
# Provide a settings store
<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Fixture owner -->
<!-- section: goal-rationale -->
## Goal
Applications can persist settings.
<!-- section: scope -->
## Scope
Provide the settings-store contract only.
<!-- section: behavior-contract -->
## Behavior
<!-- acceptance-case: AC-01 -->
- AC-01: a caller can persist and retrieve one setting.
<!-- section: start-conditions -->
## Start conditions
<!-- change-prerequisite: none -->
None. Ready from the approved baseline.
<!-- section: delivery-brief -->
## Delivery
One bounded settings-store delivery.
<!-- section: proof-plan -->
## Proof
<!-- primary-proof: AC-01 purpose=acceptance shape=component -->
| Contract | Role | Observable assertion | Command or procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | Persisted setting can be retrieved | Repository test command |
<!-- section: completion-criteria -->
## Completion
AC-01 passes.
EOF
    ;;
  answer-persistence)
    mkdir -p docs/changes/compatibility
    cat > docs/changes/compatibility/change.md <<'EOF'
# Compatibility change

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: draft -->
<!-- delivery-shape: single -->
<!-- approval-source: none -->

<!-- section: goal-rationale -->
## Goal and rationale

Callers can adopt the new behavior without an unapproved compatibility break.

<!-- section: scope -->
## Scope and non-goals

Compatibility is unresolved.
EOF
    ;;
  ambiguous-cache)
    cat > CacheConsumer.cs <<'EOF'
namespace Fixture;

internal sealed class CacheConsumer;
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
