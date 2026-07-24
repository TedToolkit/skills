#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > Sample.cs <<'EOF'
namespace Sample;

public sealed class Sample;
EOF

cat > README.md <<'EOF'
# Sample

A reusable .NET library.
EOF

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
