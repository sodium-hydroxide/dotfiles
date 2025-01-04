import os
from pathlib import Path

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from ..utils.shell import check_command_exists, run_shell_command

GHCUP_INSTALLER = "https://get-ghcup.haskell.org"
GHCUP_HOME = Path.home() / ".ghcup"
CABAL_HOME = Path.home() / ".cabal"


def install_ghcup(dry_run: bool = False) -> bool:
    """Install or update ghcup"""
    if dry_run:
        logger.info("Would install/update ghcup")
        return True

    if check_command_exists("ghcup"):
        logger.info("Updating ghcup...")
        result = run_shell_command(["ghcup", "upgrade"], capture_output=True)
    else:
        logger.info("Installing ghcup...")
        result = run_shell_command(
            f'curl --proto "=https" --tlsv1.2 -sSf {GHCUP_INSTALLER} | '
            + "sh -s -- --no-bashrc --no-stack",
            shell=True,
            capture_output=True,
        )

    if result.returncode != 0:
        logger.error(f"Failed to install/update ghcup: {result.stderr}")
        return False

    return True


def setup_ghc_env() -> None:
    """Set up GHC environment variables"""
    os.environ["GHCUP_HOME"] = str(GHCUP_HOME)
    os.environ["CABAL_DIR"] = str(CABAL_HOME)

    # Add ghcup bin to PATH for this session
    ghcup_bin = GHCUP_HOME / "bin"
    cabal_bin = CABAL_HOME / "bin"

    paths_to_add = []
    for path in [ghcup_bin, cabal_bin]:
        if path.exists():
            paths_to_add.append(str(path))

    if paths_to_add:
        os.environ["PATH"] = f"{':'.join(paths_to_add)}:{os.environ['PATH']}"


def install_components(dry_run: bool = False) -> bool:
    """Install Haskell components"""
    if dry_run:
        logger.info("Would install Haskell components")
        return True

    setup_ghc_env()

    # List of components to install
    components = [
        ("ghc", "recommended"),  # Install recommended GHC version
        ("cabal", "recommended"),  # Install recommended Cabal version
        ("hls", "latest")  # Haskell Language Server
    ]

    logger.info("Installing Haskell components...")
    for component, version in components:
        result = run_shell_command(
            ["ghcup", "install", component, version], capture_output=True
        )
        if result.returncode != 0:
            logger.error(f"Failed to install {component} {version}: {result.stderr}")
            return False

    return True


def install_tools(dry_run: bool = False) -> bool:
    """Install Haskell tools"""
    if dry_run:
        logger.info("Would install Haskell tools")
        return True

    setup_ghc_env()

    # List of cabal tools to install
    tools = ["hlint", "ormolu", "stan"]

    logger.info("Installing Haskell tools...")
    for tool in tools:
        result = run_shell_command(["cabal", "install", tool], capture_output=True)
        if result.returncode != 0:
            logger.error(f"Failed to install {tool}: {result.stderr}")
            return False

    return True


def ghcup_toolchain(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for Haskell toolchain management"""
    if options.action == "update":
        if not install_ghcup(options.dry_run):
            return False
        if not install_components(options.dry_run):
            return False
        return install_tools(options.dry_run)

    elif options.action == "reinstall":
        # Remove existing GHCup installation if it exists
        if not options.dry_run:
            for path in [GHCUP_HOME, CABAL_HOME]:
                if path.exists():
                    try:
                        import shutil
                        shutil.rmtree(path)
                    except Exception as e:
                        logger.error(f"Failed to remove {path}: {e}")
                        return False

        if not install_ghcup(options.dry_run):
            return False
        if not install_components(options.dry_run):
            return False
        return install_tools(options.dry_run)

    return False
