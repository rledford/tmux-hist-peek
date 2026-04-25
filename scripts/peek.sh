#!/usr/bin/env sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/variables.sh"
. "$SCRIPT_DIR/helpers.sh"

pane_id="$(tmux display-message -p "#{pane_id}")"
width="$(get_tmux_option "$HIST_PEEK_WIDTH_OPTION" "$HIST_PEEK_WIDTH_DEFAULT")"
height="$(get_tmux_option "$HIST_PEEK_HEIGHT_OPTION" "$HIST_PEEK_HEIGHT_DEFAULT")"
open_cmd="$(get_tmux_option "$HIST_PEEK_COMMAND_OPTION" "$HIST_PEEK_COMMAND_DEFAULT")"

result_file="$(mktemp)"

tmux display-popup -E -w "$width" -h "$height" -T " hist peek " -- \
  bash "$SCRIPT_DIR/list.sh" "$pane_id" "$result_file"

chosen="$(cat "$result_file" 2>/dev/null)"
rm -f "$result_file"

if [ -n "$chosen" ]; then
  tmux display-popup -E -w "$width" -h "$height" -- sh -c "$open_cmd \"\$1\"" _ "$chosen"
fi
