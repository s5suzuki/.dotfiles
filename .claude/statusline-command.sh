#!/usr/bin/env bash

input=$(cat)

# Single jq pass: this script now re-runs every second (statusLine.refreshInterval).
IFS=$'\x1f' read -r model used_pct five_pct week_pct transcript five_reset week_reset < <(
  echo "$input" | jq -r '[
    .model.display_name // "Unknown",
    (.context_window.used_percentage // ""),
    (.rate_limits.five_hour.used_percentage // ""),
    (.rate_limits.seven_day.used_percentage // ""),
    (.transcript_path // ""),
    (.rate_limits.five_hour.resets_at // "-"),
    (.rate_limits.seven_day.resets_at // "-")
  ] | map(tostring) | join("\u001f")'
)

reset_suffix() {
  local at="$1" fmt="$2"
  [[ "$at" =~ ^[0-9]+$ ]] || return 0
  printf ' \033[90m(~%s)\033[0m' "$(date -d "@$at" "+$fmt")"
}

make_bar() {
  local pct="$1"
  local width=10
  local filled=$(printf '%.0f' "$(echo "$pct $width" | awk '{printf "%f", $1 * $2 / 100}')")
  local empty=$(( width - filled ))
  local bar=""
  local i
  for (( i = 0; i < filled; i++ )); do bar="${bar}#"; done
  for (( i = 0; i < empty; i++ )); do bar="${bar}-"; done
  printf "[%s]" "$bar"
}

# Seconds since the transcript last grew, i.e. since the last observable event
# (prompt, tool call, tool result). Grows while a single long tool call runs.
since_last_event() {
  [ -n "$transcript" ] && [ -f "$transcript" ] || return 1
  local mtime now d
  mtime=$(stat -c %Y "$transcript" 2>/dev/null) || return 1
  now=$(date +%s)
  d=$(( now - mtime ))
  (( d < 0 )) && d=0
  if   (( d < 60 ));   then printf '%ds' "$d"
  elif (( d < 3600 )); then printf '%dm%02ds' $(( d / 60 )) $(( d % 60 ))
  else                      printf '%dh%02dm' $(( d / 3600 )) $(( d % 3600 / 60 ))
  fi
}

parts=()

parts+=("$(printf '\033[1;36m%s\033[0m' "$model")")

clock=$(date +%H:%M:%S)
if idle=$(since_last_event); then
  parts+=("$(printf '\033[1;32m%s\033[0m \033[90m(+%s)\033[0m' "$clock" "$idle")")
else
  parts+=("$(printf '\033[1;32m%s\033[0m' "$clock")")
fi

if [ -n "$used_pct" ]; then
  bar=$(make_bar "$used_pct")
  pct_int=$(printf '%.0f' "$used_pct")
  parts+=("$(printf 'ctx: \033[33m%s\033[0m %d%%' "$bar" "$pct_int")")
fi

if [ -n "$five_pct" ]; then
  bar=$(make_bar "$five_pct")
  pct_int=$(printf '%.0f' "$five_pct")
  parts+=("$(printf '5h: \033[35m%s\033[0m %d%%' "$bar" "$pct_int")$(reset_suffix "$five_reset" '%H:%M')")
fi

if [ -n "$week_pct" ]; then
  bar=$(make_bar "$week_pct")
  pct_int=$(printf '%.0f' "$week_pct")
  parts+=("$(printf '7d: \033[35m%s\033[0m %d%%' "$bar" "$pct_int")$(reset_suffix "$week_reset" '%m/%d %H:%M')")
fi

IFS=' | '
printf '%s\n' "${parts[*]}"
