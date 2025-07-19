#!/bin/sh

# Check if at least one argument (URL) is provided
if [ -z "$2" ]; then
    echo "Usage: $0 <YouTube_URL> [output_filename]"
    exit 1
fi

URL="$1"
OUTPUT="$2"

# Define SponsorBlock categories to remove
SPONSORBLOCK_CATEGORIES="sponsor,selfpromo,interaction"

# Ensure output filename has .mkv extension
case "$OUTPUT" in
    *.mkv) ;;
    *) OUTPUT="${OUTPUT}.mkv" ;;
esac

yt-dlp \
    --sponsorblock-remove "$SPONSORBLOCK_CATEGORIES" \
    --write-subs \
    --write-auto-subs \
    --embed-subs \
    -f "bestvideo+bestaudio/best" \
    --remux-video mkv \
    -o "$OUTPUT" \
    "$URL"
