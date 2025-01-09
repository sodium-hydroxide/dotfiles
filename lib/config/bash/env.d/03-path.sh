#!/bin/bash

codex_bootstrap="/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr"
dotfiles="$HOME/dotfiles"

paths=(
    "$dotfiles/bin"                             # System Settings Config
    "$dotfiles/scripts/alias/bin"               # Aliases for Shell Programs
    "$dotfiles/utils/bin"                       # Utility scripts
    "$HOME/.config/nvim/bin"
    #=========================================================================>
    "/usr/local/opt/llvm/bin" # Low Level Virtual Machine
    "$HOME/.local/bin"                          # UV (python) Management
    "$HOME/.venv/bin"                           # Global Python Environment
    "$(brew --prefix tcl-tk)/bin"               # Tkinter for Python
    "$CABAL_HOME/bin"                           # Haskell Package Manager
    "$HASKELL_HOME/bin"                         # Haskell Compiler
    "$CARGO_HOME/bin"                           # Rust Package Manager
    "$HOME/.juliaup/bin"                        # Julia Manager
    "/opt/homebrew/opt/julia/bin"               # Julia Compiler
    "/opt/homebrew/opt/openjdk/bin"             # Java Compiler
    "$(npm config get prefix 2>/dev/null)/bin"  # Node.js Environment
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

