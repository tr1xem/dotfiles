#!/usr/bin/env bash

# Find the last active player (first one that is Playing or Paused)
player=$(playerctl --list-all 2>/dev/null | while read p; do
    st=$(playerctl -p "$p" status 2>/dev/null)
    if [[ "$st" == "Playing" || "$st" == "Paused" ]]; then
        echo "$p"
        break
    fi
done)

# If no active player, exit
[[ -z "$player" ]] && exit 0

# Get player status
status=$(playerctl -p "$player" status 2>/dev/null)

# Get current track info
info=$(playerctl -p "$player" metadata --format "{{artist}} - {{title}}" 2>/dev/null)

# Output with icon
if [ "$status" = "Playing" ]; then
    printf "▶ %s" "$info"
elif [ "$status" = "Paused" ]; then
    printf "⏸ %s" "$info"
else
    printf ""
fi
