#!/bin/bash
PRIMARY="$1"
weather=$(curl -s "wttr.in?format=%c%t" | sed 's/+//' | xargs)
echo "<fc=$PRIMARY>$weather</fc>"
