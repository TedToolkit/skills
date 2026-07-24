#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
mkdir -p docs/changes/P1-temperature-parse
cat > docs/changes/P1-temperature-parse/README.md <<'EOF'
# Temperature parsing

## Status

Approved

## Behavior cases

| ID | Preconditions and input | Action | Expected observable behavior |
| --- | --- | --- | --- |
| BC-01 | `"12.5"` | Call `TryParse` | Parses invariant decimal Celsius. |
| BC-02 | `null`, whitespace, invalid text, or below absolute zero | Call `TryParse` | Returns false. |
EOF
cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
cat > TemperatureTests.cs <<'EOF'
namespace Weather.Tests;

internal sealed class TemperatureTests;
EOF
git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
