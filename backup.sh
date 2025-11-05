#!/usr/bin/env bash
# commit-all.sh - Commit main repo and submodules automatically using 'git add .'

# Exit on error
set -e

# Get timestamp for commit message
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COMMIT_MSG="Automated Dev Commit : $TIMESTAMP"

# Stage changes in main repo
git add .

# Stage changes in all submodules
git submodule foreach --recursive 'git add .'

# Commit main repo
git commit -m "$COMMIT_MSG"

# Commit submodules if they have changes
git submodule foreach --recursive '
if ! git diff-index --quiet HEAD --; then
    git commit -m "'"$COMMIT_MSG"'"
    git push
fi
'
git push

