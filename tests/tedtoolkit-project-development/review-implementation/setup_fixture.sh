#!/usr/bin/env bash
# Fixtures for review-implementation.
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  missing-behavior-case)
    mkdir -p docs/changes/P1-temperature-parse/work-items
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
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
    cat > docs/changes/P2-geometry-rebuild/change.md <<'EOF'
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
  undocumented-behavior-change)
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    ;;
  ready-final-change|ready-final-change-missing-extraction)
    mkdir -p docs/changes/P1-temperature-parse/work-items
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing change

## Status

Approved

## Change goal

Callers can safely parse valid Celsius input without accepting values below absolute zero.

## Compatibility constraints

This parsing API uses invariant-culture decimal syntax.

## Completion criteria

Both BehaviorCases have passing discoverable tests and the work package records its verification.

<!-- delivery-map -->
## Delivery map

| ID | Work package | Logical prerequisites | Status |
| --- | --- | --- | --- |
| TEMP-001 | Parse Celsius input | None | Implemented |
EOF
    if [[ "$scenario" == "ready-final-change-missing-extraction" ]]; then
      cat >> docs/changes/P1-temperature-parse/change.md <<'EOF'

## Durable technical decision

All public library parsing APIs will use invariant culture rather than caller culture. No ADR is linked.
EOF
    fi
    cat > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md <<'EOF'
# Parse Celsius input

## Status

Implemented

## Outcome

Callers can parse valid Celsius input and reject below-absolute-zero input.

## Delivery brief

| Outcome boundary | Logical prerequisite |
| --- | --- |
| Public temperature parsing behavior | None |

## Acceptance criteria

| ID | Scenario | Expected observable behavior | Verification |
| --- | --- | --- |
| BC-01 | Valid input | `TryParse("20.5")` returns true and a 20.5 Celsius temperature. | `Should_parse_valid_celsius_input` |
| BC-02 | Below absolute zero | `TryParse("-274")` returns false. | `Should_reject_below_absolute_zero` |

## Definition of done

- Both BehaviorCases are implemented and covered by the named tests.
- Recorded verification: `dotnet run --project Weather.Tests.csproj -c Release` passed on 2026-07-24.

## Completion evidence

- Changed artifacts: `Temperature.cs`, `TemperatureTests.cs`, and `Weather.Tests.csproj`.
- BC-01 and BC-02 passed through the recorded focused command.
- No migration or operational handoff is required.
EOF
    cat > Temperature.cs <<'EOF'
using System.Globalization;

namespace Weather;

public readonly record struct Temperature(decimal Celsius)
{
    public static bool TryParse(string? value, out Temperature temperature)
    {
        if (decimal.TryParse(value, NumberStyles.Number, CultureInfo.InvariantCulture, out var celsius)
            && celsius >= -273.15m)
        {
            temperature = new Temperature(celsius);
            return true;
        }

        temperature = default;
        return false;
    }
}
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
    cat > TemperatureTests.cs <<'EOF'
using TUnit.Assertions;
using TUnit.Core;

namespace Weather.Tests;

internal sealed class TemperatureTests
{
    /// <summary>
    /// 验证有效的摄氏温度文本能够被解析。
    /// </summary>
    [Test]
    public async Task Should_parse_valid_celsius_input()
    {
        var parsed = Temperature.TryParse("20.5", out var temperature);

        await Assert.That(parsed).IsTrue();
        await Assert.That(temperature).IsEqualTo(new Temperature(20.5m));
    }

    /// <summary>
    /// 验证低于绝对零度的文本会被拒绝。
    /// </summary>
    [Test]
    public async Task Should_reject_below_absolute_zero()
    {
        var parsed = Temperature.TryParse("-274", out _);

        await Assert.That(parsed).IsFalse();
    }
}
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"

if [[ "$scenario" == "undocumented-behavior-change" ]]; then
  cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius)
{
    public static Temperature FromFahrenheit(decimal fahrenheit) => new((fahrenheit - 32m) * 5m / 9m);
}
EOF
fi
