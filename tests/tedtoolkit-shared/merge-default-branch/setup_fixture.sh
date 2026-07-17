#!/usr/bin/env bash
# Build a disposable git fixture for a merge-default-branch eval scenario,
# IN PLACE in the current working directory (the agent's work dir). After this
# runs, the cwd is a git repo checked out on `feature`, with origin's default
# branch (main) ahead — so a merge of origin/main is required. The bare remote
# lives in ./.origin.git (gitignored) so `git fetch origin` works offline.
#
#   bash setup_fixture.sh <scenario>
#
# scenarios: clean-no-conflict | dirty-then-merge | conflict-keep-both | merge-breaks-build

set -euo pipefail
scenario="${1:?usage: setup_fixture.sh <scenario>}"
root="$(pwd)"
origin="$root/.origin.git"

git init --bare -b main "$origin" >/dev/null

git init -b main "$root" >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
git config commit.gpgsign false

# Keep build output and the bare remote out of the tracked tree, so a correct
# merge leaves a genuinely clean working tree.
cat > .gitignore <<'EOF'
bin/
obj/
.origin.git/
setup_fixture.sh
EOF

cat > App.csproj <<'EOF'
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
namespace App;

public static class Program
{
    public static void Main()
    {
        System.Console.WriteLine("ok");
    }
}
EOF

cat > Geometry.cs <<'EOF'
namespace App;

public class Arc2
{
    public double Radius { get; set; }

    // methods region
}
EOF

git add -A
git commit -q -m "🎉 chore: 初始化项目骨架

建立最小可构建的控制台项目，作为后续开发的基础。

- 新增 App.csproj、Program.cs 与 Geometry.cs"
git remote add origin "$origin"
git push -q origin main
git checkout -q -b feature

commit() { git add -A && git commit -q -m "$1"; }

case "$scenario" in
  clean-no-conflict|dirty-then-merge)
    cat > Feature.cs <<'EOF'
namespace App;

public static class FeatureOps
{
    public static int A() => 1;
}
EOF
    commit "✨ feat(feature): 新增 FeatureOps.A"
    git checkout -q main
    cat > Upstream.cs <<'EOF'
namespace App;

public static class UpstreamOps
{
    public static int B() => 2;
}
EOF
    commit "✨ feat(upstream): 新增 UpstreamOps.B"
    git push -q origin main
    git checkout -q feature
    if [ "$scenario" = "dirty-then-merge" ]; then
      # Leave an uncommitted local edit that must be preserved + committed first.
      cat > Program.cs <<'EOF'
namespace App;

public static class Program
{
    public static void Main()
    {
        System.Console.WriteLine("ok");
        System.Console.WriteLine(Greeting());
    }

    public static string Greeting() => "hello";
}
EOF
    fi
    ;;

  conflict-keep-both)
    cat > Geometry.cs <<'EOF'
namespace App;

public class Arc2
{
    public double Radius { get; set; }

    // methods region
    public double Length() => 2 * System.Math.PI * Radius;
}
EOF
    commit "✨ feat(geometry): 新增 Arc2.Length 求弧长"
    git checkout -q main
    cat > Geometry.cs <<'EOF'
namespace App;

public class Arc2
{
    public double Radius { get; set; }

    // methods region
    public double Bounds() => Radius * Radius;
}
EOF
    commit "✨ feat(geometry): 新增 Arc2.Bounds 求外接范围"
    git push -q origin main
    git checkout -q feature
    ;;

  merge-breaks-build)
    # Same class name in different files → no textual conflict, but the merged
    # tree has a duplicate type `Util` (CS0101) and won't compile until fixed.
    cat > Helpers.cs <<'EOF'
namespace App;

public static class Util
{
    public static int FeatureArea() => 1;
}
EOF
    commit "✨ feat(util): 新增 Util.FeatureArea"
    git checkout -q main
    cat > MoreHelpers.cs <<'EOF'
namespace App;

public static class Util
{
    public static int UpstreamArea() => 2;
}
EOF
    commit "✨ feat(util): 新增 Util.UpstreamArea"
    git push -q origin main
    git checkout -q feature
    ;;

  *)
    echo "unknown scenario: $scenario" >&2
    exit 1
    ;;
esac

git fetch -q origin
rm -f "$root/setup_fixture.sh"   # don't leave the helper as an untracked file
echo "fixture ready: scenario=$scenario branch=$(git rev-parse --abbrev-ref HEAD)"
