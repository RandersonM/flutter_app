#!/usr/bin/env bash
# PreToolUse(Bash): commits and PR descriptions must not credit Claude — the
# trailer ties Claude's account to the git history.

set -uo pipefail

command=$(jq -r '.tool_input.command // empty')

case "$command" in
  *"git commit"* | *"gh pr create"* | *"gh pr edit"* | *"git tag"*) ;;
  *) exit 0 ;;
esac

if printf '%s' "$command" | grep -qiE 'co-authored-by:[^\n]*(claude|anthropic)|generated with \[?claude code|noreply@anthropic\.com'; then
  echo 'Blocked: commits and PR descriptions must not carry Claude attribution (Co-Authored-By trailer, "Generated with Claude Code", noreply@anthropic.com). Remove it and retry — see CLAUDE.md > Workflow.' >&2
  exit 2
fi

for body_file in $(printf '%s' "$command" | grep -oE -- '(--body-file|-F|--file)[= ]+[^ ]+' | sed -E 's/^(--body-file|-F|--file)[= ]+//'); do
  if [ -f "$body_file" ] && grep -qiE 'co-authored-by:.*(claude|anthropic)|generated with \[?claude code|noreply@anthropic\.com' "$body_file"; then
    echo "Blocked: $body_file contains Claude attribution. Remove it and retry — see CLAUDE.md > Workflow." >&2
    exit 2
  fi
done

exit 0
