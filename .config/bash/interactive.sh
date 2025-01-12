#!/usr/bin/env bash

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

parse_git_dirty() {
    [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}

PS1='\[\033[32m\]\u@\h\[\033[31m\]:$PWD$(if git rev-parse --git-dir > /dev/null 2>&1; then echo -n "\[\033[35m\]$(parse_git_branch)\[\033[33m\]$(parse_git_dirty)"; fi)\n\[\033[34m\]bash-\$\[\033[0m\] '
PS2='\[\033[33m\]→ \[\033[0m\]'
PS3='Please choose an option: '
PS4='\[\033[35m\]+${BASH_SOURCE}:${LINENO}:\[\033[0m\] '

export PS1 PS2 PS3 PS4

