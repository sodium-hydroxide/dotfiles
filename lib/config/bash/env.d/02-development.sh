#!/bin/bash
# rust
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export RUST_BACKTRACE=1

# python
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PYTHONPATH="$HOME/.local/lib/python3/site-packages:$PYTHONPATH"
export LDFLAGS="-L$(brew --prefix tcl-tk)/lib" # tkinter
export CPPFLAGS="-I$(brew --prefix tcl-tk)/include" # tkinter
export TCL_LIBRARY=$(brew --prefix tcl-tk)/lib/tcl8.6

# julia
export JULIA_DEPOT_PATH="$HOME/.julia"
export JULIA_NUM_THREADS="auto"
export JULIA_EDITOR="vim"

# node
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
export NODE_ENV="development"
export NODE_OPTIONS="--max-old-space-size=4096"

# haskell
export CABAL_HOME="${HOME}/.cabal"
export HASKELL_HOME="${HOME}/.ghcup"

# mcnp
export MCNP_HOME="$HOME/.MCNP/mcnp63/exec"
export DATAPATH="$MCNP_HOME/MCNP_DATA"
export XSDIR="${DATAPATH}/xsdir"
