#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../utils.sh"

if [[ "${INSTALL_JULIA_SOURCED-}" != "true" ]]; then
    INSTALL_JULIA_SOURCED=true

    install_julia() {
        print_status "Checking for Julia installation..."

        # First ensure Julia is installed via homebrew
        if ! command -v julia &> /dev/null; then
            print_error "Julia not found. Please ensure it's installed via Homebrew first."
            return 1
        fi

        # Check for juliaup
        if ! command -v juliaup &> /dev/null; then
            print_status "Installing juliaup..."
            curl -fsSL https://install.julialang.org | sh -s -- --yes
            if [ $? -ne 0 ]; then
                print_error "Failed to install juliaup"
                return 1
            fi
        else
            print_status "Updating juliaup..."
            juliaup update
        fi

        # Source the new juliaup environment
        eval "$(juliaup hook bash)"

        # Install latest stable version
        print_status "Ensuring latest stable Julia version is installed..."
        juliaup add release
        juliaup default release

        # Install essential packages
        print_status "Installing essential Julia packages..."
        julia --startup-file=no --quiet <<EOL
            using Pkg
            
            # Add essential packages
            essential_packages = [
                "Revise",          # For interactive development
                "OhMyREPL",        # Better REPL experience
                "BenchmarkTools", # For benchmarking
                "Documenter",     # For documentation
                "TestItems",      # For testing
                "Pluto",         # Interactive notebooks
                "IJulia"         # Jupyter kernel
            ]
            
            for pkg in essential_packages
                println("Installing \$pkg...")
                Pkg.add(pkg)
            end
            
            # Precompile everything
            println("Precompiling packages...")
            Pkg.precompile()
EOL

        if [ $? -ne 0 ]; then
            print_error "Failed to install some Julia packages"
            return 1
        fi

        print_success "Julia toolchain installation/update complete!"
        return 0
    }
fi

