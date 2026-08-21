#!/usr/bin/env bash
# Verify that the current HEAD contains an explicitly supplied accepted baseline.
#
# Usage: scripts/verify_accepted_baseline.sh <accepted-baseline-ref>
#
# Exit 0: the accepted baseline is an ancestor of HEAD.
# Exit 1: HEAD does not contain the accepted baseline.
# Exit 2: usage, repository, or ref-resolution error.

set -euo pipefail

usage() {
  cat <<'EOF'
usage: scripts/verify_accepted_baseline.sh <accepted-baseline-ref>

The ref must already exist in the local Git object database. The verifier
resolves it to a commit and fails unless that commit is an ancestor of HEAD.
EOF
}

if [ "$#" -eq 1 ] && { [ "$1" = "--help" ] || [ "$1" = "-h" ]; }; then
  usage
  exit 0
fi

if [ "$#" -ne 1 ]; then
  usage >&2
  exit 2
fi

accepted_ref="$1"
case "$accepted_ref" in
  ""|-*)
    echo "error: accepted baseline must be a non-empty Git ref or commit" >&2
    exit 2
    ;;
esac

if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "error: accepted-baseline verification must run inside a Git worktree" >&2
  exit 2
fi

if ! accepted_commit="$(
  git -C "$repo_root" rev-parse --verify --quiet "${accepted_ref}^{commit}"
)"; then
  echo "error: cannot resolve accepted baseline ref '$accepted_ref' to a commit" >&2
  echo "fetch or create that ref locally, then run this verifier again" >&2
  exit 2
fi

if ! head_commit="$(
  git -C "$repo_root" rev-parse --verify --quiet "HEAD^{commit}"
)"; then
  echo "error: cannot resolve HEAD to a commit" >&2
  exit 2
fi

set +e
git -C "$repo_root" merge-base --is-ancestor "$accepted_commit" "$head_commit"
status=$?
set -e

case "$status" in
  0)
    printf 'PASS: HEAD %s contains accepted baseline %s (%s)\n' \
      "$head_commit" "$accepted_ref" "$accepted_commit"
    ;;
  1)
    printf 'FAIL: HEAD %s does not contain accepted baseline %s (%s)\n' \
      "$head_commit" "$accepted_ref" "$accepted_commit" >&2
    echo "update the candidate from the accepted baseline, then run this verifier again" >&2
    exit 1
    ;;
  *)
    echo "error: git merge-base could not compare the accepted baseline with HEAD" >&2
    exit 2
    ;;
esac
