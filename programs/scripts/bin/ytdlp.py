#!/usr/bin/env python
import subprocess
import sys

SPONSORBLOCK_CATEGORIES = "sponsor,selfpromo,interaction"
FLAGS: tuple[str, ...] = (
    "--sponsorblock-remove",
    SPONSORBLOCK_CATEGORIES,
    "--write-subs",
    "--write-auto-subs",
    "--embed-subs-f",
    "bestvideo+bestaudio/best",
)


def clean_fname(file: str, /) -> str:
    if file.endswith(".mkv"):
        return file
    return f"{file}.mkv"


def run_ytdlp(url: str, file: str) -> None:
    command: list[str] = ["yt-dlp"] + list(FLAGS) + ["-o", file, url]
    subprocess.run(command)


def usage() -> str:
    return """\
ytdlp.py URL FILE

Positional Arguments:
\tURL\turl for youtube video
\tFILE\toutput file (.mkv format)

"""


def main():
    argv: list[str] = sys.argv
    argc: int = len(argv)
    if "-h" in argv or "--help" in argv:
        print(usage())
        return 0
    if argc != 3:
        print(usage())
        return 2
    url: str = argv[1]
    file: str = clean_fname(argv[2])
    run_ytdlp(url=url, file=file)
    return 0


if __name__ == "__main__":
    sys.exit(main())

"""

#!/bin/sh

# Check if at least one argument (URL) is provided
if [ -z "$2" ]; then
    echo "Usage: $0 <YouTube_URL> [output_filename]"
    exit 1
fi

URL="$1"
OUTPUT="$2"

# Define SponsorBlock categories to remove

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

"""
