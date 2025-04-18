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
add_to_path "$HOME/bin"
add_to_path "$HOME/bin/macos"

# Development tools
add_to_path "/usr/local/opt/llvm/bin"
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/.local/.venv/bin"

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

# Environment variables
export BASH_SILENCE_DEPRECATION_WARNING=
export LOGIN_SHELL="/bin/dash"
export INTERACTIVE_SHELL="$HOME/.local/.venv/bin/xonsh"
export SHELL="$LOGIN_SHELL"
export EDITOR="nvim"
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

# Development Environment Variables
# python
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PYTHONPATH="$HOME/.local/lib/python3/site-packages:$PYTHONPATH"
export LDFLAGS="-L$(/opt/homebrew/bin/brew --prefix tcl-tk)/lib"      # tkinter
export CPPFLAGS="-I$(/opt/homebrew/bin/brew --prefix tcl-tk)/include" # tkinter
export TCL_LIBRARY=$(/opt/homebrew/bin/brew --prefix tcl-tk)/lib/tcl8.6

# R
export R_HOME="/Library/Frameworks/R.framework/Resources"

# mcnp
export MCNP_HOME="$HOME/.MCNP/mcnp63/exec"
export DATAPATH="$MCNP_HOME/MCNP_DATA"
export XSDIR="${DATAPATH}/xsdir"

# ==== Launch interactive shell ====
# Only run xonsh if this is an interactive login shell
# At the end of ~/.profile
case "$-" in
*i*)
    if [ -x "$INTERACTIVE_SHELL" ]; then
        exec "$INTERACTIVE_SHELL" --login
    fi
    ;;
esac
