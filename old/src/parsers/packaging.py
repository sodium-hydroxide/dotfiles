from argparse import ArgumentParser, _SubParsersAction

from .formatter import CustomHelpFormatter
from .types import PackageAction

PKG_DESCRIPTION = """
Manage system packages (Homebrew, NPM, Python packages)

Examples:
  %(prog)s brew update        Update all Homebrew packages
  %(prog)s npm update         Update global NPM packages
  %(prog)s pip reinstall      Reinstall all Python packages
"""


def package_manager_description(
    what_is_managed: str,
    what_is_updated: str,
    package_list_name: str,
    package_list_loc: str,
) -> str:
    """Generate a standardized description for package managers.

    Parameters
    ----------
    what_is_managed : str
        Description of what the package manager manages
    what_is_updated : str
        Description of what gets updated
    package_list_name : str
        Name of the file containing the package list
    package_list_loc : str
        Location of the package list file relative to lib/pkgs/

    Returns
    -------
    str
        Formatted description string for the package manager
    """
    return f"""
Manage {what_is_managed}

Actions:
  update    - Update {what_is_updated}
  reinstall - Reinstall all packages from {package_list_name}

The {package_list_name} is located at lib/pkgs/{package_list_loc}
"""


def create_specific_pkg_parser(
    pkg_subparsers: _SubParsersAction,
    cmd: str,
    help_str: str,
    what_is_managed: str,
    what_is_updated: str,
    package_list_name: str,
    package_list_loc: str,
) -> _SubParsersAction:
    """Create a specific package manager parser.

    Parameters
    ----------
    pkg_subparsers : _SubParsersAction
        The subparser to add the new parser to
    cmd : str
        The command name
    help_str : str
        Help string for the command
    what_is_managed : str
        Description of what is being managed
    what_is_updated : str
        Description of what is being updated
    package_list_name : str
        Name of the package list file
    package_list_loc : str
        Location of the package list file

    Returns
    -------
    _SubParsersAction
        The updated subparsers object
    """
    parser = pkg_subparsers.add_parser(
        cmd,
        help=help_str,
        description=package_manager_description(
            what_is_managed, what_is_updated, package_list_name, package_list_loc
        ),
        formatter_class=CustomHelpFormatter,
    )
    parser.add_argument(
        "action",
        choices=list(PackageAction.__args__),
        help=f"Action to perform on {what_is_managed}",
    )
    return pkg_subparsers


def create_pkg_parser(subparsers: _SubParsersAction) -> ArgumentParser:
    """Create the package management command parser.

    Parameters
    ----------
    subparsers : _SubParsersAction
        The main subparsers object

    Returns
    -------
    ArgumentParser
        The created package parser
    """
    pkg_parser = subparsers.add_parser(
        "pkg",
        help="Package management commands",
        description=PKG_DESCRIPTION,
        formatter_class=CustomHelpFormatter,
    )
    pkg_subparsers = pkg_parser.add_subparsers(
        dest="pkg_type",
        required=True,
        title="package managers",
        help="Available package managers",
    )

    # All packages subcommand
    all_pkg_parser = pkg_subparsers.add_parser(
        "all", help="Manage all package managers", formatter_class=CustomHelpFormatter
    )
    all_pkg_parser.add_argument(
        "action",
        choices=list(PackageAction.__args__),
        help="Action to perform on all package managers",
    )

    # Create specific package parsers
    create_specific_pkg_parser(
        pkg_subparsers,
        cmd="brew",
        help_str="Manage HomeBrew Packages",
        what_is_managed="Homebrew packages and casks",
        what_is_updated="Homebrew and all packages",
        package_list_name="Brewfiles",
        package_list_loc="brew/Brewfile",
    )
    create_specific_pkg_parser(
        pkg_subparsers,
        cmd="npm",
        help_str="Manage NPM Packages",
        what_is_managed="global NPM packages",
        what_is_updated="all global NPM packages",
        package_list_name="package list",
        package_list_loc="npm/npm.json",
    )
    create_specific_pkg_parser(
        pkg_subparsers,
        cmd="pip",
        help_str="Manage PyPI Packages",
        what_is_managed="PyPI packages",
        what_is_updated="all PyPI packages",
        package_list_name="requirements",
        package_list_loc="pip/pip.txt",
    )

    return pkg_parser
