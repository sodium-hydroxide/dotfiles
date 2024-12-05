from pathlib import Path
import json
import os
import re
import shutil
from typing import List, Optional
from datetime import datetime
from ..utils.logs import logger
from ..utils.paths import Paths
from ..utils.errors import FSError, LinkError
from ..utils.options import CommandOptions

class SymlinkManager:
    """Manage configuration symlinks"""

    def __init__(self, config_dir: Path):
        self.config_dir = config_dir
        self.config = self.load_config()

    def load_config(self) -> dict:
        """Load symlink configuration from metadata.json"""
        try:
            with open(self.config_dir / "metadata.json") as f:
                return json.load(f)
        except (json.JSONDecodeError, FileNotFoundError) as e:
            raise RuntimeError(f"Failed to load symlink configuration: {e}")

    def expand_variables(self, path_components: List[str]) -> Path:
        """Expand environment variables in path components"""
        expanded = []
        for component in path_components:
            if isinstance(component, str):
                # Replace $VARS with their values
                for var, value in self.config.get("variables", {}).items():
                    component = component.replace(f"${var}", value)
                # Expand any remaining environment variables
                component = os.path.expandvars(component)
            expanded.append(component)
        return Path(*expanded).expanduser()

    def create_backup(self, path: Path) -> Optional[Path]:
        """Create a backup of a file or directory"""
        if not path.exists():
            return None

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = path.with_name(f"{path.name}.backup_{timestamp}")

        try:
            if path.is_dir():
                shutil.copytree(path, backup_path)
            else:
                shutil.copy2(path, backup_path)
            logger.info(f"Created backup: {backup_path}")
            return backup_path
        except (shutil.Error, OSError) as e:
            raise FSError(f"Failed to create backup of {path}: {e}")

    def should_exclude(self, path: Path, exclusions: List[str]) -> bool:
        """Check if path matches any exclusion patterns"""
        return any(re.match(pattern, str(path)) for pattern in exclusions)

    def make_symlink(self, source: Path, target: Path, config: dict) -> Optional[Path]:
        """Create a symlink with proper permissions and backups"""
        # Ensure source exists
        if not source.exists():
            raise LinkError(f"Source path does not exist: {source}")

        # Create parent directories if needed
        target.parent.mkdir(parents=True, exist_ok=True)

        # Handle existing target
        backup_path = None
        if target.exists() or target.is_symlink():
            backup_path = self.create_backup(target)
            try:
                if target.is_symlink() or target.is_file():
                    target.unlink()
                else:
                    shutil.rmtree(target)
            except OSError as e:
                raise FSError(f"Failed to remove existing target {target}: {e}")

        # Create symlink
        try:
            target.symlink_to(source)

            # Set permissions if specified
            if "chmod" in config:
                mode = int(config["chmod"], 8)
                target.chmod(mode)

            # Run post-link command if specified
            if "post_link" in config:
                cmd = config["post_link"].replace("$TARGET", str(target))
                os.system(cmd)  # Consider using subprocess.run instead

            return backup_path
        except OSError as e:
            # If backup exists and link failed, try to restore
            if backup_path and backup_path.exists():
                try:
                    shutil.move(str(backup_path), str(target))
                except OSError:
                    pass  # If restoration fails, leave the backup in place
            raise LinkError(f"Failed to create symlink {target} -> {source}: {e}")

    def write_file(self, content: str, target: Path, chmod: Optional[str] = None) -> None:
        """Write content to a file with proper permissions"""
        try:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(content)
            if chmod:
                target.chmod(int(chmod, 8))
        except OSError as e:
            raise FSError(f"Failed to write file {target}: {e}")

    def update_symlinks(self, dry_run: bool = False) -> bool:
        """Update all symlinks according to configuration"""
        success = True

        # Process directory symlinks
        for link in self.config.get("links", []):
            source = self.config_dir / link["local"]
            target = self.expand_variables(link["link"])
            exclusions = link.get("exclude", [])

            if dry_run:
                logger.info(f"Would link {source} -> {target}")
                continue

            try:
                self.make_symlink(source, target, link)
                logger.info(f"Created symlink: {target} -> {source}")
            except (FSError, LinkError) as e:
                logger.error(str(e))
                success = False

        # Process file writes
        for file in self.config.get("files", []):
            target = self.expand_variables(file["target"])

            if dry_run:
                logger.info(f"Would write file: {target}")
                continue

            try:
                self.write_file(file["content"], target, file.get("chmod"))
                logger.info(f"Wrote file: {target}")
            except FSError as e:
                logger.error(str(e))
                success = False

        return success

    def cleanup_symlinks(self, dry_run: bool = False) -> bool:
        """Remove broken symlinks and backup files"""
        success = True

        # Clean up configured links
        for link in self.config.get("links", []):
            target = self.expand_variables(link["link"])
            if dry_run:
                if target.is_symlink() and not target.exists():
                    logger.info(f"Would remove broken symlink: {target}")
                continue

            try:
                if target.is_symlink() and not target.exists():
                    target.unlink()
                    logger.info(f"Removed broken symlink: {target}")
            except OSError as e:
                logger.error(f"Failed to remove broken symlink {target}: {e}")
                success = False

        # Clean up old backups if desired
        # (You could add backup cleanup logic here)

        return success

def symlink_config(options: CommandOptions, paths: Paths) -> bool:
    """Main entry point for symlink configuration"""
    try:
        manager = SymlinkManager(paths.config)

        if options.action == "update":
            return manager.update_symlinks(options.dry_run)
        elif options.action == "cleanup":
            return manager.cleanup_symlinks(options.dry_run)

        return False
    except Exception as e:
        logger.error(f"Symlink operation failed: {e}")
        return False
