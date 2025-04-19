#!/bin/sh

export VIRTUAL_ENV_DISABLE_PROMPT=1
export PYTHONPATH="$HOME/.local/lib/python3/site-packages:$PYTHONPATH"
export LDFLAGS="-L$(/opt/homebrew/bin/brew --prefix tcl-tk)/lib"      # tkinter
export CPPFLAGS="-I$(/opt/homebrew/bin/brew --prefix tcl-tk)/include" # tkinter
export TCL_LIBRARY=$(/opt/homebrew/bin/brew --prefix tcl-tk)/lib/tcl8.6
