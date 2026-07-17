#!/usr/bin/env bash
# Build a disposable git fixture for a generate-commit-message eval, IN PLACE in
# the current working directory. After this runs the cwd is a git repo on `main`
# with the baseline tagged `eval-base`, and a DIRTY working tree holding two
# unrelated concerns:
#   1. a new feature file src/Notifier.cs + its test tests/NotifierTests.cs
#   2. an unrelated typo fix in README.md
# A correct atomic split is therefore two commits: one feat (feature + its test
# together) and one docs (the README typo on its own).
#
#   bash setup_fixture.sh <scenario>   # scenario is informational; tree is the same
#
# scenarios: two-unrelated-changes | message-only

set -euo pipefail
root="$(pwd)"

git init -b main "$root" >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"
git config commit.gpgsign false

# Keep the harness's own artifacts out of the skill's `git status` view so the
# dirty tree under test holds only the real changes (the feature + the README
# fix). run_evals.py streams its event log to claude.stream.jsonl in this dir and
# may write prompt.txt; neither is a user change, so the skill must not see — or
# commit — them, and the clean-tree assertion must not trip over them.
printf 'claude.stream.jsonl\nprompt.txt\n' > .git/info/exclude

cat > .gitignore <<'EOF'
bin/
obj/
setup_fixture.sh
EOF

# A small typo in the README that the dirty edit will fix (开使 -> 开始).
cat > README.md <<'EOF'
# Demo

一个用于演示的最小项目。

## 快速开使

运行 `dotnet run` 即可。
EOF

mkdir -p src tests
cat > src/Calculator.cs <<'EOF'
namespace Demo;

public static class Calculator
{
    public static int Add(int a, int b) => a + b;
}
EOF

git add -A
git commit -q -m "🎉 chore: 初始化演示项目骨架

建立最小可运行的项目，作为后续开发的基础。

- 新增 README、Calculator 与 .gitignore"
git tag eval-base

# ---- Dirty the tree with two unrelated concerns -------------------------------

# 1) New feature + its test (one logical change → should ride in one commit).
cat > src/Notifier.cs <<'EOF'
namespace Demo;

public static class Notifier
{
    public static string Format(string who) => $"hello, {who}";
}
EOF
cat > tests/NotifierTests.cs <<'EOF'
namespace Demo.Tests;

public static class NotifierTests
{
    public static bool FormatsName() => Notifier.Format("world") == "hello, world";
}
EOF

# 2) Unrelated docs typo fix (开使 -> 开始) — should be its own commit.
cat > README.md <<'EOF'
# Demo

一个用于演示的最小项目。

## 快速开始

运行 `dotnet run` 即可。
EOF

rm -f "$root/setup_fixture.sh"   # gitignored anyway; remove so it's not stray
echo "fixture ready: dirty tree with a feature+test and an unrelated README fix"
