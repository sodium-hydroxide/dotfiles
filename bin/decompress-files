#!/bin/bash

# Script name: decompress-files
# Description: Decompresses all .gz files in the current directory (excluding .tar.gz)
# Usage: decompress-files

# Function to display script usage
show_usage() {
    echo "Usage: decompress-files"
    echo "Decompresses all .gz files in the current directory"
    echo "Skips .tar.gz files to prevent archive corruption"
    echo "Original .gz files will be removed after successful decompression"
}

# Show help if -h or --help is passed
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Check if any .gz files exist in the directory
if ! ls *.gz >/dev/null 2>&1; then
    echo "Error: No .gz files found in current directory"
    exit 1
fi

# Initialize counters
decompressed=0
errors=0
skipped=0

# Process each .gz file in the current directory
for file in *.gz; do
    # Skip .tar.gz files
    if [[ "$file" == *.tar.gz ]]; then
        echo "Skipping tar archive: $file"
        ((skipped++))
        continue
    fi

    # Try to decompress the file
    if gunzip -f "$file"; then
        echo "Successfully decompressed: $file"
        ((decompressed++))
    else
        echo "Error decompressing: $file"
        ((errors++))
    fi
done

# Display summary
echo -e "\nDecompression complete:"
echo "$decompressed files decompressed successfully"
if [ $skipped -gt 0 ]; then
    echo "$skipped .tar.gz files skipped"
fi
if [ $errors -gt 0 ]; then
    echo "$errors files failed to decompress"
    exit 1
fi

exit 0
