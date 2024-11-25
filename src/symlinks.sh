#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/utils.sh"

if [[ "${SYMLINKS_SOURCED-}" != "true" ]]; then
    SYMLINKS_SOURCED=true

    create_symlink() {
        local source_path="$1"
        local target_path="$2"
        local is_directory="$3"
        
        # Expand ~ in target path
        target_path="${target_path/#\~/$HOME}"
        
        # Create target directory if it doesn't exist
        local target_dir
        target_dir=$(dirname "$target_path")
        if [ ! -d "$target_dir" ]; then
            print_status "Creating directory: $target_dir"
            mkdir -p "$target_dir"
        fi

        # Handle existing symlink or file
        if [ -L "$target_path" ]; then
            local current_link
            current_link=$(readlink "$target_path")
            if [ "$current_link" = "$source_path" ]; then
                print_status "Symlink already exists and is correct: $target_path"
                return 0
            else
                print_status "Updating existing symlink: $target_path"
                rm "$target_path"
            fi
        elif [ -e "$target_path" ]; then
            # Backup existing file/directory
            local backup_path="$target_path.backup.$(date +%Y%m%d_%H%M%S)"
            print_status "Creating backup: $backup_path"
            mv "$target_path" "$backup_path"
        fi

        # Create the symlink
        if [ -e "$source_path" ]; then
            print_status "Creating symlink: $target_path -> $source_path"
            ln -sf "$source_path" "$target_path"
        else
            print_error "Source path does not exist: $source_path"
            return 1
        fi
    }

    sync_symlinks() {
        local symlinks_file="$CURRENT_DIR/../lib/symlinks.json"
        
        if [ ! -f "$symlinks_file" ]; then
            print_error "Symlinks file not found: $symlinks_file"
            return 1
        fi

        print_status "Reading symlinks configuration..."
        
        # Use Python to parse JSON and output in a format bash can handle
        # This is more robust than trying to parse JSON in bash
        python3 -c '
import json
import sys
import os

try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
    
    for link in data["symlinks"]:
        # Print in a format that bash can easily parse
        print(f"{1 if link.get(\"directory\", False) else 0}:{link[\"initial\"]}:{link[\"final\"]}")
except Exception as e:
    print(f"Error: {str(e)}", file=sys.stderr)
    sys.exit(1)
' "$symlinks_file" | while IFS=: read -r is_directory initial final; do
            # Convert paths to absolute
            local source_path="$CURRENT_DIR/../lib/$initial"
            
            if [ "$is_directory" = "1" ]; then
                # For directories, we need to create symlinks for all contents
                if [ -d "$source_path" ]; then
                    find "$source_path" -type f -print0 | while IFS= read -r -d '' file; do
                        # Get relative path from source directory
                        local rel_path="${file#$source_path/}"
                        # Construct target path
                        local target_path="$final/$rel_path"
                        create_symlink "$file" "$target_path" false
                    done
                else
                    print_error "Source directory not found: $source_path"
                fi
            else
                create_symlink "$source_path" "$final" false
            fi
        done

        print_status "Symlink synchronization complete!"
    }
fi