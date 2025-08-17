#!/bin/bash

print_help ()
{
    echo "Typical usage:"
    echo "    ./buildTags.sh ../MyProjDir [SUB_DIRECTORY=y/n]|[-a additional/path1:/additional/path2]"
    echo "You can use either relative or absolute paths for the root dir."
    echo "The default behavior is to build tags for all subdirectories of the current directory."
    echo ""
}

# stores the target directory:
TGT_DIR=$1
CURR_DIR=`pwd`

# Function to handle errors
handle_error() {
  #echo "Error: Command failed with exit status $?" >&2

  # restores the previous directory:
  cd $CURR_DIR
  echo "BOOM! Unexpected error!"
  print_help
  exit 1
}

# binds the handle_error function to any BOOM situation:
trap 'handle_error' ERR

if [[ -z $TGT_DIR ]] then
    echo "Please gimme the root dir of this project!"
    print_help;
    exit 1;
fi

SUBDIR_CHOICE=$2

if [[ -n $SUBDIR_CHOICE ]] then
    if [[ "$SUBDIR_CHOICE" != "y" ]] then
        if [[ "$SUBDIR_CHOICE" != "n" ]] then
            if [[ $SUBDIR_CHOICE != "-a" ]] then
                print_help;
                exit 1;
            fi
        fi
    fi
fi

if [[ $SUBDIR_CHOICE = "-a" ]] then
    if [[ -z $3 ]] then
        echo "
Looks like you want to specify and additional directory, but ommitted it!"
        print_help;
        exit 1
    fi
    ADDITIONAL_DIR=$3;
fi

cd $TGT_DIR
# gets the absolute path to the target (root) directory
ABS_TGT_DIR=`pwd`

# the script creates tags for c, h and rs files:
REGEX_FILE_PATTERN="\(.*\.[ch]\)\|\(.*\.rs\)$"


# name of the file in which the cached tags will be stored. We need to do this
# coz find's output easily hits the maximum allowed size for arguments
# (getconf ARG_MAX):
TARGET_FILE_CACHE=target_files_cache.temp
find ~+ -type f -regex $REGEX_FILE_PATTERN > $TARGET_FILE_CACHE
if [[ -n $ADDITIONAL_DIR ]]; then
    # includes the files in the additional directory:

    # tokenisation of of the additional dirs using ':', using '()' in order
    # to spawn a subshell, thus avoiding to mess with the system's IFS var:
    (IFS=':'; for path in $ADDITIONAL_DIR; do
        find $path -type f -regex $REGEX_FILE_PATTERN >> $TARGET_FILE_CACHE
    done)
fi

# we move back to the subdir we started from:
cd $CURR_DIR

# if user supplied the optional parameter "n", then they only want to generate
# tags in the current directory:
if [[ "$SUBDIR_CHOICE" == "n" ]] then
    ctags -L "$ABS_TGT_DIR/$TARGET_FILE_CACHE";

# builds tags for each subdir of my current directory:
else
    for i in $(find -type d); do
        cd $i;
        # reads the cache file to retrieve the target files:
        ctags -L "$ABS_TGT_DIR/$TARGET_FILE_CACHE";
        echo "Created tags file in $i"
        cd -;
    done
fi

rm $ABS_TGT_DIR/$TARGET_FILE_CACHE
