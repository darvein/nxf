#!/bin/bash

# Define usage function
usage(){
  echo "Usage: $0 directory filepath pattern"
  echo "directory: s (snippets) or c (cli)"
  echo "filepath: pattern to match in the file names"
  echo "pattern: pattern to search in the file content"
  exit 1
}

# Check number of arguments
if [ $# -lt 2 ]; then
  usage
fi

# Define directory, file path pattern, and pattern to search
DIRECTORY="${1}"
FILEPATH_PATTERN="${2}"
PATTERN="${3:-}"

# Set the search directory based on the input parameter
if [ "$DIRECTORY" = "s" ]; then
  SEARCH_DIRECTORY="snips"
elif [ "$DIRECTORY" = "c" ]; then
  SEARCH_DIRECTORY="cli"
else
  echo "Invalid directory option. Please use 's' for snippets or 'c' for cli."
  exit 1
fi

SCRIPT_PATH=$(dirname "$(readlink -f "$0")")

# Find files that match the file path pattern and process them
find "${SCRIPT_PATH}/${SEARCH_DIRECTORY}" -type f -path "*${FILEPATH_PATTERN}*" |
while read -r file; do
  awk -v pattern="${PATTERN}" -v RS='-----' '
    BEGIN {IGNORECASE = 1}
    $0 ~ pattern {
        if ($0 != "") {
            print $0
        }
    }
  ' "${file}" | sed '/^$/N;/\n$/D'
done
