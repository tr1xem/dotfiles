#!/bin/bash

random_string=$(LC_ALL=C tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 7)
focused_window=$(hyprctl activewindow)
app_name=$(echo "$focused_window" | grep "class:" | awk '{print $2}')
audiodev="alsa_output.pci-0000_00_1b.0.analog-stereo.monitor"


if [[ "$app_name" == "none" ]]; then
    app_name="wl-screenrec"
fi

file="${random_string}-${app_name}"
output_file=$HOME/Videos/Recordings/"${file}.mp4"
SAVE_DIR="$HOME/Videos/Recordings/"


ezauth="key:$EZAUTH"
ezuploadurl="https://api.e-z.host/files"
monarchauth="secret=$MONARCHKEY"
monarchuploadurl="https://api.monarchupload.cc/v3/upload"

mkdir -p $HOME/Videos/Recordings
if pgrep -f "wf-recorder" >/dev/null; then
    pkill -SIGINT -f "wf-recorder"
    sleep 1
    LAST_VIDEO=$(ls -t "$SAVE_DIR"/*.mp4 2>/dev/null | head -n 1)
    notify-send -i "screenrecorder" -a "wl-screenrec" "Recording Stopped" "$LAST_VIDEO"

    json_data=$(curl -X POST -F "file=@/$LAST_VIDEO" -H "key:$ezauth"  -v $ezuploadurl 2>/dev/null)
    # json_data=$(curl -s -F "secret=WmSwoBDJuwrB" -F "file=@$processed_file" "https://api.monarchupload.cc/v3/upload")
    status=$(echo "$json_data" | jq -r '.status')
    echo $json_data
    if [[ $status == "error" ]]; then
        message=$(echo "$json_data" | jq -r '.message')
        notify-send -i "screenrecorder" -a "wl-screenrec" "$message"
        exit 1
    fi

    video_url=$(echo "$json_data" | jq -r '.imageUrl')
    d_url=$(echo "$json_data" | jq -r '.deletionUrl')
    raw_url=$(echo "$json_data" | jq -r '.rawUrl')
    wl-copy "$video_url"
    ACTION=$(notify-send -i "screenrecorder" -a "wl-screenrec" "Recording Uploaded" "$video_url" \
    -i "screenrecorder" -A "view=View" -A "open=Open Link" -A "raw=Raw Link" -A "delete=Delete")

    if [ "$ACTION" = "view" ] && [ -n "$LAST_VIDEO" ]; then
        xdg-open "$LAST_VIDEO"
    elif [ "$ACTION" = "open" ]; then
        xdg-open "$video_url"
    elif [ "$ACTION" = "raw" ]; then
        wl-copy "$raw_url"
    elif [ "$ACTION" = "delete" ]; then
        curl $d_url && notify-send -i "screenrecorder" -a "wl-screenrec" "Deleted File" "Successfully"

    fi
    exit 0
else
    notify-send -i "screenrecorder" -a "wl-screenrec" "Recording started"
    # gpu-screen-recorder -w screen -i "screenrecorder" -ac opus -cr full -a default_output -f 60 -fm vfr -o "$output_file" 2>/dev/null
    wf-recorder -f "$output_file" -r 60 -i "screenrecorder" -a=$audiodev -g "$(slurp -d)" 2>/dev/null

fi


# wl-screenrec --i "screenrecorder" -audio --audio-device "$audiodev" -f "$output_file" -g "$(slurp -d)" 2>/dev/null







