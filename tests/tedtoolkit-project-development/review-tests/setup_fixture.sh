#!/usr/bin/env bash
set -euo pipefail

scenario=${1:-weak}

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

mkdir -p docs/changes/parse
cat > docs/changes/parse/change.md <<'EOF'
# Parse temperature

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Fixture owner -->

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
<!-- primary-proof: AC-02 purpose=acceptance shape=unit -->

## Proof plan

| Contract | Observable assertion | Authoritative command |
| --- | --- | --- |
| AC-01 | `"20.5"` succeeds with exactly `20.5m` Celsius | `dotnet test --configuration Release --project Weather.Tests.csproj` |
| AC-02 | `"invalid"` returns false and default output | `dotnet test --configuration Release --project Weather.Tests.csproj` |

<!-- acceptance-case: AC-01 -->
- AC-01: "20.5" parses to exactly 20.5 Celsius.

<!-- acceptance-case: AC-02 -->
- AC-02: The text `"invalid"` returns false with the default value.
EOF

cat > Temperature.cs <<'EOF'
using System.Globalization;

namespace Weather;

public readonly record struct Temperature(decimal Celsius)
{
    public static bool TryParse(string? text, out Temperature value)
    {
        if (decimal.TryParse(text, NumberStyles.Number, CultureInfo.InvariantCulture, out var parsed))
        {
            value = new Temperature(parsed);
            return true;
        }

        value = default;
        return false;
    }
}
EOF

cat > Weather.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="0.0.0-eval" />
  </ItemGroup>
</Project>
EOF

rm -f setup_fixture.sh
git add -A
git commit -qm "baseline"
git tag eval-base

if [[ $scenario == clean ]]; then
mkdir -p TemperatureTests
cat > TemperatureTests/TryParseTests.cs <<'EOF'
using TUnit.Assertions;
using TUnit.Core;

namespace Weather.Tests;

internal sealed class TryParseTests
{
    /// <summary>Verifies valid invariant text returns the exact Celsius value.</summary>
    [Test]
    public async Task Should_return_exact_value_when_text_is_valid()
    {
        var parsed = Temperature.TryParse("20.5", out var value);
        await Assert.That(parsed).IsTrue();
        await Assert.That(value.Celsius).IsEqualTo(20.5m);
    }

    /// <summary>Verifies invalid text returns false and the default output.</summary>
    [Test]
    public async Task Should_return_false_and_default_when_text_is_invalid()
    {
        var parsed = Temperature.TryParse("invalid", out var value);
        await Assert.That(parsed).IsFalse();
        await Assert.That(value).IsEqualTo(default(Temperature));
    }
}
EOF
else
cat > TemperatureTests.cs <<'EOF'
using TUnit.Assertions;
using TUnit.Core;

namespace Weather.Tests;

internal sealed class TryParseTests
{
    /// <summary>Checks that parsing returns some value.</summary>
    [Test]
    public async Task Should_parse_valid_text()
    {
        Temperature.TryParse("20.5", out var value);

        await Assert.That((object)value).IsNotNull();
    }
}
EOF
fi

git add TemperatureTests.cs TemperatureTests/TryParseTests.cs 2>/dev/null || git add -A
git commit -qm "candidate tests"
