#!/usr/bin/env python3
"""
Restow dot-files, update Homebrew, sync Python tools, and keep Rust + uv current

Requires only a POSIX shell, `curl`, and Python ≥3.9 to bootstrap itself - it
will install `rustup` and `uv` automatically if missing.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict, Final, List, Sequence, Union

if sys.version_info < (3, 9):
    raise RuntimeError("Python ≥ 3.9 required")

# ---------------------------------------------------------------------------
# 0.  Paths & constants
# ---------------------------------------------------------------------------
HOME: Final[Path] = Path(os.environ["HOME"]).resolve()
DOTFILES_DIR: Final[Path] = HOME / "dotfiles"
PACKAGE_LISTS: Final[Path] = DOTFILES_DIR / "package-list"
PYPROJECT: Final[Path] = PACKAGE_LISTS / "pyproject.toml"
PYTOOLS: Final[Path] = PACKAGE_LISTS / "tool-list.txt"

SYSTEM_PYTHON: Final[Path] = Path("/opt/homebrew/bin/python3")
GLOBAL_VENV: Final[Path] = HOME / ".local" / ".venv"
PYTHON: Final[Path] = GLOBAL_VENV / "bin" / "python"

# Any directory whose name is in this set - or starts with a dot - is NOT a Stow package
STOW_EXCLUDE: Final[set[str]] = {
    "bin",
    "package-list",
    ".git",
    ".mypy_cache",
    "scripts",
    "locals",
}

ARROW: Final[str] = (
    "→" if (enc := sys.stdout.encoding) and "utf" in enc.lower() else "->"
)
CHECK: Final[str] = (
    "✓" if (enc := sys.stdout.encoding) and "utf" in enc.lower() else "OK"
)

ESC = "\033["  # ANSI introducer
_BREW_BIN: Union[str, None] = None  # cache for brew path
# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def error(*msg: str, exit_code: int = 1) -> None:
    print("Error:", *msg, file=sys.stderr)
    sys.exit(exit_code)


def check_cmd(cmd: str, hint: Union[str, None] = None) -> None:
    if shutil.which(cmd):
        return
    error(f"'{cmd}' not found — {hint or 'required command missing'}")


def run_cmd(
    cmd: Union[Sequence[str], str],
    desc: str | None = None,
    *,
    env_verbose: str = "UPDATE_VERBOSE",
    **popen_kwargs: Dict[str, str],
) -> subprocess.CompletedProcess[str]:
    """
    Run *cmd*; stay quiet unless either UPDATE_VERBOSE=1 is set
    or the command fails (non‑zero exit status).

    *desc*  – short human label, defaults to the command itself
    """
    if isinstance(cmd, str):
        cmd = [cmd]

    label = desc or " ".join(cmd)
    print(f"  {ARROW} {label}…", end="\r", flush=True)

    # In quiet mode capture everything; otherwise stream as usual
    quiet = os.getenv(env_verbose, "0") != "1"
    proc: subprocess.CompletedProcess[str] = subprocess.run(  # type: ignore
        cmd,
        text=True,
        capture_output=quiet,
        **popen_kwargs,  # type: ignore
    )

    if proc.returncode == 0:  # type: ignore
        if quiet:  # erase old line, then print OK on its own row
            print(f"{ESC}K", end="\r")  # clear‑to‑EOL
        print(f"  {CHECK} {label}")
    else:
        if quiet:
            # make sure the status line is gone before dumping logs
            print(f"{ESC}K", end="\r")
        print(f"Error: {label} failed with status {proc.returncode}\n")  # type: ignore
        if quiet:
            sys.stdout.write(proc.stdout)  # type: ignore
            sys.stderr.write(proc.stderr)  # type: ignore
        sys.exit(proc.returncode)  # type: ignore

    return proc  # type: ignore


# ---------------------------------------------------------------------------
# 1.  Rust toolchain (rustup)
# ---------------------------------------------------------------------------


def ensure_rust() -> None:
    """Install *rustup* if absent, else update it and the stable toolchain."""
    if shutil.which("rustup"):
        print(f"{ARROW} Updating rustup and Rust toolchains…")
        run_cmd(["rustup", "self", "update"])
        run_cmd(["rustup", "update", "stable"])
    else:
        print(f"{ARROW} Installing rustup + Rust…")
        run_cmd(
            [
                "sh",
                "-c",
                "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y",
            ]
        )
        check_cmd("rustup", "rustup should be available after installation")


# ---------------------------------------------------------------------------
# 2.  uv package manager
# ---------------------------------------------------------------------------


def ensure_uv() -> None:
    """Install *uv* if needed, or update to the latest release."""
    if shutil.which("uv"):
        print(f"{ARROW} Updating uv…")
        run_cmd(["uv", "self", "update"])
    else:
        print(f"{ARROW} Installing uv…")
        run_cmd(["sh", "-c", "curl -LsSf https://astral.sh/uv/install.sh | sh"])
        check_cmd("uv", "uv should be available after installation")


# ---------------------------------------------------------------------------
# 3.  Dot-files via GNU Stow
# ---------------------------------------------------------------------------


def _stow_package_list() -> List[str]:
    """Return the list of child directories that should be treated as Stow packages."""
    pkgs: List[str] = []
    for d in DOTFILES_DIR.iterdir():
        if not d.is_dir():
            continue
        if d.name.startswith("."):
            # Hidden directories such as `.git` are never Stow packages
            continue
        if d.name in STOW_EXCLUDE:
            continue
        pkgs.append(d.name)
    return sorted(pkgs)


def dotfiles_sync() -> None:
    check_cmd("stow", "brew install stow")
    for junk in DOTFILES_DIR.rglob(".DS_Store"):
        junk.unlink(missing_ok=True)
    pkgs = _stow_package_list()
    print(f"{ARROW} Restowing packages: {' '.join(pkgs)}")
    run_cmd(
        [
            "stow",
            "--restow",
            "--verbose",
            f"--dir={DOTFILES_DIR}",
            f"--target={HOME}",
            *pkgs,
        ]
    )


# ---------------------------------------------------------------------------
# 4.  Homebrew
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# 1.  Homebrew boot-strapper
# ---------------------------------------------------------------------------


def brew_bin() -> Union[str, None]:
    """Return an absolute path to the `brew` binary (after ensure_homebrew)."""
    global _BREW_BIN  # noqa: PLW0603
    if _BREW_BIN is not None:
        return _BREW_BIN

    # 1) First look in $PATH
    if which := shutil.which("brew"):
        _BREW_BIN = which  # type: ignore
        return which

    # 2) Common absolute install locations
    for candidate in ("/opt/homebrew/bin/brew", "/usr/local/bin/brew"):
        if Path(candidate).is_file():
            _BREW_BIN = candidate  # type: ignore
            return candidate

    error("brew binary not found after installation")  # never returns
    return None


def ensure_homebrew() -> None:
    """Ensure Xcode Command-Line Tools and Homebrew itself are installed.

    If `brew` is already present, nothing is done.
    """
    if shutil.which("brew"):
        print(f"{ARROW} Homebrew already installed.")
        return

    # 1) Install macOS Command-Line Tools if needed (idempotent)
    clt_path = subprocess.run(
        ["xcode-select", "-p"], capture_output=True, text=True
    )
    if clt_path.returncode != 0:
        print(
            f"{ARROW} Installing Xcode Command-Line Tools… (this may pop up a GUI installer)"
        )
        # `xcode-select --install` exits 1 if already installed; ignore its status
        subprocess.run(["xcode-select", "--install"], check=False)
        print(f"{ARROW} Waiting for CLT installation to finish…")
        # Busy-wait until `xcode-select -p` succeeds
        while (
            subprocess.run(
                ["xcode-select", "-p"], capture_output=True
            ).returncode
            != 0
        ):
            pass  # could sleep to be polite, but CLT install typically quick

    # 2) Install Homebrew non-interactively
    print(f"{ARROW} Installing Homebrew…")
    run_cmd(
        [
            "/bin/bash",
            "-c",
            (
                "NONINTERACTIVE=1 "
                "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | "
                "bash"
            ),
        ]
    )

    # 3) Verify
    _ = brew_bin()  # populates cache or errors
    run_cmd(["brew", "install", "stow"], desc="brew install stow")


def _brew(*args: str) -> None:
    run_cmd(["brew", *args])


def brew_update() -> None:
    check_cmd("brew", "install Homebrew from https://brew.sh/")
    print(f"{ARROW} Updating Homebrew…")
    _brew("update")
    _brew("upgrade")

    brewfiles = sorted(PACKAGE_LISTS.glob("*Brewfile*"))
    if brewfiles:
        print(f"{ARROW} Bundling: {' '.join(map(str, brewfiles))}")
        bundle_input = "\n".join(f.read_text() for f in brewfiles).encode()
        subprocess.run(
            ["brew", "bundle", "--file=-", "--cleanup", "--force", "--quiet"],
            input=bundle_input,
            check=True,
        )
    else:
        print(f"{ARROW} No Brewfiles found - skipping bundle.")

    _brew("cleanup")


# ---------------------------------------------------------------------------
# 5.  Python / uv-managed venv
# ---------------------------------------------------------------------------


def pip_update() -> None:
    check_cmd("uv", "uv required but missing (ensure_uv failed?)")

    if not PYTHON.exists():
        print(f"{ARROW} Creating global venv at {GLOBAL_VENV}…")
        run_cmd(
            ["uv", "venv", "--python", str(SYSTEM_PYTHON), str(GLOBAL_VENV)]
        )

    run_cmd([str(PYTHON), "-m", "ensurepip", "--upgrade"])
    run_cmd([str(PYTHON), "-m", "pip", "install", "--upgrade", "pip"])

    if PYPROJECT.exists():
        print(f"{ARROW} Syncing libraries from {PYPROJECT}…")
        compiled = subprocess.run(
            ["uv", "pip", "compile", str(PYPROJECT)],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.encode()
        subprocess.run(
            ["uv", "pip", "sync", "--python", str(PYTHON), "-"],
            input=compiled,
            check=True,
        )
    else:
        print(f"{ARROW} No pyproject.toml found; skipping library sync.")

    if PYTOOLS.exists():
        print(f"{ARROW} Managing CLI tools from {PYTOOLS}…")
        desired = [
            line.strip()
            for line in PYTOOLS.read_text().splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        ]
        installed_txt = subprocess.run(
            ["uv", "tool", "list"], capture_output=True, text=True, check=True
        ).stdout
        installed = [
            ln.split()[0]
            for ln in installed_txt.splitlines()
            if ln.strip() and ln.split()[0] != "-"
        ]

        for tool in desired:
            if tool not in installed:
                print(f"    {ARROW} Installing {tool}…")
                run_cmd(["uv", "tool", "install", tool])
        for tool in installed:
            if tool not in desired:
                print(f"    {ARROW} Removing {tool}…")
                run_cmd(["uv", "tool", "uninstall", tool])
    else:
        print(
            f"{ARROW} No tool-list file at {PYTOOLS}; skipping CLI tool management."
        )


# ---------------------------------------------------------------------------
# 6.  CLI & entry-point
# ---------------------------------------------------------------------------


def parse_args(argv: Union[List[str], None] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Restow dot-files, update Homebrew, sync Python tools, and keep Rust & uv current.",
    )
    parser.add_argument(
        "-e",
        "--edit",
        action="store_true",
        help="Open the dot-files repository in $EDITOR and exit.",
    )
    parser.add_argument(
        "-s",
        "--stow",
        action="store_false",
        default=True,
        help="Supress dotfiles updates",
    )
    parser.add_argument(
        "-r",
        "--rustup",
        action="store_false",
        default=True,
        help="Supress rustup updatep",
    )
    parser.add_argument(
        "-b",
        "--homebrew",
        action="store_false",
        default=True,
        help="Supress homebrew update",
    )
    parser.add_argument(
        "-p",
        "--python",
        action="store_false",
        default=True,
        help="Supress python update",
    )
    return parser.parse_args(argv)


def edit_dotfiles() -> None:
    editor = os.environ.get("EDITOR", "vi")
    check_cmd(editor)
    subprocess.run([editor, str(DOTFILES_DIR)])


def sysup_main(argv: Union[List[str], None] = None) -> int:
    args = parse_args(argv)

    if args.edit:
        edit_dotfiles()
        return 0

    if args.homebrew:
        ensure_homebrew()
        brew_update()
    if args.rustup:
        ensure_rust()
    if args.stow:
        dotfiles_sync()
    if args.python:
        # ensure_uv()
        pip_update()

    print(f"{CHECK} All done.")
    return 0


def main() -> None:
    try:
        exit_code = sysup_main(sys.argv)
    except KeyboardInterrupt:
        print("\n")
        sys.exit(2)
    sys.exit(exit_code)
