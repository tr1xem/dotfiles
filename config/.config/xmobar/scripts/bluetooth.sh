#!/bin/bash

PRIMARY="$1"
GREEN="$2"

if ! bluetoothctl show | grep -q "Powered: yes"; then
  echo "<fc=$PRIMARY><fn=1>󰂲</fn> OFF</fc>"
  exit
fi

device=$(bluetoothctl devices Connected | awk '{print $2}')

if [ -n "$device" ]; then
  info=$(bluetoothctl info "$device")
  name=$(echo "$info" | awk -F': ' '/Name:/ {print $2}')
  battery=$(echo "$info" | awk -F'[()]' '/Battery Percentage/ {print $2}')

  if [ -n "$battery" ]; then
    echo "<fc=$PRIMARY><fn=1>󰂱</fn> $name</fc> <fc=$GREEN>${battery}%</fc>"
  else
    echo "<fc=$PRIMARY><fn=1>󰂱</fn> $name</fc>"
  fi
else
  echo "<fc=$PRIMARY><fn=1></fn> ON</fc>"
fi
