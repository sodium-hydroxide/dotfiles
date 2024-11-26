upgrade_bash() {
    echo "Upgrading bash..."

    # Check if Homebrew bash is installed
    if [ ! -f "/opt/homebrew/bin/bash" ]; then
        echo "Error: Homebrew bash not found at /opt/homebrew/bin/bash"
        echo "Please ensure you have bash installed via Homebrew first"
        return 1
    fi

    # Create or update the wrapper script
    sudo tee /usr/local/bin/bash << 'EOF' > /dev/null
#!/opt/homebrew/bin/bash
exec /opt/homebrew/bin/bash "$@"
EOF
    sudo chmod +x /usr/local/bin/bash

    # Verify the installation
    local CURRENT_BASH_PATH=$(which bash)
    if [ "$CURRENT_BASH_PATH" = "/usr/local/bin/bash" ]; then
        echo "Bash upgrade successful!"
        echo "Current bash path: $CURRENT_BASH_PATH"
        echo "Bash version: $(bash --version | head -n 1)"
        return 0
    else
        echo "Warning: Bash path is not /usr/local/bin/bash"
        echo "Current path: $CURRENT_BASH_PATH"
        echo "Verify that /usr/local/bin is in your PATH and comes before /bin"
        return 1
    fi
}
