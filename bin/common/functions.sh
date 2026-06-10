#!/bin/bash

absolute_path() {
  local path="$1"
  # If it already starts with '/', it’s absolute
  if [[ "$path" = /* ]]; then
    echo "$path"
  else
    # Otherwise, expand relative to current directory
    echo "$PWD/$path"
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

get_template_dir() {
  local template_dir="$ROOT_DIR/templates/$1"
  [ -d "$template_dir" ] || return 1
  echo "$template_dir"
}

site_exists() {
  local site_name="$1"
  get_site_dir "$site_name" >/dev/null
}

project_exists() {
  local project_name="$1"
  get_project_dir "$project_name" >/dev/null
}

write_butler_projects() {
  local site_dir="$1" project_names="$2"
  local site_env="$site_dir/.env"

  if [ -f "$site_env" ] && grep -q "^BUTLER_PROJECTS=" "$site_env"; then
    sed -i "s|^BUTLER_PROJECTS=.*|BUTLER_PROJECTS=$project_names|" "$site_env"
  else
    echo "BUTLER_PROJECTS=$project_names" >>"$site_env"
  fi
}

die_with_error() {
  echo -e "${CError}Error:${Color_Off} $*" >&2
  exit 1
}
