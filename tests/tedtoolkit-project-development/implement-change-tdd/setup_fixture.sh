#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  unapproved-design)
    mkdir -p docs/changes
    cat > docs/changes/temperature-parse.md <<'EOF'
# Temperature parsing

## Status

Draft

## Acceptance criteria

`Temperature.TryParse` accepts Celsius decimal input and rejects invalid values.
EOF
    cat > Temperature.cs <<'EOF'
namespace Weather;

public readonly record struct Temperature(decimal Celsius);
EOF
    ;;
  epic-index)
    mkdir -p docs/changes/geometry-rebuild
    cat > docs/changes/geometry-rebuild/README.md <<'EOF'
# Geometry rebuild

## Status

Approved for decomposition

| ID | Work package | Status |
| --- | --- | --- |
| GEOM-001 | Equality model | Planned |
| GEOM-002 | Bounds rename | Planned |
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
