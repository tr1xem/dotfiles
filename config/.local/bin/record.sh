#!/bin/bash

random_string=$(LC_ALL=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 7)
focused_window=$(hyprctl activewindow)
app_name=$(echo "$focused_window" | grep "class:" | awk '{print $2}')
audiodev="alsa_output.pci-0000_00_1b.0.analog-stereo.monitor"


if [[ "$app_name" == "none" ]]; then
    app_name="recording"
fi

file="${random_string}-${app_name}"
output_file=$HOME/Videos/Recordings/"${file}.mp4"
SAVE_DIR="$HOME/Videos/Recordings"


ezauth="key:$EZAUTH"
ezuploadurl="https://api.e-z.host/files"
monarchauth="secret=$MONARCHKEY"
monarchuploadurl="https://api.monarchupload.cc/v3/upload"

mkdir -p $HOME/Videos/Recordings
if pgrep -f "gpu-screen-recorder" >/dev/null; then
   #pkill -SIGINT -f "wf-recorder"
    pkill -SIGINT -f gpu-screen-recorder
    sleep 1
    LAST_VIDEO=$(ls -t "$SAVE_DIR"/*.mp4 2>/dev/null | head -n 1)
    notify-send -i "screenrecorder" -a "gpu-screen-recorder" "Recording Stopped" "$LAST_VIDEO"

    # EZ
    #json_data=$(curl -X POST -F "file=@/$LAST_VIDEO" -H "$ezauth"  -v $ezuploadurl 2>/dev/null)
    # MONARCH
    json_data=$(curl -s -F $monarchauth -F "file=@$LAST_VIDEO" $monarchuploadurl)

    # EZ
    # status=$(echo "$json_data" | jq -r '.status')
    # if [[ $status == "error" ]]; then
    #     message=$(echo "$json_data" | jq -r '.message')
    #     notify-send -i "screenrecorder" -a "wl-screenrec" "$message"
    #     exit 1
    # fi
    # video_url=$(echo "$json_data" | jq -r '.imageUrl')
    # d_url=$(echo "$json_data" | jq -r '.deletionUrl')
    # raw_url=$(echo "$json_data" | jq -r '.rawUrl')
    # wl-copy "$video_url"
    # ACTION=$(notify-send -i "screenrecorder" -a "wl-screenrec" "Recording Uploaded" "$video_url" \
    # -i "screenrecorder" -A "view=View" -A "open=Open Link" -A "raw=Raw Link" -A "delete=Delete")
    #
    # if [ "$ACTION" = "view" ] && [ -n "$LAST_VIDEO" ]; then
    #     xdg-open "$LAST_VIDEO"
    # elif [ "$ACTION" = "open" ]; then
    #     xdg-open "$video_url"
    # elif [ "$ACTION" = "raw" ]; then
    #     wl-copy "$raw_url"
    # elif [ "$ACTION" = "delete" ]; then
    #     curl $d_url && notify-send -i "screenrecorder" -a "wl-screenrec" "Deleted File" "Successfully"

    # MONARCH
    video_url=$(echo "$json_data" | jq -r '.data.url')
    message=$(echo "$json_data" | jq -r '.message')
    status=$(echo "$json_data" | jq -r '.status')
    if [ "$status" = "success" ]; then
        echo "$video_url" | xclip
        notify-send -a "gpu-screen-recorder" -i "screenrecorder" -u critical -t 10000 -h string:x-canonical-private-synchronous:shot-notify "$message" "$video_url"
        rm $LAST_VIDEO
    else
        notify-send -a "gpu-screen-recorder" -i "screenrecorder" -u critical -t 10000 -h string:x-canonical-private-synchronous:shot-notify "$message"
        exit 1
    fi
    exit 0
else
    #notify-send -i "screenrecorder" -a "wl-screenrec" "Recording started"
     gpu-screen-recorder -f 60 -q high -a "default_output|default_input" -w region -region $(slop -f "%wx%h+%x+%y") -ac aac -o "$output_file" -v no
    #wf-recorder -f "$output_file" -r 60 -i "screenrecorder" -a=$audiodev -g "$(~/.local/bin/slurp.sh -d)" 2>/dev/null
fi
