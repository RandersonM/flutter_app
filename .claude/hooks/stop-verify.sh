#!/usr/bin/env bash
# Stop hook: before Claude ends a turn that changed Dart/ARB/pubspec files,
# run the same gates CI runs (format, analyze, test). On failure, exit 2 so
# Claude keeps working and fixes them.
#
# The dirty marker is set by dart-post-edit.sh, so turns that only read code
# pay nothing. After 3 consecutive failed attempts the hook lets the turn end
# with a warning instead of looping on a failure Claude may not own (e.g. a
# test that was already red).

set -uo pipefail

cat >/dev/null # hook input is not needed
root="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$root" || exit 0

state_dir=".claude/.state"
marker="$state_dir/dart-dirty"
attempts_file="$state_dir/stop-attempts"
[ -f "$marker" ] || exit 0

fail() { # $1 = gate name, $2 = output
  local attempts
  attempts=$(cat "$attempts_file" 2>/dev/null || echo 0)
  attempts=$((attempts + 1))
  if [ "$attempts" -gt 3 ]; then
    rm -f "$attempts_file"
    printf '{"systemMessage":"Harness: %s still failing after 3 fix attempts; stopping anyway. Run it yourself before committing."}\n' "$1"
    exit 0
  fi
  echo "$attempts" >"$attempts_file"
  {
    printf 'Harness verification failed at "%s" (attempt %s/3). Fix it before finishing:\n\n' "$1" "$attempts"
    printf '%s\n' "$2" | tail -60
  } >&2
  exit 2
}

if ! out=$(fvm dart format --output=none --set-exit-if-changed lib test 2>&1); then
  fail "fvm dart format" "$(printf '%s\n' "$out" | grep '^Changed')
Run: fvm dart format lib test"
fi

if ! out=$(fvm flutter analyze --no-fatal-infos 2>&1); then
  fail "fvm flutter analyze" "$out"
fi

if ! out=$(fvm flutter test --reporter=failures-only 2>&1); then
  fail "fvm flutter test" "$out"
fi

rm -f "$marker" "$attempts_file"
exit 0
