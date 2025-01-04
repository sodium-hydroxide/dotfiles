from pathlib import Path

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths
from ..utils.shell import check_command_exists, run_shell_command

JULIAUP_INSTALLER = "https://install.julialang.org"
JULIA_DEPOT = Path.home() / ".julia"


def install_juliaup(dry_run: bool = False) -> bool:
    """Install or update juliaup"""
    if dry_run:
        logger.info("Would install/update juliaup")
        return True

    if check_command_exists("juliaup"):
        logger.info("Updating juliaup...")
        result = run_shell_command(["juliaup", "update"], capture_output=True)
    else:
        logger.info("Installing juliaup...")
        result = run_shell_command(
            f"curl -fsSL {JULIAUP_INSTALLER} | sh -s -- --yes",
            shell=True,
            capture_output=True,
        )

    if result.returncode != 0:
        logger.error(f"Failed to install/update juliaup: {result.stderr}")
        return False

    return True


def setup_julia(dry_run: bool = False) -> bool:
    """Set up Julia release channel and default version"""
    if dry_run:
        logger.info("Would setup Julia release channel")
        return True

    # Add latest stable version
    result = run_shell_command(["juliaup", "add", "release"], capture_output=True)
    if result.returncode != 0:
        logger.error(f"Failed to add release channel: {result.stderr}")
        return False

    # Set as default
    result = run_shell_command(["juliaup", "default", "release"], capture_output=True)
    if result.returncode != 0:
        logger.error(f"Failed to set default channel: {result.stderr}")
        return False

    return True


def install_packages(dry_run: bool = False) -> bool:
    """Install essential Julia packages"""
    if dry_run:
        logger.info("Would install Julia packages")
        return True

    # Create Julia script for package installation
    script = """
    using Pkg

    essential_packages = [
        "Revise",          # For interactive development
        "OhMyREPL",        # Better REPL experience
        "BenchmarkTools",  # For benchmarking
        "Documenter",      # For documentation
        "TestItems",       # For testing
        "Pluto",          # Interactive notebooks
        "IJulia"          # Jupyter kernel
    ]

    println("Installing packages...")
    for pkg in essential_packages
        println("Installing $pkg...")
        Pkg.add(pkg)
    end

    println("Precompiling packages...")
    Pkg.precompile()
    """

    logger.info("Installing Julia packages...")
    result = run_shell_command(
        ["julia", "--startup-file=no", "-e", script], capture_output=True
    )

    if result.returncode != 0:
        logger.error(f"Failed to install packages: {result.stderr}")
        return False

    return True


def juliaup_toolchain(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for Julia toolchain management"""
    if options.action == "update":
        if not install_juliaup(options.dry_run):
            return False
        if not setup_julia(options.dry_run):
            return False
        return install_packages(options.dry_run)

    elif options.action == "reinstall":
        # Remove existing Julia depot if it exists
        if not options.dry_run and JULIA_DEPOT.exists():
            try:
                import shutil

                shutil.rmtree(JULIA_DEPOT)
            except Exception as e:
                logger.error(f"Failed to remove Julia depot: {e}")
                return False

        if not install_juliaup(options.dry_run):
            return False
        if not setup_julia(options.dry_run):
            return False
        return install_packages(options.dry_run)

    return False
