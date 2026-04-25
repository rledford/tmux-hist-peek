#!/usr/bin/env sh

[ -z "$TMUX_PANE" ] && exit 0

command -v jq >/dev/null 2>&1 || exit 0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/variables.sh"
. "$SCRIPT_DIR/helpers.sh"

input="$(cat)"

tool_name="$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)"
[ -z "$tool_name" ] && exit 0

if [ "$tool_name" = "MultiEdit" ]; then
  file_paths="$(printf '%s' "$input" | jq -r '.tool_input.edits[].file_path // empty' 2>/dev/null)"
else
  file_paths="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
fi

[ -z "$file_paths" ] && exit 0

mkdir -p "$CLAUDE_PEEK_HISTORY_DIR"
hist_file="$(history_file "$TMUX_PANE")"
max_files="$(get_tmux_option "$CLAUDE_PEEK_MAX_FILES_OPTION" "$CLAUDE_PEEK_MAX_FILES_DEFAULT")"

printf '%s\n' "$file_paths" | awk '{a[NR]=$0} END{for(i=NR;i>=1;i--)print a[i]}' | while IFS= read -r file_path; do
  [ -z "$file_path" ] && continue

  case "$file_path" in
    /*) ;;
    ~*) file_path="$HOME${file_path#\~}" ;;
    *)
      pane_cwd="$(tmux display-message -t "$TMUX_PANE" -p "#{pane_current_path}" 2>/dev/null)"
      [ -n "$pane_cwd" ] && file_path="$pane_cwd/$file_path"
      ;;
  esac

  {
    printf '%s\n' "$file_path"
    [ -f "$hist_file" ] && grep -vxF "$file_path" "$hist_file"
  } | head -n "$max_files" > "${hist_file}.tmp" && mv "${hist_file}.tmp" "$hist_file"
done

exit 0
