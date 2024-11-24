#! /bin/bash

# Homebrew taps to be managed
BREW_TAPS=(
    # Modern versions of homebrew don't need these
    # "homebrew/core"
    # "homebrew/cask"
)

# Formulae to be managed
BREW_FORMULAE=(
    "bash"
    "wget"
    "git"       # needs conf
    "gh"        # needs conf
    "tmux"      # needs conf
    "lf"        # needs conf
    "massren"
    "ffmpeg"
    "htop"
    "nvim"
)

# Casks to be managed
BREW_CASKS=(
    "bbedit"    # needs license
    "docker"
    "calibre"
    "zotero"
    "hiddenbar"
    "plex"
    "grandperspective"
    "pdf-expert" # needs license
    "whatsapp"
    "backblaze"
    "mission-control-plus"
    "xquartz"
    "visual-studio-code"
)

# Individual file mappings
CONFIG_FILE_MAPPINGS=(
    "config.txt:$HOME/Library/Application Support"
    "settings.json:$HOME/.config"
)

# Directory mappings - format: "source_dir:target_dir"
CONFIG_DIR_MAPPINGS=(
    "nvim:$HOME/.config/nvim"
)

# Bashrc configuration
read -r -d '' BASHRC_CONTENT << 'EOL'
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
    echo "=================="
}

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

parse_git_dirty() {
    [[ $(git status --porcelain 2> /dev/null) ]] && echo "*"
}

export PS1='\[\033[32m\]\u@\h\[\033[31m\]:$PWD$(if git rev-parse --git-dir > /dev/null 2>&1; then echo -n "\[\033[35m\]$(parse_git_branch)\[\033[33m\]$(parse_git_dirty)"; fi)\n\[\033[34m\]\$\[\033[0m\] '
export PS2='\[\033[33m\]→ \[\033[0m\]'
export PS3='Please choose an option: '
export PS4='\[\033[35m\]+${BASH_SOURCE}:${LINENO}:\[\033[0m\] '

export BASH_SILENCE_DEPRECATION_WARNING=1
export SHELL="/bin/bash"
export EDITOR="vim"
export LANG="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export PATH="\
${HOME}/dotfiles/bin:\
/opt/homebrew/bin:\
/opt/homebrew/sbin:\
/usr/local/bin:\
/System/Cryptexes/App/usr/bin:\
/usr/bin:\
/bin:\
/usr/sbin:\
/sbin:\
/usr/local/sbin:\
/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:\
/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:\
/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
"

alias gui="open"
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

greeting
EOL