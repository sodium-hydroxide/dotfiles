from argparse import _SubParsersAction

from .formatter import CustomHelpFormatter
from .types import ConfigAction

__all__ = ["create_config_parser"]

CONFIG_DESCRIPTION = """
Manage system and application configurations

Actions:
  update  - Update/install configuration files
  cleanup - Remove broken symlinks and backup files

Configuration files are stored in lib/config/
Backups are created automatically before any changes
"""


def create_config_parser(subparsers: _SubParsersAction) -> _SubParsersAction:
    """Create the configuration management command parser.

    Parameters
    ----------
    subparsers : _SubParsersAction
        The main subparsers object to add the config parser to

    Returns
    -------
    _SubParsersAction
        The updated subparsers object with the config parser added

    Notes
    -----
    Creates a parser for managing system and application configurations
    with two possible actions:
        - update: Update/install configuration files
        - cleanup: Remove broken symlinks and backup files
    """
    (
        subparsers.add_parser(
            "config",
            help="Configuration management commands",
            description=CONFIG_DESCRIPTION,
            formatter_class=CustomHelpFormatter,
        ).add_argument(
            "action",
            choices=list(ConfigAction.__args__),
            help="Action to perform on configurations",
        )
    )
    return subparsers
