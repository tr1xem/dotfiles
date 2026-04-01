#!/usr/bin/env bash

action="$1"

case "$action" in
  # 🔊 Volume controls
  vol-up)
    wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 1%+
    ;;
  vol-down)
    wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 1%-
    ;;
  vol-mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    ;;

  # 🔆 Brightness controls
  br-up)
    brightnessctl set 3%+
    ;;
  br-down)
    brightnessctl set 3%-
    ;;
esac

# ---------- VOLUME ----------
if [[ "$action" == vol-* ]]; then
  vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%d", $2 * 100}')
  muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o MUTED)

  if [ "$muted" = "MUTED" ]; then
    dunstify -a "Volume" -r 9991 "Muted"
  else
    dunstify -a "Volume" -r 9991 -h int:value:$vol ""
  fi
fi

# ---------- BRIGHTNESS ----------
if [[ "$action" == br-* ]]; then
  brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
  dunstify -a "Brightness" -r 9992 -h int:value:$brightness ""
fi
