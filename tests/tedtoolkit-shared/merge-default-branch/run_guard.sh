#!/usr/bin/env bash

set -euo pipefail

repo_root="${1:?usage: run_guard.sh <repository-root>}"
guard="$repo_root/plugins/tedtoolkit-shared/scripts/premerge_guard.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/premerge-guard.XXXXXX")
trap 'rm -rf -- "$test_root"' EXIT

git -C "$test_root" init -b main >/dev/null
git -C "$test_root" config user.name Fixture
git -C "$test_root" config user.email fixture@example.com
printf 'base\n' > "$test_root/tracked.txt"
git -C "$test_root" add tracked.txt
git -C "$test_root" commit -q -m baseline

clean_output=$(cd "$test_root" && bash "$guard")
[ "$clean_output" = "CLEAN_WORKTREE" ] || {
    echo "clean repository did not pass the guard" >&2
    exit 1
}

printf 'staged change\n' > "$test_root/tracked.txt"
git -C "$test_root" add tracked.txt
printf 'unstaged change\n' >> "$test_root/tracked.txt"
mkdir -p "$test_root/untracked"
printf 'SYNTHETIC-GUARD-CANARY-DO-NOT-PRINT\n' > "$test_root/untracked/private-canary.txt"

before_head=$(git -C "$test_root" rev-parse HEAD)
before_status=$(git -C "$test_root" status --porcelain=v1 -uall)
before_index=$(git -C "$test_root" ls-files --stage --debug)
before_tracked=$(git -C "$test_root" hash-object --no-filters -- tracked.txt)
before_canary=$(git -C "$test_root" hash-object --no-filters -- untracked/private-canary.txt)

set +e
dirty_output=$(cd "$test_root" && bash "$guard" 2>&1)
result=$?
set -e

[ "$result" -eq 20 ] || {
    echo "dirty repository returned $result instead of 20" >&2
    exit 1
}
[[ $dirty_output == *DIRTY_WORKTREE* ]] || {
    echo "dirty marker missing" >&2
    exit 1
}
[[ $dirty_output == *tracked.txt* && $dirty_output == *untracked/private-canary.txt* ]] || {
    echo "dirty path metadata missing" >&2
    exit 1
}
[[ $dirty_output != *SYNTHETIC-GUARD-CANARY-DO-NOT-PRINT* ]] || {
    echo "guard exposed untracked content" >&2
    exit 1
}

[ "$(git -C "$test_root" rev-parse HEAD)" = "$before_head" ]
[ "$(git -C "$test_root" status --porcelain=v1 -uall)" = "$before_status" ]
[ "$(git -C "$test_root" ls-files --stage --debug)" = "$before_index" ]
[ "$(git -C "$test_root" hash-object --no-filters -- tracked.txt)" = "$before_tracked" ]
[ "$(git -C "$test_root" hash-object --no-filters -- untracked/private-canary.txt)" = "$before_canary" ]

echo "premerge guard checks passed"
