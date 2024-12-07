from argparse import _SubParsersAction

from .formatter import CustomHelpFormatter
from .types import MacosAction

MACOS_DESCRIPTION = """
Manage macOS system settings

Actions:
  update - Apply macOS system settings
  revert - Revert to default macOS settings

Settings are defined in lib/macos/defaults.yaml
Backups of original settings are created before changes
"""


def create_macos_parser(subparsers: _SubParsersAction) -> _SubParsersAction:
    """Create the macOS settings management command parser.

    Parameters
    ----------
    subparsers : _SubParsersAction
        The main subparsers object to add the macOS parser to

    Returns
    -------
    _SubParsersAction
        The updated subparsers object with the macOS parser added

    Notes
    -----
    Creates a parser for managing macOS system settings
    with two possible actions:
        - update: Apply macOS system settings from defaults.yaml
        - revert: Restore original macOS system settings from backup
    """
    (
        subparsers.add_parser(
            "mac",
            help="macOS system settings",
            description=MACOS_DESCRIPTION,
            formatter_class=CustomHelpFormatter,
        ).add_argument(
            "action",
            choices=list(MacosAction.__args__),
            help="Action to perform on macOS settings",
        )
    )
    return subparsers
