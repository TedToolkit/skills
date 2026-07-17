#!/usr/bin/env bash
set -euo pipefail

fixture="$1"

if [[ "$fixture" == "with-reference" ]]; then
  reference='<PackageReference Include="TedToolkit.RoslynHelper" Version="1.0.0" />'
else
  reference=''
fi

cat > Generator.csproj <<EOF
<Project Sdk="Microsoft.NET.Sdk">
  <ItemGroup>
    $reference
  </ItemGroup>
</Project>
EOF

cat > Generator.cs <<'EOF'
using Microsoft.CodeAnalysis;

public sealed class DemoGenerator
{
    public void Generate(SourceProductionContext context, IPropertySymbol propertySymbol, Compilation compilation)
    {
    }
}
EOF
