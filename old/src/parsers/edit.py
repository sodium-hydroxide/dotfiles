from argparse import _SubParsersAction

from .formatter import CustomHelpFormatter

__all__ = ["create_edit_parser"]

EDIT_DESCRIPTION = """
Edit the current settings:

The various settings are located in the `lib/` directory:
  lib/config - Configuration files for macOS and programs
  lib/pkgs   - Package lists for different package managers
"""


def create_edit_parser(subparsers: _SubParsersAction) -> _SubParsersAction:
    """Create the lib edit command parser

    Parameters
    ----------
    subparsers : _SubParsersAction
        The main subparsers object to add the edit parser to

    Returns
    -------
    _SubParsersAction
        The updated subparsers object with the edit parser added

    Notes
    -----
    Creates a parser that uses nvim to edit the lib directory
    """
    (
        subparsers.add_parser(
            "edit",
            help="Edit configuration files in `lib`",
            description=EDIT_DESCRIPTION,
            formatter_class=CustomHelpFormatter,
        )
    )
