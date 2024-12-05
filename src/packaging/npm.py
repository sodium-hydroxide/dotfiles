import json
from pathlib import Path
from typing import List
from ..utils.shell import run_shell_command, check_command_exists
from ..utils.paths import Paths
from ..utils.logs import logger
from ..utils.options import CommandOptions

def ensure_npm() -> bool:
    """Ensure npm is installed"""
    if not check_command_exists("npm"):
        logger.error("npm not found. Please install Node.js first.")
        return False

    # Update npm itself
    result = run_shell_command(
        ["npm", "install", "-g", "npm@latest"],
        capture_output=True
    )

    if result.returncode != 0:
        logger.error(f"Failed to upgrade npm: {result.stderr}")
        return False

    return True

def load_npm_packages(config_file: Path) -> List[str]:
    """Load npm package list from JSON configuration"""
    try:
        with open(config_file) as f:
            config = json.load(f)
            return config.get("globalPackages", [])
    except (json.JSONDecodeError, FileNotFoundError) as e:
        logger.error(f"Failed to load npm configuration: {e}")
        return []

def update_npm(config_file: Path, dry_run: bool = False) -> bool:
    """Update npm packages"""
    if dry_run:
        logger.info("Would update npm packages")
        return True

    if not ensure_npm():
        return False

    packages = load_npm_packages(config_file)
    if not packages:
        return False

    # Update all global packages
    logger.info("Updating npm packages...")
    for package in packages:
        result = run_shell_command(
            ["npm", "update", "-g", package],
            capture_output=True
        )
        if result.returncode != 0:
            logger.error(f"Failed to update {package}: {result.stderr}")
            return False

    return True

def reinstall_npm(config_file: Path, dry_run: bool = False) -> bool:
    """Reinstall all npm packages"""
    if dry_run:
        logger.info("Would reinstall all npm packages")
        return True

    if not ensure_npm():
        return False

    packages = load_npm_packages(config_file)
    if not packages:
        return False

    # First uninstall all packages
    logger.info("Uninstalling existing npm packages...")
    for package in packages:
        run_shell_command(
            ["npm", "uninstall", "-g", package],
            capture_output=True
        )

    # Reinstall all packages
    logger.info("Reinstalling npm packages...")
    for package in packages:
        result = run_shell_command(
            ["npm", "install", "-g", package],
            capture_output=True
        )
        if result.returncode != 0:
            logger.error(f"Failed to reinstall {package}: {result.stderr}")
            return False

    return True

def npm_packaging(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for npm package management"""
    config_file = paths.pkgs / "npm" / "npm.json"

    if not config_file.exists():
        logger.error(f"NPM configuration file not found at: {config_file}")
        return False

    if options.action == "update":
        return update_npm(config_file, options.dry_run)
    elif options.action == "reinstall":
        return reinstall_npm(config_file, options.dry_run)

    return False
