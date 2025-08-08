#!/bin/bash

# set this to anything byt 'yes' in order to mute the file list output:
INTERNAL_CONFIG_OUTPUT_FILE_LIST='nope' # 'yes'

print_help() {
    echo "
The goal of this is to convert all of the .c, .cpp, .h and .hpp files in the \
subdirectories of PWD to the desired pointer declaration convention.
Both pointer _and_ double pointer declarations are converted.
Please, refer to https://www.stroustrup.com/bs_faq2.html#whitespace for an \
explanation of the conventions.

Usage: cpointerdeclaration TARGET_CONVENTION
Where:
TARGET_CONVENTION:  can take one of the possible values: \"type\" or\
\"value\".
Following you can immediately see the difference between the value and type \
styles:
    int* my_var // type
    int *my_var // value"
}

if [[ "$#" -ne 1 ]]; then
    print_help
    exit 2
fi

DESIRED_CONVENTION=$1

if [[ $DESIRED_CONVENTION != "type" && $DESIRED_CONVENTION != "value" ]];
then
    if [[ $DESIRED_CONVENTION != "-h" && $DESIRED_CONVENTION != "--help" ]];
    then
        echo "Crap, you entered $DESIRED_CONVENTION!"
    fi

    print_help
    exit 2
fi

# searches into C/C++ sources and headers (I know, this is not exhaustive
# but covers the most common conventions, like Boost's):
FILE_PATTERN=".*\.[ch]\|\([ch]pp\)\|\(cc\)"
DECLARATIONS_TYPE_CONVENTION="([a-zA-Z0-9])(\*{1,2})([ ]+)([a-zA-Z_])"
DECLARATIONS_VALUE_CONVENTION="([a-zA-Z0-9])([ ]+)(\*{1,2})([a-zA-Z_])"
TARGET_SWAP="\1\3\2\4"

if [[ $DESIRED_CONVENTION = "type" ]]; then
    TARGET_DECLARATION=$DECLARATIONS_VALUE_CONVENTION
else
    TARGET_DECLARATION=$DECLARATIONS_TYPE_CONVENTION
fi

declare -i FILES_PROCESSED=0

# replace comments in the following line if you'd rather use normal file
#patterns rather than REGEXES:
# for i in $(find . -type f -name "$filePattern"); do
for i in $(find . -type f -regex "$FILE_PATTERN"); do
    sed -Ei "s/$TARGET_DECLARATION/$TARGET_SWAP/g" "$i"

    # increments file count:
    FILES_PROCESSED=$FILES_PROCESSED+1

    if [[ $INTERNAL_CONFIG_OUTPUT_FILE_LIST = 'yes' ]]; then
        echo "$DESIRED_CONVENTION convention has been applied to file $i"
    fi
done

echo ""
echo "$FILES_PROCESSED files have been converted to $DESIRED_CONVENTION \
convention!"
echo ""
