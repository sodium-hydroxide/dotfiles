from pathlib import Path
import os
from ..utils.shell import run_shell_command, check_command_exists
from ..utils.paths import Paths
from ..utils.logs import logger
from ..utils.options import CommandOptions

NVM_DIR = Path.home() / ".nvm"
NVM_SCRIPT = "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"

def install_nvm(dry_run: bool = False) -> bool:
    """Install or update nvm"""
    if dry_run:
        logger.info("Would install/update nvm")
        return True

    if NVM_DIR.exists():
        logger.info("Updating existing nvm installation...")
        # Update existing installation
        result = run_shell_command(
            f'cd {NVM_DIR} && git fetch --tags origin && ' +
            'git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" ' +
            '$(git rev-list --tags --max-count=1)`',
            shell=True,
            capture_output=True
        )
    else:
        logger.info("Installing nvm...")
        # Fresh installation
        result = run_shell_command(
            f'curl -o- {NVM_SCRIPT} | bash',
            shell=True,
            capture_output=True
        )

    if result.returncode != 0:
        logger.error(f"Failed to install/update nvm: {result.stderr}")
        return False

    return True

def setup_nvm_env() -> None:
    """Set up NVM environment variables"""
    os.environ["NVM_DIR"] = str(NVM_DIR)
    # Source nvm.sh
    result = run_shell_command(
        f'source {NVM_DIR}/nvm.sh && node --version',
        shell=True,
        capture_output=True
    )
    if result.returncode == 0:
        logger.debug(f"Node.js version: {result.stdout.strip()}")

def install_node(dry_run: bool = False) -> bool:
    """Install latest LTS Node.js"""
    if dry_run:
        logger.info("Would install latest Node.js LTS")
        return True

    setup_nvm_env()

    # Install latest LTS version
    logger.info("Installing latest Node.js LTS...")
    result = run_shell_command(
        f'source {NVM_DIR}/nvm.sh && nvm install --lts && ' +
        'nvm use --lts && nvm alias default "lts/*"',
        shell=True,
        capture_output=True
    )

    if result.returncode != 0:
        logger.error(f"Failed to install Node.js: {result.stderr}")
        return False

    return True

def install_global_packages(dry_run: bool = False) -> bool:
    """Install global npm packages"""
    if dry_run:
        logger.info("Would install global npm packages")
        return True

    setup_nvm_env()

    # List of essential global packages
    packages = [
        "typescript",
        "ts-node",
        "@types/node",
        "prettier",
        "eslint",
        "@typescript-eslint/parser",
        "@typescript-eslint/eslint-plugin",
        "tsx",
        "npm-check-updates"
    ]

    logger.info("Installing global npm packages...")
    for package in packages:
        result = run_shell_command(
            f'source {NVM_DIR}/nvm.sh && npm install -g {package}',
            shell=True,
            capture_output=True
        )
        if result.returncode != 0:
            logger.error(f"Failed to install {package}: {result.stderr}")
            return False

    return True

def nvm_toolchain(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for Node.js toolchain management"""
    if options.action == "update":
        if not install_nvm(options.dry_run):
            return False
        if not install_node(options.dry_run):
            return False
        return install_global_packages(options.dry_run)

    elif options.action == "reinstall":
        # Remove existing nvm if it exists
        if not options.dry_run and NVM_DIR.exists():
            try:
                import shutil
                shutil.rmtree(NVM_DIR)
            except Exception as e:
                logger.error(f"Failed to remove existing nvm: {e}")
                return False

        if not install_nvm(options.dry_run):
            return False
        if not install_node(options.dry_run):
            return False
        return install_global_packages(options.dry_run)

    return False
