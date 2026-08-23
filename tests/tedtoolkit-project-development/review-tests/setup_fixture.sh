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

<!-- acceptance-case: AC-01 -->
- AC-01: "20.5" parses to exactly 20.5 Celsius.

<!-- acceptance-case: AC-02 -->
- AC-02: Invalid input returns false without a value.
EOF

cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius)
{
    public static bool TryParse(string? text, out Temperature value)
    {
        if (decimal.TryParse(text, out var parsed))
        {
            value = new Temperature(parsed);
            return true;
        }

        value = default;
        return false;
    }
}
EOF

rm -f setup_fixture.sh
git add -A
git commit -qm "baseline"
git tag eval-base

if [[ $scenario == clean ]]; then
cat > TemperatureTests.cs <<'EOF'
using TUnit.Assertions;
using TUnit.Core;

namespace Weather.Tests;

internal sealed class TryParseTests
{
    [Test]
    public async Task Valid_text_returns_exact_value()
    {
        var parsed = Temperature.TryParse("20.5", out var value);
        await Assert.That(parsed).IsTrue();
        await Assert.That(value.Celsius).IsEqualTo(20.5m);
    }

    [Test]
    public async Task Invalid_text_returns_false()
    {
        var parsed = Temperature.TryParse("invalid", out _);
        await Assert.That(parsed).IsFalse();
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

git add TemperatureTests.cs
git commit -qm "candidate tests"
