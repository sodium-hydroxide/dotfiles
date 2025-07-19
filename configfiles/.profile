#!/bin/bash
#       Standard Environment Variables
export BASH_SILENCE_DEPRECATION_WARNING=1
export SHELL="/bin/bash"
export EDITOR="vim"
export PAGER="less"
export BROWSER=""
export LANG="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export TERM=xterm-256color
export COLORTERM=truecolor
#   XDG Config
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_BIN_HOME="$HOME/.local/bin"
#   HOME Directory
export FILES_DIR="$HOME/Files"
export DOTFILES_DIR="$HOME/.dotfiles"
export APPLICATIONS_GLOBAL="/Applications"
export APPLICATIONS_LOCAL="$HOME/Applications"
#       Package Manager Variables
export PACKAGE_MANAGERS_PREFIX="/opt"
#   Brew
export HOMEBREW_PREFIX="$PACKAGE_MANAGERS_PREFIX/homebrew"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
export HOMEBREW_BREW_FILE="$HOMEBREW_PREFIX/bin/brew"
export HOMEBREW_BINARIES="$HOMEBREW_PREFIX/bin"
export HOMEBREW_SBINARIES="$HOMEBREW_PREFIX/sbin"
#   Python / UV
export UV_PREFIX="$PACKAGE_MANAGERS_PREFIX/uv"
export UV_CACHE_DIR="$UV_PREFIX/cache"
export UV_INSTALL_DIR="$UV_PREFIX/bin"
export UV_PYTHON_PREFIX="$UV_PREFIX/python"
export UV_PYTHON_CACHE_DIR="$UV_PYTHON_PREFIX/cache"
export UV_PYTHON_INSTALL_DIR="$UV_PYTHON_PREFIX/install"
export UV_TOOL_BIN_DIR="$UV_PREFIX/bin"
export UV_TOOL_DIR="$UV_PREFIX/tool"
export UV_BINARIES="$UV_PREFIX/bin"
#       Program Specific Environment Variables
#   Git
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"
# #   MCNP
# export MCNP_HOME="$HOME/.MCNP/mcnp63/exec"
# export DATAPATH="$MCNP_HOME/MCNP_DATA"
# export XSDIR="${DATAPATH}/xsdir"
# export MCNP_CLUSTER="njblair@129.82.20.78"
# #   R Environment Variables
# export R_HOME="/Library/Frameworks/R.framework/Resources"
#   zoxide
export _ZO_ECHO=1
#   Wezterm
export WEZTERM_CONFIG_FILE="$XDG_CONFIG_HOME/wezterm/wezterm.lua"
#   Wolfram Engine
WOLFRAM_PATH="/Applications/Wolfram\ Engine.app/Contents/MacOS"
#       PATH
NEWPATH="$XDG_BIN_HOME:$UV_BINARIES:$HOMEBREW_BINARIES:$HOMEBREW_SBINARIES:$WOLFRAM_PATH"
export PATH="$NEWPATH:$PATH"
#       Interactivity
if [[ -n "$PS1" ]] && [ -f "$HOME/.bashrc" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.bashrc"
fi



# Setting PATH for Python 3.13
# The original version is saved in .profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin:${PATH}"
export PATH
