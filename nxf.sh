#!/bin/bash

#set -eux

# Define usage function
usage(){
  echo "Usage: $0 directory filepath pattern"
  echo "directory: s (snippets) or c (cli)"
  echo "filepath: pattern to match in the file names"
  exit 1
}

# Check number of arguments
if [ $# -lt 2 ]; then
  usage
fi

# Define directory, file path pattern, and pattern to search
DIRECTORY="${1}"
FILEPATH_PATTERN="${2}"

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

find "${SCRIPT_PATH}/${SEARCH_DIRECTORY}" -type f -path "*${FILEPATH_PATTERN}*" |
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
  | xargs -I{} ~/work/nextbrave/tltr/nxd.sh $DIRECTORY $FILEPATH_PATTERN "{}" | tee >(xsel -ib)
