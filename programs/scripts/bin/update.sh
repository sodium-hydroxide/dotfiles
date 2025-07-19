#!/usr/bin/env bash

# [ <-- needed because of Argbash

set -euo pipefail

PROGRAMS_DIR="$DOTFILES_DIR/programs"

update_dotfiles() {
    cd "$DOTFILES_DIR" || exit 1
    stow --restow --target="$HOME" configfiles
}

update_programs() {
    # Make sure we are in programs dir before running
    program="$1"
    stow --restow --target="$HOME/.local" "$program"
}

update_brew() {
    brew update
    brew upgrade --greedy
    brew bundle --file="$PROGRAMS_DIR/Brewfile" --cleanup
    brew cleanup
}

main() {
    update_dotfiles
    cd "$PROGRAMS_DIR" || exit 1
    update_programs "scripts"
    update_programs "argbash"

    update_brew
}

main $@

# uv_install "ruff"
# uv_install "pyright"
# uv_install "pyspread"
# uv_install "yt-dlp"

# ] <-- needed because of argbash
