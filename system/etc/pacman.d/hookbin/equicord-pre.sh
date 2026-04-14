#!/bin/sh

set -e

trap 'echo "An error occurred, please contact the package maintainer: https://aur.archlinux.org/packages/equicord-hook"' ERR

# Kill running Discord instances
pkill -x discord 2>/dev/null || true
pkill -x Discord 2>/dev/null || true
sleep 1

# Temp installer
installer=$(mktemp /tmp/equicord.XXXXXX)
trap 'rm -f "$installer"' EXIT

curl -sSL https://github.com/Equicord/Installer/releases/latest/download/EquilotlCli-linux \
    --output "$installer" < /dev/null

chmod +x "$installer"

# Process pacman targets
while IFS= read -r package || [ -n "$package" ]; do
    branch=$(echo "$package" | sed 's/^discord$/stable/; s/^discord-//')

    [ -z "$branch" ] && branch="stable"

    echo "Uninstalling Equicord for $branch branch..."
    "$installer" -uninstall -branch "$branch" < /dev/null || {
        echo "Falling back to auto branch..."
        "$installer" -uninstall -branch auto < /dev/null
    }

    echo "Uninstalling OpenAsar for $branch branch..."
    "$installer" -uninstall-openasar -branch "$branch" < /dev/null || {
        echo "Falling back to auto branch..."
        "$installer" -uninstall-openasar -branch auto < /dev/null
    }

done
