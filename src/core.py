from typing import Literal

from .utils.logs import setup_logging, logger
from .parsers import create_parser
from .utils.paths import get_paths
from .config.core import main_config
from .packaging import main_packaging
from .toolchains import main_toolchains
from .utils.edit import edit_in_nvim


def main() -> Literal[0, 1]:
    """Main entry point"""

    args = create_parser().parse_args()
    setup_logging(args.verbose)
    paths = get_paths()

    try:
        logger.debug(f"Processing command: {args.command}")
        if args.command == "edit":
            edit_in_nvim(paths.lib)
        if args.command == "pkg":
            return main_packaging(args, paths)
        elif args.command in ["config", "mac"]:
            # Both config and mac commands are handled by config module
            return main_config(args, paths)
        elif args.command == "tool":
            return main_toolchains(args, paths)
        return 1
    except Exception as e:
        if args.verbose:
            logger.error(f"Error details: {str(e)}", exc_info=True)
        else:
            logger.error(str(e))
        return 1

