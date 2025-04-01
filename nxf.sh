#!/bin/bash

# Define usage function for help
usage() {
    echo "Usage: $0 filepath pattern"
    echo "filepath: pattern to match in the file names"
    exit 1
}

# Function to get real path (works on both macOS and Linux)
get_real_path() {
    # If readlink -f exists (Linux), use it
    if command -v readlink >/dev/null 2>&1 && readlink -f . >/dev/null 2>&1; then
        readlink -f "$1"
    else
        # Otherwise use pwd -P method (macOS fallback)
        if [[ -d "$1" ]]; then
            pushd "$1" >/dev/null
            pwd -P
            popd >/dev/null
        else
            pushd "$(dirname "$1")" >/dev/null
            echo "$(pwd -P)/$(basename "$1")"
            popd >/dev/null
        fi
    fi
}

# Detect operating system and set clipboard commands
detect_clipboard_commands() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS clipboard commands
        COPY_CMD="pbcopy"
        PASTE_CMD="pbpaste"
    else
        # Linux clipboard commands (using xclip)
        COPY_CMD="xclip -selection clipboard"
        PASTE_CMD="xclip -selection clipboard -o"
    fi
}

# Check for required commands based on OS
check_dependencies() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v pbcopy >/dev/null 2>&1; then
            echo "Error: pbcopy is required but not found"
            exit 1
        fi
    else
        if ! command -v xclip >/dev/null 2>&1; then
            echo "Error: xclip is required but not found"
            echo "Install with: sudo apt-get install xclip (Debian/Ubuntu)"
            echo "            sudo pacman -S xclip (Arch Linux)"
            exit 1
        fi
    fi

    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is required but not found"
        exit 1
    fi
}

# Initialize clipboard commands
detect_clipboard_commands
check_dependencies

# Check number of arguments and prompt if needed
if [ $# -lt 1 ]; then
    echo -n "Enter search pattern: "
    read -r FILEPATH_PATTERN_INPUT
fi

# Define directory and file path pattern
DIRECTORY="snips"
FILEPATH_PATTERN="${1:-$FILEPATH_PATTERN_INPUT}"
SCRIPT_PATH=$(dirname "$(get_real_path "$0")")

# Main search and process loop
# The perl script processes files and extracts first non-empty lines
find "${SCRIPT_PATH}/${DIRECTORY}" -type f -path "*${FILEPATH_PATTERN}*" | 
while read -r file; do
    perl -ne 'BEGIN { $/ = "-----\n" }
        if (/$ARGV[0]/i) {
            @lines = split("\n");
            foreach $line (@lines) {
                if ($line ne "") {
                    $first_line = $line;
                    last;
                }
            }
            print "$first_line\n";
        }' "${file}"
done | fzf --preview "${SCRIPT_PATH}/nxd.sh $DIRECTORY $FILEPATH_PATTERN {}" \
    | xargs -I{} ~/work/me/nxf/nxd.sh $DIRECTORY $FILEPATH_PATTERN "{}" | tee >(eval "$COPY_CMD")

# Get clipboard content and open in vim if not empty
CLIPBOARD_CONTENT=$(eval "$PASTE_CMD")
if [ -n "$CLIPBOARD_CONTENT" ]; then
    echo "$CLIPBOARD_CONTENT" | nvim -
fi
