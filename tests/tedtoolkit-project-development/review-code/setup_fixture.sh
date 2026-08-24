#!/usr/bin/env bash
set -euo pipefail

scenario=${1:-defect}

git init -b main . >/dev/null
git config user.name "Fixture"
git config user.email "fixture@example.com"

mkdir -p docs/changes/ratio
cat > docs/changes/ratio/change.md <<'EOF'
# Safe ratio

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Fixture owner -->

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
<!-- primary-proof: AC-02 purpose=acceptance shape=unit -->

<!-- acceptance-case: AC-01 -->
- AC-01: A non-zero denominator whose quotient is representable returns the quotient.

<!-- acceptance-case: AC-02 -->
- AC-02: A zero denominator returns false without throwing.
EOF

cat > Ratio.cs <<'EOF'
namespace Numbers;

public static class Ratio;
EOF

rm -f setup_fixture.sh
git add -A
git commit -qm "baseline"
git tag eval-base

if [[ $scenario == clean ]]; then
cat > Ratio.cs <<'EOF'
namespace Numbers;

public static class Ratio
{
    public static bool TryDivide(decimal numerator, decimal denominator, out decimal result)
    {
        if (denominator == 0)
        {
            result = default;
            return false;
        }

        result = numerator / denominator;
        return true;
    }
}
EOF
elif [[ $scenario == overdesigned ]]; then
cat > Ratio.cs <<'EOF'
namespace Numbers;

public interface IDenominatorPolicy
{
    bool CanDivide(decimal denominator);
}

public sealed class NonZeroDenominatorPolicy : IDenominatorPolicy
{
    public bool CanDivide(decimal denominator) => denominator != 0;
}

public static class Ratio
{
    public static bool TryDivide(decimal numerator, decimal denominator, out decimal result)
    {
        IDenominatorPolicy policy = new NonZeroDenominatorPolicy();
        if (!policy.CanDivide(denominator))
        {
            result = default;
            return false;
        }

        result = numerator / denominator;
        return true;
    }
}
EOF
else

cat > Ratio.cs <<'EOF'
namespace Numbers;

public static class Ratio
{
    public static bool TryDivide(decimal numerator, decimal denominator, out decimal result)
    {
        result = numerator / denominator;
        return true;
    }
}
EOF
fi

git add Ratio.cs
git commit -qm "candidate"
