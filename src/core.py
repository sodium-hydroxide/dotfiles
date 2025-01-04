#! /usr/bin/env python3

#
import argparse
import json
import logging
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Literal, Optional, Tuple, Union

DOTFILES_DIR = Path(__file__).resolve().parent.parent
MACOS_SETTINGS_PATH = DOTFILES_DIR / "lib" / "macos.jsonc"
CONFIG_FILES_PATH = DOTFILES_DIR / "lib" / "config"
PACKAGES_PATH = DOTFILES_DIR / "lib" / "pkgs" / "toolchain.jsonc"

# ANSI color codes for console output
COLORS = {
    "DEBUG": "\033[36m",  # Cyan
    "INFO": "\033[32m",  # Green
    "WARNING": "\033[33m",  # Yellow
    "ERROR": "\033[31m",  # Red
    "CRITICAL": "\033[41m",  # Red background
    "RESET": "\033[0m",  # Reset color
}

# Create the main logger
logger = logging.getLogger("dotfiles")


class ColorFormatter(logging.Formatter):
    """Custom formatter adding colors to levelname for console output"""

    def format(self, record: logging.LogRecord) -> str:
        if sys.stdout.isatty():
            levelname = record.levelname
            if levelname in COLORS:
                record.levelname = f"{COLORS[levelname]}{levelname}{COLORS['RESET']}"
        return super().format(record)


def get_log_file() -> Path:
    """Get the path for the log file"""
    cache_dir = Path.home() / ".cache" / "dotfiles"
    cache_dir.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y%m%d")
    return cache_dir / f"dotfiles_{timestamp}.log"


def setup_logging(verbose: bool = False, log_file: Optional[Path] = None) -> None:
    """Set up logging configuration"""
    logger.setLevel(logging.DEBUG)
    logger.handlers.clear()

    # Console handler with color formatting
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.DEBUG if verbose else logging.INFO)
    console_format = "%(levelname)s: %(message)s"
    console_handler.setFormatter(ColorFormatter(console_format))
    logger.addHandler(console_handler)

    # File handler
    if log_file is None:
        log_file = get_log_file()

    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.DEBUG)
    file_format = "%(asctime)s - %(levelname)s - %(message)s"
    file_handler.setFormatter(logging.Formatter(file_format))
    logger.addHandler(file_handler)

    logger.debug(f"Logging started. Log file: {log_file}")


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


def symlink_config_files(config_directory: Path) -> Literal[0, 1]:
    """Create symbolic links for configuration files in ~/.config/

    Parameters
    ----------
    config_directory : Path
        Source directory path containing configuration files and directories

    Returns
    -------
    int
        0 if successful, 1 if critical error occurred
    """
    try:
        config_directory = Path(config_directory)
        target_dir = Path.home() / ".config"

        if not config_directory.is_dir():
            logger.error(f"Source path {config_directory} is not a directory")
            return 1

        logger.info(f"Creating symlinks from {config_directory} to {target_dir}")
        target_dir.mkdir(parents=True, exist_ok=True)

        for item in config_directory.rglob("*"):
            rel_path = item.relative_to(config_directory)
            target_path = target_dir / rel_path

            target_path.parent.mkdir(parents=True, exist_ok=True)

            if target_path.exists() or target_path.is_symlink():
                logger.debug(f"Skipping existing path: {target_path}")
                continue

            try:
                os.symlink(item, target_path)
                logger.debug(f"Created symlink: {target_path} -> {item}")
            except OSError as e:
                logger.error(f"Failed to create symlink for {item}: {e}")

        logger.info("Completed creating symlinks")
        return 0

    except Exception as e:
        logger.error(f"Failed to create symlinks: {str(e)}")
        return 1


def apply_macos_settings(json_path: Path) -> Literal[0, 1]:
    """Apply macOS system settings from a JSON configuration file.

    Parameters
    ----------
    json_path : Path
        Path to the JSON configuration file

    Returns
    -------
    int
        0 if successful, 1 if critical error occurred
    """
    try:
        with open(json_path, "r") as f:
            config = json.load(f)

        logger.info("Applying macOS settings...")

        # Apply macOS settings
        for category, settings_list in config["settings"].items():
            logger.info(f"Applying {category} settings...")
            for item in settings_list:
                domain = item["domain"]
                for key, value in item["settings"].items():
                    # Convert boolean values to 'YES' or 'NO' for defaults command
                    if isinstance(value, bool):
                        value = "YES" if value else "NO"

                    # Convert float/int to string
                    if isinstance(value, (int, float)):
                        value = str(value)

                    cmd = [
                        "defaults",
                        "write",
                        domain,
                        key,
                        "-" + type(value).__name__,
                        str(value),
                    ]
                    result = run_command(cmd)
                    if result["returncode"] != 0:
                        logger.error(
                            f"Failed to apply setting {key}: {result['stderr']}"
                        )

        # Apply duti settings
        logger.info("Applying default application settings...")
        for app_id, file_types in config["default_files"].items():
            for file_type in file_types:
                if file_type.startswith("."):
                    role = "all"
                    file_type = file_type[1:]
                else:
                    role = "viewer"

                cmd = ["duti", "-s", app_id, file_type, role]
                result = run_command(cmd)
                if result["returncode"] != 0:
                    logger.error(
                        f"Failed to set default application for {file_type}: {result['stderr']}"
                    )

        # Restart affected services
        logger.info("Restarting system services...")
        services_to_restart = ["cfprefsd", "Dock", "Finder", "SystemUIServer"]

        for service in services_to_restart:
            result = run_command(["killall", service], dry_run=False)
            if (
                result["returncode"] != 0
                and "No matching processes" not in result["stderr"]
            ):
                logger.warning(f"Failed to restart {service}: {result['stderr']}")

        logger.info(
            "Settings applied successfully. Some changes may require a logout/login to take effect."
        )
        return 0

    except Exception as e:
        logger.error(f"Failed to apply macOS settings: {str(e)}")
        return 1


def add_verbosity(parser: argparse.ArgumentParser) -> argparse.ArgumentParser:
    verbosity = parser.add_mutually_exclusive_group()
    verbosity.add_argument(
        "-v", "--verbose", action="store_true", help="Verbose (debug level) output"
    )
    verbosity.add_argument(
        "-q", "--quiet", action="store_true", help="Suppress non error messages"
    )
    return parser


def add_actions(parser: argparse.ArgumentParser) -> argparse.ArgumentParser:
    subparsers = parser.add_subparsers(dest="command", required=True)

    macos_parser = subparsers.add_parser(
        "macos",
        help="macOS related commands",
        description="Configure macOS system settings",
    )

    config_parser = subparsers.add_parser(
        "config",
        help="Configuration commands",
        description="Manage configuration files and symlinks",
    )

    pkg_parser = subparsers.add_parser(
        "pkg", help="Package management commands", description="Manage system packages"
    )
    pkg_subparsers = pkg_parser.add_subparsers(dest="pkg_command", required=True)

    pkg_subparsers.add_parser("update", help="Update installed packages")
    pkg_subparsers.add_parser("reinstall", help="Reinstall packages from configuration")

    return parser


def get_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Manage dotfiles, packages, and macOS settings",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making actual changes",
    )
    add_verbosity(parser)
    add_actions(parser)

    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(0)

    return parser.parse_args()


def main() -> Literal[0, 1]:
    """Main entry point for the script.

    Returns
    -------
    Literal[0, 1]
        0 for success, 1 for failure
    """
    args = get_args()

    log_level = (
        logging.WARNING
        if args.quiet
        else logging.DEBUG
        if args.verbose
        else logging.INFO
    )

    setup_logging(verbose=(log_level == logging.DEBUG))
    logger.info("Starting dotfiles management")

    try:
        if args.command == "pkg":
            if args.pkg_command == "reinstall":
                return install_pkgs(PACKAGES_PATH, dry_run=args.dry_run)
            elif args.pkg_command == "update":
                return update_pkgs(PACKAGES_PATH, dry_run=args.dry_run)
            logger.error("Invalid package command")
            return 1

        elif args.command == "config":
            if not CONFIG_FILES_PATH.exists():
                logger.error(f"Config directory not found: {CONFIG_FILES_PATH}")
                return 1
            return symlink_config_files(CONFIG_FILES_PATH)

        elif args.command == "macos":
            if not MACOS_SETTINGS_PATH.exists():
                logger.error(f"macOS settings file not found: {MACOS_SETTINGS_PATH}")
                return 1
            return apply_macos_settings(MACOS_SETTINGS_PATH)

        logger.error(f"Unknown command: {args.command}")
        return 1

    except KeyboardInterrupt:
        logger.warning("Operation interrupted by user")
        return 1
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        if args.verbose:
            logger.exception("Detailed error information:")
        return 1
