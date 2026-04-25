#!/usr/bin/env sh

_vars="$(dirname "$0")/variables.sh"
[ -f "$_vars" ] && . "$_vars"
unset _vars

get_tmux_option() {
  result="$(tmux show-option -gqv "$1")"
  if [ -z "$result" ]; then
    echo "$2"
  else
    echo "$result"
  fi
}

history_file() {
  safe_id="$(printf '%s' "$1" | tr '%' '_')"
  echo "${HIST_PEEK_HISTORY_DIR}/${safe_id}"
}

pin_file() {
  safe_id="$(printf '%s' "$1" | tr '%' '_')"
  echo "${HIST_PEEK_HISTORY_DIR}/${safe_id}.pin"
}
