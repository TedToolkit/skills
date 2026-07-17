#!/usr/bin/env bash
# Build a disposable .NET fixture for a run-fix eval scenario, IN PLACE in the
# current working directory (the agent's work dir). After this runs, the cwd is
# a git repo on `main` holding a single project that fails in a specific way the
# skill must diagnose and fix. The repo is tracked so the skill's `git ls-files
# '*.csproj'` locate step works; bin/obj are gitignored so a correct fix leaves
# a clean working tree.
#
#   bash setup_fixture.sh <scenario>
#
# scenarios: library-compile-error | exe-runtime-error | test-failure

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
setup_fixture.sh
EOF

case "$scenario" in
  library-compile-error)
    # A library that won't compile: Square references an undefined identifier
    # `m` (CS0103). The fix is to use the parameter `n`.
    cat > MathLib.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
EOF
    cat > Calculator.cs <<'EOF'
namespace MathLib;

public static class Calculator
{
    public static int Add(int a, int b) => a + b;

    public static int Square(int n) => n * m;
}
EOF
    ;;

  exe-runtime-error)
    # An app that compiles but throws at runtime: the loop bound `<=` walks one
    # past the array end (IndexOutOfRangeException). Fixed, it prints sum=6.
    cat > Calc.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
EOF
    cat > Program.cs <<'EOF'
namespace Calc;

public static class Program
{
    public static void Main()
    {
        int[] data = { 1, 2, 3 };
        int sum = 0;
        for (int i = 0; i <= data.Length; i++)
            sum += data[i];
        System.Console.WriteLine($"sum={sum}");
    }
}
EOF
    ;;

  test-failure)
    # A test project whose one test fails because the production method under
    # test has a bug: Discount subtracts instead of applying a percentage.
    # NOTE: xunit / Test.Sdk require a NuGet restore — this scenario is NOT
    # offline (unlike the other two). The fix lives in Pricing.cs.
    cat > Widget.Tests.csproj <<'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
    <IsPackable>false</IsPackable>
  </PropertyGroup>
  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.11.1" />
    <PackageReference Include="xunit" Version="2.9.2" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.8.2" />
  </ItemGroup>
</Project>
EOF
    cat > Pricing.cs <<'EOF'
namespace Widget;

public static class Pricing
{
    // Apply a percentage discount, e.g. price 100 at 10% -> 90.
    public static decimal Discount(decimal price, decimal percent)
        => price - percent;
}
EOF
    cat > PricingTests.cs <<'EOF'
using Widget;
using Xunit;

public class PricingTests
{
    [Fact]
    public void Discount_AppliesPercentage()
    {
        Assert.Equal(90m, Pricing.Discount(100m, 10m));
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
git commit -q -m "🎉 chore: 初始化 run-fix 夹具

建立一个会以特定方式失败的最小项目，供 run-fix 技能定位、诊断并修复。"
rm -f "$root/setup_fixture.sh"   # don't leave the helper as an untracked file
echo "fixture ready: scenario=$scenario branch=$(git rev-parse --abbrev-ref HEAD)"
