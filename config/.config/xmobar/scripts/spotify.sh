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

        scroll_text="$combined  "
        len=${#scroll_text}

        t=$(date +%s)
        offset=$(( t % len ))




        (( offset >= len )) && offset=0


        doubled="$scroll_text$scroll_text"

        display="${doubled:offset:max_len}"


    else
        display="$combined"
    fi

    echo "<fc=$SEP_COLOR>│</fc> <fc=$TEXT_COLOR><fn=1>$ICON</fn> $display</fc>"
else
    rm -f "$STATE_FILE"
    echo ""
fi
