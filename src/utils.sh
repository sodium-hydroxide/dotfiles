#! /bin/bash

if [[ "${UTILS_SOURCED-}" != "true" ]]; then
    UTILS_SOURCED=true

    # Color definitions
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly NC='\033[0m'

    # Global flags (can be set via command line arguments)
    FORCE_REINSTALL=false
    DRY_RUN=false
    VERBOSE=false

    # Logging
    readonly LOG_FILE="/var/log/system_config.log"

    # Logging and output functions
    print_status() {
        echo -e "${BLUE}>>>${NC} $1"
        [[ $VERBOSE == true ]] && log_operation "STATUS: $1"
    }

    print_error() {
        echo -e "${RED}Error:${NC} $1" >&2
        log_operation "ERROR: $1"
    }

    print_warning() {
        echo -e "${YELLOW}Warning:${NC} $1"
        [[ $VERBOSE == true ]] && log_operation "WARNING: $1"
    }

    print_success() {
        echo -e "${GREEN}Success:${NC} $1"
        [[ $VERBOSE == true ]] && log_operation "SUCCESS: $1"
    }

    show_progress() {
        local current=$1
        local total=$2
        local prefix=$3
        local percentage=$((current * 100 / total))
        printf "\r%s [%-50s] %d%%" "$prefix" $(printf "#%.0s" $(seq 1 $((percentage/2)))) "$percentage"
        [[ $VERBOSE == true ]] && log_operation "PROGRESS: $prefix - $percentage%"
    }

    log_operation() {
        local operation=$1
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] $operation" # >> "$LOG_FILE"
    }

    # System check functions
    check_root() {
        if [[ $EUID -eq 0 ]]; then
            print_error "This script should not be run as root"
            return 1
        fi
        return 0
    }

    ensure_command() {
        local cmd=$1
        if ! command -v "$cmd" &> /dev/null; then
            print_error "Required command '$cmd' not found"
            return 1
        fi
        return 0
    }

    ensure_dir() {
        local dir=$1
        if [[ ! -d "$dir" ]]; then
            if [[ $DRY_RUN == true ]]; then
                print_status "[DRY RUN] Would create directory: $dir"
                return 0
            fi
            mkdir -p "$dir" || {
                print_error "Failed to create directory: $dir"
                return 1
            }
        fi
        return 0
    }

    backup_file() {
        local file=$1
        local backup_dir="$HOME/.config/backups"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="$backup_dir/$(basename "$file").backup.$timestamp"

        if [[ $DRY_RUN == true ]]; then
            print_status "[DRY RUN] Would backup $file to $backup_file"
            return 0
        fi

        ensure_dir "$backup_dir" || return 1

        if [[ -f "$file" ]]; then
            cp "$file" "$backup_file" || {
                print_error "Failed to create backup of $file"
                return 1
            }
            print_status "Created backup: $backup_file"
        fi
        return 0
    }

    # Installation functions
    install_homebrew() {
        if command -v brew &>/dev/null && [[ $FORCE_REINSTALL == false ]]; then
            print_status "Homebrew already installed"
            return 0
        fi

        if [[ $DRY_RUN == true ]]; then
            print_status "[DRY RUN] Would install Homebrew"
            return 0
        fi

        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        local exit_code=$?

        if [ $exit_code -ne 0 ]; then
            print_error "Failed to install Homebrew"
            return 1
        fi

        # Add Homebrew to PATH for the current session
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if ! command -v brew &>/dev/null; then
            print_error "Homebrew installation succeeded but 'brew' command not found"
            return 1
        fi

        print_success "Homebrew installation complete"
        return 0
    }

    check_prerequisites() {
        print_status "Checking prerequisites..."

        check_root || return 1
        ensure_command "curl" || return 1
        ensure_command "git" || return 1
        install_homebrew || return 1

        print_success "All prerequisites installed successfully"
        return 0
    }
fi
