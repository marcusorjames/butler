#!/bin/bash

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

get_site_dir() {
  get_dir "$SITES_DIR" "$1" 1
}

get_project_dir() {
  get_dir "$PROJECTS_DIR" "$1" 2
}

get_dir() {
  local base_dir="$1"
  local name="$2"
  local depth="${3:-1}"
  local result
  result=$(find "$base_dir" -maxdepth "$depth" -name "$name" -type d 2>/dev/null | head -1)
  [ -n "$result" ] && echo "$result" && return 0
  return 1
}

site_exists() {
  local site_name="$1"
  get_site_dir "$site_name" >/dev/null
}

die_with_error() {
  echo -e "${CError}Error:${Color_Off} $*" >&2
  exit 1
}
