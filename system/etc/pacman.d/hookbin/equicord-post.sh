#!/bin/sh

set -e

trap 'echo "An error occurred, please contact the package maintainer: https://aur.archlinux.org/packages/equicord-hook"' ERR

pkill -x discord 2>/dev/null || true
pkill -x Discord 2>/dev/null || true
sleep 1

installer=$(mktemp /tmp/equicord.XXXXXX)
trap 'rm -f "$installer"' EXIT

curl -sSL https://github.com/Equicord/Installer/releases/latest/download/EquilotlCli-linux \
    --output "$installer" < /dev/null

chmod +x "$installer"

while IFS= read -r package || [ -n "$package" ]; do
    branch=$(echo "$package" | sed 's/^discord$/stable/; s/^discord-//')

    [ -z "$branch" ] && branch="stable"

    echo "Installing Equicord for $branch branch..."
    "$installer" -install -branch "$branch" < /dev/null || {
        echo "Falling back to auto branch..."
        "$installer" -install -branch auto < /dev/null
    }

    echo "Installing OpenAsar for $branch branch..."
    "$installer" -install-openasar -branch "$branch" < /dev/null
done
