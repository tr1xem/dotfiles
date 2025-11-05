#!/usr/bin/env bash

LOG_FILE="$HOME/.cache/cloud_drives.log"
rm -rf "$LOG_FILE"
touch "$LOG_FILE"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Exponential backoff for Internet
sleep_time=30
max_sleep=300

while ! ping -c1 -W1 www.google.com &>/dev/null; do
    log "No internet – sleeping for ${sleep_time}s before retry..."
    sleep "$sleep_time"
    if (( sleep_time + 10 > max_sleep )); then
        sleep_time=$max_sleep
    else
        sleep_time=$((sleep_time + 10))
    fi
done

log "Internet OK."

# Ensure rclone is present
if ! command -v rclone &>/dev/null; then
    log "rclone not found!"
    exit 1
fi

# Define remotes and mount points
declare -A REMOTES=(
    [mega:]="$HOME/Clouds/Mega"
    [googledrive:]="$HOME/Clouds/GoogleDrive"
    [googlephotos:]="$HOME/Clouds/GooglePhotos"
    [protondrive:]="$HOME/Clouds/ProtonDrive"
)

# Common rclone opts as an array
RCLONE_OPTS=(
    --vfs-cache-mode full
    --vfs-cache-max-size 3G
    --vfs-read-chunk-size 10M
    --vfs-read-chunk-size-limit 100M
    --buffer-size 0M
    --allow-other
    --daemon
)

# Mount remotes in parallel
for remote in "${!REMOTES[@]}"; do
    (
        dir="${REMOTES[$remote]}"
        mkdir -p "$dir"

        if ! mountpoint -q "$dir"; then
            log "Mounting $remote → $dir"
            opts=( "${RCLONE_OPTS[@]}" )
            [[ "$remote" == "googlephotos:" ]] && opts+=(--gphotos-read-size)

            if rclone mount "$remote" "$dir" "${opts[@]}"; then
                log "$remote mounted on $dir"
            else
                log "Failed to mount $remote"
            fi
        else
            log "$dir already mounted"
        fi
    ) &
done

wait

