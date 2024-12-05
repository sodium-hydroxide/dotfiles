from dataclasses import dataclass
from pathlib import Path

@dataclass(frozen=True)  # frozen=True makes it immutable
class Paths:
    root: Path
    lib: Path
    config: Path
    pkgs: Path

def get_paths() -> Paths:
    """
    Get standardized paths for the project
    Returns a Paths object with all relevant paths
    """
    # Get the root directory (two levels up from utils)
    root = Path(__file__).resolve().parent.parent.parent

    lib = root / "lib"
    config = lib / "config"
    pkgs = lib / "pkgs"

    # Ensure directories exist
    for path in (root, lib, config, pkgs):
        path.mkdir(parents=True, exist_ok=True)

    return Paths(
        root=root,
        lib=lib,
        config=config,
        pkgs=pkgs
    )

def expand_path(path: Path) -> Path:
    """Expand a path, resolving any special characters or variables"""
    return Path(path).expanduser().resolve()

def get_cache_dir() -> Path:
    """Get the cache directory for temporary files"""
    cache_dir = Path.home() / ".cache" / "dotfiles"
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir
