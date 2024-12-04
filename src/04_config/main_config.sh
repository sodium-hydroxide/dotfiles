#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USER_LIBRARY="$HOME/Library"
USER_APP_SUPPORT="$USER_LIBRARY/Application Support"
USER_CONFIG="$HOME/.config"

# Check if a symlink points to the expected target
check_symlink() {
    local target=$1
    local expected_source=$2

    if [[ -L "$target" ]]; then
        local current_source=$(readlink "$target")
        if [[ "$current_source" == "$expected_source" ]]; then
            return 0  # Correct symlink exists
        fi
    fi
    return 1  # Not a symlink or points to wrong location
}

# Create a symlink for a single file
linkf() {
    local filepath=$1
    local outpath=$2
    local source="$CURRENT_DIR/$filepath"

    if [[ $DRY_RUN == true ]]; then
        print_status "[DRY RUN] Would link $source to $outpath"
        return 0
    fi

    # Check if correct symlink already exists
    if check_symlink "$outpath" "$source"; then
        if [[ $VERBOSE == true ]]; then
            print_status "Correct symlink already exists: $outpath"
        fi
        return 0
    fi

    # Handle existing file/symlink
    if [[ -e "$outpath" ]] || [[ -L "$outpath" ]]; then
        if [[ $FORCE == true ]]; then
            backup_file "$outpath"
            rm -f "$outpath"
        else
            print_warning "File exists and --force not specified: $outpath"
            return 1
        fi
    fi

    print_status "Creating symlink: $outpath -> $source"
    ln -s "$source" "$outpath"
}

# Create symlinks for all files in a directory
linkd() {
    local dirpath=$1
    local outpath=$2
    local source_dir="$CURRENT_DIR/$dirpath"

    if [[ $DRY_RUN == true ]]; then
        print_status "[DRY RUN] Would link all files from $source_dir to $outpath"
        return 0
    fi

    # Ensure the output directory exists
    ensure_dir "$outpath"

    # Process each file in the source directory
    for src in "$source_dir"/*; do
        if [[ -e "$src" ]]; then
            local filename=$(basename "$src")
            local target="$outpath/$filename"

            # Check if correct symlink already exists
            if check_symlink "$target" "$src"; then
                if [[ $VERBOSE == true ]]; then
                    print_status "Correct symlink already exists: $target"
                fi
                continue
            fi

            # Handle existing file/symlink
            if [[ -e "$target" ]] || [[ -L "$target" ]]; then
                if [[ $FORCE == true ]]; then
                    backup_file "$target"
                    rm -f "$target"
                else
                    print_warning "File exists and --force not specified: $target"
                    continue
                fi
            fi

            print_status "Creating symlink: $target -> $src"
            ln -s "$src" "$target"
        fi
    done
}

# Sync all configuration files
sync_config() {
    print_status "Syncing configuration files..."

    # Core config files
    linkf "bash_profile"          "$HOME/.bash_profile"

    # Application configs
    linkd "bash"            "$USER_CONFIG/bash"
    linkd "git"             "$USER_CONFIG/git"
    linkd "latexmk"         "$USER_CONFIG/latexmk"
    linkd "nvim"            "$USER_CONFIG/nvim"
    linkd "freetube"        "$USER_APP_SUPPORT/FreeTube"
    linkd "vscode"          "$USER_APP_SUPPORT/Code/User"
    linkd "lf"              "$USER_CONFIG/lf"
}



cleanup_broken_links() {
    local dir=$1
    find "$dir" -type l ! -exec test -e {} \; -delete
}
