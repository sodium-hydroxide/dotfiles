#!/bin/bash

# Script name: compress-files
# Description: Compresses each file in the current directory using gzip
# Usage: compress-files

# Function to display script usage
show_usage() {
    echo "Usage: compress-files"
    echo "Compresses all files in the current directory using gzip"
    echo "Compressed files will have .gz extension added"
    echo "Original files will be removed after successful compression"
}

# Show help if -h or --help is passed
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Check if any files exist in the directory
if [ -z "$(ls -A)" ]; then
    echo "Error: No files found in current directory"
    exit 1
fi

# Initialize counters
compressed=0
errors=0

# Process each file in the current directory
for file in *; do
    # Skip if it's a directory or already a .gz file
    if [ -d "$file" ] || [[ "$file" == *.gz ]]; then
        continue
    fi
    
    # Try to compress the file
    if gzip -f "$file"; then
        echo "Successfully compressed: $file"
        ((compressed++))
    else
        echo "Error compressing: $file"
        ((errors++))
    fi
done

# Display summary
echo -e "\nCompression complete:"
echo "$compressed files compressed successfully"
if [ $errors -gt 0 ]; then
    echo "$errors files failed to compress"
    exit 1
fi

exit 0
