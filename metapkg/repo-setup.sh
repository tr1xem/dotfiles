#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

set -euo pipefail

log() {
  echo -e "\n==> $1"
}

# ---- Chaotic-AUR ----

log "Importing Chaotic-AUR key"
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com

log "Locally signing key"
pacman-key --lsign-key 3056513887B78AEB

log "Installing Chaotic-AUR keyring + mirrorlist"
pacman -U --noconfirm \
  https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst \
  https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst

log "Adding Chaotic-AUR repo (if missing)"
if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then
  tee -a /etc/pacman.conf > /dev/null << 'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
else
  echo "==> Chaotic-AUR repo already present, skipping"
fi

# ---- CachyOS repo ----

log "Downloading CachyOS repo setup"
tmpdir=$(mktemp -d)
cd "$tmpdir"

curl -L https://mirror.cachyos.org/cachyos-repo.tar.xz -o cachyos-repo.tar.xz

log "Extracting archive"
tar xf cachyos-repo.tar.xz
cd cachyos-repo

log "Running CachyOS repo installer"
./cachyos-repo.sh

log "Cleaning up"
cd /
rm -rf "$tmpdir"

# ---- Final sync ----

log "Syncing pacman databases"
pacman -Sy

log "Done ✔"
