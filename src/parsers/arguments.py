from argparse import ArgumentParser

from .config import create_config_parser
from .edit import create_edit_parser
from .formatter import CustomHelpFormatter
from .macos import create_macos_parser
from .packaging import create_pkg_parser
from .toolchains import create_toolchain_parser

__all__ = ["create_parser"]

MAIN_DESCRIPTION = """
System configuration management tool for managing packages, configurations,
and macOS settings.

Common usage patterns:
  %(prog)s pkg brew update     - Update Homebrew packages
  %(prog)s pkg npm reinstall   - Reinstall all NPM packages
  %(prog)s config update       - Update configuration files
  %(prog)s mac update          - Apply macOS settings
  %(prog)s edit                - Edit library files
"""


def set_global_flags(parser: ArgumentParser) -> ArgumentParser:
    """Set verbose and dry run options for main program

    Parameters
    ----------
    parser : ArgumentParser
        Main parser to add -v and -d flags for

    Returns
    -------
    ArgumentParser
        Original parser with new -v and -d flags

    Notes
    -----
    Adds in global settings for:
        -v, --verbose : Print all debug messages
        -d, --dry-run : Test commands without running them
    """

    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Enable verbose output with detailed logging",
    )
    parser.add_argument(
        "-d",
        "--dry-run",
        action="store_true",
        help="Show what would be done without making any changes",
    )
    return parser


def create_parser() -> ArgumentParser:
    """Create and return the argument parser with detailed help messages"""

    parser = ArgumentParser(
        description=MAIN_DESCRIPTION, formatter_class=CustomHelpFormatter
    )
    set_global_flags(parser)

    subparsers = parser.add_subparsers(
        dest="command", required=True, title="commands", help="Available commands"
    )
    create_edit_parser(subparsers)
    create_pkg_parser(subparsers)
    create_config_parser(subparsers)
    create_macos_parser(subparsers)
    create_toolchain_parser(subparsers)

    return parser

