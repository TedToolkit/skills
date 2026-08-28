#!/usr/bin/env bash

set -euo pipefail

repo_root="${1:?usage: run.sh <repository-root>}"
helper="$repo_root/plugins/tedtoolkit-shared/scripts/commit_group.sh"
real_git=$(command -v git)
test_root=$(mktemp -d "${TMPDIR:-/tmp}/commit-group-state.XXXXXX")
trap 'rm -rf -- "$test_root"' EXIT

fail() {
    echo "commit-group state check failed: $*" >&2
    exit 1
}

initialize_repository() {
    local target=$1
    mkdir -p "$target"
    git -C "$target" init -b main >/dev/null
    git -C "$target" config user.name Fixture
    git -C "$target" config user.email fixture@example.com
    git -C "$target" config commit.gpgsign false
    git -C "$target" config core.filemode true

    printf 'group base\n' >"$target/group.txt"
    printf 'delete me\n' >"$target/group-delete.txt"
    printf 'outside staged base\n' >"$target/outside-staged.txt"
    printf 'outside unstaged base\n' >"$target/outside-unstaged.txt"
    printf 'outside both base\n' >"$target/outside-both.txt"
    printf 'outside delete base\n' >"$target/outside-delete.txt"
    printf 'outside rename base\n' >"$target/outside-rename-old.txt"
    printf '#!/usr/bin/env bash\nprintf mode\n' >"$target/outside-mode.sh"
    chmod -x "$target/outside-mode.sh"
    git -C "$target" add -A
    git -C "$target" commit -q -m baseline
}

prepare_mixed_state() {
    local target=$1
    printf 'group changed\n' >"$target/group.txt"
    rm -- "$target/group-delete.txt"

    printf 'outside staged changed\n' >"$target/outside-staged.txt"
    git -C "$target" add outside-staged.txt

    printf 'outside unstaged changed\n' >"$target/outside-unstaged.txt"

    printf 'outside both staged\n' >"$target/outside-both.txt"
    git -C "$target" add outside-both.txt
    printf 'outside both worktree\n' >"$target/outside-both.txt"

    rm -- "$target/outside-delete.txt"
    git -C "$target" mv outside-rename-old.txt outside-rename-new.txt
    chmod +x "$target/outside-mode.sh"
    git -C "$target" add outside-mode.sh

    printf 'intent to add\n' >"$target/outside-intent.txt"
    git -C "$target" add -N outside-intent.txt
    printf 'SENSITIVE-CANARY-DO-NOT-PRINT\n' >"$target/sensitive.txt"
}

snapshot_outside_state() {
    local target=$1
    local destination=$2
    (
        cd "$target"
        git status --porcelain=v1 -uall -- \
            outside-staged.txt outside-unstaged.txt outside-both.txt outside-delete.txt \
            outside-rename-old.txt outside-rename-new.txt outside-mode.sh outside-intent.txt \
            sensitive.txt
        git ls-files --stage --debug -- \
            outside-staged.txt outside-unstaged.txt outside-both.txt outside-delete.txt \
            outside-rename-old.txt outside-rename-new.txt outside-mode.sh outside-intent.txt
        for path in outside-staged.txt outside-unstaged.txt outside-both.txt outside-rename-new.txt \
            outside-mode.sh outside-intent.txt sensitive.txt; do
            printf '%s ' "$path"
            git hash-object --no-filters -- "$path"
        done
        test ! -e outside-delete.txt && printf 'outside-delete.txt absent\n'
    ) >"$destination"
}

snapshot_group_state() {
    local target=$1
    local destination=$2
    (
        cd "$target"
        git status --porcelain=v1 -uall -- group.txt group-delete.txt
        git ls-files --stage --debug -- group.txt group-delete.txt
        printf 'group.txt '
        git hash-object --no-filters -- group.txt
        test ! -e group-delete.txt && printf 'group-delete.txt absent\n'
    ) >"$destination"
}

assert_state_equal() {
    local expected=$1
    local actual=$2
    cmp -s "$expected" "$actual" || {
        diff -u "$expected" "$actual" >&2 || true
        fail "out-of-group state changed"
    }
}

assert_transaction_cleaned() {
    local target=$1
    [ -z "$(find "$target/.git" -maxdepth 1 -type d -name 'commit-group.*' -print -quit)" ] ||
        fail "transaction directory was not cleaned"
}

run_success_case() {
    local target="$test_root/success"
    initialize_repository "$target"
    prepare_mixed_state "$target"
    snapshot_outside_state "$target" "$test_root/success.before"

    local output
    output=$(cd "$target" && printf 'test: commit approved group\n' | bash "$helper" group.txt group-delete.txt)
    [[ $output != *SENSITIVE-CANARY-DO-NOT-PRINT* ]] || fail "helper exposed untracked content"

    snapshot_outside_state "$target" "$test_root/success.after"
    assert_state_equal "$test_root/success.before" "$test_root/success.after"

    local committed_paths
    committed_paths=$(git -C "$target" diff-tree --no-commit-id --name-only -r HEAD | sort)
    [ "$committed_paths" = $'group-delete.txt\ngroup.txt' ] || fail "success commit included unexpected paths"
    [ -z "$(git -C "$target" status --porcelain=v1 -- group.txt group-delete.txt)" ] ||
        fail "approved group did not become clean"
    assert_transaction_cleaned "$target"
}

run_unborn_success_case() {
    local target="$test_root/unborn-success"
    mkdir -p "$target"
    git -C "$target" init -b main >/dev/null
    git -C "$target" config user.name Fixture
    git -C "$target" config user.email fixture@example.com
    git -C "$target" config commit.gpgsign false
    printf 'first grouped path\n' >"$target/group.txt"
    printf 'unapproved untracked bytes\n' >"$target/outside.txt"
    local outside_before
    outside_before=$(git -C "$target" hash-object --no-filters -- outside.txt)

    (cd "$target" && printf 'test: initial grouped commit\n' | bash "$helper" group.txt >/dev/null)

    [ "$(git -C "$target" rev-list --count HEAD)" = 1 ] || fail "unborn success did not create one root commit"
    [ "$(git -C "$target" diff-tree --root --no-commit-id --name-only -r HEAD)" = group.txt ] ||
        fail "unborn success included unexpected paths"
    [ "$(git -C "$target" hash-object --no-filters -- outside.txt)" = "$outside_before" ] ||
        fail "unborn success changed the unapproved file"
    [ "$(git -C "$target" status --porcelain=v1 -uall -- outside.txt)" = "?? outside.txt" ] ||
        fail "unborn success changed unapproved status"
    assert_transaction_cleaned "$target"
}

install_git_failure_shim() {
    local target=$1
    local fail_command=$2
    mkdir -p "$target/.test-bin"
    cat >"$target/.test-bin/git" <<'SHIM'
#!/usr/bin/env bash
set -euo pipefail
if [ "$FAIL_GIT_COMMAND" = commit-post-update ] && [ "${1:-}" = update-ref ] &&
    [[ "${3:-}" = commit_group:* ]]; then
    "$REAL_GIT" "$@"
    exit 97
fi
if [ "$FAIL_GIT_COMMAND" = commit-post-update-external ] && [ "${1:-}" = update-ref ] &&
    [[ "${3:-}" = commit_group:* ]]; then
    "$REAL_GIT" "$@"
    helper_head=$("$REAL_GIT" rev-parse HEAD)
    parent=$("$REAL_GIT" rev-parse HEAD^)
    parent_tree=$("$REAL_GIT" rev-parse "$parent^{tree}")
    subject=$("$REAL_GIT" show -s --format=%s "$helper_head")
    external_head=$(printf '%s\n' "$subject" | "$REAL_GIT" commit-tree "$parent_tree" -p "$parent")
    "$REAL_GIT" update-ref HEAD "$external_head" "$helper_head"
    printf '%s\n' "$external_head" >"$EXTERNAL_HEAD_FILE"
    exit 97
fi
if [ "${1:-}" = "$FAIL_GIT_COMMAND" ]; then
    "$REAL_GIT" "$@"
    exit 97
fi
exec "$REAL_GIT" "$@"
SHIM
    chmod +x "$target/.test-bin/git"
    printf '%s\n' "$fail_command" >"$target/.failure-command"
}

run_failure_case() {
    local label=$1
    local fail_command=$2
    local reflog_mode=${3:-enabled}
    local target="$test_root/$label"
    initialize_repository "$target"
    if [ "$reflog_mode" = disabled ]; then
        git -C "$target" config core.logAllRefUpdates false
        rm -rf -- "$target/.git/logs"
    fi
    prepare_mixed_state "$target"
    snapshot_outside_state "$target" "$test_root/$label.before"
    snapshot_group_state "$target" "$test_root/$label.group.before"
    local before_head
    before_head=$(git -C "$target" rev-parse HEAD)

    if [ "$fail_command" = commit ]; then
        mkdir -p "$target/.git/hooks"
        cat >"$target/.git/hooks/pre-commit" <<'HOOK'
#!/usr/bin/env bash
printf 'hook changed approved path\n' >>group.txt
printf 'hook changed staged path\n' >>outside-staged.txt
printf 'hook changed untracked path\n' >>sensitive.txt
printf 'hook created this file\n' >hook-created.txt
rm -f -- outside-unstaged.txt
printf '%s\n' "$PWD" >"$(git rev-parse --git-dir)/hook-worktree"
exit 98
HOOK
        chmod +x "$target/.git/hooks/pre-commit"
        set +e
        output=$(cd "$target" && printf 'must fail\n' | bash "$helper" group.txt group-delete.txt 2>&1)
        result=$?
        set -e
    else
        install_git_failure_shim "$target" "$fail_command"
        set +e
        output=$(cd "$target" && printf 'must fail\n' | \
            PATH="$target/.test-bin:$PATH" REAL_GIT="$real_git" FAIL_GIT_COMMAND="$fail_command" \
            bash "$helper" group.txt group-delete.txt 2>&1)
        result=$?
        set -e
    fi

    [ "$result" -ne 0 ] || fail "$label unexpectedly succeeded"
    [[ $output != *SENSITIVE-CANARY-DO-NOT-PRINT* ]] || fail "$label exposed untracked content"
    if [ "$fail_command" = commit ]; then
        [ -s "$target/.git/hook-worktree" ] || fail "$label did not execute the mutating hook"
        [ "$(cat "$target/.git/hook-worktree")" != "$target" ] ||
            fail "$label executed the hook in the user worktree"
    fi
    [ "$(git -C "$target" rev-parse HEAD)" = "$before_head" ] || fail "$label left a commit"

    snapshot_outside_state "$target" "$test_root/$label.after"
    assert_state_equal "$test_root/$label.before" "$test_root/$label.after"
    snapshot_group_state "$target" "$test_root/$label.group.after"
    assert_state_equal "$test_root/$label.group.before" "$test_root/$label.group.after"
    assert_transaction_cleaned "$target"
}

run_external_head_collision_case() {
    local label=post-commit-external-head-no-reflog
    local target="$test_root/$label"
    local external_head_file="$test_root/$label.external-head"
    initialize_repository "$target"
    git -C "$target" config core.logAllRefUpdates false
    rm -rf -- "$target/.git/logs"
    prepare_mixed_state "$target"
    snapshot_outside_state "$target" "$test_root/$label.before"
    snapshot_group_state "$target" "$test_root/$label.group.before"
    install_git_failure_shim "$target" commit-post-update-external

    set +e
    output=$(cd "$target" && printf 'must fail\n' | \
        PATH="$target/.test-bin:$PATH" REAL_GIT="$real_git" \
        FAIL_GIT_COMMAND=commit-post-update-external EXTERNAL_HEAD_FILE="$external_head_file" \
        bash "$helper" group.txt group-delete.txt 2>&1)
    result=$?
    set -e

    [ "$result" -ne 0 ] || fail "$label unexpectedly succeeded"
    [ -s "$external_head_file" ] || fail "$label did not install the external HEAD"
    [ "$(git -C "$target" rev-parse HEAD)" = "$(cat "$external_head_file")" ] ||
        fail "$label rewrote the unrelated external HEAD"
    snapshot_outside_state "$target" "$test_root/$label.after"
    assert_state_equal "$test_root/$label.before" "$test_root/$label.after"
    snapshot_group_state "$target" "$test_root/$label.group.after"
    assert_state_equal "$test_root/$label.group.before" "$test_root/$label.group.after"
    assert_transaction_cleaned "$target"
}

run_scope_expanding_hook_case() {
    local label=scope-expanding-hook
    local target="$test_root/$label"
    initialize_repository "$target"
    prepare_mixed_state "$target"
    snapshot_outside_state "$target" "$test_root/$label.before"
    snapshot_group_state "$target" "$test_root/$label.group.before"
    local before_head
    before_head=$(git -C "$target" rev-parse HEAD)

    mkdir -p "$target/.git/hooks"
    cat >"$target/.git/hooks/pre-commit" <<'HOOK'
#!/usr/bin/env bash
printf 'hook staged an unapproved path\n' >outside-staged.txt
git add outside-staged.txt
printf '%s\n' "$PWD" >"$(git rev-parse --git-dir)/hook-worktree"
HOOK
    chmod +x "$target/.git/hooks/pre-commit"

    set +e
    output=$(cd "$target" && printf 'must fail\n' | bash "$helper" group.txt group-delete.txt 2>&1)
    result=$?
    set -e

    [ "$result" -ne 0 ] || fail "$label unexpectedly succeeded"
    [ -s "$target/.git/hook-worktree" ] || fail "$label did not execute the hook"
    [ "$(cat "$target/.git/hook-worktree")" != "$target" ] ||
        fail "$label executed the hook in the user worktree"
    [ "$(git -C "$target" rev-parse HEAD)" = "$before_head" ] || fail "$label left a commit"
    snapshot_outside_state "$target" "$test_root/$label.after"
    assert_state_equal "$test_root/$label.before" "$test_root/$label.after"
    snapshot_group_state "$target" "$test_root/$label.group.after"
    assert_state_equal "$test_root/$label.group.before" "$test_root/$label.group.after"
    assert_transaction_cleaned "$target"
}

run_success_case
run_unborn_success_case
run_failure_case stage-failure add
run_failure_case commit-failure commit
run_failure_case post-commit-failure commit-post-update
run_failure_case post-commit-no-reflog commit-post-update disabled
run_failure_case synchronization-failure reset
run_external_head_collision_case
run_scope_expanding_hook_case

echo "commit-group state checks passed"
