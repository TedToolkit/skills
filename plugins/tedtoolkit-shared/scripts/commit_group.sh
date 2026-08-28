#!/usr/bin/env bash
#
# commit_group.sh <file>...  — commit only these files while preserving every
# out-of-group index and worktree entry. The message is read from stdin; pass it
# with a *quoted* heredoc so emoji, non-ASCII text, and characters like ` and $
# are taken literally:
#
#   bash commit_group.sh path/one path/two <<'MSG'
#   ✨ feat(scope): subject
#
#   body text.
#   MSG

set -euo pipefail

# Require explicit paths: `git add -A` with none would stage the whole tree.
[ "$#" -gt 0 ] || { echo "usage: commit_group.sh <file>... (message on stdin)" >&2; exit 1; }

real_index=$(git rev-parse --path-format=absolute --git-path index)
if command -v cygpath >/dev/null 2>&1; then
    real_index=$(cygpath -u -- "$real_index")
fi
case "$real_index" in
    /*) ;;
    *) real_index="$(pwd)/$real_index" ;;
esac

if [ -e "$real_index.lock" ]; then
    echo "commit_group: Git index is locked; refusing to disturb another operation" >&2
    exit 1
fi

# Keep transaction state beside the real index. This stays outside the user
# worktree while remaining inside the repository boundary granted to Git by
# workspace-write sandboxes.
transaction_dir=$(mktemp -d "$(dirname "$real_index")/commit-group.XXXXXX")
temporary_index="$transaction_dir/index"
temporary_worktree="$transaction_dir/worktree"
index_backup="$transaction_dir/original-index"
message_file="$transaction_dir/message"
clean_message_file="$transaction_dir/message.clean"
git_dir=$(git rev-parse --absolute-git-dir)
had_index=false
old_head=$(git rev-parse --verify HEAD 2>/dev/null || true)
head_ref=$(git symbolic-ref -q HEAD || true)
new_head=""
expected_tree=""
expected_subject=""
reflog_action="commit_group:$(basename "$transaction_dir")"
complete=false

cat >"$message_file"

if [ -e "$real_index" ]; then
    cp -- "$real_index" "$index_backup"
    had_index=true
fi

restore_original_index() {
    if $had_index; then
        restore_path="$real_index.commit-group-restore.$$"
        if cp -- "$index_backup" "$restore_path" && mv -f -- "$restore_path" "$real_index"; then
            return 0
        fi
        rm -f -- "$restore_path"
        return 1
    fi

    rm -f -- "$real_index"
}

rollback_commit() {
    current_head=$(git rev-parse --verify HEAD 2>/dev/null || true)
    [ "$current_head" = "$new_head" ] || {
        echo "commit_group: HEAD changed during recovery; refusing to rewrite it" >&2
        return 1
    }

    if [ -n "$old_head" ]; then
        git update-ref -m "commit_group rollback" HEAD "$old_head" "$new_head"
    elif [ -n "$head_ref" ]; then
        git update-ref -d "$head_ref" "$new_head"
    else
        echo "commit_group: cannot restore an unborn detached HEAD" >&2
        return 1
    fi
}

recover_attempted_commit() {
    current_head=$(git rev-parse --verify HEAD 2>/dev/null || true)
    [ "$current_head" != "$old_head" ] || return 0

    # new_head is the exact object created before the compare-and-swap ref update. Never infer
    # ownership from non-unique metadata such as parent, tree, subject, or reflog availability.
    if [ -z "$new_head" ] || [ "$current_head" != "$new_head" ]; then
        echo "commit_group: HEAD changed outside this transaction; refusing to rewrite it" >&2
        return 1
    fi

    rollback_commit
}

run_hook() {
    hook_name=$1
    shift
    hook_path=$(git rev-parse --path-format=absolute --git-path "hooks/$hook_name")
    [ -x "$hook_path" ] || return 0

    (
        cd "$temporary_worktree"
        GIT_DIR="$git_dir" GIT_WORK_TREE="$temporary_worktree" \
            GIT_INDEX_FILE="$temporary_index" GIT_PREFIX= \
            "$hook_path" "$@"
    )
}

finish() {
    status=$?
    trap - EXIT
    set +e

    if ! $complete; then
        recovery_failed=false
        if ! recover_attempted_commit; then
            recovery_failed=true
        fi
        if ! restore_original_index; then
            echo "commit_group: failed to restore the original index" >&2
            recovery_failed=true
        fi
        $recovery_failed && status=1
    fi

    rm -rf -- "$transaction_dir"
    exit "$status"
}
trap finish EXIT

if [ -n "$old_head" ]; then
    GIT_INDEX_FILE="$temporary_index" git read-tree "$old_head"
else
    GIT_INDEX_FILE="$temporary_index" git read-tree --empty
fi

# A temporary index isolates this commit from every unrelated staged entry.
# Literal pathspecs keep the approved path list from expanding through Git
# pathspec magic.
GIT_INDEX_FILE="$temporary_index" GIT_LITERAL_PATHSPECS=1 git add -A -- "$@"
expected_tree=$(GIT_INDEX_FILE="$temporary_index" git write-tree)

# Hooks run with the temporary index and an isolated checkout. Running them before the ref update
# prevents a failing or scope-expanding hook from touching user bytes or creating an ambiguous
# commit. The final commit object is then known exactly before HEAD is changed.
mkdir -p "$temporary_worktree"
GIT_INDEX_FILE="$temporary_index" git checkout-index --all --force \
    --prefix="$temporary_worktree/"
run_hook pre-commit
run_hook prepare-commit-msg "$message_file" message
run_hook commit-msg "$message_file"

hook_tree=$(GIT_INDEX_FILE="$temporary_index" git write-tree)
[ "$hook_tree" = "$expected_tree" ] || {
    echo "commit_group: a commit hook changed the approved group" >&2
    exit 1
}

git stripspace <"$message_file" >"$clean_message_file"
expected_subject=$(sed -n '1p' "$clean_message_file")
[ -n "$expected_subject" ] || {
    echo "commit_group: refusing to create a commit with an empty message" >&2
    exit 1
}

if [ -n "$old_head" ]; then
    old_tree=$(git show -s --format=%T "$old_head")
    [ "$expected_tree" != "$old_tree" ] || {
        echo "commit_group: approved paths contain no changes" >&2
        exit 1
    }
    commit_tree_args=(commit-tree "$expected_tree" -p "$old_head" -F "$clean_message_file")
else
    commit_tree_args=(commit-tree "$expected_tree" -F "$clean_message_file")
fi

if [ "$(git config --bool --get commit.gpgsign 2>/dev/null || true)" = true ]; then
    signing_key=$(git config --get user.signingkey 2>/dev/null || true)
    if [ -n "$signing_key" ]; then
        commit_tree_args+=("-S$signing_key")
    else
        commit_tree_args+=(-S)
    fi
fi

new_head=$(git "${commit_tree_args[@]}")
if [ -n "$old_head" ]; then
    git update-ref -m "$reflog_action: $expected_subject" HEAD "$new_head" "$old_head"
else
    git update-ref -m "$reflog_action: $expected_subject" HEAD "$new_head" ""
fi

# Git ignores post-commit failures. Preserve that behavior while containing any file mutation in
# the isolated worktree. A concurrent/ref-mutating hook is detected before real-index sync.
run_hook post-commit || true
[ "$(git rev-parse --verify HEAD 2>/dev/null || true)" = "$new_head" ] || {
    echo "commit_group: HEAD changed after the grouped commit; refusing to continue" >&2
    exit 1
}

# HEAD now contains the approved group. Advance only those entries in the real
# index so their worktree state becomes clean; every out-of-group entry remains
# byte-for-byte represented by the original index.
GIT_LITERAL_PATHSPECS=1 git reset -q "$new_head" -- "$@"

summary=$(git --no-pager log -1 --format='%h  %s')
complete=true
printf '%s\n' "$summary"
