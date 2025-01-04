from argparse import Namespace
from typing import Literal, Protocol

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from .brew import brew_packaging
from .npm import npm_packaging
from .pip import pip_packaging


class PackageManager(Protocol):
    def update(self, dry_run: bool = False) -> bool:
        """Update packages"""
        ...

    def reinstall(self, dry_run: bool = False) -> bool:
        """Reinstall packages"""
        ...


def main_packaging(args: Namespace, paths: Paths) -> Literal[0, 1]:
    """Main entry point for package management"""
    logger.debug(f"Package management: {args.pkg_type} {args.action}")

    options = CommandOptions(
        action=args.action, dry_run=args.dry_run, verbose=args.verbose
    )

    if args.pkg_type == "all":
        # Run all package managers and check if all succeeded
        success = all(
            [
                brew_packaging(options, paths),
                pip_packaging(options, paths),
                npm_packaging(options, paths),
            ]
        )
        return 0 if success else 1

    elif args.pkg_type == "brew":
        return 0 if brew_packaging(options, paths) else 1
    elif args.pkg_type == "pip":
        return 0 if pip_packaging(options, paths) else 1
    elif args.pkg_type == "npm":
        return 0 if npm_packaging(options, paths) else 1

    return 1
