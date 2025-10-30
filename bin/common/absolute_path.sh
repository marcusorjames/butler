#!/bin/sh
# Convert a path to absolute
#
absolute_path() {
    local path="$1"
    # If it already starts with '/', it’s absolute
    if [[ "$path" = /* ]]; then
        echo "$path"
    else
        # Otherwise, expand relative to current directory
        echo "$(pwd)/$path"
    fi
}
