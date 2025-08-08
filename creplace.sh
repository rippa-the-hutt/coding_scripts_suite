#!/bin/bash

filePattern="$1"
target="$2"
goal="$3"

if [[ "$#" -ne 3 ]]; then
    echo "Error! Wrong number of parameters!
Usage: creplace FILE_REGEX_PATTERN TARGET_REGEX_PATTERN REPLACEMENT_REGEX_PATTERN
Where:
FILE_REGEX_PATTERN:         a regular expression describing the file names that you want to match;
TARGET_REGEX_PATTERN:       a regular expression describing the string that you want to replace;
REPLACEMENT_REGEX_PATTERN:  a regular expression describing the replacement string;"
    exit 2
fi

# replace comments in the following line if you'd rather use normal file patterns rather
# than REGEXES:
# for i in $(find . -type f -name "$filePattern"); do
for i in $(find . -type f -regex "$filePattern"); do
    sed -Ei "s/$target/$goal/g" "$i"
done
