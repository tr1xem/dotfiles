#!/usr/bin/env bash
set -euo pipefail

KEYS_DIR="./keys"
VAULT_PREFIX="keys-vault"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

mkdir -p "$KEYS_DIR"

# --------------------------------------------------
# DECRYPT MODE
# --------------------------------------------------
if [[ "${1:-}" == "--decrypt" ]]; then
    echo "Decrypting latest vault..."

    LATEST=$(ls -t "$KEYS_DIR"/$VAULT_PREFIX-*.tar.gpg 2>/dev/null | head -n1)

    [[ -z "${LATEST:-}" ]] && {
        echo "No vault found."
        exit 1
    }

    echo "Using: $LATEST"

    gpg -d "$LATEST" | tar -xvf - -C "$KEYS_DIR"

    echo "✅ Extracted into $KEYS_DIR"
    exit 0
fi

# --------------------------------------------------
# ENCRYPT MODE
# --------------------------------------------------

echo "Creating encrypted snapshot..."

ARCHIVE="$KEYS_DIR/$VAULT_PREFIX-$TIMESTAMP.tar.gpg"

# Collect files except encrypted archives
mapfile -t FILES < <(
    find "$KEYS_DIR" \
        -mindepth 1 \
        ! -name "*.gpg" \
        -print | sort
)

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "Nothing to archive."
    exit 0
fi

echo "Packing + encrypting..."


tar -C "$KEYS_DIR" \
    --exclude="*.gpg" \
    -cf - . \
| gpg --symmetric --cipher-algo AES256 -o "$ARCHIVE"


echo "✅ Snapshot created:"
echo "   $ARCHIVE"

