#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
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
    mkdir -p docs/features
    cat > docs/features/request.md <<'EOF'
# Large request

Several public API families, generator output, equality semantics, and mesh validation must change.
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
