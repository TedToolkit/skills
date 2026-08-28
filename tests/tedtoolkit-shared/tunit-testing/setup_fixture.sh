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

if [[ "${1:-}" != "test" ]]; then
  echo "fixture dotnet stub supports only 'dotnet test'" >&2
  exit 64
fi


shift
project=""
previous=""
for argument in "$@"; do
  if [[ "$previous" == "--project" ]]; then
    project="$argument"
    break
  fi
  if [[ "$argument" == *.csproj ]]; then
    project="$argument"
  fi
  previous="$argument"
done

if [[ -z "$project" || ! -f "$project" ]]; then
  echo "fixture verification failed: an existing .csproj must be selected" >&2
  exit 65
fi

if grep -Eiq 'PackageReference[[:space:]]+Include="(Microsoft\.NET\.Test\.Sdk|coverlet\.(collector|msbuild))"' "$project"; then
  echo "fixture verification failed: VSTest-only package remains in $project" >&2
  exit 66
fi

if ! grep -Eiq 'PackageReference[[:space:]]+Include="TUnit"' "$project"; then
  echo "fixture verification failed: TUnit package is missing from $project" >&2
  exit 67
fi

mapfile -t test_files < <(find . -type f -name '*Tests.cs' -not -path './obj/*' -not -path './bin/*')
if (( ${#test_files[@]} == 0 )); then
  echo "fixture verification failed: zero test files discovered" >&2
  exit 68
fi

if grep -Eq '\[(Fact|Theory|TestMethod)\]|using[[:space:]]+(Xunit|Microsoft\.VisualStudio\.TestTools)' "${test_files[@]}"; then
  echo "fixture verification failed: previous test-framework syntax remains" >&2
  exit 70
fi

discovered=0
for test_file in "${test_files[@]}"; do
  if grep -Fq '[Test]' "$test_file" && grep -Fq 'await Assert.That' "$test_file"; then
    discovered=$((discovered + 1))
  fi
done

if (( discovered == 0 )); then
  echo "fixture verification failed: zero TUnit tests discovered" >&2
  exit 69
fi

if [[ "$project" == "Buggy.Tests.csproj" ]] &&
   ! grep -Fq 'public static int Square(int value) => value * value;' Calculator.cs; then
  echo "Failed: Square should multiply the input by itself" >&2
  exit 1
fi

printf 'Test run for %s\nDiscovered: %d Passed: %d Failed: 0 Skipped: 0\n' \
  "$project" "$discovered" "$discovered"
EOF
chmod +x .binstub/dotnet
cat > .binstub/dotnet.cmd <<'EOF'
@echo off
bash "%~dp0dotnet" %*
exit /b %ERRORLEVEL%
EOF

case "$scenario" in
  tunit-command-selection)
    cat > Geometry.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <OutputType>Exe</OutputType>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
    <NoWarn>$(NoWarn);RCS1046</NoWarn>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="0.0.0-eval" />
  </ItemGroup>
</Project>
EOF

    cat > CONTRIBUTING.md <<'EOF'
# Testing

This TUnit suite is verified with:

```sh
dotnet test --configuration Release --project Geometry.Tests.csproj
```
EOF

    cat > Vector.cs <<'EOF'
namespace Geometry;

internal readonly record struct Vector(double X, double Y)
{
    public double Length() => System.Math.Sqrt((X * X) + (Y * Y));
}
EOF

    mkdir -p VectorTests
    cat > VectorTests/LengthTests.cs <<'EOF'
namespace Geometry.Tests;

internal sealed class LengthTests
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
EOF
    ;;

  tunit-mocks)
    cat > Pricing.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <OutputType>Exe</OutputType>
    <LangVersion>14</LangVersion>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
    <NoWarn>$(NoWarn);RCS1046</NoWarn>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="0.0.0-eval" />
  </ItemGroup>
</Project>
EOF

    cat > CONTRIBUTING.md <<'EOF'
# Testing

Run the focused test project with:

```sh
dotnet test --configuration Release --project Pricing.Tests.csproj
```

Put each production class's tests in a `ClassNameTests` directory. Inside it, use one
`MethodNameTests.cs` file and `MethodNameTests` class per tested method. Test methods use
`Should_xxx_when_xxx` and include an XML `summary`.
EOF

    cat > PricingService.cs <<'EOF'
namespace Pricing;

internal interface IPriceSource
{
    decimal GetPrice(string sku);
}

internal sealed class PricingService(IPriceSource priceSource)
{
    public decimal GetTotal(string sku, int quantity) => priceSource.GetPrice(sku) * quantity;
}
EOF

    mkdir -p PricingServiceTests
    cat > PricingServiceTests/GetTotalTests.cs <<'EOF'
namespace Pricing.Tests;

// Add focused PricingService.GetTotal coverage here.
EOF
    ;;

  tunit-migration)
    cat > Legacy.Tests.csproj <<'EOF'
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
    <PackageReference Include="coverlet.collector" Version="6.0.2" />
    <PackageReference Include="coverlet.msbuild" Version="6.0.2" />
    <PackageReference Include="xunit" Version="2.9.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.8.2" />
  </ItemGroup>
</Project>
EOF

    cat > CONTRIBUTING.md <<'EOF'
# Testing

Run the test project with:

```sh
dotnet test --configuration Release --project Legacy.Tests.csproj
```

Migrated TUnit tests use `Should_xxx_when_xxx`, include an XML `summary`, and await assertions.
EOF

    cat > Calculator.cs <<'EOF'
namespace Legacy;

internal static class Calculator
{
    public static int Add(int left, int right) => left + right;
}
EOF

    mkdir -p CalculatorTests
    cat > CalculatorTests/AddTests.cs <<'EOF'
namespace Legacy.Tests;

internal sealed class AddTests
{
    [Fact]
    public void Adds_two_values()
    {
        var result = Calculator.Add(2, 3);

        Assert.Equal(5, result);
    }
}
EOF
    ;;

  tunit-run-fix-handoff)
    cat > Buggy.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <OutputType>Exe</OutputType>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsTestProject>true</IsTestProject>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="TUnit" Version="0.0.0-eval" />
  </ItemGroup>
</Project>
EOF

    cat > CONTRIBUTING.md <<'EOF'
# Testing

Run the TUnit project with:

```sh
dotnet test --configuration Release --project Buggy.Tests.csproj
```
EOF

    cat > Calculator.cs <<'EOF'
namespace Buggy;

internal static class Calculator
{
    public static int Square(int value) => value + value;
}
EOF

    mkdir -p CalculatorTests
    cat > CalculatorTests/SquareTests.cs <<'EOF'
namespace Buggy.Tests;

internal sealed class SquareTests
{
    /// <summary>
    /// Verifies that a value is multiplied by itself.
    /// </summary>
    [Test]
    public async Task Should_multiply_the_value_by_itself()
    {
        var result = Calculator.Square(3);

        await Assert.That(result).IsEqualTo(9);
    }
}
EOF
    ;;

  *)
    echo "unknown scenario: $scenario" >&2
    exit 1
    ;;
esac

git add -A
git commit -q -m "🎉 chore: initialize tunit-testing fixture

Create a minimal project that exposes TUnit command selection for skill evaluation."
rm -f "$root/setup_fixture.sh"
echo "fixture ready: scenario=$scenario branch=$(git rev-parse --abbrev-ref HEAD)"
