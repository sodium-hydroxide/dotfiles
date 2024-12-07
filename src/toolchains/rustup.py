import os
from pathlib import Path

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from ..utils.shell import check_command_exists, run_shell_command

RUSTUP_INSTALLER = "https://sh.rustup.rs"
CARGO_HOME = Path.home() / ".cargo"
RUSTUP_HOME = Path.home() / ".rustup"


def install_rustup(dry_run: bool = False) -> bool:
    """Install or update rustup"""
    if dry_run:
        logger.info("Would install/update rustup")
        return True

    if check_command_exists("rustup"):
        logger.info("Updating rustup...")
        result = run_shell_command(["rustup", "self", "update"], capture_output=True)
    else:
        logger.info("Installing rustup...")
        result = run_shell_command(
            f'curl --proto "=https" --tlsv1.2 -sSf {RUSTUP_INSTALLER} | '
            + "sh -s -- -y --no-modify-path",
            shell=True,
            capture_output=True,
        )

    if result.returncode != 0:
        logger.error(f"Failed to install/update rustup: {result.stderr}")
        return False

    return True


def setup_rust_env() -> None:
    """Set up Rust environment variables"""
    os.environ["CARGO_HOME"] = str(CARGO_HOME)
    os.environ["RUSTUP_HOME"] = str(RUSTUP_HOME)

    # Add cargo bin to PATH for this session
    cargo_bin = CARGO_HOME / "bin"
    if cargo_bin.exists():
        os.environ["PATH"] = f"{cargo_bin}:{os.environ['PATH']}"


def install_components(dry_run: bool = False) -> bool:
    """Install Rust components"""
    if dry_run:
        logger.info("Would install Rust components")
        return True

    setup_rust_env()

    # List of components to install
    components = ["rustfmt", "clippy", "rust-analyzer"]

    logger.info("Installing Rust components...")
    for component in components:
        result = run_shell_command(
            ["rustup", "component", "add", component], capture_output=True
        )
        if result.returncode != 0:
            logger.error(f"Failed to install {component}: {result.stderr}")
            return False

    return True


def install_tools(dry_run: bool = False) -> bool:
    """Install Rust tools"""
    if dry_run:
        logger.info("Would install Rust tools")
        return True

    setup_rust_env()

    # List of cargo tools to install
    tools = ["cargo-edit", "cargo-watch", "cargo-update"]

    logger.info("Installing Rust tools...")
    for tool in tools:
        result = run_shell_command(["cargo", "install", tool], capture_output=True)
        if result.returncode != 0:
            logger.error(f"Failed to install {tool}: {result.stderr}")
            return False

    return True


def rustup_toolchain(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for Rust toolchain management"""
    if options.action == "update":
        if not install_rustup(options.dry_run):
            return False
        if not install_components(options.dry_run):
            return False
        return install_tools(options.dry_run)

    elif options.action == "reinstall":
        # Remove existing Rust installation if it exists
        if not options.dry_run:
            for path in [CARGO_HOME, RUSTUP_HOME]:
                if path.exists():
                    try:
                        import shutil

                        shutil.rmtree(path)
                    except Exception as e:
                        logger.error(f"Failed to remove {path}: {e}")
                        return False

        if not install_rustup(options.dry_run):
            return False
        if not install_components(options.dry_run):
            return False
        return install_tools(options.dry_run)

    return False
