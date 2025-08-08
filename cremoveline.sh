#!/bin/bash

filePattern="$1"
target="$2"

if [[ "$#" -ne 2 ]]; then
    echo "Error! Wrong number of parameters!
Usage: cremoveline FILE_REGEX_PATTERN TARGET_REGEX_PATTERN \
REPLACEMENT_REGEX_PATTERN
Where:
FILE_REGEX_PATTERN:         a regular expression describing the file names \
that you want to match;
TARGET_REGEX_PATTERN:       a regular expression describing the string that \
identifies the line to be deleted;"
    exit 2
fi

# replace comments in the following line if you'd rather use normal file
#patterns rather than REGEXES:
# for i in $(find . -type f -name "$filePattern"); do
for i in $(find . -type f -regex "$filePattern"); do
    sed -Ei "/$target/d" "$i"
done
