#!/usr/bin/env bash
set -euo pipefail

repo_root=${TEDTOOLKIT_REPO_ROOT:-}
if [[ -z $repo_root ]]; then
    repo_root=$(git rev-parse --show-toplevel)
fi
scripts="$repo_root/plugins/tedtoolkit-project-development/scripts"
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT

state_repo="$fixture/state-repo"
mkdir -p "$state_repo/.tedtoolkit"
git -C "$state_repo" init -q
printf '# existing namespace rule without a final newline' >"$state_repo/.tedtoolkit/.gitignore"
(
    cd "$state_repo"
    bash "$scripts/ensure-tool-state.sh" worktrees >/dev/null
    bash "$scripts/ensure-tool-state.sh" worktrees >/dev/null
    bash "$scripts/ensure-tool-state.sh" runs >/dev/null
    bash "$scripts/ensure-tool-state.sh" preparations >/dev/null
)
test -d "$state_repo/.tedtoolkit/worktrees"
test -d "$state_repo/.tedtoolkit/runs"
test -d "$state_repo/.tedtoolkit/preparations"
test "$(grep -Fxc '/worktrees/' "$state_repo/.tedtoolkit/.gitignore")" = 1
test "$(grep -Fxc '/runs/' "$state_repo/.tedtoolkit/.gitignore")" = 1
test ! -e "$state_repo/.gitignore"
git -C "$state_repo" check-ignore -q .tedtoolkit/worktrees/probe
git -C "$state_repo" check-ignore -q .tedtoolkit/runs/probe
if git -C "$state_repo" check-ignore -q .tedtoolkit/preparations/probe; then
    echo "tracked preparation namespace was incorrectly ignored" >&2
    exit 1
fi
if (cd "$state_repo" && bash "$scripts/ensure-tool-state.sh" unknown >/dev/null 2>&1); then
    echo "unknown tool-state area was incorrectly accepted" >&2
    exit 1
fi

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

<!-- section: start-conditions -->
## 开始条件

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## 交付安排

公共解析器和其摄取消费者是两个可独立验证的交付。

<!-- section: proof-plan -->
## 证明

<!-- primary-proof: AC-01 purpose=acceptance shape=unit -->
<!-- primary-proof: AC-02 purpose=acceptance shape=component -->
| 契约 | Role | 可观察断言 | 命令或过程 |
| --- | --- | --- | --- |
| AC-01 | Primary | 合法值解析且非法值拒绝 | bash verify-parser.sh |
| AC-02 | Primary | 摄取结果与公共解析一致 | bash verify-ingestion.sh |

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
| Contract | Role | Observable assertion | Command or procedure |
| --- | --- | --- | --- |
| $owned | Primary | Stable boundary demonstrates $owned | bash verify-item.sh |

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

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Status | Document |
| --- | --- | --- | --- | --- | --- |
| TEMP-001 | 公共解析器 | Owns AC-01 / Supports AC-02 | None | Verified | `work-items/TEMP-001-parser.md` |
| TEMP-002 | 摄取边界 | Owns AC-02 | TEMP-001: verified parser contract | Approved | `work-items/TEMP-002-ingestion.md` |
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

cp "$change_dir/work-items.md" "$fixture/status-map.md"
sed -i 's/| Approved | `work-items\/TEMP-002-ingestion.md`/| In progress | `work-items\/TEMP-002-ingestion.md`/' "$change_dir/work-items.md"
"$scripts/validate-work-items.sh" "$change_dir"
in_progress_schedule=$("$scripts/schedule-work-items.sh" "$change_dir")
grep -Fq $'TEMP-002\tBLOCKED\tdocument status is In progress' <<<"$in_progress_schedule"
sed -i 's/| In progress | `work-items\/TEMP-002-ingestion.md`/| Implementing | `work-items\/TEMP-002-ingestion.md`/' "$change_dir/work-items.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "deprecated Implementing status was incorrectly accepted" >&2
    exit 1
fi
cp "$fixture/status-map.md" "$change_dir/work-items.md"

cp "$change_dir/work-items.md" "$fixture/multi-map.md"
grep -v 'TEMP-002' "$fixture/multi-map.md" > "$change_dir/work-items.md"
if "$scripts/validate-work-items.sh" "$change_dir" >/dev/null 2>&1; then
    echo "single-row delivery map was incorrectly accepted" >&2
    exit 1
fi

cp "$fixture/multi-map.md" "$change_dir/work-items.md"
sed -i 's/| None | Verified/| MISS-999: missing input | Verified/' "$change_dir/work-items.md"
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

| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Status | Document |
| --- | --- | --- | --- | --- | --- |
| TEMP-001 | 公共解析器 | Owns AC-01 | None | Verified | `work-items/TEMP-001-parser.md` |
| TEMP-002 | 摄取边界 | Owns AC-02 | TEMP-003: candidate output | Approved | `work-items/TEMP-002-ingestion.md` |
| TEMP-003 | 循环候选 | None | TEMP-002: candidate output | Approved | `work-items/TEMP-003-cycle.md` |
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

cp "$change_dir/change.md" "$fixture/expanded-format3-proof.md"
sed -i 's/| AC-01 | Primary | 合法值解析且非法值拒绝 | bash verify-parser.sh |/| AC-01 | Primary | Acceptance | Unit | 合法值解析且非法值拒绝 | bash verify-parser.sh |/' "$fixture/expanded-format3-proof.md"
grep -Fq '| AC-01 | Primary | Acceptance | Unit |' "$fixture/expanded-format3-proof.md"
"$scripts/validate-acceptance-specification.sh" "$fixture/expanded-format3-proof.md"

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

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

One bounded internal refactor.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: INV-01 purpose=regression shape=unit -->
| Contract | Role | Observable assertion | Command or procedure |
| --- | --- | --- | --- |
| INV-01 | Primary | Existing public-boundary behavior remains unchanged | bash verify-refactor.sh |

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

<!-- section: start-conditions -->
## Start conditions

<!-- change-prerequisite: none -->

None. Ready from the approved baseline.

<!-- section: delivery-brief -->
## Delivery brief

Create isolated evidence only.

<!-- section: proof-plan -->
## Proof

<!-- primary-proof: EXP-01 purpose=decision shape=benchmark -->
| Contract | Role | Observable assertion | Command or procedure |
| --- | --- | --- | --- |
| EXP-01 | Primary | Measurements answer the approved threshold question | bash run-benchmark.sh |

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
| ID | Outcome | Contract ownership | Real prerequisites and supplied input | Status | Document |
| --- | --- | --- | --- | --- | --- |
| EXPW-001 | First evidence slice | Owns EXP-01 | None | Approved | `work-items/EXPW-001.md` |
| EXPW-002 | Second evidence slice | None | None | Approved | `work-items/EXPW-002.md` |
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
<!-- section: start-conditions -->
## Start conditions
<!-- change-prerequisite: none -->
None. Ready from the approved baseline.
<!-- section: delivery-brief -->
## Delivery
Repair the one link.
<!-- section: proof-plan -->
## Proof
<!-- primary-proof: STR-01 purpose=structural shape=manual -->
| Contract | Role | Observable assertion | Command or procedure |
| --- | --- | --- | --- |
| STR-01 | Primary | No broken guide link is reported | bash verify-links.sh |
<!-- section: completion-criteria -->
## Completion
STR-01 passes without production changes.
EOF
"$scripts/validate-acceptance-specification.sh" "$fixture/maintenance.md"

write_prerequisite_change() {
    local file=$1 status=$2 approval=$3 prerequisite_marker=$4 prerequisite_body=$5
    mkdir -p "$(dirname "$file")"
    cat > "$file" <<EOF
# Prerequisite fixture
<!-- change-format: 3 -->
<!-- workflow-profile: standard -->
<!-- change-kind: behavior-change -->
<!-- change-status: $status -->
<!-- delivery-shape: single -->
<!-- approval-source: $approval -->
<!-- section: goal-rationale -->
## Goal
Deliver one prerequisite-aware result.
<!-- section: scope -->
## Scope
One repository-contained outcome; unrelated behavior stays unchanged.
<!-- section: behavior-contract -->
## Behavior
<!-- acceptance-case: AC-01 -->
- AC-01: the declared result is observable.
<!-- section: start-conditions -->
## Start conditions
$prerequisite_marker
$prerequisite_body
<!-- section: delivery-brief -->
## Delivery
One bounded delivery.
<!-- section: proof-plan -->
## Proof
<!-- primary-proof: AC-01 purpose=acceptance shape=component -->
| Contract | Role | Observable assertion | Command or procedure |
| --- | --- | --- | --- |
| AC-01 | Primary | The result is observable | bash verify.sh |
<!-- section: completion-criteria -->
## Completion
AC-01 passes.
EOF
}

prereq_repo="$fixture/prerequisite-repo"
mkdir -p "$prereq_repo"
git -C "$prereq_repo" init -q
git -C "$prereq_repo" config user.email fixture@example.com
git -C "$prereq_repo" config user.name Fixture
git -C "$prereq_repo" config commit.gpgsign false

source_change="$prereq_repo/docs/changes/source/change.md"
dependent_change="$prereq_repo/docs/changes/dependent/change.md"
write_prerequisite_change "$source_change" approved "Workflow fixture" \
    '<!-- change-prerequisite: none -->' \
    'None. Ready from the approved baseline.'
write_prerequisite_change "$dependent_change" approved "Workflow fixture" \
    '<!-- change-prerequisite: PRE-01 source=../source/change.md contract=AC-01 -->' \
    $'| ID | Required input or guarantee | Source change outcome | Required readiness evidence |\n| --- | --- | --- | --- |\n| PRE-01 | Source result is integrated | `../source/change.md`, AC-01 | Source is completed on the selected Git baseline |'
git -C "$prereq_repo" add docs
git -C "$prereq_repo" commit -qm "add approved dependency fixtures"
approved_baseline=$(git -C "$prereq_repo" rev-parse HEAD)

"$scripts/validate-acceptance-specification.sh" "$source_change"
"$scripts/validate-acceptance-specification.sh" "$dependent_change"
if "$scripts/validate-acceptance-specification.sh" --require-ready --baseline "$approved_baseline" "$dependent_change" >"$fixture/planned-readiness.out" 2>&1; then
    echo "approved source incorrectly satisfied a completed prerequisite" >&2
    exit 1
fi
grep -Fq 'BLOCKED' "$fixture/planned-readiness.out"

sed -i 's/change-status: approved/change-status: completed/' "$source_change"
if "$scripts/validate-acceptance-specification.sh" --require-ready --baseline "$approved_baseline" "$dependent_change" >/dev/null 2>&1; then
    echo "working-tree-only completion incorrectly unlocked readiness" >&2
    exit 1
fi
git -C "$prereq_repo" add "$source_change"
git -C "$prereq_repo" commit -qm "complete source change"
completed_baseline=$(git -C "$prereq_repo" rev-parse HEAD)
"$scripts/validate-acceptance-specification.sh" --require-ready --baseline "$completed_baseline" "$dependent_change"
grep -Fq '<!-- change-status: approved -->' "$dependent_change"

cp "$dependent_change" "$fixture/dependent.valid.md"
cp "$source_change" "$fixture/source.completed.valid.md"

# Each prerequisite contract must be checked even when two rows reference the same source.
sed -i '/<!-- acceptance-case: AC-01 -->/a <!-- acceptance-case: AC-02 -->' "$source_change"
sed -i '/change-prerequisite: PRE-01/a <!-- change-prerequisite: PRE-02 source=../source/change.md contract=AC-02 -->' "$dependent_change"
sed -i '/^| PRE-01 |/a | PRE-02 | Second source result is integrated | `../source/change.md`, AC-02 | Source AC-02 is completed on the selected Git baseline |' "$dependent_change"
"$scripts/validate-acceptance-specification.sh" "$dependent_change"
if "$scripts/validate-acceptance-specification.sh" --require-ready --baseline "$completed_baseline" "$dependent_change" >"$fixture/repeated-source-contract.out" 2>&1; then
    echo "a cached source path incorrectly skipped its second contract" >&2
    exit 1
fi
grep -Fq 'AC-02' "$fixture/repeated-source-contract.out"
cp "$fixture/source.completed.valid.md" "$source_change"
cp "$fixture/dependent.valid.md" "$dependent_change"

# A contract marker outside the change-kind's canonical contract section is never authoritative.
printf '\n<!-- acceptance-case: AC-02 -->\n' >> "$source_change"
sed -i 's/contract=AC-01/contract=AC-02/' "$dependent_change"
if "$scripts/validate-acceptance-specification.sh" "$dependent_change" >/dev/null 2>&1; then
    echo "a stray source contract marker was incorrectly accepted structurally" >&2
    exit 1
fi

# Readiness resolves the same canonical section from the exact Git tree, not from the worktree.
git -C "$prereq_repo" add docs/changes/source/change.md
git -C "$prereq_repo" commit -qm "record stray source marker baseline"
stray_marker_baseline=$(git -C "$prereq_repo" rev-parse HEAD)
cp "$fixture/source.completed.valid.md" "$source_change"
sed -i '/<!-- acceptance-case: AC-01 -->/a <!-- acceptance-case: AC-02 -->' "$source_change"
"$scripts/validate-acceptance-specification.sh" "$dependent_change"
if "$scripts/validate-acceptance-specification.sh" --require-ready --baseline "$stray_marker_baseline" "$dependent_change" >"$fixture/baseline-stray-contract.out" 2>&1; then
    echo "a baseline stray contract marker incorrectly unlocked readiness" >&2
    exit 1
fi
grep -Fq 'AC-02' "$fixture/baseline-stray-contract.out"
cp "$fixture/source.completed.valid.md" "$source_change"
cp "$fixture/dependent.valid.md" "$dependent_change"
git -C "$prereq_repo" add docs/changes/source/change.md
git -C "$prereq_repo" commit -qm "restore canonical source fixture"

for invalid in missing-source missing-contract self absolute escape; do
    cp "$fixture/dependent.valid.md" "$dependent_change"
    case "$invalid" in
        missing-source) sed -i 's#source=../source/change.md#source=../missing/change.md#' "$dependent_change" ;;
        missing-contract) sed -i 's/contract=AC-01/contract=AC-99/' "$dependent_change" ;;
        self) sed -i 's#source=../source/change.md#source=change.md#' "$dependent_change" ;;
        absolute) sed -i 's#source=../source/change.md#source=C:/outside/change.md#' "$dependent_change" ;;
        escape) sed -i 's#source=../source/change.md#source=../../../../outside/change.md#' "$dependent_change" ;;
    esac
    if "$scripts/validate-acceptance-specification.sh" "$dependent_change" >/dev/null 2>&1; then
        echo "$invalid prerequisite was incorrectly accepted" >&2
        exit 1
    fi
done
cp "$fixture/dependent.valid.md" "$dependent_change"

cp "$source_change" "$fixture/source.valid.md"
write_prerequisite_change "$source_change" completed "Workflow fixture" \
    '<!-- change-prerequisite: PRE-01 source=../dependent/change.md contract=AC-01 -->' \
    $'| ID | Required input or guarantee | Source change outcome | Required readiness evidence |\n| --- | --- | --- | --- |\n| PRE-01 | Dependent result is integrated | `../dependent/change.md`, AC-01 | Dependent is completed on the selected Git baseline |'
if "$scripts/validate-acceptance-specification.sh" "$dependent_change" >"$fixture/cycle.out" 2>&1; then
    echo "cross-change prerequisite cycle was incorrectly accepted" >&2
    exit 1
fi
grep -Fqi 'cycle' "$fixture/cycle.out"
cp "$fixture/source.valid.md" "$source_change"

cp "$fixture/dependent.valid.md" "$dependent_change"
sed -i '/change-prerequisite: PRE-01/a <!-- change-prerequisite: none -->' "$dependent_change"
if "$scripts/validate-acceptance-specification.sh" "$dependent_change" >/dev/null 2>&1; then
    echo "mixed none and concrete prerequisites were incorrectly accepted" >&2
    exit 1
fi
cp "$fixture/dependent.valid.md" "$dependent_change"
sed -i '/^| PRE-01 |/d' "$dependent_change"
if "$scripts/validate-acceptance-specification.sh" "$dependent_change" >/dev/null 2>&1; then
    echo "prerequisite marker without a human row was incorrectly accepted" >&2
    exit 1
fi
cp "$fixture/dependent.valid.md" "$dependent_change"

outside_change="$fixture/outside-change.md"
cp "$source_change" "$outside_change"
mkdir -p "$prereq_repo/docs/changes/escape"
if ln -s "$outside_change" "$prereq_repo/docs/changes/escape/change.md" 2>/dev/null &&
    [[ -L $prereq_repo/docs/changes/escape/change.md ]]; then
    sed -i 's#source=../source/change.md#source=../escape/change.md#' "$dependent_change"
    if "$scripts/validate-acceptance-specification.sh" "$dependent_change" >/dev/null 2>&1; then
        echo "symlink-escaped prerequisite was incorrectly accepted" >&2
        exit 1
    fi
    cp "$fixture/dependent.valid.md" "$dependent_change"
fi

legacy_repo="$fixture/prerequisite-legacy-repo"
mkdir -p "$legacy_repo"
git -C "$legacy_repo" init -q
git -C "$legacy_repo" config user.email fixture@example.com
git -C "$legacy_repo" config user.name Fixture
git -C "$legacy_repo" config commit.gpgsign false
legacy_change="$legacy_repo/docs/changes/legacy-active/change.md"
write_prerequisite_change "$legacy_change" approved "Historical approval" \
    '<!-- change-prerequisite: none -->' \
    'None. Ready from the approved baseline.'
sed -i '/<!-- section: start-conditions -->/,/<!-- section: delivery-brief -->/{ /<!-- section: delivery-brief -->/!d; }' "$legacy_change"
git -C "$legacy_repo" add docs
git -C "$legacy_repo" commit -qm "add pre-prerequisite-contract record"
legacy_base=$(git -C "$legacy_repo" rev-parse HEAD)
if "$scripts/validate-acceptance-specification.sh" "$legacy_change" >/dev/null 2>&1; then
    echo "format-3 record without prerequisite declaration passed by default" >&2
    exit 1
fi
legacy_notice=$("$scripts/validate-acceptance-specification.sh" --allow-approved-prerequisite-legacy "$legacy_base" "$legacy_change")
grep -Fq 'DEPRECATED:' <<<"$legacy_notice"
"$scripts/validate-acceptance-specification.sh" --allow-approved-prerequisite-legacy "$legacy_base" --require-ready --baseline "$legacy_base" "$legacy_change"

sed -i 's/change-status: approved/change-status: in-progress/' "$legacy_change"
legacy_status_notice=$("$scripts/validate-acceptance-specification.sh" --allow-approved-prerequisite-legacy "$legacy_base" "$legacy_change")
grep -Fq 'DEPRECATED:' <<<"$legacy_status_notice"
"$scripts/validate-acceptance-specification.sh" --allow-approved-prerequisite-legacy "$legacy_base" --require-ready --baseline "$legacy_base" "$legacy_change"
sed -i 's/change-status: in-progress/change-status: approved/' "$legacy_change"

cp "$legacy_change" "$fixture/legacy-active.valid.md"
sed -i 's/change-status: approved/change-status: draft/; s/approval-source: Historical approval/approval-source: none/' "$legacy_change"
if "$scripts/validate-acceptance-specification.sh" --allow-approved-prerequisite-legacy "$legacy_base" "$legacy_change" >/dev/null 2>&1; then
    echo "legacy Draft incorrectly entered prerequisite compatibility" >&2
    exit 1
fi
cp "$fixture/legacy-active.valid.md" "$legacy_change"
printf '\nMaterial contract revision.\n' >> "$legacy_change"
if "$scripts/validate-acceptance-specification.sh" --allow-approved-prerequisite-legacy "$legacy_base" "$legacy_change" >/dev/null 2>&1; then
    echo "materially revised legacy record incorrectly entered compatibility" >&2
    exit 1
fi
untracked_legacy="$legacy_repo/docs/changes/untracked/change.md"
mkdir -p "$(dirname "$untracked_legacy")"
cp "$fixture/legacy-active.valid.md" "$untracked_legacy"
if "$scripts/validate-acceptance-specification.sh" --allow-approved-prerequisite-legacy "$legacy_base" "$untracked_legacy" >/dev/null 2>&1; then
    echo "untracked legacy record incorrectly entered compatibility" >&2
    exit 1
fi

legacy_multi_repo="$fixture/prerequisite-legacy-multi-repo"
legacy_multi_dir="$legacy_multi_repo/docs/changes/legacy-parent"
mkdir -p "$legacy_multi_dir"
cp -R "$change_dir/." "$legacy_multi_dir"
sed -i '/<!-- section: start-conditions -->/,/<!-- section: delivery-brief -->/{ /<!-- section: delivery-brief -->/!d; }' "$legacy_multi_dir/change.md"
git -C "$legacy_multi_repo" init -q
git -C "$legacy_multi_repo" config user.email fixture@example.com
git -C "$legacy_multi_repo" config user.name Fixture
git -C "$legacy_multi_repo" config commit.gpgsign false
git -C "$legacy_multi_repo" add docs
git -C "$legacy_multi_repo" commit -qm "add legacy multi-item parent"
legacy_multi_base=$(git -C "$legacy_multi_repo" rev-parse HEAD)
if "$scripts/validate-work-items.sh" "$legacy_multi_dir" >/dev/null 2>&1; then
    echo "legacy multi-item parent passed work-item validation without explicit compatibility" >&2
    exit 1
fi
legacy_multi_validation=$("$scripts/validate-work-items.sh" --allow-approved-prerequisite-legacy "$legacy_multi_base" "$legacy_multi_dir")
grep -Fq 'DEPRECATED:' <<<"$legacy_multi_validation"
legacy_multi_schedule=$("$scripts/schedule-work-items.sh" --allow-approved-prerequisite-legacy "$legacy_multi_base" "$legacy_multi_dir")
grep -Fq $'TEMP-002\tREADY' <<<"$legacy_multi_schedule"
"$scripts/validate-acceptance-specification.sh" --allow-approved-prerequisite-legacy "$legacy_multi_base" --require-ready --baseline "$legacy_multi_base" "$legacy_multi_dir/change.md"
printf '\nMaterial parent revision.\n' >> "$legacy_multi_dir/change.md"
if "$scripts/schedule-work-items.sh" --allow-approved-prerequisite-legacy "$legacy_multi_base" "$legacy_multi_dir" >/dev/null 2>&1; then
    echo "materially revised legacy parent passed scheduling" >&2
    exit 1
fi

cat > "$fixture/legacy-approved.md" <<'EOF'
# Historical change
<!-- change-format: 2 -->
## 📌 Status
Approved
## 🎯 Change goal
Preserve an existing approved outcome.
## ✅ Acceptance specification
The historical approved behavior remains authoritative.
| ID | Outcome | Result | Proof | Owner | Prerequisites | Notes | Status |
| --- | --- | --- | --- | --- | --- | --- | --- |
| LEG-001 | Historical slice | Done | Existing proof | Owner | None | None | Implemented |
| LEG-002 | Final slice | Pending | Existing proof | Owner | LEG-001 | None | Approved |
EOF
if "$scripts/validate-acceptance-specification.sh" "$fixture/legacy-approved.md" >/dev/null 2>&1; then
    echo "legacy change entered compatibility without an explicit flag" >&2
    exit 1
fi
legacy_validation=$("$scripts/validate-acceptance-specification.sh" --allow-approved-legacy "$fixture/legacy-approved.md")
grep -Fq 'DEPRECATED:' <<<"$legacy_validation"
legacy_dir="$fixture/docs/changes/legacy"
mkdir -p "$legacy_dir"
cp "$fixture/legacy-approved.md" "$legacy_dir/change.md"
legacy_schedule=$("$scripts/schedule-work-items.sh" "$legacy_dir" 2>"$fixture/legacy-warning.txt")
grep -Fq $'LEG-002\tREADY' <<<"$legacy_schedule"
grep -Fq 'DEPRECATED:' "$fixture/legacy-warning.txt"
sed -i 's/^Approved$/Draft/' "$fixture/legacy-approved.md"
cp "$fixture/legacy-approved.md" "$legacy_dir/change.md"
if "$scripts/validate-acceptance-specification.sh" --allow-approved-legacy "$fixture/legacy-approved.md" >/dev/null 2>&1; then
    echo "legacy Draft was incorrectly accepted as approved compatibility input" >&2
    exit 1
fi
if "$scripts/schedule-work-items.sh" "$legacy_dir" >/dev/null 2>&1; then
    echo "legacy Draft embedded map was incorrectly scheduled" >&2
    exit 1
fi

sed '/change-format: 2/d; s/^Draft$/Approved/' "$fixture/legacy-approved.md" > "$fixture/unversioned-legacy.md"
if "$scripts/validate-acceptance-specification.sh" --allow-approved-legacy "$fixture/unversioned-legacy.md" >/dev/null 2>&1; then
    echo "unversioned Markdown was incorrectly recognized as a legacy contract" >&2
    exit 1
fi

printf 'OK: workflow script regressions passed\n'
