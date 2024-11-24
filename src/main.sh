CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/utils.sh"
source "$CURRENT_DIR/brew.sh"
source "$CURRENT_DIR/conf_files.sh"
source "$CURRENT_DIR/macos.sh"
source "$CURRENT_DIR/upgrade_bash.sh"
source "$CURRENT_DIR/../lib/params.sh"  # Load parameters


show_usage() {
    echo "Usage: $0 [-f|--force]"
    echo "Options:"
    echo "  -f, --force    Force reinstall of all packages"
    echo "  -h, --help     Show this help message"
}


main() {
    local total_steps=7
    local current_step=0

    print_status "Starting system configuration..."

#     ((current_step++))
#     show_progress $current_step $total_steps "Checking prerequisites"
#     check_prerequisites

    ((current_step++))
    show_progress $current_step $total_steps "Syncing Homebrew"
    sync_homebrew "${HOMEBREW_PARAMS[@]}"

    ((current_step++))
    show_progress $current_step $total_steps "Upgrading bash"
    upgrade_bash

    ((current_step++))
    show_progress $current_step $total_steps "Writing defaults"
    write_my_defaults

    ((current_step++))
    show_progress $current_step $total_steps "Writing config files"
    write_config_files "${CONFIG_PARAMS[@]}"

    ((current_step++))
    show_progress $current_step $total_steps "Writing bashrc"
    write_bashrc "$BASHRC_CONTENT"

    ((current_step++))
    show_progress $current_step $total_steps "Finishing up"
    print_status "System configuration completed successfully!"
}
