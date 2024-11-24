#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../utils.sh"
source "$CURRENT_DIR/rust.sh"
source "$CURRENT_DIR/julia.sh"
source "$CURRENT_DIR/python.sh"
source "$CURRENT_DIR/node.sh"

if [[ "${INSTALL_TOOLCHAINS_SOURCED-}" != "true" ]]; then
    INSTALL_TOOLCHAINS_SOURCED=true

    install_toolchains() {
        print_status "Installing development toolchains..."

        # Install Rust first as UV depends on it
        print_status "Installing Rust toolchain..."
        install_rust
        if [ $? -ne 0 ]; then
            print_error "Failed to install Rust toolchain"
            return 1
        fi

        # Install Julia
        print_status "Installing Julia toolchain..."
        install_julia
        if [ $? -ne 0 ]; then
            print_error "Failed to install Julia toolchain"
            return 1
        fi

        # Install Python tools
        print_status "Installing Python toolchain..."
        install_python
        if [ $? -ne 0 ]; then
            print_error "Failed to install Python toolchain"
            return 1
        fi

        # Install Node.js and TypeScript
        print_status "Installing Node.js toolchain..."
        install_node
        if [ $? -ne 0 ]; then
            print_error "Failed to install Node.js toolchain"
            return 1
        fi

        print_success "All toolchains installed successfully!"
        return 0
    }
fi
