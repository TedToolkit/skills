#!/usr/bin/env bash
# Fixtures for review-implementation.
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  independence-required)
    mkdir -p docs/changes/public-id
    cat > docs/changes/public-id/change.md <<'EOF'
# Public identifier parsing
<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Fixture owner -->
<!-- acceptance-case: AC-01 -->
- AC-01: The new public TryParse API returns a parsed identifier for valid text.
EOF
    cat > PublicId.cs <<'EOF'
namespace Identity;
public readonly record struct PublicId(int Value);
EOF
    git add -A
    git commit -qm "baseline"
    git tag eval-base
    cat > PublicId.cs <<'EOF'
namespace Identity;
public readonly record struct PublicId(int Value)
{
    public static bool TryParse(string? text, out PublicId value)
    {
        var ok = int.TryParse(text, out var parsed);
        value = new PublicId(parsed);
        return ok;
    }
}
EOF
    git add PublicId.cs
    git commit -qm "candidate"
    ;;
  conflicting-lanes)
    mkdir -p docs/changes/parse review-packet
    cat > .gitignore <<'EOF'
review-packet/
EOF
    cat > docs/changes/parse/change.md <<'EOF'
# Parse temperature
<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Fixture owner -->
<!-- acceptance-case: AC-02 -->
- AC-02: Invalid text returns false and the default temperature value.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;
public readonly record struct Temperature(decimal Celsius)
{
    public static bool TryParse(string? text, out Temperature value)
    {
        var ok = decimal.TryParse(text, out var parsed);
        value = new Temperature(parsed);
        return ok;
    }
}
EOF
    git add -A
    git commit -qm "baseline"
    git tag eval-base
    cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;
internal sealed class TryParseTests
{
    public void Should_reject_invalid_text()
    {
        Temperature.TryParse("invalid", out var value);
        Assert.NotNull(value);
    }
}
EOF
    git add TemperatureTests.cs
    git commit -qm "candidate"
    candidate="$(git rev-parse HEAD)"
    cat > review-packet/code.md <<EOF
Independent fresh code lane for $candidate: pass.
EOF
    cat > review-packet/tests.md <<EOF
Independent fresh test lane for $candidate: AC-02 weak because the test does not assert false or the default value.
EOF
    cat > review-packet/verification.md <<EOF
Independent executor for $candidate: command passed, 1 discovered, 1 passed, 0 failed, 0 skipped.
EOF
    ;;
  missing-acceptance-case)
    mkdir -p docs/changes/P1-temperature-parse/work-items
    cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing change

<!-- change-format: 2 -->

## Status

Approved

## Rationale traceability

| ID | Design claim | Why it is necessary | Evidence, governing record, or decision ID | Status |
| --- | --- | --- | --- | --- |
| R-01 | Safe parsing | Prevent impossible domain values. | Approved request | Resolved |

## Observable behavior change

| ID | Observable boundary | Current behavior | Expected behavior | Must remain unchanged | Rationale ID |
| --- | --- | --- | --- | --- | --- |
| OB-01 | Public temperature parsing | Parsing accepts impossible values. | Valid input parses and below-absolute-zero input is rejected. | Existing construction behavior. | R-01 |

## Acceptance specification

<!-- acceptance-case: AC-01 -->
### AC-01 — Parse valid Celsius

- Type: Success
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-01

```gherkin
Scenario: Parse valid Celsius
  Given the text "20.5"
  When a caller attempts to parse it
  Then parsing succeeds with a 20.5 Celsius temperature
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Reject below absolute zero

- Type: Failure
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-01

```gherkin
Scenario: Reject below absolute zero
  Given the text "-274"
  When a caller attempts to parse it
  Then parsing fails
```

## Completion criteria

AC-01 and AC-02 have passing Acceptance evidence.
EOF
    cat > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md <<'EOF'
# Temperature parsing

## Status

Approved

## Acceptance coverage

| Acceptance case | Source | Responsibility | Acceptance proof intent |
| --- | --- | --- | --- |
| AC-01 | `../change.md`, AC-01 | Owns | Prove valid public parsing. |
| AC-02 | `../change.md`, AC-02 | Owns | Prove impossible input is rejected. |
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

<!-- change-format: 2 -->

## Status

Approved

## Change goal

Callers can safely parse valid Celsius input without accepting values below absolute zero.

## Compatibility constraints

This parsing API uses invariant-culture decimal syntax.

## Rationale traceability

| ID | Design claim | Why it is necessary | Evidence, governing record, or decision ID | Status |
| --- | --- | --- | --- | --- |
| R-01 | Safe parsing | Prevent impossible domain values. | Approved request | Resolved |

## Observable behavior change

| ID | Observable boundary | Current behavior | Expected behavior | Must remain unchanged | Rationale ID |
| --- | --- | --- | --- | --- | --- |
| OB-01 | Public temperature parsing | No shared safe parser exists. | Valid Celsius parses and below-absolute-zero input is rejected. | Existing construction behavior. | R-01 |

## Acceptance specification

<!-- acceptance-case: AC-01 -->
### AC-01 — Parse valid Celsius

- Type: Success
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-01

```gherkin
Scenario: Parse valid Celsius
  Given the text "20.5"
  When a caller attempts to parse it
  Then parsing succeeds with a 20.5 Celsius temperature
```

<!-- acceptance-case: AC-02 -->
### AC-02 — Reject below absolute zero

- Type: Failure
- Observable boundary: Public temperature parsing API
- Behavior change: OB-01
- Rationale: R-01

```gherkin
Scenario: Reject below absolute zero
  Given the text "-274"
  When a caller attempts to parse it
  Then parsing fails
```

## Completion criteria

AC-01 and AC-02 have passing discoverable Acceptance evidence and the work item records verification.

<!-- delivery-map -->
## Delivery map

| ID | Work package | Logical prerequisites | Status |
| --- | --- | --- | --- |
| TEMP-001 | Parse valid Celsius input | None | Verified |
| TEMP-002 | Reject impossible Celsius input | TEMP-001: verified public parser | Verified |
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

Verified

## Outcome

Callers can parse valid Celsius input.

## Delivery brief

| Outcome boundary | Logical prerequisite |
| --- | --- |
| Valid public temperature parsing behavior | None |

## Acceptance coverage

| Acceptance case | Source | Responsibility | Acceptance proof |
| --- | --- | --- |
| AC-01 | `../change.md`, AC-01 | Owns | `Should_parse_valid_celsius_input` |

## Definition of done

- AC-01 is implemented and covered by the named Acceptance test.
- Recorded verification: `dotnet run --project Weather.Tests.csproj -c Release` passed on 2026-07-24.

## Completion evidence

- Changed artifacts: `Temperature.cs`, `TemperatureTests.cs`, and `Weather.Tests.csproj`.
- AC-01 passed through the recorded focused command.
- No migration or operational handoff is required.
EOF
    cat > docs/changes/P1-temperature-parse/work-items/TEMP-002-reject.md <<'EOF'
# Reject impossible Celsius input

## Status

Verified

## Outcome

Callers receive a non-throwing failure for below-absolute-zero input.

## Delivery brief

| Outcome boundary | Logical prerequisite |
| --- | --- |
| Invalid public temperature parsing behavior | TEMP-001 verified public parser |

## Acceptance coverage

| Acceptance case | Source | Responsibility | Acceptance proof |
| --- | --- | --- | --- |
| AC-02 | `../change.md`, AC-02 | Owns | `Should_reject_below_absolute_zero` |

## Definition of done

- AC-02 is implemented and covered by the named Acceptance test.
- Recorded verification: `dotnet run --project Weather.Tests.csproj -c Release` passed on 2026-07-24.

## Completion evidence

- Changed artifacts: `Temperature.cs`, `TemperatureTests.cs`, and `Weather.Tests.csproj`.
- AC-02 passed through the recorded focused command.
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
    <NoWarn>$(NoWarn);RCS1046</NoWarn>
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

if [[ "$scenario" == "ready-final-change" || "$scenario" == "ready-final-change-missing-extraction" ]]; then
  candidate="$(git rev-parse HEAD)"
  git notes add -m "Independent review packet for candidate $candidate. Fresh code reviewer: pass against AC-01 and AC-02 with no implementation findings. Fresh test reviewer: both material partitions have strong observable assertions, no shared resources, and no adequacy findings. Independent verification executor: dotnet run --project Weather.Tests.csproj -c Release passed; 2 discovered, 2 passed, 0 failed, 0 skipped. Each lane reviewed the raw contract and candidate without sibling conclusions."
fi

if [[ "$scenario" == "undocumented-behavior-change" ]]; then
  cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius)
{
    public static Temperature FromFahrenheit(decimal fahrenheit) => new((fahrenheit - 32m) * 5m / 9m);
}
EOF
fi
