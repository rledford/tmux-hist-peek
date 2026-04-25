#!/usr/bin/env sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

input="$(cat)"

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
[ -z "$tool_name" ] && exit 0

if [ "$tool_name" = "MultiEdit" ]; then
  printf '%s' "$input" | jq -c '{files: [.tool_input.edits[].file_path]}' | "$SCRIPT_DIR/../record.sh"
else
  printf '%s' "$input" | jq -c '{file: .tool_input.file_path}' | "$SCRIPT_DIR/../record.sh"
fi
