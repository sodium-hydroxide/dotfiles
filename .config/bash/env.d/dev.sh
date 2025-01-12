#!/usr/bin/env bash

# python
export VIRTUAL_ENV_DISABLE_PROMPT=1
export PYTHONPATH="$HOME/.local/lib/python3/site-packages:$PYTHONPATH"
export LDFLAGS="-L$(/opt/homebrew/bin/brew --prefix tcl-tk)/lib" # tkinter
export CPPFLAGS="-I$(/opt/homebrew/bin/brew --prefix tcl-tk)/include" # tkinter
export TCL_LIBRARY=$(/opt/homebrew/bin/brew --prefix tcl-tk)/lib/tcl8.6

# R
export R_HOME="/usr/local/bin/R"

# mcnp
export MCNP_HOME="$HOME/.MCNP/mcnp63/exec"
export DATAPATH="$MCNP_HOME/MCNP_DATA"
export XSDIR="${DATAPATH}/xsdir"

