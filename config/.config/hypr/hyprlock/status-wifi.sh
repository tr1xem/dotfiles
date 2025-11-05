#!/usr/bin/env bash

get_wifi_strength() {
  local interface
  interface=$(iw dev | awk '$1=="Interface"{print $2}' | head -n1)

  if [[ -n "$interface" ]]; then
    local signal
    signal=$(grep "$interface" /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')
    echo "$signal"
  else
    echo 0
  fi
}

get_wifi_icon() {
  local strength=$1

  if (( strength >= 80 )); then
    echo "󰤨 ㅤ"
  elif (( strength >= 60 )); then
    echo "󰤥ㅤ"
  elif (( strength >= 40 )); then
    echo "󰤢ㅤ"
  elif (( strength >= 20 )); then
    echo "󰤟ㅤ"
  else
    echo "󰤮ㅤ"
  fi
}

strength=$(get_wifi_strength)
get_wifi_icon "$strength"

