#!/usr/bin/env bash
# Print the remote default branch name (e.g. "main" or "master") for `origin`,
# without the "origin/" prefix. Exits non-zero if it cannot be determined.
#
# Strategy, most-authoritative first:
#   1. Refresh and read origin/HEAD — the symbolic ref the server advertises.
#   2. Fall back to whichever of main / master actually exists on origin.

set -euo pipefail

# Ask the remote what its HEAD points at and cache it locally. Harmless if the
# network is down — we just fall through to the ref we may already have.
git remote set-head origin --auto >/dev/null 2>&1 || true

def="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
def="${def#origin/}"

if [ -z "$def" ]; then
  for cand in main master; do
    if git show-ref --verify --quiet "refs/remotes/origin/$cand"; then
      def="$cand"
      break
    fi
  done
fi

[ -n "$def" ] || { echo "could not determine origin's default branch" >&2; exit 1; }
echo "$def"
