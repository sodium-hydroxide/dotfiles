#!/usr/bin/env python3
"""open macos applications"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

OPEN_CMD = Path("/usr") / "bin" / "open"
MODES: dict[str, list[Path | str]] = {
    "open": [OPEN_CMD],
    "code": [Path("/opt") / "homebrew" / "bin" / "code"],
    "term": [OPEN_CMD, "-na", "Ghostty", "--args"],
    "nvim": [OPEN_CMD, "-na", "Ghostty", "--args", "nvim"],
    "app": [OPEN_CMD, "-a"],
}


def get_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()

    flags = parser.add_mutually_exclusive_group(required=False)
    flags.add_argument(
        "-t",
        "--term",
        action="store_true",
        help="Run command in terminal emulator",
    )
    flags.add_argument(
        "-n",
        "--nvim",
        action="store_true",
        help="Open file or directory in neovim",
    )
    flags.add_argument(
        "-a",
        "--app",
        action="store_true",
        help="Open applications from /Applications/",
    )
    flags.add_argument(
        "-c",
        "--code",
        action="store_true",
        help="Open file or directory in VSCode",
    )
    parser.add_argument(
        "args",
        nargs="*",
        help="Files, directories, or commands to be passed based on the flag used",
    )
    return parser


def resolve_mode(args: argparse.Namespace) -> str:
    for flag, name in {
        "code": "code",
        "nvim": "nvim",
        "term": "term",
        "app": "app",
    }.items():
        if getattr(args, flag):
            return name
    return "open"


def main(argv: list[str] | tuple[str, ...]) -> int:
    args: argparse.Namespace = get_parser().parse_args(argv)
    mode = resolve_mode(args)
    cmd = [str(x) for x in MODES[mode]] + list(args.args)
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(
            f"Error: command failed with exit code {e.returncode}",
            file=sys.stderr,
        )
        return e.returncode
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
