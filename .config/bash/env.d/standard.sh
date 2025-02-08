#!/usr/bin/env bash

export BASH_SILENCE_DEPRECATION_WARNING=1
export SHELL="/bin/bash"
export EDITOR="nvim"
export BROWSER=""
export LANG="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

export TERM=xterm-256color
export COLORTERM=truecolor

# browser() {
#     PREFERRED_BROWSER="Brave Browser"
#     if open -a "$PREFERRED_BROWSER" --args "$1" 2>/dev/null; then
#         echo ""
#     else
#         open -a Safari "$1"
#     fi
#
# }
# export BROWSER="browser"

