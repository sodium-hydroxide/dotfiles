#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../utils.sh"

if [[ "${INSTALL_RUST_SOURCED-}" != "true" ]]; then
    INSTALL_RUST_SOURCED=true

    install_rust() {
        print_status "Checking for Rust installation..."

        # Check if rustup is installed
        if ! command -v rustup &> /dev/null; then
            print_status "Installing Rust via rustup..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
            if [ $? -ne 0 ]; then
                print_error "Failed to install Rust"
                return 1
            fi
        else
            print_status "Rust is already installed, updating..."
            rustup update
        fi

        # Source cargo environment
        source "$HOME/.cargo/env"

        # Install commonly used components
        print_status "Installing Rust components..."
        rustup component add rustfmt clippy rust-analyzer

        # Install helpful tools
        print_status "Installing/updating Rust tools..."
        cargo install cargo-edit cargo-watch cargo-update

        print_success "Rust toolchain installation/update complete!"
        return 0
    }
fi
