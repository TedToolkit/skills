#!/usr/bin/env bash
set -euo pipefail

repo_root=${TEDTOOLKIT_REPO_ROOT:-}
if [[ -z $repo_root ]]; then
    repo_root=$(git rev-parse --show-toplevel)
fi
scripts="$repo_root/plugins/tedtoolkit-project-development/scripts"
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT

change_dir="$fixture/docs/changes/temperature-ingestion"
mkdir -p "$change_dir/work-items"

cat > "$change_dir/change.md" <<'EOF'
# 统一温度输入

<!-- change-format: 3 -->
<!-- workflow-profile: controlled -->
<!-- change-kind: behavior-change -->
<!-- change-status: approved -->
<!-- delivery-shape: multi-item -->

<!-- approval-source: Workflow fixture -->

<!-- section: goal-rationale -->
## 目标与理由

调用方通过一个公共契约解析温度，避免接受不可能的值。

<!-- section: scope -->
## 范围与非目标

包括公共解析和摄取边界；不包括格式化；保留现有构造函数行为。

<!-- section: behavior-contract -->
## 行为契约

<!-- acceptance-case: AC-01 -->
- AC-01：合法的不变区域性温度可以解析，非法值被拒绝。
<!-- acceptance-case: AC-02 -->
- AC-02：摄取边界复用公共解析契约并保持相同结果。

<!-- section: delivery-brief -->
## 交付安排

公共解析器和其摄取消费者是两个可独立验证的交付。

<!-- section: proof-plan -->
## 证明

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
<!-- primary-proof: AC-02 purpose=acceptance shape=component -->
| 契约 | Role | 目的 | 执行形态 | 可观察断言 | 命令或过程 |
| --- | --- | --- | --- | --- | --- |
| AC-01 | Primary | 验收 | Unit | 合法值解析且非法值拒绝 | bash verify-parser.sh |
| AC-02 | Primary | 验收 | Component | 摄取结果与公共解析一致 | bash verify-ingestion.sh |

<!-- section: completion-criteria -->
## 完成条件

AC-01 和 AC-02 的主要证明均通过。
EOF

write_item() {
    local file=$1 id=$2 owned=$3 prerequisite=$4
    cat > "$file" <<EOF
# 交付项

<!-- work-item-format: 2 -->
<!-- work-item-id: $id -->

<!-- approval-source: Workflow fixture -->

<!-- work-item: scope -->
## 范围

交付 $owned，不改动无关行为。

<!-- work-item: start-conditions -->
## 开始条件

$prerequisite

<!-- work-item: contract-coverage -->
## 契约责任

$owned

<!-- work-item: delivery-constraints -->
## 约束

保持现有构造函数兼容。

<!-- work-item: proof-plan -->
## 证明

<!-- primary-proof: $owned purpose=acceptance shape=unit -->
| Contract | Role | Purpose | Shape | Observable assertion | Command or procedure |
| --- | --- | --- | --- | --- | --- |
| $owned | Primary | Acceptance | Unit | Stable boundary demonstrates $owned | bash verify-item.sh |

<!-- work-item: definition-of-done -->
## 完成

$owned 的主要证明通过。

<!-- work-item: completion-evidence -->
## 完成证据

记录命令、断言、结果和供应给后续项的输出。
EOF
}

write_item "$change_dir/work-items/TEMP-001-parser.md" "TEMP-001" "AC-01" "None"
write_item "$change_dir/work-items/TEMP-002-ingestion.md" "TEMP-002" "AC-02" "TEMP-001 的公共解析契约已验证"

cat > "$change_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
## 交付图

<!-- approval-source: Workflow fixture -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| TEMP-001 | 公共解析器 | Owns AC-01 / Supports AC-02 | None | 公共解析示例 | Verified | `work-items/TEMP-001-parser.md` |
| TEMP-002 | 摄取边界 | Owns AC-02 | TEMP-001: verified parser contract | 摄取示例 | Approved | `work-items/TEMP-002-ingestion.md` |
EOF

"$scripts/validate-acceptance-specification.sh" "$change_dir/change.md"
"$scripts/validate-work-items.sh" "$change_dir"

cp "$change_dir/change.md" "$fixture/unmapped-proof.md"
sed -i '/| AC-02 |/d; /primary-proof: AC-02/d' "$fixture/unmapped-proof.md"
if "$scripts/validate-acceptance-specification.sh" "$fixture/unmapped-proof.md" >/dev/null 2>&1; then
    echo "change with an unmapped contract was incorrectly accepted" >&2
    exit 1
fi

cp "$change_dir/change.md" "$fixture/duplicate-primary.md"
sed -i '/primary-proof: AC-01/a <!-- primary-proof: AC-01 purpose=regression shape=unit -->' "$fixture/duplicate-primary.md"
if "$scripts/validate-acceptance-specification.sh" "$fixture/duplicate-primary.md" >/dev/null 2>&1; then
    echo "change with duplicate primary proof was incorrectly accepted" >&2
    exit 1
fi

schedule=$("$scripts/schedule-work-items.sh" "$change_dir")
grep -Fq $'TEMP-001\tCOMPLETE' <<<"$schedule"
grep -Fq $'TEMP-002\tREADY' <<<"$schedule"

mv "$change_dir/work-items.md" "$fixture/format3-map.md"
if "$scripts/schedule-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "format 3 change without work-items.md incorrectly used legacy table parsing" >&2
    exit 1
fi
mv "$fixture/format3-map.md" "$change_dir/work-items.md"

cp "$change_dir/work-items.md" "$fixture/verified-map.md"
sed -i 's/| Verified | `work-items\/TEMP-001-parser.md`/| Implemented | `work-items\/TEMP-001-parser.md`/' "$change_dir/work-items.md"
if "$scripts/schedule-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "Implemented candidate incorrectly unlocked a dependent before verified integration" >&2
    exit 1
fi
cp "$fixture/verified-map.md" "$change_dir/work-items.md"

cp "$change_dir/work-items.md" "$fixture/multi-map.md"
grep -v 'TEMP-002' "$fixture/multi-map.md" > "$change_dir/work-items.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "single-row delivery map was incorrectly accepted" >&2
    exit 1
fi

cp "$fixture/multi-map.md" "$change_dir/work-items.md"
sed -i 's/| None | 公共解析示例/| MISS-999: missing input | 公共解析示例/' "$change_dir/work-items.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "missing prerequisite was incorrectly accepted" >&2
    exit 1
fi

cp "$fixture/multi-map.md" "$change_dir/work-items.md"
sed -i 's#work-items/TEMP-002-ingestion.md#../outside.md#' "$change_dir/work-items.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "work-item document path traversal was incorrectly accepted" >&2
    exit 1
fi
cp "$fixture/multi-map.md" "$change_dir/work-items.md"
write_item "$change_dir/work-items/TEMP-003-cycle.md" "TEMP-003" "None" "TEMP-002 的候选输出"
cat > "$change_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
## 交付图

<!-- approval-source: Workflow fixture -->

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| TEMP-001 | 公共解析器 | Owns AC-01 | None | 公共解析示例 | Verified | `work-items/TEMP-001-parser.md` |
| TEMP-002 | 摄取边界 | Owns AC-02 | TEMP-003: candidate output | 摄取示例 | Approved | `work-items/TEMP-002-ingestion.md` |
| TEMP-003 | 循环候选 | None | TEMP-002: candidate output | 结构检查 | Approved | `work-items/TEMP-003-cycle.md` |
EOF
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "partial dependency cycle was incorrectly accepted" >&2
    exit 1
fi
rm "$change_dir/work-items/TEMP-003-cycle.md"
cp "$fixture/multi-map.md" "$change_dir/work-items.md"
cp "$change_dir/change.md" "$fixture/language-neutral-proof.md"
sed -i 's/主要证明/补充证据/g; s/Primary proof/Conditional proof/g' "$fixture/language-neutral-proof.md"
"$scripts/validate-acceptance-specification.sh" "$fixture/language-neutral-proof.md"

cat > "$fixture/refactor.md" <<'EOF'
# Preserve temperature semantics while reorganizing internals

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-preserving-refactor -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->

<!-- approval-source: Workflow fixture -->

<!-- section: goal-rationale -->
## Goal and rationale

Simplify internal organization without changing supported temperature results.

<!-- section: scope -->
## Scope and non-goals

Internal organization only; no public API or behavior change.

<!-- section: invariants -->
## Preserved invariants

<!-- preserved-invariant: INV-01 -->
- INV-01: Every currently supported input returns the same observable result.

<!-- section: delivery-brief -->
## Delivery brief

One bounded internal refactor.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: INV-01 purpose=regression shape=unit -->
| Contract | Role | Evidence purpose | Execution shape | Observable assertion | Command or procedure |
| --- | --- | --- | --- | --- | --- |
| INV-01 | Primary | Regression | Unit | Existing public-boundary behavior remains unchanged | bash verify-refactor.sh |

<!-- section: completion-criteria -->
## Completion

INV-01 and the repository build pass.
EOF

"$scripts/validate-acceptance-specification.sh" "$fixture/refactor.md"

grep -v '<!-- approval-source:' "$fixture/refactor.md" > "$fixture/refactor-without-approval.md"
if "$scripts/validate-acceptance-specification.sh" "$fixture/refactor-without-approval.md" >/dev/null 2>&1; then
    echo "approved change without a pinned approval source was incorrectly accepted" >&2
    exit 1
fi

cat > "$fixture/experiment.md" <<'EOF'
# Compare parser allocation strategies

<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: experiment -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->

<!-- approval-source: Workflow fixture -->

<!-- section: goal-rationale -->
## Goal and rationale

Choose whether a parser optimization is worth a separate production change.

<!-- section: scope -->
## Scope

Measure representative parsing only; do not modify production behavior.

<!-- section: experiment-contract -->
## Experiment contract

<!-- experiment: EXP-01 -->
- EXP-01 asks whether the candidate reduces allocation without unacceptable latency.
- Stop after the representative dataset and record the decision owner.

<!-- section: delivery-brief -->
## Delivery brief

Create isolated evidence only.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: EXP-01 purpose=decision shape=benchmark -->
| Contract | Role | Evidence purpose | Execution shape | Observable assertion | Command or procedure |
| --- | --- | --- | --- | --- | --- |
| EXP-01 | Primary | Decision | Benchmark | Measurements answer the approved threshold question | bash run-benchmark.sh |

<!-- section: completion-criteria -->
## Completion

EXP-01 evidence and its downstream decision are recorded.
EOF

"$scripts/validate-acceptance-specification.sh" "$fixture/experiment.md"

experiment_dir="$fixture/docs/changes/parser-experiment"
mkdir -p "$experiment_dir"
cp "$fixture/experiment.md" "$experiment_dir/change.md"
sed -i 's/workflow-profile: standard/workflow-profile: controlled/' "$experiment_dir/change.md"
cat > "$experiment_dir/work-items.md" <<'EOF'
<!-- delivery-map -->
<!-- approval-source: Workflow fixture -->
| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Primary proof | Status | Document |
| --- | --- | --- | --- | --- | --- | --- |
| EXPW-001 | First evidence slice | Owns EXP-01 | None | Evidence | Approved | `work-items/EXPW-001.md` |
| EXPW-002 | Second evidence slice | None | None | Evidence | Approved | `work-items/EXPW-002.md` |
EOF
if "$scripts/validate-work-items.sh" "$experiment_dir" >"$fixture/experiment-map.out" 2>&1; then
    echo "experiment work-item map was incorrectly accepted" >&2
    exit 1
fi
grep -Fq 'experiments are single deliveries' "$fixture/experiment-map.out"

if grep -Rq '<!-- work-item-status:' "$change_dir/work-items"; then
    echo "work-item documents incorrectly duplicate mutable status" >&2
    exit 1
fi

cp "$change_dir/change.md" "$fixture/single-with-map.md"
sed -i 's/delivery-shape: multi-item/delivery-shape: single/' "$fixture/single-with-map.md"
cp "$change_dir/change.md" "$fixture/multi-change.md"
cp "$fixture/single-with-map.md" "$change_dir/change.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "single-delivery parent incorrectly accepted a work-item map" >&2
    exit 1
fi
cp "$fixture/multi-change.md" "$change_dir/change.md"

cp "$change_dir/change.md" "$fixture/draft-parent.md"
sed -i 's/change-status: approved/change-status: draft/; s/approval-source: Workflow fixture/approval-source: none/' "$change_dir/change.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "Draft parent incorrectly accepted a work-item map" >&2
    exit 1
fi
cp "$fixture/draft-parent.md" "$change_dir/change.md"

cp "$change_dir/change.md" "$fixture/invalid-proof-enum.md"
sed -i 's/purpose=acceptance shape=unit/purpose=banana shape=magic/' "$fixture/invalid-proof-enum.md"
if "$scripts/validate-acceptance-specification.sh" "$fixture/invalid-proof-enum.md" >/dev/null 2>&1; then
    echo "invalid proof purpose and shape were incorrectly accepted" >&2
    exit 1
fi

cp "$change_dir/change.md" "$fixture/marker-only-proof.md"
sed -i '/^|/d' "$fixture/marker-only-proof.md"
if "$scripts/validate-acceptance-specification.sh" "$fixture/marker-only-proof.md" >/dev/null 2>&1; then
    echo "marker-only proof was incorrectly accepted" >&2
    exit 1
fi

cp "$change_dir/change.md" "$fixture/orphan-proof.md"
sed -i '/primary-proof: AC-01/a <!-- primary-proof: AC-99 purpose=acceptance shape=unit -->' "$fixture/orphan-proof.md"
if "$scripts/validate-acceptance-specification.sh" "$fixture/orphan-proof.md" >/dev/null 2>&1; then
    echo "orphan primary proof was incorrectly accepted" >&2
    exit 1
fi

cp "$change_dir/work-items.md" "$fixture/complete-map.md"
sed -i 's/| TEMP-001 | 公共解析器 |/| TEMP-001 |  |/' "$change_dir/work-items.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "delivery map with an empty outcome was incorrectly accepted" >&2
    exit 1
fi
cp "$fixture/complete-map.md" "$change_dir/work-items.md"
sed -i 's/Owns AC-01 \/ Supports AC-02/Owns AC-01, AC-02/' "$change_dir/work-items.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "unlabeled ownership ID was incorrectly accepted" >&2
    exit 1
fi
cp "$fixture/complete-map.md" "$change_dir/work-items.md"

cp "$change_dir/change.md" "$fixture/change-with-external-reference.md"
sed -i '/<!-- section: delivery-brief -->/i External change AC-99 remains out of scope.' "$fixture/change-with-external-reference.md"
cp "$fixture/change-with-external-reference.md" "$change_dir/change.md"
"$scripts/validate-work-items.sh" "$change_dir"
cp "$fixture/multi-change.md" "$change_dir/change.md"

cat > "$fixture/maintenance.md" <<'EOF'
# Repair the documentation link
<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: maintenance -->
<!-- change-status: approved -->
<!-- delivery-shape: single -->
<!-- approval-source: Workflow fixture -->
<!-- section: goal-rationale -->
## Goal
Readers can follow the local guide link.
<!-- section: scope -->
## Scope
One documentation link only; production behavior is unchanged.
<!-- section: structural-contract -->
## Structural outcome
<!-- structural-outcome: STR-01 -->
- STR-01: the local link checker reports no broken guide link.
<!-- section: delivery-brief -->
## Delivery
Repair the one link.
<!-- section: proof-plan -->
## Proof
<!-- primary-proof: STR-01 purpose=structural shape=manual -->
| Contract | Role | Purpose | Shape | Observable assertion | Command or procedure |
| --- | --- | --- | --- | --- | --- |
| STR-01 | Primary | Structural | Manual | No broken guide link is reported | bash verify-links.sh |
<!-- section: completion-criteria -->
## Completion
STR-01 passes without production changes.
EOF
"$scripts/validate-acceptance-specification.sh" "$fixture/maintenance.md"

cat > "$fixture/legacy-approved.md" <<'EOF'
# Historical change
## 📌 Status
Approved
## 🎯 Change goal
Preserve an existing approved outcome.
## ✅ Acceptance specification
The historical approved behavior remains authoritative.
EOF
"$scripts/validate-acceptance-specification.sh" "$fixture/legacy-approved.md"
sed -i 's/^Approved$/Draft/' "$fixture/legacy-approved.md"
if "$scripts/validate-acceptance-specification.sh" "$fixture/legacy-approved.md" >/dev/null 2>&1; then
    echo "legacy Draft was incorrectly accepted as approved compatibility input" >&2
    exit 1
fi

printf 'OK: workflow script regressions passed\n'
