#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$CURRENT_DIR")"  # Go up one level from src/
source "$CURRENT_DIR/utils.sh"

sync_homebrew() {
    print_status "Updating Homebrew..."
    brew update

    print_status "Checking Brewfile..."
    local brewfile="$PROJECT_ROOT/lib/Brewfile"
    if [ ! -f "$brewfile" ]; then
        print_error "Brewfile not found at: $brewfile"
        return 1
    fi

    print_status "Checking for brew bundle..."
    if ! brew bundle check --file="$brewfile" --no-upgrade &>/dev/null; then
        print_status "Installing missing dependencies..."
        brew bundle install --file="$brewfile" --no-upgrade
    else
        print_status "All dependencies are satisfied."
    fi

    if [ "$FORCE_REINSTALL" = true ]; then
        print_status "Force reinstall requested. Reinstalling all dependencies..."
        brew bundle install --file="$brewfile" --force
    fi

    print_status "Checking for outdated packages..."
    if brew bundle check --file="$brewfile" --verbose | grep -q 'outdated'; then
        print_status "Would you like to upgrade outdated packages? (y/N) "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            print_status "Upgrading outdated packages..."
            brew bundle install --file="$brewfile"
        else
            print_status "Skipping upgrades."
        fi
    fi

    print_status "Checking for unmanaged dependencies..."
    brew bundle cleanup --file="$brewfile" --force --zap

    print_status "Cleaning up Homebrew cache..."
    brew cleanup

    print_success "Homebrew sync complete!"
}

# Optional: Add a function to dump current state to Brewfile
dump_brewfile() {
    local brewfile="$PROJECT_ROOT/lib/Brewfile"
    print_status "Dumping current Homebrew state to Brewfile..."
    brew bundle dump --force --describe --file="$brewfile"
    print_success "Brewfile updated at: $brewfile"
}
