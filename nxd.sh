#!/bin/bash

# Define usage function
usage(){
  echo "Usage: $0 filepath pattern"
  echo "filepath: pattern to match in the file names"
  echo "pattern: pattern to search in the file content"
  exit 1
}

# Check number of arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  usage
fi

# Define file path pattern and pattern to search
FILEPATH_PATTERN="${1}"
PATTERN="${2:-}"  # Default to empty string if not provided

SCRIPT_PATH=$(dirname "$(readlink -f "$0")")

# Find files that match the file path pattern and process them
find "${SCRIPT_PATH}/snippets" -type f -path "*${FILEPATH_PATTERN}*" |
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
