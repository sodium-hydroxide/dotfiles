import json
import os
from pathlib import Path
from typing import Literal

from .cmd import run_command
from .logs import logger


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
                and "No matching processes" not in result["stderr"]  # type: ignore
            ):
                logger.warning(f"Failed to restart {service}: {result['stderr']}")

        logger.info(
            "Settings applied successfully. Some changes may require a logout/login to take effect."
        )
        return 0

    except Exception as e:
        logger.error(f"Failed to apply macOS settings: {str(e)}")
        return 1

