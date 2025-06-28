#!/bin/bash
# Standard Environment Variables
export BASH_SILENCE_DEPRECATION_WARNING=1
export SHELL="/bin/bash"
export EDITOR="nvim"
export PAGER="bat"
export BROWSER=""
export LANG="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export TERM=xterm-256color
export COLORTERM=truecolor
export ICLOUDDRIVE="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
export XDG_CONFIG_HOME="$HOME/.config"

# Package Manager Variables
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
export HOMEBREW_BREW_FILE="${HOMEBREW_PREFIX}/bin/brew"
# curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
export CARGO_HOME="/opt/cargo"
export RUSTUP_HOME="${CARGO_HOME}/rustup"
# curl -LsSf https://astral.sh/uv/install.sh | sh
export UV_INSTALL_PATH="/opt/uv"

# Git Environment Variables
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"

# # MCNP Environment Variables
# export MCNP_HOME="$HOME/.MCNP/mcnp63/exec"
# export DATAPATH="$MCNP_HOME/MCNP_DATA"
# export XSDIR="${DATAPATH}/xsdir"
# export MCNP_CLUSTER="njblair@129.82.20.78"

# # R Environment Variables
# export R_HOME="/Library/Frameworks/R.framework/Resources"

NEWPATH="$HOME/.local/bin:$CARGO_HOME/bin:$UV_INSTALL_PATH/bin:$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin"
PATH="$NEWPATH:$PATH"
export PATH

if [ -f ~/.bashrc ]; then
    # shellcheck disable=SC1091
    source "$HOME/.bashrc"
fi
