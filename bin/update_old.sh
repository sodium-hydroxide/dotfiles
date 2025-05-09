#!/bin/sh
# Update dot‑files, Homebrew, and Python CLI tools
# POSIX‑sh; exits on first error
set -e

#######################################################################
# 0.  Paths & filenames
#######################################################################
DOTFILES_DIR="$HOME/dotfiles"

PACKAGELISTS="$DOTFILES_DIR/package-list"
PYPROJECT="$PACKAGELISTS/pyproject.toml"
PYTOOLS="$PACKAGELISTS/tool-list.txt"

SYSTEMPYTHON="/opt/homebrew/bin/python3"
GLOBAL_VENV="$HOME/.local/.venv"
PYTHON="$GLOBAL_VENV/bin/python"

#######################################################################
# Helpers
#######################################################################
error() {
    printf '%s\n' "Error: $*" >&2
    exit 1
}
check_cmd() { command -v "$1" >/dev/null 2>&1 || error "'$1' not found – $2"; }

usage() {
    cat <<-EOF
Usage: update [--help]

Re-stow dot-files, update Homebrew, and sync Python tools.
EOF
}

edit_dotfiles() {
    vi "$DOTFILES_DIR"
}

#######################################################################
# 1.  Dot‑files via GNU Stow
#######################################################################
_stow_package_list() (
    cd "$DOTFILES_DIR" || exit 1
    for d in */; do
        case "${d%/}" in
        bin | package-list) continue ;; # not Stow packages
        esac
        printf '%s ' "${d%/}"
    done
)

dotfiles_sync() {
    check_cmd stow "e.g. 'brew install stow'"
    find "$HOME/dotfiles" -name ".DS_Store" -delete
    pkgs=$(_stow_package_list)
    printf '→ Restowing packages: %s\n' "$pkgs"
    # shellcheck disable=SC2086
    stow --restow --verbose \
        --dir="$DOTFILES_DIR" \
        --target="$HOME" \
        $pkgs
}

#######################################################################
# 2.  Homebrew
#######################################################################
brew_update() {
    check_cmd brew "install Homebrew from https://brew.sh/"
    printf '→ Updating Homebrew…\n'
    brew update
    brew upgrade

    # Expand all matching files (root Brewfile, Brewfile‑rust …)
    set -- "$PACKAGELISTS"/*Brewfile*

    # If nothing matched, stop early
    [ -e "$1" ] || {
        printf '→ No Brewfiles found – skipping bundle.\n'
        return
    }

    printf '→ Bundling: %s\n' "$*"
    for f; do
        cat "$f"
    done | brew bundle --file=- --cleanup --force # --file=- = read from STDIN :contentReference[oaicite:1]{index=1}

    brew cleanup
}

#######################################################################
# 3.  Python / uv
#######################################################################
pip_update() {
    check_cmd uv "install uv via pip, pipx, or your venv"

    # 1) Ensure the global venv exists
    if [ ! -x "$PYTHON" ]; then
        printf '→ Creating global venv at %s…\n' "$GLOBAL_VENV"
        uv venv --python "$SYSTEMPYTHON" "$GLOBAL_VENV"
    fi

    # 2) Bootstrap and upgrade pip
    "$PYTHON" -m ensurepip --upgrade
    "$PYTHON" -m pip install --upgrade pip

    # 3) Sync library dependencies into the venv
    if [ -f "$PYPROJECT" ]; then
        printf '→ Syncing libraries from %s…\n' "$PYPROJECT"
        uv pip compile "$PYPROJECT" | uv pip sync --python "$PYTHON" -
    else
        printf '→ No pyproject.toml found; skipping library sync.\n'
    fi

    # 4) Manage CLI tools
    if [ -f "$PYTOOLS" ]; then
        printf '→ Managing CLI tools from %s…\n' "$PYTOOLS"

        desired=$(grep -Ev '^\s*($|#)' "$PYTOOLS")
        installed=$(uv tool list 2>/dev/null |
            awk 'NF && $1 != "-" {print $1}')

        for tool in $desired; do
            printf '  → Ensuring %s is installed…\n' "$tool"
            echo "$installed" | grep -qx "$tool" || uv tool install "$tool"
        done

        for tool in $installed; do
            echo "$desired" | grep -qx "$tool" || uv tool uninstall "$tool"
        done
    else
        printf '→ No tool‑list file at %s; skipping CLI tool management.\n' "$PYTOOLS"
    fi
}

#######################################################################
# 4.  Main
#######################################################################
main() {
    [ "$1" = "-h" ] || [ "$1" = "--help" ] && {
        usage
        exit 0
    }
    [ "$1" = "-e" ] || [ "$1" = "--edit" ] && {
        edit_dotfiles
        exit 0
    }

    dotfiles_sync
    brew_update
    pip_update
    printf '✅ All done.\n'
}

main "$@"
