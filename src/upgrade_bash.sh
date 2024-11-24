#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/utils.sh"

if [[ "${UPGRADE_BASH_SOURCED-}" != "true" ]]; then
    UPGRADE_BASH_SOURCED=true

    upgrade_bash() {
        print_status "Checking for Homebrew bash installation..."
        
        # Check if bash is installed via Homebrew
        local homebrew_bash="/opt/homebrew/bin/bash"
        if [ ! -f "$homebrew_bash" ]; then
            print_error "Homebrew bash not found. Please ensure it's in your FORMULAE list"
            return 1
        fi

        print_status "Verifying Homebrew bash version..."
        local homebrew_bash_version
        homebrew_bash_version=$("$homebrew_bash" --version | head -n 1 | cut -d ' ' -f 4)
        print_status "Found Homebrew bash version: $homebrew_bash_version"

        # Check if Homebrew bash is already in /etc/shells
        if ! grep -q "^${homebrew_bash}$" /etc/shells; then
            print_status "Adding Homebrew bash to /etc/shells..."
            echo "$homebrew_bash" | sudo tee -a /etc/shells > /dev/null
            if [ $? -ne 0 ]; then
                print_error "Failed to add Homebrew bash to /etc/shells"
                return 1
            fi
            print_success "Added Homebrew bash to /etc/shells"
        else
            print_status "Homebrew bash already in /etc/shells"
        fi

        # Check if /bin/bash is already a symlink to Homebrew bash
        if [ -L "/bin/bash" ] && [ "$(readlink /bin/bash)" = "$homebrew_bash" ]; then
            print_status "System bash is already linked to Homebrew bash"
            return 0
        fi

        # Create backup of original bash if it hasn't been done
        if [ -f "/bin/bash" ] && [ ! -f "/bin/bash.bak" ]; then
            print_status "Creating backup of system bash..."
            sudo cp "/bin/bash" "/bin/bash.bak"
            if [ $? -ne 0 ]; then
                print_error "Failed to create backup of system bash"
                return 1
            fi
            print_success "Created backup of system bash at /bin/bash.bak"
        fi

        # Remove original bash and create symlink
        print_status "Creating symlink to Homebrew bash..."
        sudo rm -f "/bin/bash"
        sudo ln -s "$homebrew_bash" "/bin/bash"
        if [ $? -ne 0 ]; then
            print_error "Failed to create symlink to Homebrew bash"
            # Try to restore backup if we have one
            if [ -f "/bin/bash.bak" ]; then
                print_status "Attempting to restore backup..."
                sudo cp "/bin/bash.bak" "/bin/bash"
            fi
            return 1
        fi

        print_status "Verifying symlink..."
        if [ "$(readlink /bin/bash)" = "$homebrew_bash" ]; then
            print_success "Successfully upgraded system bash to Homebrew version"
            
            # Verify shell is working
            if ! "$homebrew_bash" -c "echo 'Shell test successful'" > /dev/null 2>&1; then
                print_error "New shell verification failed! Rolling back changes..."
                sudo rm -f "/bin/bash"
                sudo cp "/bin/bash.bak" "/bin/bash"
                return 1
            fi
        else
            print_error "Failed to verify symlink"
            return 1
        fi

        # Change current user's shell if they want
        if [ "$SHELL" != "$homebrew_bash" ]; then
            print_status "Would you like to change your shell to the new bash? (y/n)"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                chsh -s "$homebrew_bash"
                if [ $? -eq 0 ]; then
                    print_success "Shell changed successfully. Please log out and back in for changes to take effect."
                else
                    print_error "Failed to change shell. You can do this manually with: chsh -s $homebrew_bash"
                fi
            fi
        fi

        return 0
    }
fi