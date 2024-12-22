#!/bin/bash

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

alias gui="open"
alias mdp="glow -p"
alias lsold="ls"
alias ls="ls -CFl"
alias lsa="ls -CFla"
alias vi="nvim"
alias vim="nvim"
alias lfold="lf"
alias lf="lf_exit"
alias kd="cd_ls"
alias notes="open -a Obsidian"

