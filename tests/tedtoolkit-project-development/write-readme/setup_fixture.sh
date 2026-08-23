#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > CLAUDE.md <<'EOF'
# Repository guidance

- Implementation language: C#.
- README and code-comment language: English.
- Build with `dotnet build Sample.csproj -c Release`.
EOF

cat > AGENTS.md <<'EOF'
Repository guidance is maintained in [CLAUDE.md](./CLAUDE.md).
EOF

cat > Sample.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
  </PropertyGroup>
</Project>
EOF

cat > Sample.cs <<'EOF'
namespace Sample;

/// <summary>Validates non-empty input.</summary>
public static class Parser
{
    public static bool IsValid(string value) => !string.IsNullOrWhiteSpace(value);
}
EOF

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
