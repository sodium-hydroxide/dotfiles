#! /usr/bin/env python3

import argparse
import logging
from pathlib import Path
from typing import Literal

from .arguments import get_args
from .config import apply_macos_settings, symlink_config_files
from .edit import edit_in_nvim
from .logs import setup_logging, logger
from .packages import update_pkgs, install_pkgs

DOTFILES_DIR = Path(__file__).resolve().parent.parent
LIB_PATH = DOTFILES_DIR / "lib"
MACOS_SETTINGS_PATH = LIB_PATH / "macos.jsonc"
CONFIG_FILES_PATH = LIB_PATH / "config"
PACKAGES_PATH = LIB_PATH / "pkgs" / "toolchain.jsonc"


def main_no_errors(args: argparse.Namespace) -> Literal[0, 1]:
    """Main loop for script if no exceptions are raised"""
    if args.command == "pkg":
        if args.pkg_command == "reinstall":
            return install_pkgs(PACKAGES_PATH, dry_run=args.dry_run)
        elif args.pkg_command == "update":
            return update_pkgs(PACKAGES_PATH, dry_run=args.dry_run)
        logger.error("Invalid package command")
        return 1

    elif args.command == "config":
        if not CONFIG_FILES_PATH.exists():
            logger.error(f"Config directory not found: {CONFIG_FILES_PATH}")
            return 1
        return symlink_config_files(CONFIG_FILES_PATH)

    elif args.command == "macos":
        if not MACOS_SETTINGS_PATH.exists():
            logger.error(f"macOS settings file not found: {MACOS_SETTINGS_PATH}")
            return 1
        return apply_macos_settings(MACOS_SETTINGS_PATH)
    elif args.command == "edit":
        if not LIB_PATH.exists():
            logger.error(f"Dotfiles lib path not found {LIB_PATH}")
            return 1
        return edit_in_nvim(LIB_PATH)
    logger.error(f"Unknown command: {args.command}")
    return 1


def main() -> Literal[0, 1]:
    """Main entry point for the script.

    Returns
    -------
    Literal[0, 1]
        0 for success, 1 for failure
    """
    args = get_args()

    log_level = (
        logging.WARNING
        if args.quiet
        else logging.DEBUG
        if args.verbose
        else logging.INFO
    )

    setup_logging(verbose=(log_level == logging.DEBUG))
    logger.info("Starting dotfiles management")

    try:
        return main_no_errors(args)
    except KeyboardInterrupt:
        logger.warning("Operation interrupted by user")
        return 1
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        if args.verbose:
            logger.exception("Detailed error information:")
        return 1

