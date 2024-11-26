#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/utils.sh"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/01_brew/main_brew.sh"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/02_toolchain/main_toolchain.sh"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/03_macos/main_macos.sh"
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/04_config/main_config.sh"

show_usage() {
    cat << EOF
Usage: $0 [options]

Options:
    -h, --help              Show this help message
    -a, --all              Run all operations (default if no flags specified)
    -b, --brew             Update Homebrew and installed packages
    -t, --toolchain        Update development toolchains
    -T, --reinstall-toolchain  Completely reinstall development toolchains
    -m, --macos            Apply macOS system settings
    -c, --config           Sync configuration files
    -f, --force            Force operations (reinstall packages, overwrite configs)
    -d, --dry-run          Show what would be done without making changes
    -v, --verbose          Enable verbose output

Examples:
    $0 --brew --toolchain     # Only update Homebrew and toolchains
    $0 --macos --config       # Only apply system settings and sync configs
    $0 --all --force          # Run everything with forced reinstalls
EOF
}

parse_args() {
    DO_ALL=false
    DO_BREW=false
    DO_TOOLCHAIN=false
    DO_MACOS=false
    DO_CONFIG=false
    REINSTALL_TOOLCHAIN=false
    export FORCE=false
    export DRY_RUN=false
    export VERBOSE=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--all)
                DO_ALL=true
                ;;
            -b|--brew)
                DO_BREW=true
                ;;
            -t|--toolchain)
                DO_TOOLCHAIN=true
                ;;
            -T|--reinstall-toolchain)
                DO_TOOLCHAIN=true
                REINSTALL_TOOLCHAIN=true
                ;;
            -m|--macos)
                DO_MACOS=true
                ;;
            -c|--config)
                DO_CONFIG=true
                ;;
            -f|--force)
                export FORCE=true
                ;;
            -d|--dry-run)
                export DRY_RUN=true
                ;;
            -v|--verbose)
                export VERBOSE=true
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
        shift
    done

    # If no specific operations selected, do everything
    if [[ $DO_ALL == false ]] && \
       [[ $DO_BREW == false ]] && \
       [[ $DO_TOOLCHAIN == false ]] && \
       [[ $DO_MACOS == false ]] && \
       [[ $DO_CONFIG == false ]]; then
        DO_ALL=true
    fi
}

run_operation() {
    local operation=$1
    local function_name=$2
    shift 2

    if [[ $DRY_RUN == true ]]; then
        print_status "[DRY RUN] Would run: $operation"
        return 0
    fi

    print_status "Running: $operation"
    if $function_name "$@"; then
        print_success "$operation completed"
        return 0
    else
        print_error "$operation failed"
        return 1
    fi
}

run_operations() {
    local exit_status=0

    # Check prerequisites if necessary
    if [[ $DO_ALL == true ]] || [[ $DO_BREW == true ]] || [[ $DO_TOOLCHAIN == true ]]; then
        run_operation "Checking prerequisites" check_prerequisites || return 1
    fi

    # Homebrew updates
    if [[ $DO_ALL == true ]] || [[ $DO_BREW == true ]]; then
        run_operation "Updating Homebrew packages" main_brew || exit_status=$?
    fi

    # Toolchain updates/installation
    if [[ $DO_ALL == true ]] || [[ $DO_TOOLCHAIN == true ]]; then
        if [[ $REINSTALL_TOOLCHAIN == true ]] || [[ $FORCE == true ]]; then
            run_operation "Installing development toolchains" install_toolchains || exit_status=$?
        else
            run_operation "Updating development toolchains" update_toolchains || exit_status=$?
        fi
    fi

    # macOS settings
    if [[ $DO_ALL == true ]] || [[ $DO_MACOS == true ]]; then
        run_operation "Applying macOS settings" main_macos || exit_status=$?
    fi

    # Config sync
    if [[ $DO_ALL == true ]] || [[ $DO_CONFIG == true ]]; then
        run_operation "Syncing configuration files" sync_config || exit_status=$?
    fi

    return $exit_status
}

main() {
    parse_args "$@"

    if [[ $VERBOSE == true ]]; then
        set -x
    fi

    if ! run_operations; then
        print_error "One or more operations failed"
        exit 1
    fi

    print_success "All operations completed successfully!"
}

# Run main function with all arguments
