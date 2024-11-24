#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/utils.sh"

sync_taps() {
    local -a taps=("$@")
    print_status "Syncing Homebrew taps..."

    # Add missing taps
    for tap in "${taps[@]}"; do
        if ! brew tap | grep -q "^${tap}$"; then
            print_status "Adding tap: ${tap}"
            brew tap "$tap"
        else
            print_status "Tap already present: ${tap}"
        fi
    done

    # Remove unwanted taps (excluding core taps)
    while IFS= read -r installed_tap; do
        if [[ ! " ${taps[*]} " =~ " ${installed_tap} " ]] && \
           [[ "$installed_tap" != "homebrew/core" ]] && \
           [[ "$installed_tap" != "homebrew/cask" ]]; then
            print_status "Removing tap: ${installed_tap}"
            brew untap "$installed_tap"
        fi
    done < <(brew tap)
}

get_all_dependencies() {
    local formula=$1
    brew deps --installed "$formula" 2>/dev/null | tr '\n' ' '
}

get_formula_dependencies() {
    local formula=$1
    brew deps "$formula" 2>/dev/null | tr '\n' ' '
}

sync_formulae() {
    local -a formulae=("$@")
    print_status "Syncing Homebrew formulae..."

    # First pass: Install/update desired formulae
    for formula in "${formulae[@]}"; do
        if ! brew list --formula | grep -q "^${formula}$"; then
            print_status "Installing formula: ${formula}"
            brew install "$formula"
        else
            if [ "$FORCE_REINSTALL" = true ]; then
                print_status "Reinstalling formula: ${formula}"
                brew reinstall "$formula"
            else
                print_status "Formula already installed: ${formula}"
                if brew outdated --quiet | grep -q "^${formula}$"; then
                    print_status "Upgrading formula: ${formula}"
                    brew upgrade "$formula"
                fi
            fi
        fi
    done

    # Get list of all installed formulae
    local installed_formulae=($(brew list --formula))
    
    # Get all dependencies of our desired formulae
    local all_deps=""
    for formula in "${formulae[@]}"; do
        deps=$(get_formula_dependencies "$formula")
        all_deps+=" $deps"
    done
    local required_deps=($(echo "$all_deps" | tr ' ' '\n' | sort -u))

    # Second pass: Only remove formulae that aren't dependencies of anything
    for installed_formula in "${installed_formulae[@]}"; do
        # Skip if it's in our desired list
        if [[ " ${formulae[*]} " =~ " ${installed_formula} " ]]; then
            continue
        fi

        # Skip if it's a required dependency of our desired formulae
        if [[ " ${required_deps[*]} " =~ " ${installed_formula} " ]]; then
            print_status "Keeping ${installed_formula} as it's a required dependency"
            continue
        fi

        # Skip if it's homebrew's built-in dependencies
        if [[ "$installed_formula" == "ca-certificates" ]] || \
           [[ "$installed_formula" == "openssl@3" ]]; then
            continue
        fi

        # Check if it's a dependency of any other installed formula
        local is_dep=false
        for other_formula in "${installed_formulae[@]}"; do
            if [[ " ${formulae[*]} " =~ " ${other_formula} " ]]; then
                continue  # Skip our desired formulae
            fi
            if brew deps "$other_formula" 2>/dev/null | grep -q "^${installed_formula}$"; then
                is_dep=true
                break
            fi
        done

        if [ "$is_dep" = true ]; then
            print_status "Keeping ${installed_formula} as it's a dependency of other packages"
            continue
        fi

        # If we get here, it's safe to remove
        print_status "Removing formula: ${installed_formula}"
        brew uninstall "$installed_formula"
    done
}

sync_casks() {
    local -a casks=("$@")
    print_status "Syncing Homebrew casks..."

    # Install or update casks
    for cask in "${casks[@]}"; do
        if ! brew list --cask | grep -q "^${cask}$"; then
            print_status "Installing cask: ${cask}"
            brew install --cask "$cask"
        else
            if [ "$FORCE_REINSTALL" = true ]; then
                print_status "Reinstalling cask: ${cask}"
                brew reinstall --cask "$cask"
            else
                print_status "Cask already installed: ${cask}"
                if brew outdated --cask --quiet | grep -q "^${cask}$"; then
                    print_status "Upgrading cask: ${cask}"
                    brew upgrade --cask "$cask"
                fi
            fi
        fi
    done

    # Only remove casks that aren't in our list
    while IFS= read -r installed_cask; do
        if [[ ! " ${casks[*]} " =~ " ${installed_cask} " ]]; then
            print_status "Removing cask: ${installed_cask}"
            brew uninstall --cask --force "$installed_cask"
        fi
    done < <(brew list --cask)
}

sync_homebrew() {
    # Update Homebrew first
    print_status "Updating Homebrew..."
    brew update
    print_status "Cleaning up Homebrew..."
    brew cleanup

    # Sync everything
    sync_taps "${BREW_TAPS[@]}"
    sync_formulae "${BREW_FORMULAE[@]}"
    sync_casks "${BREW_CASKS[@]}"

    print_status "Homebrew sync complete!"
}