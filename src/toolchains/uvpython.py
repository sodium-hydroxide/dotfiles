import os
from pathlib import Path

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from ..utils.shell import check_command_exists, run_shell_command

VENV_PATH = Path.home() / ".venv"


def install_uv(dry_run: bool = False) -> bool:
    """Install or update uv"""
    if dry_run:
        logger.info("Would install/update uv")
        return True

    logger.info("Installing/updating uv...")
    cmd = "curl -LsSf https://astral.sh/uv/install.sh | sh"
    result = run_shell_command(cmd, shell=True, capture_output=True)

    if result.returncode != 0:
        logger.error(f"Failed to install uv: {result.stderr}")
        return False

    return True


def create_venv(dry_run: bool = False) -> bool:
    """Create virtual environment using uv"""
    if dry_run:
        logger.info(f"Would create virtual environment at {VENV_PATH}")
        return True

    if not check_command_exists("uv"):
        logger.error("uv not found. Please install it first.")
        return False

    # Create virtual environment
    logger.info("Creating virtual environment...")
    result = run_shell_command(["uv", "venv", str(VENV_PATH)], capture_output=True)

    if result.returncode != 0:
        logger.error(f"Failed to create virtual environment: {result.stderr}")
        return False

    return True


def install_base_packages(dry_run: bool = False) -> bool:
    """Install base Python packages"""
    if dry_run:
        logger.info("Would install base Python packages")
        return True

    # List of base packages to install
    packages = ["pip", "ruff", "mypy", "ipython", "jupyter", "build", "requests"]

    # Activate virtual environment
    venv_python = VENV_PATH / "bin" / "python"
    if not venv_python.exists():
        logger.error("Virtual environment not found")
        return False

    # Install packages
    logger.info("Installing base Python packages...")
    result = run_shell_command(
        [str(venv_python), "-m", "uv", "pip", "install", "--upgrade", *packages],
        capture_output=True,
    )

    if result.returncode != 0:
        logger.error(f"Failed to install packages: {result.stderr}")
        return False

    return True


def uvpython_toolchain(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for Python toolchain management"""
    if options.action == "update":
        if not install_uv(options.dry_run):
            return False
        if not VENV_PATH.exists():
            if not create_venv(options.dry_run):
                return False
        return install_base_packages(options.dry_run)

    elif options.action == "reinstall":
        # Remove existing venv if it exists
        if not options.dry_run and VENV_PATH.exists():
            try:
                import shutil

                shutil.rmtree(VENV_PATH)
            except Exception as e:
                logger.error(f"Failed to remove existing virtual environment: {e}")
                return False

        if not install_uv(options.dry_run):
            return False
        if not create_venv(options.dry_run):
            return False
        return install_base_packages(options.dry_run)

    return False
