from pathlib import Path

from ..utils.logs import logger
from ..utils.options import CommandOptions
from ..utils.paths import Paths


def symlink_config(options: CommandOptions, paths: Paths) -> bool:
    """Symlink all files from lib/config to ~/.config"""
    config_dir = paths.lib / "config"
    target_dir = Path.home() / ".config"

    if not config_dir.exists():
        logger.error(f"Config directory not found: {config_dir}")
        return False

    try:
        # Create ~/.config if it doesn't exist
        target_dir.mkdir(parents=True, exist_ok=True)

        success = True
        for source in config_dir.rglob("*"):
            # Skip __pycache__ and other special directories
            if source.name.startswith("__") or source.name.startswith("."):
                continue

            # Calculate relative path from lib/config
            rel_path = source.relative_to(config_dir)
            target = target_dir / rel_path

            if options.dry_run:
                logger.info(f"Would link {source} -> {target}")
                continue

            if source.is_dir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                # Create parent directories if needed
                target.parent.mkdir(parents=True, exist_ok=True)

                # Backup existing file if needed
                if target.exists() or target.is_symlink():
                    backup = target.with_suffix(f"{target.suffix}.backup")
                    if target.exists():
                        target.rename(backup)
                    elif target.is_symlink():
                        target.unlink()

                # Create symlink
                target.symlink_to(source)
                logger.info(f"Linked {target} -> {source}")

        return success

    except Exception as e:
        logger.error(f"Failed to setup config symlinks: {e}")
        return False
