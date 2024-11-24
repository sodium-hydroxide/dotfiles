#! /bin/bash

if [[ "${UTILS_SOURCED-}" != "true" ]]; then
    UTILS_SOURCED=true

    CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Color definitions
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
    FORCE_REINSTALL=false
    DRY_RUN=false
    declare LOG_FILE="/var/log/system_config.log"

    parse_params() {
        local array_name=$1  # Name of the array to populate
        shift               # Remove array_name from arguments

        local current_section=""
        local result=()     # Temporary array to store results

        for param in "$@"; do
            if [[ -z "$param" ]]; then
                current_section=""
                continue
            fi
        
            if [[ "$param" =~ ^[A-Z_]+$ ]]; then
                current_section=$param
                continue
            fi
        
            if [[ -n "$current_section" ]]; then
                result+=("$param")
            fi
        done

        # Create the output in a format that can be eval'd
        local output="$array_name=("
        for item in "${result[@]}"; do
            output+=" \"$item\""
        done
        output+=")"

        # Use eval to assign to the array variable
        eval "$output"
    }
    parse_params_old() {
        local params=("$@")
        local current_section=""
        local -n result_array=$1
        result_array=()

        for param in "${params[@]:1}"; do  # Skip first element (array name)
            if [[ -z "$param" ]]; then
                current_section=""
                continue
            fi
            
            if [[ "$param" =~ ^[A-Z_]+$ ]]; then
                current_section=$param
                continue
            fi
            
            if [[ -n "$current_section" ]]; then
                result_array+=("$param")
            fi
        done
    }

    print_status() {
        echo -e "${BLUE}>>>${NC} $1"
    }

    print_error() {
        echo -e "${RED}Error:${NC} $1" >&2
    }

    print_warning() {
        echo -e "${YELLOW}Warning:${NC} $1"
    }

    print_success() {
        echo -e "${GREEN}Success:${NC} $1"
    }

    show_progress() {
        local current=$1
        local total=$2
        local prefix=$3
        local percentage=$((current * 100 / total))
        printf "\r%s [%-50s] %d%%" "$prefix" $(printf "#%.0s" $(seq 1 $((percentage/2)))) "$percentage"
    }

    # Function to check if running as root
    check_root() {
        if [[ $EUID -eq 0 ]]; then
            print_error "This script should not be run as root"
            exit 1
        fi
    }

    # Function to ensure a command exists
    ensure_command() {
        local cmd=$1
        if ! command -v "$cmd" &> /dev/null; then
            print_error "Required command '$cmd' not found"
            return 1
        fi
        return 0
    }

    # Function to create directory if it doesn't exist
    ensure_dir() {
        local dir=$1
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir" || {
                print_error "Failed to create directory: $dir"
                return 1
            }
        fi
        return 0
    }

    # Function to backup a file with timestamp
    backup_file() {
        local file=$1
        local backup_dir="$HOME/.config/backups"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup_file="$backup_dir/$(basename "$file").backup.$timestamp"

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

#     install_command_line_tools() {
#         if xcode-select -p &>/dev/null; then
#             print_status "Command Line Tools already installed"
#             return 0
#         fi
# 
#         print_status "Installing Command Line Tools..."
# 
#         # Create temporary file to trigger installation
#         touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# 
#         # Get the latest Command Line Tools package name
#         PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n')
# 
#         if [ -z "$PROD" ]; then
#             print_error "Could not find Command Line Tools in Software Update"
#             rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
#             return 1
#         fi
# 
#         # Install Command Line Tools
#         softwareupdate -i "$PROD" --verbose
#         local exit_code=$?
# 
#         # Clean up
#         rm /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
# 
#         if [ $exit_code -ne 0 ]; then
#             print_error "Failed to install Command Line Tools"
#             return 1
#         fi
# 
#         print_success "Command Line Tools installation complete"
#         return 0
#     }

    install_homebrew() {
        if command -v brew &>/dev/null; then
            print_status "Homebrew already installed"
            return 0
        fi

        print_status "Installing Homebrew..."

        # Download and install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        local exit_code=$?

        if [ $exit_code -ne 0 ]; then
            print_error "Failed to install Homebrew"
            return 1
        fi

        # Add Homebrew to PATH for the current session
        if [[ $(uname -m) == "arm64" ]]; then
            # For Apple Silicon Macs
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # For Intel Macs
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        # Verify installation
        if ! command -v brew &>/dev/null; then
            print_error "Homebrew installation succeeded but 'brew' command not found"
            return 1
        fi

        print_success "Homebrew installation complete"
        return 0
    }

    check_prerequisites() {
        print_status "Checking prerequisites..."

        # Ensure we're not running as root
        check_root

        # Check for required commands
        ensure_command "curl" || return 1
        ensure_command "git" || return 1

        # Check and install Command Line Tools
        if ! install_command_line_tools; then
            print_error "Failed to install Command Line Tools"
            return 1
        fi

        # Check and install Homebrew
        if ! install_homebrew; then
            print_error "Failed to install Homebrew"
            return 1
        fi

        print_success "All prerequisites installed successfully"
        return 0
    }

    log_operation() {
        local operation=$1
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[$timestamp] $operation" >> "$LOG_FILE"
    }

fi