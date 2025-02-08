#!/usr/bin/env bash

codex_bootstrap="/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr"
dotfiles="$HOME/dotfiles"

paths=(
    "$HOME/bin"
    "$HOME/bin/macos"                           # Launch Applications in GUI
    "$dotfiles/scripts/alias/bin"               # Aliases for Shell Programs
    "$dotfiles/utils/bin"                       # Utility scripts
    #=========================================================================>
    "/usr/local/opt/llvm/bin" # Low Level Virtual Machine
    "$HOME/.local/bin"                          # UV (python) Management
    "$HOME/.venv/bin"                           # Global Python Environment
    "$(/opt/homebrew/bin/brew --prefix tcl-tk)/bin" # Tkinter for Python
    "/opt/homebrew/opt/openjdk/bin"             # Java Compiler
    #=========================================================================>
    "$HOME/.MCNP/mcnparse/bin"                  # MCNP Parser
    "$MCNP_HOME/mcnp-6.3.0-Darwin/bin"          # MCNP Executable
    "$MCNP_HOME/mcnp-6.3.0-Qt-preview-Darwin/bin"
    #=========================================================================>
    "/opt/homebrew/bin"                         # Homebrew
    "/opt/homebrew/sbin"                        # Homebrew Sysadmin
    #=========================================================================>
    "/usr/local/bin"                            #
    "/usr/local/sbin"                           #
    "/usr/bin"                                  #
    "/usr/sbin"                                 #
    "/bin"                                      #
    "/sbin"                                     #
    "/Library/Apple/usr/bin"                    #
    "/System/Cryptexes/App/usr/bin"             #
    #=========================================================================>
    "${codex_bootstrap}/local/bin"              #
    "${codex_bootstrap}/bin"                    #
    "${codex_bootstrap}/appleinternal/bin"      #
    #=========================================================================>
)
PATH=$(
    IFS=:
    echo "${paths[*]}"
)
export PATH
