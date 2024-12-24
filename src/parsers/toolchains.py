from argparse import ArgumentParser, _SubParsersAction

from .formatter import CustomHelpFormatter
from .types import ToolchainAction

__all__ = ["create_toolchain_parser"]

TOOL_DESCRIPTION = """
Manage development toolchains

Examples:
  %(prog)s tool python update   - Update Python and tools
  %(prog)s tool node reinstall  - Reinstall Node.js and tools
  %(prog)s tool julia update    - Update Julia and packages
  %(prog)s tool rust update     - Update Rust toolchain
"""


def create_specific_toolchain_parser(
    toolchain_subparsers: _SubParsersAction, cmd: str, toolchain_name: str
) -> _SubParsersAction:
    """Create a parser for a specific toolchain.

    Parameters
    ----------
    toolchain_subparsers : _SubParsersAction
        Toolchain subparser to add to
    cmd : str
        Command name for toolchain (e.g., 'python', 'node')
    toolchain_name : str
        Display name for toolchain in help documents (e.g., 'Python', 'Node.js')

    Returns
    -------
    _SubParsersAction
        Updated toolchain subparser with the new toolchain added

    Notes
    -----
    Creates a parser for a specific development toolchain
    with two possible actions:
        - update: Update the toolchain and its associated tools
        - reinstall: Completely reinstall the toolchain
    """
    (
        toolchain_subparsers.add_parser(
            cmd,
            help=f"Manage {toolchain_name} toolchain",
            formatter_class=CustomHelpFormatter,
        ).add_argument(
            "action",
            choices=list(ToolchainAction.__args__),
            help=f"Action to perform on {toolchain_name} toolchain",
        )
    )
    return toolchain_subparsers


def create_toolchain_parser(subparsers: _SubParsersAction) -> ArgumentParser:
    """Create the toolchain management command parser.

    Parameters
    ----------
    subparsers : _SubParsersAction
        The main subparsers object

    Returns
    -------
    ArgumentParser
        The created toolchain parser

    Notes
    -----
    Creates the main toolchain parser with subparsers for each supported
    development toolchain (Python, Node.js, Julia, Rust) and an 'all'
    option to manage all toolchains at once.
    """
    toolchain_parser = subparsers.add_parser(
        "tool",
        help="Development toolchain management",
        description=TOOL_DESCRIPTION,
        formatter_class=CustomHelpFormatter,
    )
    toolchain_subparsers = toolchain_parser.add_subparsers(
        dest="tool_type", required=True, title="toolchains", help="Available toolchains"
    )

    # Create 'all' toolchains parser
    all_toolchain_parser = toolchain_subparsers.add_parser(
        "all", help="Manage all toolchains", formatter_class=CustomHelpFormatter
    )
    all_toolchain_parser.add_argument(
        "action",
        choices=list(ToolchainAction.__args__),
        help="Action to perform on all toolchains",
    )

    # Create individual toolchain parsers
    create_specific_toolchain_parser(
        toolchain_subparsers, cmd="python", toolchain_name="Python"
    )
    create_specific_toolchain_parser(
        toolchain_subparsers, cmd="node", toolchain_name="Node.js"
    )
    create_specific_toolchain_parser(
        toolchain_subparsers, cmd="julia", toolchain_name="Julia"
    )
    create_specific_toolchain_parser(
        toolchain_subparsers, cmd="rust", toolchain_name="Rust"
    )
    create_specific_toolchain_parser(
        toolchain_subparsers, cmd="haskell", toolchain_name="Haskell"
    )

    return toolchain_parser
