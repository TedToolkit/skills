#!/usr/bin/env bash

set -euo pipefail

# --no-optional-locks prevents status inventory from refreshing the index.
# Porcelain output contains path and status metadata only; it never prints file
# contents.
status=$(git --no-optional-locks status --porcelain=v1 -uall)

if [ -z "$status" ]; then
    echo "CLEAN_WORKTREE"
    exit 0
fi

echo "DIRTY_WORKTREE"
printf '%s\n' "$status"
exit 20
