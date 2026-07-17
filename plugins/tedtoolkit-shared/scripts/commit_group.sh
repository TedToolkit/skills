#!/usr/bin/env bash
#
# commit_group.sh <file>...  — stage only these files and commit them as one
# commit. The message is read from stdin; pass it with a *quoted* heredoc so
# emoji, non-ASCII text, and characters like ` and $ are taken literally:
#
#   bash commit_group.sh path/one path/two <<'MSG'
#   ✨ feat(scope): subject
#
#   body text.
#   MSG

set -euo pipefail

# Require explicit paths: `git add -A` with none would stage the whole tree.
[ "$#" -gt 0 ] || { echo "usage: commit_group.sh <file>... (message on stdin)" >&2; exit 1; }

git reset -q             # clean index → this commit holds only these files
git add -A -- "$@"       # stage just this group (modify / add / delete / untracked)
git commit -q -F -       # message from stdin; git rejects an empty one or empty stage
git --no-pager log -1 --format='%h  %s'
