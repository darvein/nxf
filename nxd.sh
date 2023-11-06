#!/bin/bash

# Define usage function
usage(){
  echo "Usage: $0 filepath pattern"
  echo "filepath: pattern to match in the file names"
  echo "pattern: pattern to search in the file content"
  exit 1
}

# Check number of arguments
if [ $# -lt 2 ]; then
  usage
fi

# Define directory, file path pattern, and pattern to search
DIRECTORY="snips"
FILEPATH_PATTERN="${2}"
PATTERN="${3:-}"

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
