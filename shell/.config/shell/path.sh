#!/bin/sh
# Setting PATH Variable
codex_bootstrap="/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr"
PATH_ENTRIES=""
add_to_path() {
    if [ -d "$1" ]; then
        PATH_ENTRIES="${PATH_ENTRIES:+$PATH_ENTRIES:}$1"
    fi
}

# User scripts
add_to_path "$HOME/dotfiles/bin"
add_to_path "$HOME/dotfiles/bin/macos"
add_to_path "$HOME/dotfiles/bin/alias"

# Development tools
add_to_path "/usr/local/opt/llvm/bin"
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.local/.venv/bin"
add_to_path "$HOME/.cargo/bin"

# This requires `brew` to be available already in the path
brew_tcltk_path="$(/opt/homebrew/bin/brew --prefix tcl-tk 2>/dev/null)/bin"
add_to_path "$brew_tcltk_path"

add_to_path "/opt/homebrew/opt/openjdk/bin"

# MCNP paths
add_to_path "$HOME/.MCNP/mcnparse/bin"
add_to_path "$MCNP_HOME/mcnp-6.3.0-Darwin/bin"
add_to_path "$MCNP_HOME/mcnp-6.3.0-Qt-preview-Darwin/bin"

# Homebrew core paths
add_to_path "/opt/homebrew/bin"
add_to_path "/opt/homebrew/sbin"

# System paths
add_to_path "/usr/local/bin"
add_to_path "/usr/local/sbin"
add_to_path "/usr/bin"
add_to_path "/usr/sbin"
add_to_path "/bin"
add_to_path "/sbin"
add_to_path "/Library/Apple/usr/bin"
add_to_path "/System/Cryptexes/App/usr/bin"

# Apple cryptex paths
add_to_path "${codex_bootstrap}/local/bin"
add_to_path "${codex_bootstrap}/bin"
add_to_path "${codex_bootstrap}/appleinternal/bin"

# Export the final PATH
export PATH="$PATH_ENTRIES"
