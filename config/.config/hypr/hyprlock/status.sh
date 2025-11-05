#!/usr/bin/env bash

enable_battery=false
battery_charging=false
battery_percent=0

for battery in /sys/class/power_supply/*BAT*; do
  if [[ -f "$battery/uevent" ]]; then
    enable_battery=true
    battery_status=$(cat "$battery/status")
    battery_percent=$(cat "$battery/capacity")
    [[ "$battery_status" == "Charging" ]] && battery_charging=true
    break
  fi
done

get_battery_icon() {
  local percent=$1
  local charging=$2

  if (( percent >= 90 )); then
    echo " "
  elif (( percent >= 70 )); then
    echo " "
  elif (( percent >= 50 )); then
    echo " "
  elif (( percent >= 30 )); then
    echo " "
  else
    echo " "
  fi
}

if [[ $enable_battery == true ]]; then
  get_battery_icon "$battery_percent" "$battery_charging"
fi

