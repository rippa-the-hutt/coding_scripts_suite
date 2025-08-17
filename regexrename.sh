#!/bin/bash

DEBUGOK='nope'

print_help() {
    echo "
Regex-based batch utility to rename files matching a specific regex\
pattern in the current directory.

Usage: regexrename FILE_PATTERN REGEX_PATTERN NEW_TEXT
Where:
    FILE_PATTERN:  a regex describing the files that are to be renamed.
                   Forward slashes for matching files in subdirs are NOT \
currently handled;
    REGEX_PATTERN: The regex pattern INSIDE the name of the matching file, \
this is the text that you want to replace.
    NEW_TEXT:      The text that you want to replace REGEX_PATTERN with.
                   This can follow all of the sed-supported regex expressions.
                   It can also be an empty field, if you want to erase the \
text matching REGEX_PATTERN.
"
}

FILE_PATTERN=$1
REGEX_PATTERN=$2
NEW_TEXT=$3

if [[ -z $FILE_PATTERN || -z $REGEX_PATTERN || \
         $FILE_PATTERN = "-h" || \
         $FILE_PATTERN = "--help" ]]; then
    print_help
    exit 1
fi

# name of the file in which the cached tags will be stored. We need to do this
# coz find's output easily hits the maximum allowed size for arguments
# (getconf ARG_MAX):
TARGET_FILE_CACHE=target_files_cache.temp
find . -regex "./$FILE_PATTERN" -printf '%P\n' > $TARGET_FILE_CACHE

while read -r line; do
    j="`echo "$line" | sed -E "s/$REGEX_PATTERN/$NEW_TEXT/"`";
    if [[ $DEBUGOK = 'yes' ]]; then
        echo "i: $line"
        echo "j: $j"
    fi
    mv "$line" "$j";
done < $TARGET_FILE_CACHE

rm $TARGET_FILE_CACHE

