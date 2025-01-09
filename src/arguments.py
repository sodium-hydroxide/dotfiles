#! /usr/bin/env python3

import argparse
import sys


def add_verbosity(parser: argparse.ArgumentParser) -> argparse.ArgumentParser:
    verbosity = parser.add_mutually_exclusive_group()
    verbosity.add_argument(
        "-v", "--verbose", action="store_true", help="Verbose (debug level) output"
    )
    verbosity.add_argument(
        "-q", "--quiet", action="store_true", help="Suppress non error messages"
    )
    return parser


def add_actions(parser: argparse.ArgumentParser) -> argparse.ArgumentParser:
    subparsers = parser.add_subparsers(dest="command", required=True)

    edit_parser = subparsers.add_parser(
        "edit",
        help="Edit configuration files",
        description="Edit config files in NeoVim",
    )
    macos_parser = subparsers.add_parser(
        "macos",
        help="macOS related commands",
        description="Configure macOS system settings",
    )

    config_parser = subparsers.add_parser(
        "config",
        help="Configuration commands",
        description="Manage configuration files and symlinks",
    )

    pkg_parser = subparsers.add_parser(
        "pkg", help="Package management commands", description="Manage system packages"
    )
    pkg_subparsers = pkg_parser.add_subparsers(dest="pkg_command", required=True)

    pkg_subparsers.add_parser("update", help="Update installed packages")
    pkg_subparsers.add_parser("reinstall", help="Reinstall packages from configuration")

    return parser


def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Manage dotfiles, packages, and macOS settings",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making actual changes",
    )
    add_verbosity(parser)
    add_actions(parser)

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)

    return parser.parse_args()

