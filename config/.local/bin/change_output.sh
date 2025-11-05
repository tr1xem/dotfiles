#!/bin/bash

# Create a list of sinks with descriptions
mapfile -t sinks < <(
  pactl list sinks short | awk '{print $1}' |
  while read -r index; do
    name=$(pactl list sinks | awk -v RS='' "/Sink #$index/" | grep 'Name:' | awk '{print $2}')
    desc=$(pactl list sinks | awk -v RS='' "/Sink #$index/" | grep 'Description:' | cut -d':' -f2- | sed 's/^ *//')
    echo "$desc [$name]"
  done
)

# Display the list in fuzzel
selected=$(printf "%s\n" "${sinks[@]}" | fuzzel --dmenu -p "Select Audio Output:")

# Exit if nothing selected
[ -z "$selected" ] && exit 0

# Extract the sink name from selection (from inside [...])
sink_name=$(echo "$selected" | sed -n 's/.*\[\(.*\)\]/\1/p')

# Set as default sink
pactl set-default-sink "$sink_name"

# Move all playing streams to the new sink
pactl list short sink-inputs | while read -r input; do
  input_id=$(echo "$input" | awk '{print $1}')
  pactl move-sink-input "$input_id" "$sink_name"
done

notify-send "Audio Output Changed" "Now using: $selected"

