#!/bin/bash

#set -eux

# Define usage function
usage(){
  echo "Usage: $0 filepath pattern"
  echo "filepath: pattern to match in the file names"
  exit 1
}

# Check number of arguments
if [ $# -lt 1 ]; then
  #usage
  echo -e "Huh?: \c"
  read -r FILEPATH_PATTERN_INPUT
fi

# Define directory, file path pattern, and pattern to search
DIRECTORY="snips"
FILEPATH_PATTERN="${1:-$FILEPATH_PATTERN_INPUT}"

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

CLIPBOARD_CONTENT=$(xsel -ob)
if [ -n "$CLIPBOARD_CONTENT" ]; then
    echo "$CLIPBOARD_CONTENT" | nvim -
fi
