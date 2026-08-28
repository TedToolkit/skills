#!/usr/bin/env bash
set -euo pipefail

fail() {
    printf 'RETAINED: %s\n' "$1" >&2
    exit 20
}

[[ $# == 2 ]] || {
    printf 'usage: cleanup-temporary-branch.sh <authoritative-integration-ref> <temporary-branch>\n' >&2
    exit 2
}

authoritative_ref=$1
branch=$2

git rev-parse --git-dir >/dev/null 2>&1 || fail 'not inside a Git repository'
git rev-parse --verify --quiet "${authoritative_ref}^{commit}" >/dev/null || \
    fail "authoritative integration ref does not resolve to a commit: $authoritative_ref"

case $branch in
    refs/heads/*) branch_ref=$branch; branch=${branch#refs/heads/} ;;
    *) branch_ref="refs/heads/$branch" ;;
esac

[[ -n $branch && $branch != -* ]] || fail 'temporary branch name is invalid'
branch_oid=$(git rev-parse --verify --quiet "${branch_ref}^{commit}") || \
    fail "local temporary branch does not exist: $branch"

while IFS= read -r checked_out_ref; do
    [[ $checked_out_ref != "branch $branch_ref" ]] || \
        fail "temporary branch is still checked out in a registered worktree: $branch"
done < <(git worktree list --porcelain | grep '^branch ' || true)

git merge-base --is-ancestor "$branch_oid" "$authoritative_ref" || \
    fail "temporary branch has commits not reachable from $authoritative_ref: $branch"

git update-ref -d "$branch_ref" "$branch_oid"
printf 'DELETED: %s (reachable from %s)\n' "$branch" "$authoritative_ref"
