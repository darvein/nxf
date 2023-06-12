#!/bin/bash

SCRIPT_PATH=$(dirname "$(readlink -f "$0")")

if [ $# -eq 2 ]; then
  FILEPATH_PATTERN="${1}"
  PATTERN="${2}"
elif [ $# -eq 1 ]; then
  FILEPATH_PATTERN="${1}"
  PATTERN=""
else
    echo "No parameters were passed."
    exit 0
fi

find "${SCRIPT_PATH}/snippets" -type f -path "*$FILEPATH_PATTERN*" -exec awk '
    /^# [A-Za-z]:/ {
        if (block != "")
            print block
        block = $0
        next
    }
    {
        block = block ORS $0
    }
    END {
        if (block != "")
            print block
    }
' {} + \
  | awk -v RS= -v ORS='\n\n' -v pattern="$PATTERN" 'tolower($0) ~ tolower(pattern)' \
  | xargs -0 -I '{}' echo -e '{}'
