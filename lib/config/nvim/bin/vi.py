#!/usr/bin/env python3

import argparse
from pathlib import Path
import os
import subprocess
import sys
from typing import Dict, Final, List, Optional, Tuple
from dataclasses import dataclass


@dataclass
class NvimConfig:
    """Represents a Neovim configuration mode"""

    name: str
    lua_function: str
    description: str


MODES: Final[Dict[str, NvimConfig]] = {
    "plain": NvimConfig("plain", "", "Basic Neovim configuration"),
    "ide": NvimConfig("ide", "modes.ide.setup", "General IDE setup"),
    "python": NvimConfig("python", "modes.python.setup", "Python development"),
    "haskell": NvimConfig("haskell", "modes.haskell.setup", "Haskell development"),
}


def detect_mode_from_file(filepath: str) -> str:
    """Try to automatically detect the appropriate mode based on file extension"""
    if not filepath or filepath.startswith("+"):
        return "plain"

    ext = Path(filepath).suffix.lower()
    mode_map = {
        ".py": "python",
        ".hs": "haskell",
        ".lhs": "haskell",
        # Add more mappings as needed
    }
    return mode_map.get(ext, "plain")


def make_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Enhanced Neovim launcher that handles vi-style arguments"
    )
    parser.add_argument(
        "--gui",
        "-g",
        action="store_true",
        help="Open in Neovide instead of terminal Neovim",
    )
    parser.add_argument(
        "--mode",
        "-m",
        default=None,
        choices=MODES.keys(),
        help="IDE mode for the Neovim window",
    )
    # We'll handle remaining arguments manually to support vi-style arguments
    parser.add_argument("remaining", nargs=argparse.REMAINDER, help=argparse.SUPPRESS)
    return parser


def process_vi_args(args: List[str]) -> Tuple[List[str], Optional[str], Optional[str]]:
    """Process traditional vi-style arguments and return (nvim_args, filepath, mode)"""
    nvim_args = []
    filepath = None
    mode = None

    i = 0
    while i < len(args):
        arg = args[i]
        if arg.startswith("+"):
            nvim_args.extend(["-c", f"normal! {arg[1:]}G"])
        elif arg.startswith("-"):
            if arg == "-R":
                nvim_args.append("-R")  # readonly mode
            # Add other vi flags as needed
        else:
            filepath = arg
            mode = detect_mode_from_file(filepath)
        i += 1

    return nvim_args, filepath, mode


def get_directory(filepath: Optional[str]) -> Path:
    """Get the directory to open, using filepath or current directory"""
    if not filepath:
        return Path.cwd()

    path = Path(filepath)
    return path.parent if path.is_file() else path


def get_nvim_command(
    directory: Path,
    mode: str,
    gui: bool,
    nvim_args: List[str],
    filepath: Optional[str] = ".",
) -> List[str]:
    """Build the complete Neovim command"""
    config = MODES[mode]

    # Base command
    cmd = ["neovide"] if gui else ["nvim"]

    # Add any vi-style arguments we processed
    cmd.extend(nvim_args)

    # Add initialization command if we have a Lua function to call
    if config.lua_function:
        cmd.extend(
            [
                "--cmd",
                f"lua vim.defer_fn(function() require('{config.lua_function}')() end, 100)",
            ]
        )

    # Add the filepath if specified, otherwise add the directory
    if filepath:
        cmd.append(filepath)
    else:
        cmd.append(str(directory))

    return cmd


def main() -> int:
    # Parse our custom arguments first
    parser = make_parser()
    args = parser.parse_args()

    # Process remaining vi-style arguments
    nvim_args, filepath, detected_mode = process_vi_args(args.remaining)

    # Use explicitly specified mode, or detected mode, or default to plain
    default_mode = "ide" if args.gui else "plain"
    mode = args.mode or detected_mode or default_mode

    # Get directory from filepath or use current directory
    directory = get_directory(filepath)

    # Build and execute the command
    cmd = get_nvim_command(directory, mode, args.gui, nvim_args, filepath)

    # Set environment variable for Neovim
    env = os.environ.copy()
    env["NVIM_MODE"] = mode

    # Execute and return the same exit code
    try:
        result = subprocess.run(cmd, env=env)
        return result.returncode
    except KeyboardInterrupt:
        return 130  # Standard interrupt exit code
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())

