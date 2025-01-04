from typing import Literal

from .utils.logs import setup_logging, logger
from .parsers import create_parser
from .utils.paths import get_paths
from .config.core import main_config
from .packaging import main_packaging
from .toolchains import main_toolchains
from .utils.edit import edit_in_nvim


def main() -> Literal[0, 1]:
    args = create_parser().parse_args()
    setup_logging(args.verbose)
    paths = get_paths()

    try:
        match args.command:
            case "config":
                options = CommandOptions(
                    action=args.action,
                    dry_run=args.dry_run,
                    verbose=args.verbose
                )
                return 0 if symlink_config(options, paths) else 1
            case "mac":
                from .macos import macos_config
                return 0 if macos_config(args, paths) else 1
            case "pkg":
                from .packaging import main_packaging
                return 0 if main_packaging(args, paths) else 1
            case "edit":
                from .utils.edit import edit_in_nvim
                return 0 if edit_in_nvim(paths.lib) else 1
            case _:
                return 1
    except Exception as e:
        logger.error(str(e), exc_info=args.verbose)
        return 1
