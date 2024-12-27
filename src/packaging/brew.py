from pathlib import Path

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from ..utils.shell import check_command_exists, run_shell_command


def ensure_homebrew() -> bool:
    """Ensure Homebrew is installed"""
    if check_command_exists("brew"):
        return True

    logger.info("Installing Homebrew...")
    cmd = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    result = run_shell_command(cmd, shell=True, capture_output=True)

    if result.returncode != 0:
        logger.error(f"Failed to install Homebrew: {result.stderr}")
        return False

    return True


def update_brew(brewfile: Path, dry_run: bool = False) -> bool:
    """Update Homebrew and packages"""
    if dry_run:
        logger.info("Would update Homebrew and packages")
        return True

    if not ensure_homebrew():
        return False

    # Update Homebrew itself
    logger.info("Updating Homebrew...")
    result = run_shell_command(["brew", "update"], capture_output=True)
    if result.returncode != 0:
        logger.error(f"Failed to update Homebrew: {result.stderr}")
        return False

    # Update packages
    logger.info("Updating Homebrew packages...")
    result = run_shell_command(
        ["brew", "bundle", "--file", str(brewfile), "--cleanup"], capture_output=True
    )
    if result.returncode != 0:
        logger.error(f"Failed to update Homebrew packages: {result.stderr}")
        return False

    logger.info("Running Homebrew cleanup...")
    run_shell_command(["brew", "cleanup"], capture_output=True)

    return True


def reinstall_brew(brewfile: Path, dry_run: bool = False) -> bool:
    """Reinstall all Homebrew packages"""
    if dry_run:
        logger.info("Would reinstall all Homebrew packages")
        return True

    if not ensure_homebrew():
        return False

    logger.info("Reinstalling all Homebrew packages...")
    result = run_shell_command(
        ["brew", "bundle", "--file", str(brewfile), "--force"], capture_output=True
    )

    if result.returncode != 0:
        logger.error(f"Failed to reinstall Homebrew packages: {result.stderr}")
        return False

    return True


def brew_packaging(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for Homebrew package management"""
    brewfile = paths.pkgs / "brew" / "Brewfile"

    if not brewfile.exists():
        logger.error(f"Brewfile not found at: {brewfile}")
        return False

    if options.action == "update":
        return update_brew(brewfile, options.dry_run)
    elif options.action == "reinstall":
        return reinstall_brew(brewfile, options.dry_run)

    return False

