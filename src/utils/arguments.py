import argparse

__all__ = ["create_parser"]

MAIN_DESCRIPTION = """
System configuration management tool for managing packages, configurations,
and macOS settings.

Common usage patterns:
  %(prog)s pkg brew update     - Update Homebrew packages
  %(prog)s pkg npm reinstall   - Reinstall all NPM packages
  %(prog)s config update       - Update configuration files
  %(prog)s mac update          - Apply macOS settings
"""

PKG_DESCRIPTION = """
Manage system packages (Homebrew, NPM, Python packages)

Examples:
  %(prog)s brew update        Update all Homebrew packages
  %(prog)s npm update         Update global NPM packages
  %(prog)s pip reinstall      Reinstall all Python packages
"""

BREW_DESCRIPTION = """
Manage Homebrew packages and casks

Actions:
  update    - Update Homebrew and all packages
  reinstall - Reinstall all packages from Brewfile

The Brewfile is located at lib/homebrew/Brewfile
"""

NPM_DESCRIPTION = """
Manage global NPM packages

Actions:
  update    - Update all global NPM packages
  reinstall - Reinstall all packages from package list

The package list is located at lib/packages/node.json
"""

PIP_DESCRIPTION = """
Manage Python packages

Actions:
  update    - Update all Python packages
  reinstall - Reinstall all packages from requirements

The requirements file is located at lib/packages/python.txt
"""

CONFIG_DESCRIPTION = """
Manage system and application configurations

Actions:
  update  - Update/install configuration files
  cleanup - Remove broken symlinks and backup files

Configuration files are stored in lib/config/
Backups are created automatically before any changes
"""

MACOS_DESCRIPTION = """
Manage macOS system settings

Actions:
  update - Apply macOS system settings
  revert - Revert to default macOS settings

Settings are defined in lib/macos/defaults.yaml
Backups of original settings are created before changes
"""

TOOL_DESCRIPTION = """
Manage development toolchains

Examples:
  %(prog)s tool python update   - Update Python and tools
  %(prog)s tool node reinstall  - Reinstall Node.js and tools
  %(prog)s tool julia update    - Update Julia and packages
  %(prog)s tool rust update     - Update Rust toolchain
"""

class CustomHelpFormatter(argparse.RawDescriptionHelpFormatter):
    """Custom formatter that maintains formatting but adjusts indentation"""
    def __init__(self, prog):
        super().__init__(prog, max_help_position=40, width=80)

def create_parser() -> argparse.ArgumentParser:
    """Create and return the argument parser with detailed help messages"""

    parser = argparse.ArgumentParser(
        description=MAIN_DESCRIPTION,
        formatter_class=CustomHelpFormatter
    )

    # Global options
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose output with detailed logging"
    )
    parser.add_argument(
        "-d", "--dry-run",
        action="store_true",
        help="Show what would be done without making any changes"
    )

    # Create subcommand parsers
    subparsers = parser.add_subparsers(
        dest="command",
        required=True,
        title="commands",
        help="Available commands"
    )

    # Package management (pkg) command
    pkg_parser = subparsers.add_parser(
        "pkg",
        help="Package management commands",
        description=PKG_DESCRIPTION,
        formatter_class=CustomHelpFormatter
    )
    pkg_subparsers = pkg_parser.add_subparsers(
        dest="pkg_type",
        required=True,
        title="package managers",
        help="Available package managers"
    )

    # All packages subcommand
    all_pkg_parser = pkg_subparsers.add_parser(
        "all",
        help="Manage all package managers",
        formatter_class=CustomHelpFormatter
    )
    all_pkg_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on all package managers"
    )

    # Brew subcommand
    brew_parser = pkg_subparsers.add_parser(
        "brew",
        help="Manage Homebrew packages",
        description=BREW_DESCRIPTION,
        formatter_class=CustomHelpFormatter
    )
    brew_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on Homebrew packages"
    )

    # NPM subcommand
    npm_parser = pkg_subparsers.add_parser(
        "npm",
        help="Manage NPM packages",
        description=NPM_DESCRIPTION,
        formatter_class=CustomHelpFormatter
    )
    npm_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on NPM packages"
    )

    # Pip subcommand
    pip_parser = pkg_subparsers.add_parser(
        "pip",
        help="Manage Python packages",
        description=PIP_DESCRIPTION,
        formatter_class=CustomHelpFormatter
    )
    pip_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on Python packages"
    )

    # Config command
    config_parser = subparsers.add_parser(
        "config",
        help="Configuration management commands",
        description=CONFIG_DESCRIPTION,
        formatter_class=CustomHelpFormatter
    )
    config_parser.add_argument(
        "action",
        choices=["update", "cleanup"],
        help="Action to perform on configurations"
    )

    # macOS command
    mac_parser = subparsers.add_parser(
        "mac",
        help="macOS system settings",
        description=MACOS_DESCRIPTION,
        formatter_class=CustomHelpFormatter
    )
    mac_parser.add_argument(
        "action",
        choices=["update", "revert"],
        help="Action to perform on macOS settings"
    )

    # Tool management
    tool_parser = subparsers.add_parser(
        "tool",
        help="Development toolchain management",
        description=TOOL_DESCRIPTION,
        formatter_class=CustomHelpFormatter
    )
    tool_subparsers = tool_parser.add_subparsers(
        dest="tool_type",
        required=True,
        title="toolchains",
        help="Available toolchains"
    )

    # All toolchains subcommand
    all_tool_parser = tool_subparsers.add_parser(
        "all",
        help="Manage all toolchains",
        formatter_class=CustomHelpFormatter
    )
    all_tool_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on all toolchains"
    )

    # Python toolchain
    python_parser = tool_subparsers.add_parser(
        "python",
        help="Manage Python toolchain",
        formatter_class=CustomHelpFormatter
    )
    python_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on Python toolchain"
    )

    # Node.js toolchain
    node_parser = tool_subparsers.add_parser(
        "node",
        help="Manage Node.js toolchain",
        formatter_class=CustomHelpFormatter
    )
    node_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on Node.js toolchain"
    )

    # Julia toolchain
    julia_parser = tool_subparsers.add_parser(
        "julia",
        help="Manage Julia toolchain",
        formatter_class=CustomHelpFormatter
    )
    julia_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on Julia toolchain"
    )

    # Rust toolchain
    rust_parser = tool_subparsers.add_parser(
        "rust",
        help="Manage Rust toolchain",
        formatter_class=CustomHelpFormatter
    )
    rust_parser.add_argument(
        "action",
        choices=["update", "reinstall"],
        help="Action to perform on Rust toolchain"
    )

    return parser
