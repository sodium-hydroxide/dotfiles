#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../utils.sh"

if [[ "${INSTALL_PYTHON_SOURCED-}" != "true" ]]; then
    INSTALL_PYTHON_SOURCED=true

    install_python() {
        print_status "Setting up Python environment..."

        # Install uv directly from website
        print_status "Installing/updating uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        if [ $? -ne 0 ]; then
            print_error "Failed to install uv"
            return 1
        fi

        # Create base virtual environment if it doesn't exist
        local venv_path="$HOME/.venv"
        if [ ! -d "$venv_path" ]; then
            print_status "Creating base virtual environment..."
            uv venv "$venv_path"
        fi

        # Install base Python packages
        print_status "Installing base Python packages..."
        source "$venv_path/bin/activate"

        uv pip install --upgrade \
            pip \
            ruff \
            mypy \
            ipython \
            jupyter \
            build \
            requests

        if [ $? -ne 0 ]; then
            print_error "Failed to install some Python packages"
            return 1
        fi

        deactivate

        print_success "Python toolchain installation/update complete!"
        return 0
    }
fi
