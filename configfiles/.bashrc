#!/bin/bash
#       Prompt Customization
PROMPT_COMMAND='PS1_CMD1=$(git branch --show-current 2>/dev/null)'
PS1='\u@\h:$(pwd)  ${PS1_CMD1}\n> '
export PS1
#       Aliases
#   File Listing
alias ls="/bin/ls -F"
alias ll="/bin/ls -lhF"
alias la="/bin/ls -lhFA"

