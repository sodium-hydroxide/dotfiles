#!/bin/bash

set -euo pipefail

DOTFILES_DIR="$HOME/Files/dotfiles"

BREW="/opt/homebrew/bin/brew"
RUSTUP="/opt/cargo/bin/rustup"
CARGO="/opt/cargo/bin/cargo"
UV="$HOME/.local/bin/uv"

# Move to dotfiles
cd "$DOTFILES_DIR" || exit 1

# -----------------------------------------------------------------------------
# Homebrew setup
# -----------------------------------------------------------------------------

if ! command -v stow &>/dev/null; then
    echo "stow not found, installing via Homebrew..."
    "$BREW" install stow
fi

"$BREW" update
"$BREW" upgrade
"$BREW" bundle --file="$DOTFILES_DIR/Brewfile" --cleanup
"$BREW" cleanup

# -----------------------------------------------------------------------------
# Cargo setup
# -----------------------------------------------------------------------------

if [[ -x "$RUSTUP" ]]; then
    "$RUSTUP" self update
    "$RUSTUP" update
fi

cargo_install() {
    local tool="$1"
    if ! "$CARGO" install --list | grep -q "^$tool "; then
        echo "Installing $tool with cargo"
        "$CARGO" install --locked "$tool"
    else
        echo "$tool already installed"
    fi
}

cargo_install "just"
cargo_install "bat"
cargo_install "ripgrep"
cargo_install "fd-find"

# -----------------------------------------------------------------------------
# uv setup
# -----------------------------------------------------------------------------

uv_install() {
    local tool="$1"
    echo "Installing/upgrading $tool with uv"
    "$UV" pip install --upgrade "$tool"
}

uv_install "ruff"
uv_install "pyright"

# # Setup Vscode Extensions
# echo "Adding vscode extensions"
# while read -r extension; do
#     code --install-extension "$extension"
# done <<EOF
# charliermarsh.ruff
# davidanson.vscode-markdownlint
# docker.docker
# esbenp.prettier-vscode
# foxundermoon.shell-format
# guilhermestella.github-light-hight-contrast-theme
# h5web.vscode-h5web
# james-yu.latex-workshop
# kevinrose.vsc-python-indent
# kortina.vscode-markdown-notes
# mechatroner.rainbow-csv
# ms-azuretools.vscode-containers
# ms-azuretools.vscode-docker
# ms-python.debugpy
# ms-python.python
# ms-python.vscode-pylance
# ms-toolsai.datawrangler
# ms-toolsai.jupyter
# ms-toolsai.jupyter-keymap
# ms-toolsai.jupyter-renderers
# ms-toolsai.vscode-jupyter-cell-tags
# ms-toolsai.vscode-jupyter-slideshow
# ms-vscode-remote.remote-containers
# ms-vscode-remote.remote-ssh
# ms-vscode-remote.remote-ssh-edit
# ms-vscode-remote.remote-wsl
# ms-vscode-remote.vscode-remote-extensionpack
# ms-vscode.cpptools
# ms-vscode.cpptools-extension-pack
# ms-vscode.cpptools-themes
# ms-vscode.hexeditor
# ms-vscode.makefile-tools
# ms-vscode.remote-explorer
# ms-vscode.remote-server
# nickfode.latex-formatter
# njpwerner.autodocstring
# posit.air-vscode
# quarto.quarto
# repositony.vscodemcnp
# rodolphebarbanneau.python-docstring-highlighter
# skellock.just
# stkb.rewrap
# streetsidesoftware.code-spell-checker
# streetsidesoftware.code-spell-checker-cspell-bundled-dictionaries
# timonwong.shellcheck
# usernamehw.errorlens
# vscodevim.vim
# yoshi389111.visible-whitespace
# EOF

# -----------------------------------------------------------------------------
# Stow dotfiles
# -----------------------------------------------------------------------------

STOW_DIR="$DOTFILES_DIR/configfiles"
if [[ -d "$STOW_DIR" ]]; then
    echo "Stowing dotfiles from $STOW_DIR to $HOME..."
    cd "$DOTFILES_DIR" || exit 1
    stow --target="$HOME" --delete configfiles
    stow --target="$HOME" configfiles
else
    echo "No stowable configfiles found in $STOW_DIR"
fi
