#!/bin/bash
# rust
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export RUST_BACKTRACE=1

# python
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PYTHONPATH="$HOME/.local/lib/python3/site-packages:$PYTHONPATH"

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

# mcnp
export XSDIR=""
