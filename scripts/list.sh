#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/variables.sh"
. "$SCRIPT_DIR/helpers.sh"

pane_id="$1"
result_file="$2"
hist_file="$(history_file "$pane_id")"
pinned_record="$(pin_file "$pane_id")"

if [ ! -f "$hist_file" ] || [ ! -s "$hist_file" ]; then
  printf ' no files recorded yet\n'
  sleep 1
  exit 0
fi

mapfile -t raw_files < "$hist_file"
pinned_files=()
[ -f "$pinned_record" ] && mapfile -t pinned_files < "$pinned_record"
max_pins="$(get_tmux_option "$CLAUDE_PEEK_MAX_PINS_OPTION" "$CLAUDE_PEEK_MAX_PINS_DEFAULT")"

is_pinned() {
  local f="$1"
  for p in "${pinned_files[@]}"; do
    [ "$p" = "$f" ] && return 0
  done
  return 1
}

remove_pin() {
  local f="$1" new_pins=()
  for p in "${pinned_files[@]}"; do
    [ "$p" != "$f" ] && new_pins+=("$p")
  done
  pinned_files=("${new_pins[@]}")
}

save_pins() {
  if [ "${#pinned_files[@]}" -eq 0 ]; then
    rm -f "$pinned_record"
  else
    printf '%s\n' "${pinned_files[@]}" > "$pinned_record"
  fi
}

build_display() {
  display_files=()
  for p in "${pinned_files[@]}"; do
    display_files+=("$p")
  done
  for f in "${raw_files[@]}"; do
    is_pinned "$f" || display_files+=("$f")
  done
  file_count="${#display_files[@]}"
}

build_display

selected=0
prev_selected=-1

draw_line() {
  local i="$1"
  tput cup $((i + 1)) 0
  if [ "$i" -eq "$selected" ] && is_pinned "${display_files[$i]}"; then
    printf ' \033[1;32m◆ %s\033[0m\033[K' "${display_files[$i]}"
  elif [ "$i" -eq "$selected" ]; then
    printf ' \033[1;32m▶ %s\033[0m\033[K' "${display_files[$i]}"
  elif is_pinned "${display_files[$i]}"; then
    printf ' \033[33m◆ %s\033[0m\033[K' "${display_files[$i]}"
  else
    printf '   %s\033[K' "${display_files[$i]}"
  fi
}

draw() {
  if [ "$prev_selected" -lt 0 ]; then
    clear
    printf ' ────────────────────────────────────────────────────────\n'
    for i in "${!display_files[@]}"; do
      if [ "$i" -eq "$selected" ] && is_pinned "${display_files[$i]}"; then
        printf ' \033[1;32m◆ %s\033[0m\n' "${display_files[$i]}"
      elif [ "$i" -eq "$selected" ]; then
        printf ' \033[1;32m▶ %s\033[0m\n' "${display_files[$i]}"
      elif is_pinned "${display_files[$i]}"; then
        printf ' \033[33m◆ %s\033[0m\n' "${display_files[$i]}"
      else
        printf '   %s\n' "${display_files[$i]}"
      fi
    done
    printf '\n \033[2m[j/↓] down  [k/↑] up  [Enter] open  [p] pin  [q] quit\033[0m\n'
  else
    draw_line "$prev_selected"
    draw_line "$selected"
    tput cup $((file_count + 2)) 0
  fi
  prev_selected="$selected"
}

tput civis 2>/dev/null
trap 'tput cnorm 2>/dev/null' EXIT

draw

chosen=""
while true; do
  IFS= read -r -s -n1 key < /dev/tty
  if [[ "$key" == $'\x1b' ]]; then
    IFS= read -r -s -n1 -t 0.1 s1 < /dev/tty
    IFS= read -r -s -n1 -t 0.1 s2 < /dev/tty
    key="${key}${s1}${s2}"
  fi
  case "$key" in
    j|$'\x1b[B')
      [ "$selected" -lt $((file_count - 1)) ] && selected=$((selected + 1))
      draw
      ;;
    k|$'\x1b[A')
      [ "$selected" -gt 0 ] && selected=$((selected - 1))
      draw
      ;;
    p)
      cur_file="${display_files[$selected]}"
      if is_pinned "$cur_file"; then
        remove_pin "$cur_file"
      elif [ "${#pinned_files[@]}" -lt "$max_pins" ]; then
        pinned_files+=("$cur_file")
      fi
      save_pins
      build_display
      selected=0
      for i in "${!display_files[@]}"; do
        [ "${display_files[$i]}" = "$cur_file" ] && selected="$i" && break
      done
      prev_selected=-1
      draw
      ;;
    $'\r'|$'\n'|'')
      printf '%s' "${display_files[$selected]}" > "$result_file"
      break
      ;;
    q|$'\x1b')
      break
      ;;
  esac
done

exit 0
