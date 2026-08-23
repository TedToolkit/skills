#!/usr/bin/env bash
set -euo pipefail

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

cat > Geometry.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <OutputType>Exe</OutputType>
    <IsTestProject>true</IsTestProject>
    <NoWarn>$(NoWarn);RCS1046</NoWarn>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="0.0.0-eval" />
  </ItemGroup>
</Project>
EOF

cat > README.md <<'EOF'
# Geometry test fixture

Keep deterministic public-API proofs in the existing `Geometry.Tests.csproj` project.
EOF

rm -f setup_fixture.sh
git add -A
git commit -qm "fixture"
