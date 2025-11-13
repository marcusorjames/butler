#!/bin/sh

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
  local site_name="$1"

  for dir in "${SITES_DIR[@]}"; do
    local candidate="$dir/$site_name"
    if [ -d "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done

  return 1  # not found
}

site_exists() {
  local site_name="$1"
  get_site_dir "$site_name" >/dev/null
}

die_with_error() {
  echo -e "${CError}Error:${Color_Off} $*" >&2
  exit 1
}
