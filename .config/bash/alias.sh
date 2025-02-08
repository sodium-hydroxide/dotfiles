#!/usr/bin/env bash

lf_exit() {
    tmp="$(mktemp)"
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ] && [ "$dir" != "$(pwd)" ]; then
            cd "$dir" || return
        fi
    fi
}

cd_ls() {
    dir=$1
    cd "$dir" || return
    ls
}

alias lsold="ls"       # Use the typical ls command
alias ls="ls -CFl"     # List Files in a List
alias lsa="ls -CFla"   # List All Files in a List
alias vim="vi"         # Open VIm
alias lfold="lf"       # List Files (without Changing Directory)
alias lf="lf_exit"     # List Files (and Change Directory)
alias kd="cd_ls"       # Change Directory and List Contents
alias icat="kitten icat"
alias cluster="ssh njblair@129.82.20.78"
alias web="awrit https://html.duckduckgo.com/html/"
alias rstudio="open -a RStudio"
alias dotedit="vi ${HOME}/dotfiles"
alias colostate="cd ${HOME}/Files/COLOSTATE && ls"

