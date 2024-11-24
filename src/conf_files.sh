#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/utils.sh"

# Base location for config files
CONFIG_BASE="$CURRENT_DIR/../lib"

create_symlink() {
    local source_path="$1"
    local target_path="$2"
    
    # Create target directory if it doesn't exist
    local target_dir=$(dirname "$target_path")
    if [ ! -d "$target_dir" ]; then
        print_status "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi

    # Create the symlink
    if [ -e "$source_path" ]; then
        if [ -L "$target_path" ]; then
            print_status "Updating existing symlink: $target_path -> $source_path"
        else
            print_status "Creating symlink: $target_path -> $source_path"
        fi
        ln -sf "$source_path" "$target_path"
    else
        print_error "Error: Source path does not exist: $source_path"
        return 1
    fi
}

sync_config_file() {
    local mapping="$1"
    local IFS=':'
    read -r source target <<< "$mapping"

    # Expand ~ to $HOME if present
    target="${target/#\~/$HOME}"
    
    local source_path="$CONFIG_BASE/$source"
    local target_path="$target/$(basename "$source")"

    create_symlink "$source_path" "$target_path"
}

sync_config_dir() {
    local mapping="$1"
    local IFS=':'
    read -r source_dir target_dir <<< "$mapping"

    # Expand ~ to $HOME if present
    target_dir="${target_dir/#\~/$HOME}"
    
    local source_base="$CONFIG_BASE/$source_dir"

    if [ ! -d "$source_base" ]; then
        print_error "Source directory does not exist: $source_base"
        return 1
    fi

    # Create target directory if it doesn't exist
    if [ ! -d "$target_dir" ]; then
        print_status "Creating target directory: $target_dir"
        mkdir -p "$target_dir"
    fi

    # Find all files in source directory recursively
    find "$source_base" -type f -print0 | while IFS= read -r -d '' source_file; do
        # Get relative path from source_base
        local rel_path="${source_file#$source_base/}"
        local target_path="$target_dir/$rel_path"
        
        # Create target subdirectories if needed
        mkdir -p "$(dirname "$target_path")"
        
        # Create symlink
        create_symlink "$source_file" "$target_path"
    done
}

write_config_files() {
    print_status "Syncing configuration files..."
    
    # Process individual file mappings
    for mapping in "${CONFIG_FILE_MAPPINGS[@]}"; do
        sync_config_file "$mapping"
    done

    # Process directory mappings
    for mapping in "${CONFIG_DIR_MAPPINGS[@]}"; do
        sync_config_dir "$mapping"
    done
}

write_bashrc() {
    local content="$1"
    local bashrc_path="$HOME/.bashrc"
    
    print_status "Writing bashrc configuration..."
    
    # Backup existing bashrc if it exists
    if [ -f "$bashrc_path" ]; then
        backup_file "$bashrc_path"
    fi

    # Write new bashrc
    print_status "Writing new .bashrc to $bashrc_path"
    echo "$content" > "$bashrc_path"
    
    # Set proper permissions
    chmod 644 "$bashrc_path"
    
    # Source the new bashrc if we're in an interactive shell
    if [[ $- == *i* ]]; then
        print_status "Sourcing new .bashrc..."
        source "$bashrc_path"
    else
        print_status "Non-interactive shell detected, skipping source"
    fi
    
    print_status "Bashrc has been written to $bashrc_path"
}