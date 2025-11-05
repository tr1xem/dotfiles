#!/usr/bin/env bash
# commit-all.sh - Commit main repo and submodules automatically

set -e

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COMMIT_MSG="Automated Dev Commit : $TIMESTAMP"

echo "Staging main repo changes..."
git add .

# Stage and commit submodules
git submodule foreach --recursive '
  echo "Checking submodule: $name"
  git add -A
  if ! git diff-index --quiet HEAD --; then
      echo "Committing in submodule: $name"
      git commit -m "'"$COMMIT_MSG"'"
      # Optional: push submodule
      git push || echo "Push failed for submodule: $name"
  else
      echo "No changes in submodule: $name"
  fi
'

# Commit main repo if there are changes
if ! git diff-index --quiet HEAD --; then
    echo "Committing main repo..."
    git commit -m "$COMMIT_MSG"
fi

# Push main repo
git push

