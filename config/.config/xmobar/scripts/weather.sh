#!/bin/bash

PRIMARY="$1"

weather=$(curl -s \
    --retry 5 \
    --retry-delay 1 \
    --max-time 5 \
    "wttr.in?format=%c%t" 2>/dev/null | sed 's/+//' | xargs)

if [[ -n "$weather" ]]; then
    echo "<fc=$PRIMARY>$weather</fc>"
else
    echo ""
fi
