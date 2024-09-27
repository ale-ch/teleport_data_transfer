#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 --path <directory_path> --type <type> --output <output_file>"
    echo "Example: $0 --path \"$(pwd)/ome_tiff_images\" --type d --output directories.txt"
    exit 1
}

# Default values
DIRECTORY_PATH=""
TYPE=""
OUTPUT_FILE=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --path) DIRECTORY_PATH="$2"; shift ;;
        --type) TYPE="$2"; shift ;;
        --output) OUTPUT_FILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Validate inputs
if [[ -z "$DIRECTORY_PATH" || -z "$TYPE" || -z "$OUTPUT_FILE" ]]; then
    usage
fi

# Run the find command
find "$DIRECTORY_PATH" -type "$TYPE" -print0 | xargs -0 ls -ld --sort=time | awk '{print $9}' > "$OUTPUT_FILE"

echo "Directories listed in $OUTPUT_FILE sorted by date."

