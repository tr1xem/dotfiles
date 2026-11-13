#!/usr/bin/env bash

TEXT_COLOR="$1"

# ICON_ON=" "
ICON_ON=""
ICON_OFF=""

level=$(dunstctl get-pause-level 2>/dev/null)

if [[ "$level" == "0" ]]; then
    echo ""
elif [[ "$level" == "100" ]]; then
    ICON="$ICON_OFF"
    # echo "<fc=$SEP_COLOR>│</fc> <fc=$TEXT_COLOR><fn=1>$ICON</fn> $LABEL</fc>"
    echo "<fc=$TEXT_COLOR> <fn=1>$ICON</fn></fc>"
else
    echo ""
    exit 0
fi


