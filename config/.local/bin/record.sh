#!/bin/sh

# Screen recording script using gpu-screen-recorder
# Supports region selection, fullscreen, and upload to Monarch API

set -eu

SCRIPTNAME="record.sh"
PIDFILE="/tmp/$SCRIPTNAME.pid"
SAVE_DIR="$HOME/Videos/Recordings"
MAX_WIDTH=1920
MAX_HEIGHT=1080

main() {
	case "${1:-help}" in
		start) start ;;
		stop) stop ;;
		toggle) toggle ;;
		fullscreen) start_fullscreen ;;
		status) status "${2:-#ff0000}" ;;
		help|*) help ;;
	esac
}

status() {
	color="${1:-#ff0000}"
	if [ -f "$PIDFILE" ]
	then
		echo "<fc=$color><fn=1> </fn>REC</fc>"
	fi
}

start() {
	# Get region via slop (user selects)
	slop_output=$(slop -f "W=%w H=%h X=%x Y=%y")
	W=$(echo "$slop_output" | grep -oP 'W=\K[0-9]+')
	H=$(echo "$slop_output" | grep -oP 'H=\K[0-9]+')
	X=$(echo "$slop_output" | grep -oP 'X=\K[0-9]+')
	Y=$(echo "$slop_output" | grep -oP 'Y=\K[0-9]+')
	_start_recording "$W" "$H" "$X" "$Y" "region"
}

start_fullscreen() {
	# Get full screen resolution via xrandr
	res="$(xrandr | head -n1)"
	res="${res#*current }"
	res="${res%%, maximum*}"
	set -- $res
	W=$1
	H=$3
	X=0
	Y=0
	_start_recording "$W" "$H" "$X" "$Y" "fullscreen"
}

_start_recording() {
	W=$1
	H=$2
	X=$3
	Y=$4
	mode=$5

	# Clamp dimensions to max resolution
	if [ "$W" -gt "$MAX_WIDTH" ]; then
		W=$MAX_WIDTH
	fi
	if [ "$H" -gt "$MAX_HEIGHT" ]; then
		H=$MAX_HEIGHT
	fi

	random_string=$(LC_ALL=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 7)
	focused_window=$(xdotool getactivewindow 2>/dev/null) || focused_window=""
	if [ -z "$focused_window" ]; then
		app_name="none"
	else
		app_name=$(xprop -id "$focused_window" WM_CLASS | grep -oP '(?<=")[^"]*(?=")' | tail -1)
	fi

	if [ -z "$app_name" ]
	then
		app_name="none"
	fi

	# Escape special characters in app_name for safe filename
	app_name=$(echo "$app_name" | sed 's/[^a-zA-Z0-9._-]/_/g')

	file="${random_string}-${app_name}"
	output_file="$SAVE_DIR/${file}.mp4"

	mkdir -p "$SAVE_DIR"

	if [ "$mode" = "fullscreen" ]
	then
		gpu-screen-recorder -f 60 -q high -a "default_output|default_input" -w screen -ac aac -o "$output_file" -v no &
	else
		gpu-screen-recorder -f 60 -q high -a "default_output|default_input" -w region -region "${W}x${H}+${X}+${Y}" -ac aac -o "$output_file" -v no &
	fi

	echo "PID=$!" > "$PIDFILE"
	echo "FILENAME=$output_file" >> "$PIDFILE"
}

stop() {
	if [ ! -f "$PIDFILE" ]
	then
		echo "No recording in progress"
		exit 1
	fi

	. "$PIDFILE"
	kill -INT "$PID" 2>/dev/null || notify-send "failed to kill recording process"
	sleep 1
	rm "$PIDFILE"

	# Upload to Monarch
	json_data=$(curl -s -F "secret=$MONARCHKEY" -F "file=@$FILENAME" https://api.monarchupload.cc/v3/upload)

	video_url=$(echo "$json_data" | jq -r '.data.url')
	message=$(echo "$json_data" | jq -r '.message')
	upload_status=$(echo "$json_data" | jq -r '.status')

	if [ "$upload_status" = "success" ]
	then
		echo -n "$video_url" | xclip -selection clipboard
		notify-send -a "gpu-screen-recorder" -i "screenrecorder" -u critical -t 10000 -h string:x-canonical-private-synchronous:shot-notify "$message" "$video_url"
		rm "$FILENAME"
	else
		notify-send -a "gpu-screen-recorder" -i "screenrecorder" -u critical -t 10000 -h string:x-canonical-private-synchronous:shot-notify "$message"
		exit 1
	fi
}

toggle() {
	if [ -f "$PIDFILE" ]
	then
		stop
	else
		start
	fi
}

help() {
	cat <<EOF
Usage: $SCRIPTNAME [COMMAND] [OPTIONS]

Commands:
  start              Start recording with region selection (slop)
  stop               Stop recording and upload
  toggle             Toggle recording (stop if running, start if not)
  fullscreen         Start recording full screen (-w screen)
  status [COLOR]     Show recording status (defaults to #ff0000)
  help               Show this help message

Examples:
  $SCRIPTNAME              # Shows help menu
  $SCRIPTNAME start        # Start with region selection
  $SCRIPTNAME fullscreen   # Start full screen recording
  $SCRIPTNAME status       # Show status with default red color
  $SCRIPTNAME status #00ff00 # Show status with green color
  $SCRIPTNAME toggle       # Toggle recording state

Environment Variables:
  MONARCHKEY         API key for Monarch upload service (required for upload)
EOF
}

main "$@"
