
import os
import shutil
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Optional, List, Union, Tuple

from .errors import FSError, LinkError


def backup_path(path: Path) -> Path:
    """Create a backup path with timestamp"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    return path.with_name(f"{path.name}.backup_{timestamp}")

def create_backup(path: Path) -> Optional[Path]:
    """
    Create a backup of a file or directory if it exists
    Returns the backup path if backup was created, None otherwise
    """
    if not path.exists():
        return None

    backup = backup_path(path)
    try:
        if path.is_dir():
            shutil.copytree(path, backup)
        else:
            shutil.copy2(path, backup)
        return backup
    except (shutil.Error, OSError) as e:
        raise FSError(f"Failed to create backup of {path}: {e}")

def safe_unlink(path: Path) -> None:
    """Safely remove a file or symlink"""
    try:
        if path.is_symlink() or path.is_file():
            path.unlink()
        elif path.is_dir():
            shutil.rmtree(path)
    except OSError as e:
        raise FSError(f"Failed to remove {path}: {e}")

def make_symlink(source: Path, target: Path, backup: bool = True) -> Optional[Path]:
    """
    Create a symlink from target to source.
    Returns the path of the backup if one was created.

    Args:
        source: The file/directory to link to
        target: The location of the symlink
        backup: Whether to backup existing files
    """
    # Ensure source exists
    if not source.exists():
        raise LinkError(f"Source path does not exist: {source}")

    # Resolve source to absolute path
    source = source.resolve()

    # Create parent directories if needed
    target.parent.mkdir(parents=True, exist_ok=True)

    # Handle existing target
    backup_file = None
    if target.exists() or target.is_symlink():
        if backup:
            backup_file = create_backup(target)
        safe_unlink(target)

    # Create symlink
    try:
        target.symlink_to(source)
        return backup_file
    except OSError as e:
        # If backup was created but link failed, try to restore
        if backup_file and backup_file.exists():
            try:
                shutil.move(str(backup_file), str(target))
            except OSError:
                pass  # If restoration fails, leave the backup in place
        raise LinkError(f"Failed to create symlink {target} -> {source}: {e}")

def symlink_directory(source_dir: Path, target_dir: Path, backup: bool = True) -> List[Tuple[Path, Optional[Path]]]:
    """
    Recursively symlink contents of source_dir to target_dir.
    Returns list of (target, backup) pairs.
    """
    if not source_dir.is_dir():
        raise LinkError(f"Source directory does not exist: {source_dir}")

    results = []
    for source_path in source_dir.rglob('*'):
        # Skip if it's not a file
        if not source_path.is_file():
            continue

        # Calculate relative path from source_dir to the file
        rel_path = source_path.relative_to(source_dir)
        # Calculate target path
        target_path = target_dir / rel_path

        # Create symlink and track result
        backup_path = make_symlink(source_path, target_path, backup=backup)
        results.append((target_path, backup_path))

    return results

# Shell utilities
def run_shell_command(
    cmd: Union[str, List[str]],
    shell: bool = False,
    capture_output: bool = True,
    check: bool = True,
    cwd: Optional[Path] = None,
    env: Optional[dict] = None
) -> subprocess.CompletedProcess:
    """
    Run a shell command with proper error handling

    Args:
        cmd: Command to run (string or list of strings)
        shell: Whether to run command in shell
        capture_output: Whether to capture stdout/stderr
        check: Whether to raise exception on non-zero exit
        cwd: Working directory for command
        env: Environment variables for command
    """
    try:
        # If cmd is a string and shell is False, split it
        if isinstance(cmd, str) and not shell:
            cmd = cmd.split()

        return subprocess.run(
            cmd,
            shell=shell,
            capture_output=capture_output,
            text=True,
            check=check,
            cwd=cwd,
            env={**os.environ, **(env or {})}
        )
    except subprocess.CalledProcessError as e:
        # Add command context to error message
        cmd_str = cmd if isinstance(cmd, str) else ' '.join(cmd)
        e.args = (f"Command '{cmd_str}' failed with exit code {e.returncode}. "
                 f"stdout: {e.stdout}, stderr: {e.stderr}",)
        raise

def check_command_exists(cmd: str) -> bool:
    """Check if a command exists in PATH"""
    try:
        run_shell_command(['which', cmd], capture_output=True, check=False)
        return True
    except (subprocess.SubprocessError, OSError):
        return False

def get_home_dir() -> Path:
    """Get user's home directory"""
    return Path.home()

def expand_path(path: Union[str, Path]) -> Path:
    """Expand ~ and environment variables in path"""
    return Path(os.path.expandvars(os.path.expanduser(str(path))))
