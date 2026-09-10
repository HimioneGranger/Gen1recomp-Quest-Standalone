#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERIFIER="$ROOT/scripts/verify_accepted_baseline.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/accepted-baseline-gate.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

PASS=0
FAIL=0

check_result() {
  local expected_status="$1"
  local expected_text="$2"
  local label="$3"
  shift 3

  local output
  local actual_status
  set +e
  output=$("$@" 2>&1)
  actual_status=$?
  set -e

  if [ "$actual_status" -eq "$expected_status" ] \
      && printf '%s\n' "$output" | grep -Fq -- "$expected_text"; then
    PASS=$((PASS + 1))
    printf '  PASS: %s\n' "$label"
  else
    FAIL=$((FAIL + 1))
    printf '  FAIL: %s (status %s, expected %s)\n' \
      "$label" "$actual_status" "$expected_status" >&2
    printf '%s\n' "$output" >&2
  fi
}

REPO="$TEST_ROOT/repo"
OUTSIDE="$TEST_ROOT/outside"
NO_HOOKS="$TEST_ROOT/no-hooks"
git init -q "$REPO"
mkdir -p "$OUTSIDE" "$NO_HOOKS"
git -C "$REPO" symbolic-ref HEAD refs/heads/gate-fixture
git -C "$REPO" config user.name "Accepted Baseline Test"
git -C "$REPO" config user.email "accepted-baseline-test@example.invalid"
git -C "$REPO" config core.hooksPath "$NO_HOOKS"
git -C "$REPO" config commit.gpgsign false
git -C "$REPO" config core.autocrlf false

printf 'root\n' > "$REPO/history.txt"
git -C "$REPO" add history.txt
git -C "$REPO" commit -qm "root"
ROOT_COMMIT="$(git -C "$REPO" rev-parse HEAD)"
git -C "$REPO" tag accepted-v1

printf 'split-good\n' >> "$REPO/history.txt"
git -C "$REPO" commit -qam "split contains accepted v1"
mkdir -p "$REPO/nested/path"

gate_in_repo() {
  (cd "$REPO" && "$VERIFIER" "$@")
}

gate_in_nested_dir() {
  (cd "$REPO/nested/path" && "$VERIFIER" "$@")
}

gate_outside_repo() {
  (cd "$OUTSIDE" && "$VERIFIER" "$@")
}

check_result 0 "usage:" "help exits successfully" gate_in_repo --help
check_result 2 "usage:" "missing ref is a usage error" gate_in_repo
check_result 2 "usage:" "extra ref is a usage error" gate_in_repo accepted-v1 extra
check_result 2 "cannot resolve accepted baseline ref" \
  "missing ref fails closed" gate_in_repo refs/heads/does-not-exist
check_result 2 "must run inside a Git worktree" \
  "non-repository invocation fails closed" gate_outside_repo accepted-v1
check_result 0 "contains accepted baseline accepted-v1 ($ROOT_COMMIT)" \
  "named accepted ref passes when it is an ancestor" gate_in_repo accepted-v1
check_result 0 "contains accepted baseline $ROOT_COMMIT ($ROOT_COMMIT)" \
  "explicit accepted commit passes" gate_in_repo "$ROOT_COMMIT"
check_result 0 "contains accepted baseline accepted-v1 ($ROOT_COMMIT)" \
  "invocation from a nested directory checks the same HEAD" \
  gate_in_nested_dir accepted-v1

git -C "$REPO" checkout -qb accepted-next accepted-v1
printf 'accepted-v2\n' >> "$REPO/history.txt"
git -C "$REPO" commit -qam "accepted v2"
git -C "$REPO" tag accepted-v2
ACCEPTED_V2="$(git -C "$REPO" rev-parse accepted-v2)"

git -C "$REPO" checkout -qb stale-split accepted-v1
printf 'stale-split\n' >> "$REPO/history.txt"
git -C "$REPO" commit -qam "split misses accepted v2"

check_result 1 "does not contain accepted baseline accepted-v2 ($ACCEPTED_V2)" \
  "diverged HEAD fails the accepted-baseline gate" gate_in_repo accepted-v2

if [ "$FAIL" -ne 0 ]; then
  printf '%s/%s accepted-baseline gate checks failed\n' "$FAIL" "$((PASS + FAIL))" >&2
  exit 1
fi

printf '%s/%s accepted-baseline gate checks passed\n' "$PASS" "$((PASS + FAIL))"
