#!/bin/bash

PRIMARY="$1"
GREEN="$2"

# Run a single interactive session and capture output
BT_OUTPUT=$(bluetoothctl <<EOF
show
devices
info $(bluetoothctl devices | awk '{print $2}')
EOF
)

# Check if controller is powered
if ! echo "$BT_OUTPUT" | grep -q "Powered: yes"; then
    echo "<fc=$PRIMARY><fn=3>󰂲 </fn>OFF</fc>"
    exit
fi

# Find first connected device
device=$(echo "$BT_OUTPUT" | awk '
/Device/ {mac=$2}
/Connected: yes/ {print mac; exit}
')

if [ -n "$device" ]; then
    # Extract info for that device
    info=$(echo "$BT_OUTPUT" | awk -v mac="$device" '
    $0 ~ "Device " mac {flag=1; next}
    /^Device/ {flag=0}
    flag {print}
    ')

    name=$(echo "$info" | awk -F': ' '/Name:/ {print $2}')
    battery=$(echo "$info" | grep -i "Percentage" | awk -F'[()]' '{print $2}' | tr -d '% ')

    if [ -n "$battery" ]; then
        echo "<fc=$PRIMARY><fn=1>󰂱</fn> $name</fc> <fc=$GREEN>${battery}%</fc>"
    else
        echo "<fc=$PRIMARY><fn=1>󰂱</fn> $name</fc>"
    fi
else
    echo "<fc=$PRIMARY><fn=3></fn> ON</fc>"
fi
