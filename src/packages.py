import json
import os
from pathlib import Path
from typing import Dict, List, Literal, Tuple

from .cmd import run_command
from .logs import logger


def get_toolchain_json(file_path: Path) -> Tuple[List[Dict], List[Dict]]:
    """Read and parse the toolchain JSON file.

    Parameters
    ----------
    file_path : Path
        Path to the toolchain JSON file

    Returns
    -------
    Tuple[List[Dict], List[Dict]]
        Returns a tuple containing:
        - List of toolchain dictionaries
        - List of package dictionaries

    Raises
    ------
    Exception
        If JSON file cannot be read or parsed
    """
    try:
        with open(file_path) as f:
            data = json.load(f)
        return data.get("tool", []), data.get("pkg", [])
    except Exception as e:
        logger.critical(f"Failed to parse toolchain JSON: {str(e)}")
        raise


def install_pkgs(file_path: Path, dry_run: bool = False) -> Literal[0, 1]:
    """Install toolchains and packages.

    Parameters
    ----------
    file_path : Path
        Path to the toolchain JSON file
    dry_run : bool
        If True, only log actions without executing them

    Returns
    -------
    int
        0 if any installations succeeded (or dry run)
        1 if all installations failed
    """
    toolchains, packages = get_toolchain_json(file_path)
    success = False

    # Install toolchains
    logger.info("Installing toolchains...")
    for tool in toolchains:
        name = tool.get("name", "Unknown")
        install_cmd = tool.get("install")

        if not install_cmd:
            logger.warning(f"No install command found for {name}")
            continue

        logger.info(f"Installing {name}...")
        result = run_command(install_cmd, dry_run=dry_run)
        if result["returncode"] == 0:
            logger.info(f"Successfully installed {name}")
            success = True
        else:
            logger.error(f"Failed to install {name}")

    # Install packages
    logger.info("Installing packages...")
    for pkg in packages:
        name = pkg.get("name", "Unknown")
        commands = pkg.get("command", [])
        pkg_path = pkg.get("path")

        if pkg_path:
            full_path = Path(file_path).parent / pkg_path
            if not full_path.exists():
                logger.error(f"Package path not found for {name}: {full_path}")
                continue
        else:
            full_path = None

        for cmd in commands:
            if "install" in cmd.lower():
                logger.info(f"Running {name} install command: {cmd}")
                result = run_command(cmd, cwd=full_path, dry_run=dry_run)
                if result["returncode"] == 0:
                    logger.info(f"Successfully ran {name} install command")
                    success = True
                else:
                    logger.error(f"Failed to run {name} install command")

    return 0 if (success or dry_run) else 1


def update_pkgs(file_path: Path, dry_run: bool = False) -> Literal[0, 1]:
    """Update toolchains and packages.

    Parameters
    ----------
    file_path : Path
        Path to the toolchain JSON file
    dry_run : bool
        If True, only log actions without executing them

    Returns
    -------
    int
        0 if any updates succeeded (or dry run)
        1 if all updates failed
    """
    toolchains, packages = get_toolchain_json(file_path)
    success = False

    # Update toolchains
    logger.info("Updating toolchains...")
    for tool in toolchains:
        name = tool.get("name", "Unknown")
        update_cmd = tool.get("update")

        if not update_cmd:
            logger.warning(f"No update command found for {name}")
            continue

        logger.info(f"Updating {name}...")
        result = run_command(update_cmd, dry_run=dry_run)
        if result["returncode"] == 0:
            logger.info(f"Successfully updated {name}")
            success = True
        else:
            logger.error(f"Failed to update {name}")

    # Update packages
    working_dir = Path(os.getcwd())
    logger.info("Updating packages...")
    for pkg in packages:
        name = pkg.get("name", "Unknown")
        commands = pkg.get("command", [])
        pkg_path = pkg.get("path")

        if pkg_path:
            full_path = Path(file_path).parent / pkg_path
            if not full_path.exists():
                logger.error(f"Package path not found for {name}: {full_path}")
                continue
        else:
            full_path = None

        for cmd in commands:
            logger.debug(f"Running {name} update command: {cmd}")
            result = run_command(cmd, cwd=full_path, dry_run=dry_run)
            if result["returncode"] == 0:
                logger.info(f"Successfully ran {name} update command")
                success = True
            else:
                logger.error(f"Failed to run {name} update command")

    return 0 if (success or dry_run) else 1

