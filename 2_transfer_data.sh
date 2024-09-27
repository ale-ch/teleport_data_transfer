#!/bin/bash

# Initialize variables
FILE_PATH=""
DST=""

# Function to display help message
function display_help() {
    echo "Usage: $0 --src-list /path/to/file.txt --dst /path/to/dst_dir"
    echo
    echo "Options:"
    echo "  --src-list      Path to the source list file containing file paths to transfer."
    echo "  --dst           Destination directory on the remote server."
    echo "  --help          Display this help message."
    echo
    echo "Example:"
    echo "  $0 --src-list /path/to/file.txt --dst /path/to/dst_dir"
    exit 0
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --src-list) FILE_PATH="$2"; shift ;;
        --dst) DST="$2"; shift ;;
        --help) display_help ;;  # Call the help function
        *) echo "Unknown parameter passed: $1"; display_help ;;
    esac
    shift
done

# Check if the file path and destination are provided
if [[ -z "$FILE_PATH" ]]; then
    echo "Error: Source list file is required."
    display_help
fi

if [[ -z "$DST" ]]; then
    echo "Error: Destination directory is required."
    display_help
fi

# Check if the file exists
if [[ -f "$FILE_PATH" ]]; then
    # Read and print each line in the text file
    while IFS= read -r line; do
        echo "Line: $line"
        singularity exec -B /hpcnfs/ /hpcnfs/techunits/bioinformatics/singularity/teleport-distroless_14.0.3.sif tsh scp -r --proxy teleport.ieo.it "$line" "dimaimaging.garr.cloud.ct:$DST"
    done < "$FILE_PATH"
else
    echo "File not found: $FILE_PATH"
    exit 1
fi
