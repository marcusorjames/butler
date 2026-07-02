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

app_link_status() {
  local link_path="$1"
  if [ -L "$link_path" ] && [ -e "$link_path" ]; then
    echo "ok"
  elif [ -L "$link_path" ]; then
    echo "broken"
  else
    echo "missing"
  fi
}

assert_app_linked() {
  local site_dir="$1" site="$2" butler_projects="$3"
  local app_path="$site_dir/app"

  if [ -n "$butler_projects" ]; then
    local p status fix
    for p in ${butler_projects//,/ }; do
      status="$(app_link_status "$app_path/$p")"
      [ "$status" = "ok" ] && continue
      fix="$([ "$status" = "broken" ] && echo "--fix ")"
      die_with_error "Project symlink ${CWarn}$p${Color_Off} is $status. Run: butler site link ${fix}$site"
    done
  else
    local status fix
    status="$(app_link_status "$app_path")"
    [ "$status" = "ok" ] && return 0
    fix="$([ "$status" = "broken" ] && echo "--fix ")"
    die_with_error "app symlink is $status. Run: butler site link ${fix}$site"
  fi
}

# Prompt when a project directory already exists before cloning into it.
# Returns 0 to proceed, 1 to abort. Returns 0 immediately if dir does not exist.
confirm_existing_project_dir() {
  local proj_dir="$1"
  [ -d "$proj_dir" ] || return 0

  if [ -d "$proj_dir/.git" ]; then
    local existing_url
    existing_url="$(git -C "$proj_dir" config --get remote.origin.url)"
    read -r -p "$(echo -e "Project dir ${Green}$proj_dir${Color_Off} already exists (repo: ${Green}$existing_url${Color_Off}) — use existing? [Yn] ")" -n 1
  else
    read -r -p "$(echo -e "Project dir ${Green}$proj_dir${Color_Off} already exists — use existing? [Yn] ")" -n 1
  fi
  echo
  [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
  return 0
}

die_with_error() {
  echo -e "${CError}Error:${Color_Off} $*" >&2
  exit 1
}

for_each_site() {
  local callback="$1"
  local found=false
  local site site_dir
  for site_dir in "$SITES_DIR"/*/; do
    [ -d "$site_dir" ] || continue
    site_dir="${site_dir%/}"
    site="$(basename "$site_dir")"
    found=true
    "$callback" "$site" "$site_dir"
  done
  $found || echo "No sites found in $SITES_DIR"
}

dns_is_configured() {
  local tld="${BUTLER_TLD:-test}"
  local butler_conf

  if [ "$(uname -s)" = "Darwin" ]; then
    butler_conf="$(brew --prefix 2>/dev/null)/etc/dnsmasq.d/butler.conf"
  else
    butler_conf="/etc/dnsmasq.d/butler.conf"
  fi

  [ -f "$butler_conf" ] && grep -q "address=/\.$tld/" "$butler_conf" 2>/dev/null &&
    systemctl is-active --quiet dnsmasq 2>/dev/null
}
