#!/bin/bash
PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
PS1='\u@\h:$(pwd)  ${PS1_CMD1}\n> '
export PS1

alias ls="/bin/ls -F"
alias ll="/bin/ls -lhF"
alias la="/bin/ls -lhFA"

alias vi="nvim"
alias vim="nvim"
alias lg="lazygit"
