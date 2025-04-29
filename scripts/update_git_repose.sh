#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/path/to/repos" # change to your folder

find "$BASE_DIR" -maxdepth 1 -mindepth 1 -type d | while read -r dir; do
    if [ -d "$dir/.git" ]; then # skip anything that is not a Git repo
        echo "Updating $(basename "$dir")"
        git -C "$dir" pull --ff-only # fast-forward-only to avoid merge commits
    fi
done
