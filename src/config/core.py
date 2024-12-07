from argparse import Namespace
from typing import Literal

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from .macos import macos_config
from .symlinks import symlink_config


def main_config(args: Namespace, paths: Paths) -> Literal[0, 1]:
    """Main entry point for configuration management"""
    try:
        logger.debug(f"Configuration management: {args.command} {args.action}")
        options = CommandOptions(
            action=args.action, dry_run=args.dry_run, verbose=args.verbose
        )

        if args.command == "config":
            return 0 if symlink_config(options, paths) else 1
        elif args.command == "mac":
            return 0 if macos_config(options, paths) else 1

        return 1
    except Exception as e:
        logger.error(f"Configuration failed: {e}")
        return 1
