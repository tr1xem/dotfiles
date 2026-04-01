#!/usr/bin/env bash

file=$(find -L ~/Pictures/Wallpapers \
  -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) \
  | vicinae dmenu -p "Pick a wallpaper...")

[ -n "$file" ] && matugen --source-color-index 0 image "$file"
