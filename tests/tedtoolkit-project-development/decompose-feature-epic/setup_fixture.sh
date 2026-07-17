#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

case "$scenario" in
  geometry-epic)
    mkdir -p docs/features src tests
    cat > docs/features/geometry-rebuild.md <<'EOF'
# Geometry rebuild

## Status

Approved

The proposal renames public bounds APIs, changes root interfaces, alters generated equality, and
adds validated mesh types. Some equality semantics are still undecided.
EOF
    cat > src/Geometry.cs <<'EOF'
namespace Geometry;

public interface IGeometryObject;
EOF
    ;;
  *) echo "unknown scenario: $scenario" >&2; exit 1 ;;
esac

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
