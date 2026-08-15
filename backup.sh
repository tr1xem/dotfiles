#!/usr/bin/env bash
# dev-sync.sh — dotfiles + keys manager

set -euo pipefail

# --------------------------------------------------
# CONFIG
# --------------------------------------------------

KEYS_DIR="./keys"
VAULT_PREFIX="keys-vault"

TS_HUMAN=$(date '+%Y-%m-%d %I:%M:%S %p')
TS_SAFE=$(date '+%Y-%m-%d_%H-%M-%S')
COMMIT_MSG="Automated Dev Commit : $TS_HUMAN"

# --------------------------------------------------
# KEYS ENCRYPT
# --------------------------------------------------

encrypt_keys() {
    echo "🔐 Encrypting keys..."

    mkdir -p "$KEYS_DIR"

    TMP_ARCHIVE="/tmp/$VAULT_PREFIX-$TS_SAFE.tar.gpg"
    FINAL_ARCHIVE="$KEYS_DIR/$VAULT_PREFIX-$TS_SAFE.tar.gpg"

    tar -C "$KEYS_DIR" \
        --exclude="*.gpg" \
        -cf - . \
    | gpg --symmetric --cipher-algo AES256 -o "$TMP_ARCHIVE"

    mv "$TMP_ARCHIVE" "$FINAL_ARCHIVE"

    echo "✅ Created $FINAL_ARCHIVE"
}

# --------------------------------------------------
# KEYS DECRYPT
# --------------------------------------------------

decrypt_keys() {
    echo "🔓 Restoring keys..."

    LATEST=$(ls -t "$KEYS_DIR"/$VAULT_PREFIX-*.tar.gpg 2>/dev/null | head -n1 || true)

    [[ -z "${LATEST:-}" ]] && {
        echo "❌ No vault found"
        exit 1
    }

    echo "Using $LATEST"

    gpg -d "$LATEST" | tar -xvf - -C "$KEYS_DIR"

    echo "✅ Keys restored"
}

# --------------------------------------------------
# COMMIT SUBMODULES + MAIN REPO
# --------------------------------------------------

commit_all() {

    echo "📦 Processing submodules..."

    git submodule foreach --recursive '
        echo "---- $name ----"

        # stage everything inside submodule
        git add -A

        # commit if needed
        if ! git diff-index --quiet HEAD --; then
            echo "Committing $name"
            git commit -sm "'"$COMMIT_MSG"'"
        else
            echo "No commit needed"
        fi

        # push if branch has upstream
        if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
            git push || echo "Push failed for $name"
        fi
    '

    echo "📌 Updating submodule pointers in main repo..."
    git add .

    echo "📦 Checking main repo..."

    if ! git diff-index --quiet HEAD --; then
        git commit -sm "$COMMIT_MSG"
    else
        echo "Main repo clean"
    fi

    echo "🚀 Pushing main repo..."
    git push
}

# --------------------------------------------------
# ARGUMENT PARSER
# --------------------------------------------------

case "${1:-}" in
    --encrypt)
        encrypt_keys
        ;;
    --decrypt)
        decrypt_keys
        ;;
    --commit)
        commit_all
        ;;
    *)
        echo "Usage:"
        echo "  $0 --encrypt   Encrypt keys"
        echo "  $0 --decrypt   Restore keys"
        echo "  $0 --commit    Commit + push all repos"
        exit 1
        ;;
esac

