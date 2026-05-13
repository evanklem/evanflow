#!/bin/bash

# Fail-closed: if jq is unavailable, block the command rather than allowing it.
if ! command -v jq &>/dev/null; then
  echo "BLOCKED: jq is not installed — cannot verify command safety. Install jq or remove this hook." >&2
  exit 2
fi

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

DANGEROUS_PATTERNS=(
  "git push"
  "git reset --hard"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git checkout -- \."
  "git restore \."
  "git restore -- \."
  "push --force"
  "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exit 0
