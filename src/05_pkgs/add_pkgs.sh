#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NPM_PKG_LIST="$SCRIPT_DIR/node.json"
PIP_PKG_LIST="$SCRIPT_DIR/python.txt"

add_npm() {
    # Get the directory where the script is located

    # Check if the JSON file exists
    if [ ! -f "$NPM_PKG_LIST" ]; then
        echo "Error: JSON file not found at $NPM_PKG_LIST"
        exit 1
    fi

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed"
        echo "Install it using: brew install jq"
        exit 1
    fi

    # Read packages from JSON and install them
    echo "Installing global npm packages..."
    jq -r '.globalPackages[]' "$NPM_PKG_LIST" | while read package; do
        echo "Installing $package..."
        npm install -g "$package"
    done

    echo "NPM packages installation complete!"
}


add_python() {
    # Check if the requirements file exists
    if [ ! -f "$PIP_PKG_LIST" ]; then
        echo "Error: Python requirements file not found at $PIP_PKG_LIST"
        exit 1
    fi

    # Check if pip is installed
    if ! command -v pip &> /dev/null; then
        echo "Error: pip is required but not installed"
        echo "Install it using: python -m ensurepip --upgrade"
        exit 1
    fi

    # Install packages from requirements file
    echo "Installing Python packages..."
    pip install -r "$PIP_PKG_LIST"

    echo "Python packages installation complete!"
}

