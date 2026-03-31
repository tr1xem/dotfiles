#!/bin/bash

# Check if Bluetooth is powered on
if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo "<fc=#7aa2f7>󰂲 OFF</fc>"
    exit
fi

# Get connected device MAC
device=$(bluetoothctl devices Connected | awk '{print $2}')

if [ -n "$device" ]; then
    # Get device name
    name=$(bluetoothctl info "$device" | grep "Name:" | cut -d ' ' -f2-)
    echo "<fc=#7aa2f7>󰂱 $name</fc>"
else
    echo "<fc=#7aa2f7> ON</fc>"
fi
