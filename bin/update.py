#!/usr/bin/env python3

import argparse
import os
import shutil
import subprocess
import sys
import typing as tp
from pathlib import Path

HOME: tp.Final[Path] = Path(os.environ["HOME"])
DOTFILES_DIR: tp.Final[Path] = HOME / "dotfiles"
PACKAGE_LISTS: tp.Final[Path] = DOTFILES_DIR / "package-list"
PYPROJECT: tp.Final[Path] = PACKAGE_LISTS / "pyproject.toml"
PYTOOLS: tp.Final[Path] = PACKAGE_LISTS / "tool-list.txt"
BREWFILE: tp.Final[Path] = PACKAGE_LISTS / "Brewfile"

SYSTEM_PYTHON: tp.Final[Path] = Path("/opt") / "homebrew" / "bin" / "python3"
GLOBAL_VENV: tp.Final[Path] = HOME / ".local" / ".venv"
PYTHON: tp.Final[Path] = GLOBAL_VENV / "bin" / "python"


def check_cmd(cmd: str, hint: str | None = None) -> int:
    check = shutil.which(cmd)
    if check is None:
        hint = f'try adding brew "{cmd}" to Brewfile' if hint is None else hint
        print(
            f"'{cmd}' not found -- {hint}",
            file=sys.stderr
        )
        return 1
    return 0


def run_cmd(cmd: list[str] | str) -> int:
    if isinstance(cmd, str):
        cmd = [cmd]
    run = subprocess.run(
        cmd,
        stdout=sys.stdout,
        stderr=sys.stderr,
        stdin=sys.stdin
    )
    return run.returncode


def edit_dotfiles() -> int:
    editor = os.environ["EDITOR"]
    if check_cmd(editor):
        return 1
    return run_cmd([editor, DOTFILES_DIR.as_posix()])

def parse_args(argv: list[str]) -> argparse.ArgumentParser:
    progname = argv[0]
    parser = argparse.ArgumentParser(
        prog=progname,
        epilog="Re-stow dotfiles, update packages"
    )
    parser.add_argument(
        "-e", "--edit",
        action="store true",
        required=False,
        help="Edit the dotfiles using $EDITOR"
    )


    return parser

def main(argv: list[str]) -> int:
    argc = len(argv)
    parser = parse_args(argv)
    args = parser.parse_args()

    if argc == 1 and argv[0] in ("-h", "--help"):
        parser.print_help(file=sys.stdout)
        return 0

    if args.edit:
        return edit_dotfiles()

    return 0

if __name__=="__main__":
    sys.exit(main(sys.argv))
