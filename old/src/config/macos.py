from pathlib import Path
from typing import Any, Dict, List

import yaml

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from ..utils.shell import run_shell_command


def read_yaml_config(file_path: Path) -> Dict[str, Any]:
    """Read YAML configuration file"""
    try:
        with open(file_path) as f:
            return yaml.safe_load(f)
    except Exception as e:
        logger.error(f"Failed to read config file {file_path}: {e}")
        return {}


def check_defaults(domain: str, key: str, expected: Any) -> bool:
    """Check if defaults setting matches expected value"""
    try:
        result = run_shell_command(
            ["defaults", "read", domain, key], capture_output=True
        )
        return result.returncode == 0 and str(result.stdout.strip()) == str(expected)
    except Exception:
        return False


def write_defaults(
    domain: str,
    key: str,
    value: Any,
    value_type: str,
    sudo: bool = False,
    dry_run: bool = False,
) -> bool:
    """Write defaults setting"""
    if dry_run:
        logger.info(f"Would set {domain} {key} to {value}")
        return True

    if check_defaults(domain, key, value):
        logger.debug(f"Setting already correct: {domain} {key}")
        return True

    cmd = ["defaults", "write", domain, key, f"-{value_type}", str(value)]
    if sudo:
        cmd.insert(0, "sudo")

    result = run_shell_command(cmd, capture_output=True)
    if result.returncode != 0:
        logger.error(f"Failed to set {domain} {key}: {result.stderr}")
        return False

    return True


def get_value_type(value: Any) -> str:
    """Determine defaults value type"""
    if isinstance(value, bool):
        return "bool"
    elif isinstance(value, int):
        return "int"
    elif isinstance(value, float):
        return "float"
    else:
        return "string"


def apply_settings(
    config: Dict[str, List[Dict[str, Any]]], dry_run: bool = False
) -> bool:
    """Apply macOS settings from configuration"""
    success = True

    for section, entries in config.items():
        logger.info(f"Applying {section} settings...")

        for entry in entries:
            domain = entry["domain"]
            settings = entry["settings"]

            # Determine if sudo is needed based on domain
            needs_sudo = any(
                d in domain
                for d in [
                    "/Library/Preferences/",
                    "com.apple.loginwindow",
                    "com.apple.WindowManager",
                    "/Library/Preferences/SystemConfiguration/",
                ]
            )

            for key, value in settings.items():
                value_type = get_value_type(value)
                if not write_defaults(
                    domain, key, value, value_type, needs_sudo, dry_run
                ):
                    success = False

    return success


def configure_duti(
    config: Dict[str, List[str]],
    dry_run: bool = False
) -> bool:
    """Configure default applications using duti"""
    if not Path("/opt/homebrew/bin/duti").exists():
        logger.error("duti not installed. Please install via Homebrew first.")
        return False

    success = True
    for app, entries in config.items():
        for entry in entries:
            if dry_run:
                logger.info(f"Would set {app} as handler for {entry}")
                continue

            result = run_shell_command(
                ["duti", "-s", app, entry, "all"], capture_output=True
            )

            if result.returncode != 0:
                logger.error(
                    f"Failed to set {app} as handler for {entry}: {result.stderr}"
                )
                success = False

    return success


def restart_services(changed_services: List[str], dry_run: bool = False) -> None:
    """Restart necessary macOS services"""
    if dry_run:
        logger.info(f"Would restart: {', '.join(changed_services)}")
        return

    for service in changed_services:
        logger.info(f"Restarting {service}...")
        run_shell_command(["killall", service], check=False)


def setup_macos(paths: Paths, dry_run: bool = False) -> bool:
    """Set up macOS system settings"""
    config_dir = paths.config / "macos"
    settings_file = config_dir / "settings.yaml"
    duti_file = config_dir / "duti.yaml"

    if not settings_file.exists():
        logger.error(f"Settings file not found: {settings_file}")
        return False

    # Read configurations
    settings = read_yaml_config(settings_file)
    if not settings:
        return False

    # Apply system settings
    changed_services = set()
    success = True

    if not apply_settings(settings, dry_run):
        success = False
    else:
        # Track which services need restart
        if any(k in settings for k in ["dock", "hot_corners"]):
            changed_services.add("Dock")
        if "finder" in settings:
            changed_services.add("Finder")
        if any(k in settings for k in ["keyboard", "trackpad"]):
            changed_services.add("SystemUIServer")

    # Apply duti settings if file exists
    if duti_file.exists():
        duti_config = read_yaml_config(duti_file)
        if duti_config and not configure_duti(duti_config, dry_run):
            success = False

    # Restart necessary services
    if changed_services and not dry_run:
        restart_services(list(changed_services), dry_run)

    return success


def revert_macos(paths: Paths, dry_run: bool = False) -> bool:
    """Revert macOS settings to defaults"""
    logger.warning("Reverting macOS settings not implemented yet")
    return False


def macos_config(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for macOS configuration"""
    if options.action == "update":
        return setup_macos(paths, options.dry_run)
    elif options.action == "revert":
        return revert_macos(paths, options.dry_run)

    return False


def run_with_login_shell(cmd: str) -> bool:
    """Run command in login shell to ensure environment is loaded"""
    wrapped_cmd = f'bash -l -c "{cmd}"'
    try:
        result = run_shell_command(wrapped_cmd, shell=True, capture_output=True)
        return result.returncode == 0
    except Exception as e:
        logger.error(f"Command failed: {e}")
        return False

