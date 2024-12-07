from pathlib import Path

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from ..utils.shell import run_shell_command

HOMEBREW_BASH = "/opt/homebrew/bin/bash"
SYSTEM_SHELLS = "/etc/shells"
WRAPPER_PATH = "/usr/local/bin/bash"


def check_homebrew_bash() -> bool:
    """Check if Homebrew's bash is installed"""
    return Path(HOMEBREW_BASH).exists()


def is_shell_registered(shell_path: str) -> bool:
    """Check if shell is registered in /etc/shells"""
    try:
        with open(SYSTEM_SHELLS, "r") as f:
            return shell_path in f.read().splitlines()
    except FileNotFoundError:
        return False


def register_shell(shell_path: str, dry_run: bool = False) -> bool:
    """Register shell in /etc/shells"""
    if dry_run:
        logger.info(f"Would register {shell_path} in {SYSTEM_SHELLS}")
        return True

    if is_shell_registered(shell_path):
        return True

    try:
        # Add shell to /etc/shells
        cmd = f'echo "{shell_path}" | sudo tee -a {SYSTEM_SHELLS}'
        result = run_shell_command(cmd, shell=True, capture_output=True)
        if result.returncode != 0:
            logger.error(f"Failed to register shell: {result.stderr}")
            return False
        return True
    except Exception as e:
        logger.error(f"Failed to register shell: {e}")
        return False


def create_wrapper(dry_run: bool = False) -> bool:
    """Create or update the bash wrapper script"""
    if dry_run:
        logger.info(f"Would create bash wrapper at {WRAPPER_PATH}")
        return True

    wrapper_content = f"""#!/bin/sh
exec {HOMEBREW_BASH} "$@"
"""
    try:
        # Create wrapper script
        cmd = f'echo "{wrapper_content}" | sudo tee {WRAPPER_PATH}'
        result = run_shell_command(cmd, shell=True, capture_output=True)
        if result.returncode != 0:
            logger.error(f"Failed to create wrapper: {result.stderr}")
            return False

        # Make wrapper executable
        cmd = f"sudo chmod +x {WRAPPER_PATH}"
        result = run_shell_command(cmd, shell=True, capture_output=True)
        if result.returncode != 0:
            logger.error(f"Failed to make wrapper executable: {result.stderr}")
            return False

        return True
    except Exception as e:
        logger.error(f"Failed to create wrapper: {e}")
        return False


def set_as_default_shell(dry_run: bool = False) -> bool:
    """Set Homebrew's bash as the default shell"""
    if dry_run:
        logger.info(f"Would set {WRAPPER_PATH} as default shell")
        return True

    try:
        cmd = f"chsh -s {WRAPPER_PATH}"
        result = run_shell_command(cmd, shell=True, capture_output=True)
        if result.returncode != 0:
            logger.error(f"Failed to set default shell: {result.stderr}")
            return False
        return True
    except Exception as e:
        logger.error(f"Failed to set default shell: {e}")
        return False


def setup_bash(dry_run: bool = False) -> bool:
    """Set up Homebrew's bash as the default shell"""
    if not check_homebrew_bash():
        logger.error(f"Homebrew bash not found at {HOMEBREW_BASH}")
        return False

    # Register Homebrew's bash in /etc/shells
    if not register_shell(HOMEBREW_BASH, dry_run):
        return False

    # Create wrapper script
    if not create_wrapper(dry_run):
        return False

    # Register wrapper in /etc/shells
    if not register_shell(WRAPPER_PATH, dry_run):
        return False

    # Set as default shell
    if not set_as_default_shell(dry_run):
        return False

    return True


def bash_toolchain(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for bash toolchain management"""
    if options.action == "update":
        # For bash, update is same as reinstall since we're just
        # setting up the shell configuration
        return setup_bash(options.dry_run)
    elif options.action == "reinstall":
        return setup_bash(options.dry_run)

    return False
