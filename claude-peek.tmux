#!/usr/bin/env sh

PLUGIN_DIR=$(cd "$(dirname "$0")" && pwd)

. "$PLUGIN_DIR/scripts/variables.sh"
. "$PLUGIN_DIR/scripts/helpers.sh"

key=$(get_tmux_option "$CLAUDE_PEEK_KEY_OPTION" "$CLAUDE_PEEK_KEY_DEFAULT")

tmux bind-key "$key" run-shell "$PLUGIN_DIR/scripts/peek.sh"

exit 0
