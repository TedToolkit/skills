#!/usr/bin/env bash
set -euo pipefail

scenario="${1:?usage: setup_fixture.sh <scenario>}"
root="$(pwd)"

git init -b main "$root" >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
git config commit.gpgsign false

cat > .gitignore <<'EOF'
bin/
obj/
.command-log.txt
setup_fixture.sh
EOF

mkdir -p .binstub

cat > .binstub/dotnet <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'dotnet %s\n' "$*" >> ".command-log.txt"
if [[ "${1:-}" == "test" ]]; then
  exit 0
fi
exit 0
EOF
chmod +x .binstub/dotnet

case "$scenario" in
  tunit-command-selection)
    cat > Geometry.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.11.1" />
    <PackageReference Include="TUnit" Version="0.0.0-eval" />
    <PackageReference Include="TUnit.Assertions" Version="0.0.0-eval" />
  </ItemGroup>
</Project>
EOF

    cat > CONTRIBUTING.md <<'EOF'
# Testing

This multi-targeted TUnit suite is verified across all target frameworks with:

```sh
dotnet test --configuration Release --project Geometry.Tests.csproj
```
EOF

    cat > VectorLengthTests.cs <<'EOF'
namespace Geometry.Tests;

internal sealed class VectorLengthTests
{
    /// <summary>
    /// Verifies that the vector length is preserved for an already normalized input.
    /// </summary>
    [Test]
    public async Task Should_return_same_length_when_vector_is_normalized()
    {
        var vector = new Vector(0, 1);

        var result = vector.Length();

        await Assert.That(result).IsEqualTo(1d);
    }
}

internal readonly record struct Vector(double X, double Y)
{
    public double Length() => System.Math.Sqrt((X * X) + (Y * Y));
}
EOF
    ;;

  *)
    echo "unknown scenario: $scenario" >&2
    exit 1
    ;;
esac

git add -A
git commit -q -m "🎉 chore: initialize tunit-unit-testing fixture

Create a minimal project that exposes TUnit command selection for skill evaluation."
rm -f "$root/setup_fixture.sh"
echo "fixture ready: scenario=$scenario branch=$(git rev-parse --abbrev-ref HEAD)"
