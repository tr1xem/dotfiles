#!/usr/bin/env bash
# local-setup.sh
# Build PKGBUILDs without dependencies and update local repo at /opt/trix-repo

set -euo pipefail

REPO_DIR="/opt/trix-repo"
mkdir -p "$REPO_DIR"

echo "=== Building packages and updating local repo (no dependency checks) ==="

# Loop over all package-* files
for PKGFILE in ./package-*; do
    if [[ -f "$PKGFILE" ]]; then
        echo "[INFO] Building package $PKGFILE (without deps)..."
        
        # Create temp build dir
        TMPDIR=$(mktemp -d)
        cp "$PKGFILE" "$TMPDIR/PKGBUILD"
        pushd "$TMPDIR" >/dev/null

        # Build package without dependency checks and without confirmation
        makepkg --clean --force --nodeps --noconfirm

        # Move built package(s) to repo
        for PKG in ./*.pkg.tar.zst; do
            echo "[INFO] Moving $PKG to $REPO_DIR"
            sudo cp "$PKG" "$REPO_DIR/"
        done

        popd >/dev/null
        rm -rf "$TMPDIR"
    fi
done

# Generate local repo database
echo "=== Updating local repo database ==="
pushd "$REPO_DIR" >/dev/null
sudo repo-add trix.db.tar.gz ./*.pkg.tar.zst
popd >/dev/null

echo "=== Local repo updated at $REPO_DIR ==="
echo "Add the following to /etc/pacman.conf if not already present:"
echo "[trix]"
echo "SigLevel = Optional TrustAll"
echo "Server = file://$REPO_DIR"
echo "Run 'sudo pacman -Sy' to refresh databases."
