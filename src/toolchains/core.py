from pathlib import Path
from typing import Protocol, Literal
from argparse import Namespace
from ..utils.logs import logger
from ..utils.paths import Paths
from ..utils.options import CommandOptions

from .bash import bash_toolchain
from .uvpython import uvpython_toolchain
from .nvm import nvm_toolchain
from .juliaup import juliaup_toolchain
from .rustup import rustup_toolchain

class ToolchainManager(Protocol):
    def update(self, dry_run: bool = False) -> bool:
        """Update toolchain and packages"""
        ...

    def reinstall(self, dry_run: bool = False) -> bool:
        """Reinstall toolchain and packages"""
        ...

def main_toolchains(args: Namespace, paths: Paths) -> Literal[0, 1]:
    """Main entry point for toolchain management"""
    logger.debug(f"Toolchain management: {args.tool_type} {args.action}")

    options = CommandOptions(
        action=args.action,
        dry_run=args.dry_run,
        verbose=args.verbose
    )

    if args.tool_type == "all":
        # Run all toolchains and check if all succeeded
        success = all([
            bash_toolchain(options, paths),
            uvpython_toolchain(options, paths),
            nvm_toolchain(options, paths),
            juliaup_toolchain(options, paths),
            rustup_toolchain(options, paths)
        ])
        return 0 if success else 1

    elif args.tool_type == "bash":
        return 0 if bash_toolchain(options, paths) else 1
    elif args.tool_type == "python":
        return 0 if uvpython_toolchain(options, paths) else 1
    elif args.tool_type == "node":
        return 0 if nvm_toolchain(options, paths) else 1
    elif args.tool_type == "julia":
        return 0 if juliaup_toolchain(options, paths) else 1
    elif args.tool_type == "rust":
        return 0 if rustup_toolchain(options, paths) else 1

    return 1
