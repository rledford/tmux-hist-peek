#!/usr/bin/env sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/variables.sh"
. "$SCRIPT_DIR/helpers.sh"

pane_id="$(tmux display-message -p "#{pane_id}")"
width="$(get_tmux_option "$CLAUDE_PEEK_WIDTH_OPTION" "$CLAUDE_PEEK_WIDTH_DEFAULT")"
height="$(get_tmux_option "$CLAUDE_PEEK_HEIGHT_OPTION" "$CLAUDE_PEEK_HEIGHT_DEFAULT")"
editor="$(get_tmux_option "$CLAUDE_PEEK_EDITOR_OPTION" "$CLAUDE_PEEK_EDITOR_DEFAULT")"

result_file="$(mktemp)"

tmux display-popup -E -w "$width" -h "$height" -T " claude peek " -- \
  bash "$SCRIPT_DIR/list.sh" "$pane_id" "$result_file"

chosen="$(cat "$result_file" 2>/dev/null)"
rm -f "$result_file"

if [ -n "$chosen" ]; then
  tmux display-popup -E -w "$width" -h "$height" -- "$editor" "$chosen"
fi
