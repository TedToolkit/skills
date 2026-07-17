#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  missing-behavior-case)
    mkdir -p docs/changes/P1-temperature-parse/work-items
    cat > docs/changes/P1-temperature-parse/README.md <<'EOF'
# Temperature parsing change

## Status

Approved
EOF
    cat > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md <<'EOF'
# Temperature parsing

## Status

Approved

## Acceptance criteria

| ID | Scenario | Expected observable behavior |
| --- | --- | --- |
| BC-01 | Valid input | `TryParse("20.5")` returns true and a 20.5 Celsius temperature. |
| BC-02 | Below absolute zero | `TryParse("-274")` returns false. |
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius)
{
    public static bool TryParse(string? value, out Temperature temperature)
    {
        if (decimal.TryParse(value, out var celsius))
        {
            temperature = new Temperature(celsius);
            return true;
        }

        temperature = default;
        return false;
    }
}
EOF
    cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests
{
    public void Should_parse_valid_celsius_input()
    {
        var parsed = Temperature.TryParse("20.5", out var temperature);

        Assert.True(parsed);
        Assert.Equal(new Temperature(20.5m), temperature);
    }
}
EOF
    ;;
  change-index)
    mkdir -p docs/changes/P2-geometry-rebuild
    cat > docs/changes/P2-geometry-rebuild/README.md <<'EOF'
# Geometry rebuild

## Status

Approved

| ID | Work package | Status |
| --- | --- | --- |
| GEOM-001 | Equality model | Planned |
EOF
    cat > Geometry.cs <<'EOF'
namespace Geometry;

public sealed class Bounds;
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
