#!/bin/bash

PRIMARY="$1"
GREEN="$2"

# Check power
if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo "<fc=$PRIMARY><fn=3>󰂲 </fn>OFF</fc>"
    exit
fi

# Get connected device
device=$(bluetoothctl devices Connected | awk '{print $2}' | head -n1)

if [ -z "$device" ]; then
    echo "<fc=$PRIMARY><fn=3></fn> ON</fc>"
    exit
fi

# SINGLE info call (important)
info=$(bluetoothctl info "$device")

name=$(echo "$info" | awk -F': ' '/Name:/ {print $2}')
battery=$(echo "$info" | grep -i "Percentage" | awk -F'[()]' '{print $2}' | tr -d '% ')

if [ -n "$battery" ]; then
    echo "<fc=$PRIMARY><fn=1>󰂱</fn> $name</fc> <fc=$GREEN>${battery}%</fc>"
else
    echo "<fc=$PRIMARY><fn=1>󰂱</fn> $name</fc>"
fi
