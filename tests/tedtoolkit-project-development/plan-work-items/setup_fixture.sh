#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

if [[ ${1:-} == incomplete ]]; then
    mkdir -p docs/changes/P1-incomplete-change
    cat > docs/changes/P1-incomplete-change/change.md <<'EOF'
# Incomplete change

## Status

Draft
EOF
    rm -f setup_fixture.sh
    git add -A
    git commit -qm "fixture"
    exit 0
fi

mkdir -p docs/changes/P1-temperature-parse/work-items
cat > docs/changes/P1-temperature-parse/change.md <<'EOF'
# Temperature parsing

## Status

Approved

## Change goal

Callers can parse valid invariant Celsius text without accepting invalid or impossible values.

## Scope and non-goals

Add one non-throwing public parsing API. Do not add formatting or conversion APIs.

## Public contract

Add `public static bool TryParse(string? text, out Temperature result)`. It uses invariant decimal
syntax, returns `false` for invalid or impossible values, and leaves the existing constructor
unchanged.

## Behavior cases

| ID | Preconditions and input | Action | Expected observable behavior |
| --- | --- | --- | --- |
| BC-01 | `"12.5"` | Call `TryParse` | Parses invariant decimal Celsius. |
| BC-02 | `null`, whitespace, invalid text, or below absolute zero | Call `TryParse` | Returns false. |

## Completion criteria

Both behavior cases are implemented and protected by focused automated tests.
EOF
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
rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
: > docs/changes/P1-temperature-parse/work-items/TEMP-001-parse.md
