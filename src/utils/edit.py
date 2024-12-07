import subprocess
from pathlib import Path
from typing import Literal

from .logs import logger


def edit_in_nvim(target: Path) -> Literal[0, 1]:
    """
    Open the target path in neovim

    Args:
        target (Path): The target path to edit

    Returns:
        Literal[0, 1]: 0 for success, 1 for failure
    """
    try:
        if not target.exists():
            logger.error(f"Path does not exist: {target}")
            return 1

        # Use nvim as configured in your environment
        result = subprocess.run(["nvim", str(target.absolute())])
        return result.returncode

    except Exception as e:
        logger.error(f"Failed to open editor: {e}")
        return 1
