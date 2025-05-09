#!/bin/sh

# Shell for login and shell for interactive
export LOGIN_SHELL="/bin/dash"
export INTERACTIVE_SHELL="$HOME/.local/.venv/bin/xonsh"

# Ensure XDG_CONFIG_HOME is properly set
: "${XDG_CONFIG_HOME:=$HOME/.config}"

# Source each .sh file in the dotfiles directory
# PATH setting, etc
for f in "$XDG_CONFIG_HOME"/shell/*.sh; do
    # shellcheck source=/dev/null
    [ -r "$f" ] && . "$f"
done

# ==== Launch interactive shell ====
# Only run xonsh if this is an interactive login shell
# At the end of ~/.profile
case "$-" in
*i*)
    if [ -x "$INTERACTIVE_SHELL" ]; then
        exec "$INTERACTIVE_SHELL" --login
    fi
    ;;
esac
