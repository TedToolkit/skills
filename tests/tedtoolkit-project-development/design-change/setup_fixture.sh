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
