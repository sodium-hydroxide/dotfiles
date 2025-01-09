import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Union

from .logs import logger


def run_command(
    cmd: Union[str, List[str]], cwd: Optional[Path] = None, dry_run: bool = False
) -> Dict[str, Union[int, str]]:
    """Execute a shell command and return its output.

    Parameters
    ----------
    cmd : Union[str, List[str]]
        Command to run, either as a string or list of strings
    cwd : Optional[Path]
        Working directory for command execution
    dry_run : bool
        If True, only log the command without executing it

    Returns
    -------
    Dict[str, Union[int, str]]
        Dictionary containing:
        - returncode: int, exit code of the command
        - stdout: str, standard output
        - stderr: str, error output
    """

    try:
        cmd_list = cmd.split() if isinstance(cmd, str) else cmd
        cmd_str = " ".join(cmd_list)

        if dry_run:
            logger.info(f"[DRY RUN] Would execute: {cmd_str}")
            return {"returncode": 0, "stdout": "", "stderr": ""}

        logger.debug(f"Executing command: {cmd_str}")

        result = subprocess.run(
            cmd_list,
            capture_output=True,
            text=True,
            cwd=cwd if cwd else None,
            shell=False,
        )

        # Log all output at debug level
        if result.stdout:
            logger.debug(f"stdout: {result.stdout}")
        if result.stderr:
            logger.debug(f"stderr: {result.stderr}")

        output = {
            "returncode": result.returncode,
            "stdout": result.stdout.strip(),
            "stderr": result.stderr.strip(),
        }

        if result.returncode != 0:
            logger.error(f"Command failed: {cmd_str}")
            if result.stderr:
                logger.error(f"Error output: {result.stderr}")
            if result.stdout:
                logger.error(f"Standard output: {result.stdout}")

        return output

    except Exception as e:
        logger.error(f"Failed to execute command '{cmd}': {str(e)}")
        return {"returncode": 1, "stdout": "", "stderr": str(e)}

