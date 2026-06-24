#!/usr/bin/env bash

SEP_COLOR="$1"
TEXT_COLOR="$2"
ICON=""

STATE_FILE="/tmp/xmobar_spotify_offset"

status=$(playerctl -p spotify status 2>/dev/null)

if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
    title=$(playerctl -p spotify metadata title 2>/dev/null)
    artist=$(playerctl -p spotify metadata artist 2>/dev/null)

    combined="$title  $artist"

    max_len=30

    if (( ${#combined} > max_len )); then
        # Read previous offset
        offset=0
        [[ -f "$STATE_FILE" ]] && offset=$(<"$STATE_FILE")

        # Add some spaces so the text wraps nicely
        scroll_text="$combined  "
        len=${#scroll_text}

        # Ensure offset is valid
        (( offset >= len )) && offset=0

        # Duplicate text to make wrapping seamless
        doubled="$scroll_text$scroll_text"

        display="${doubled:offset:max_len}"

        # Advance offset
        echo $(( (offset + 1) % len )) > "$STATE_FILE"
    else
        display="$combined"
    fi

    echo "<fc=$SEP_COLOR>│</fc> <fc=$TEXT_COLOR><fn=1>$ICON</fn> $display</fc>"
else
    rm -f "$STATE_FILE"
    echo ""
fi
