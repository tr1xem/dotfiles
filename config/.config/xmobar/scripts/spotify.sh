#!/usr/bin/env bash

SEP_COLOR="$1"
TEXT_COLOR="$2"
ICON=""

status=$(playerctl -p spotify status 2>/dev/null)

if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
    title=$(playerctl -p spotify metadata title 2>/dev/null)
    artist=$(playerctl -p spotify metadata artist 2>/dev/null)

    combined="$title - $artist"

    # Truncate to 10 characters if longer
    if (( ${#combined} > 30 )); then
        combined="${combined:0:30}..."
    fi

    echo "<fc=$SEP_COLOR>│</fc> <fc=$TEXT_COLOR><fn=1>$ICON</fn> $combined</fc>"
else
    echo ""
fi
