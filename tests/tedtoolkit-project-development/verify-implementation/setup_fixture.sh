#!/usr/bin/env bash
set -euo pipefail

scenario=${1:-zero}

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

mkdir -p .binstub docs/changes/value
cat > CONTRIBUTING.md <<'EOF'
Run `dotnet test --configuration Release --project Value.Tests.csproj`.
EOF
cat > docs/changes/value/change.md <<'EOF'
# Value behavior
<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Fixture owner -->
<!-- acceptance-case: AC-01 -->
- AC-01: Value.Normalize returns the approved normalized result.
<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
EOF
cat > Value.cs <<'EOF'
namespace Values;
public readonly record struct Value(int Number);
EOF
cat > .gitignore <<'EOF'
.command-log.txt
.expected-head
EOF
cat > .binstub/dotnet <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "dotnet $*" >> .command-log.txt
if [[ -f .verification-success ]]; then
  echo "Test run summary: total: 1, failed: 0, succeeded: 1, skipped: 0"
else
  echo "Test run summary: total: 0, failed: 0, succeeded: 0, skipped: 0"
fi
exit 0
EOF
chmod +x .binstub/dotnet
cat > .binstub/dotnet.cmd <<'EOF'
@echo off
bash "%~dp0dotnet" %*
exit /b %ERRORLEVEL%
EOF

if [[ $scenario == success ]]; then
  : > .verification-success
fi

rm -f setup_fixture.sh
git add -A
git commit -qm "candidate"
git rev-parse HEAD > .expected-head
