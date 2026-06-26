#!/bin/bash

PRIMARY="$1"

weather=$(curl -s \
    --retry 3 \
    --retry-delay 3 \
    --max-time 3 \
    "wttr.in?format=%c%t" 2>/dev/null)

if [[ -n "$weather" ]]; then
    echo "<fc=$PRIMARY>$weather</fc>"
else
    echo ""
fi
