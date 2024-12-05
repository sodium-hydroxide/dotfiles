#!/bin/bash
# Git status functions for prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

parse_git_dirty() {
    [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}

greeting() {
    echo "=== System Status ==="
    echo "Uptime: $(uptime | sed 's/.*up \([^,]*\),.*/\1/')"
    # CPU/Memory load using native macOS commands
    cpu_load=$(top -l 1 | grep "CPU usage" | awk '{print $3 $4 $5 $6 $7}')
    echo "CPU Usage: $cpu_load"
    # Memory stats using vm_stat
    vm_stat=$(vm_stat)
    page_size=16384
    mem_used=$(echo "$vm_stat" | awk -v page_size=$page_size '
        /Pages active|Pages wired/ {pages += $NF}
        END {printf "%.1f GB", (pages * page_size) / 1073741824}
    ')
    mem_total=$(sysctl hw.memsize | awk '{printf "%.1f GB", $2 / 1073741824}')
    echo "Memory: $mem_used / $mem_total"
    # System load averages
    echo "Load Averages: $(sysctl -n vm.loadavg | awk '{print $2, $3, $4}')"
    echo "Current Time: $(date -Iseconds)"
    bash --version
    echo "============================================================================="
}

# Prompt strings
PS1='\[\033[32m\]\u@\h\[\033[31m\]:$PWD$(if git rev-parse --git-dir > /dev/null 2>&1; then echo -n "\[\033[35m\]$(parse_git_branch)\[\033[33m\]$(parse_git_dirty)"; fi)\n\[\033[34m\]bash-\$\[\033[0m\] '
PS2='\[\033[33m\]→ \[\033[0m\]'
PS3='Please choose an option: '
PS4='\[\033[35m\]+${BASH_SOURCE}:${LINENO}:\[\033[0m\] '

export PS1 PS2 PS3 PS4 greeting


# Enable fzf keybindings
# FZF configuration
[ -f "/usr/share/doc/fzf/examples/key-bindings.bash" ] && source "/usr/share/doc/fzf/examples/key-bindings.bash"
[ -f "/usr/share/doc/fzf/examples/completion.bash" ] && source "/usr/share/doc/fzf/examples/completion.bash"


# Configure fzf to use your command history
export FZF_DEFAULT_OPTS="--history=$HOME/.fzf_history"

# Enable using Up arrow to search command history
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
