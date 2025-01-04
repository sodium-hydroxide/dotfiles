from pathlib import Path

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from ..utils.shell import check_command_exists, run_shell_command


def ensure_pip() -> bool:
    """Ensure pip is installed and up to date"""
    if not check_command_exists("pip"):
        logger.error("pip not found. Please install Python first.")
        return False

    # Upgrade pip itself
    result = run_shell_command(
        ["pip", "install", "--upgrade", "pip"], capture_output=True
    )

    if result.returncode != 0:
        logger.error(f"Failed to upgrade pip: {result.stderr}")
        return False

    return True


def update_pip(requirements: Path, dry_run: bool = False) -> bool:
    """Update pip packages"""
    if dry_run:
        logger.info("Would update pip packages")
        return True

    if not ensure_pip():
        return False

    # Update all packages from requirements file
    logger.info("Updating pip packages...")
    result = run_shell_command(
        ["pip", "install", "--upgrade", "-r", str(requirements)], capture_output=True
    )

    if result.returncode != 0:
        logger.error(f"Failed to update pip packages: {result.stderr}")
        return False

    return True


def reinstall_pip(requirements: Path, dry_run: bool = False) -> bool:
    """Reinstall all pip packages"""
    if dry_run:
        logger.info("Would reinstall all pip packages")
        return True

    if not ensure_pip():
        return False

    # First uninstall all packages from requirements
    logger.info("Uninstalling existing pip packages...")
    result = run_shell_command(
        ["pip", "uninstall", "-y", "-r", str(requirements)], capture_output=True
    )

    # Install packages from requirements file
    logger.info("Reinstalling pip packages...")
    result = run_shell_command(
        ["pip", "install", "-r", str(requirements)], capture_output=True
    )

    if result.returncode != 0:
        logger.error(f"Failed to reinstall pip packages: {result.stderr}")
        return False

    return True


def pip_packaging(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for pip package management"""
    requirements = paths.pkgs / "pip" / "pip.txt"

    if not requirements.exists():
        logger.error(f"Requirements file not found at: {requirements}")
        return False

    if options.action == "update":
        return update_pip(requirements, options.dry_run)
    elif options.action == "reinstall":
        return reinstall_pip(requirements, options.dry_run)

    return False
