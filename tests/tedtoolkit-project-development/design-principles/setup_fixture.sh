#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > Sample.cs <<'EOF'
namespace Sample;

public sealed class Sample;
EOF

mkdir -p docs/changes/temporary-principles
cat > docs/changes/temporary-principles/README.md <<'EOF'
# Temporary delivery notes

Tracking marker: TRANSIENT-PRINCIPLES-CHANGE

This short-lived file will be deleted after delivery. Durable principles must not link to it, cite
it, name it, or depend on it.
EOF

git add -A
git commit -qm "fixture"
rm -f setup_fixture.sh
