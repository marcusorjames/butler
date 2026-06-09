#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  . "$DIR/bin/site-convert"
}

# --- convert_app_symlink ---

@test "convert_app_symlink replaces symlink with directory" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  ln -s "$proj_dir" "$site_dir/app"

  convert_app_symlink "mysite" "$site_dir"
  [ -d "$site_dir/app" ]
  [ ! -L "$site_dir/app" ]
}

@test "convert_app_symlink creates named symlink inside app/" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  ln -s "$proj_dir" "$site_dir/app"

  convert_app_symlink "mysite" "$site_dir"
  [ -L "$site_dir/app/$(basename "$proj_dir")" ]
}

@test "convert_app_symlink exits with error if already multi-project" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir/app"

  run convert_app_symlink "mysite" "$site_dir"
  [ "$status" -ne 0 ]
}

@test "convert_app_symlink exits with error if no app symlink" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"

  run convert_app_symlink "mysite" "$site_dir"
  [ "$status" -ne 0 ]
}

# --- write_butler_projects ---

@test "write_butler_projects writes BUTLER_PROJECTS to .env" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"

  write_butler_projects "$site_dir" "project-a,project-b"
  grep -q "^BUTLER_PROJECTS=project-a,project-b" "$site_dir/.env"
}

@test "write_butler_projects updates existing BUTLER_PROJECTS line" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  echo "BUTLER_PROJECTS=old-value" >"$site_dir/.env"

  write_butler_projects "$site_dir" "project-a"
  grep -q "^BUTLER_PROJECTS=project-a" "$site_dir/.env"
  [ "$(grep -c "^BUTLER_PROJECTS=" "$site_dir/.env")" -eq 1 ]
}
