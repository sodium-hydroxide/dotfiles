CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/utils.sh"
source "$CURRENT_DIR/brew.sh"
source "$CURRENT_DIR/macos.sh"
source "$CURRENT_DIR/symlinks.sh"
source "$CURRENT_DIR/upgrade_bash.sh"
source "$CURRENT_DIR/toolchains/install.sh"

show_usage() {
    echo "Usage: $0 [-f|--force]"
    echo "Options:"
    echo "  -f, --force    Force reinstall of all packages"
    echo "  -h, --help     Show this help message"
}

main() {
    local total_steps=9
    local current_step=0

    print_status "Starting system configuration..."

#     ((current_step++))
#     show_progress $current_step $total_steps "Checking prerequisites"
#     check_prerequisites

    ((current_step++))
    show_progress $current_step $total_steps "Syncing Homebrew"
    sync_homebrew

    ((current_step++))
    show_progress $current_step $total_steps "Installing development toolchains"
    install_toolchains

    ((current_step++))
    show_progress $current_step $total_steps "Syncing configuration files"
    sync_symlinks

    ((current_step++))
    show_progress $current_step $total_steps "Upgrading bash"
    upgrade_bash

    ((current_step++))
    show_progress $current_step $total_steps "Writing defaults"
    write_my_defaults

    ((current_step++))
    show_progress $current_step $total_steps "Finishing up"
    print_status "System configuration completed successfully!"
}
