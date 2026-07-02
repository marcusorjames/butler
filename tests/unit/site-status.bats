#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  . "$BIN_DIR/site-status"
}

# --- app_link_status ---

@test "app_link_status returns ok for valid symlink" {
  local target link
  target="$(mktemp -d)"
  link="$(mktemp -u)"
  ln -s "$target" "$link"

  result="$(app_link_status "$link")"
  rm "$link"
  [ "$result" = "ok" ]
}

@test "app_link_status returns broken for dead symlink" {
  local link
  link="$(mktemp -u)"
  ln -s "/nonexistent/path" "$link"

  result="$(app_link_status "$link")"
  rm "$link"
  [ "$result" = "broken" ]
}

@test "app_link_status returns missing when path does not exist" {
  result="$(app_link_status "/nonexistent/path")"
  [ "$result" = "missing" ]
}

# --- status_single ---

@test "status_single reports OK for valid app symlink" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  ln -s "$proj_dir" "$site_dir/app"

  run status_single "mysite" "$site_dir" false
  [[ "$output" == *"OK"* ]]
}

@test "status_single reports BROKEN for dead app symlink" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  ln -s "/nonexistent/path" "$site_dir/app"

  run status_single "mysite" "$site_dir" false
  [[ "$output" == *"BROKEN"* ]]
}

@test "status_single reports MISSING when no app symlink" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"

  run status_single "mysite" "$site_dir" false
  [[ "$output" == *"MISSING"* ]]
}

# --- status_multi ---

@test "status_multi reports OK for all valid project symlinks" {
  local proj_a proj_b site_dir
  proj_a="$(mktemp -d)"
  proj_b="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir/app"
  ln -s "$proj_a" "$site_dir/app/project-a"
  ln -s "$proj_b" "$site_dir/app/project-b"
  BUTLER_PROJECTS="project-a,project-b"

  run status_multi "mysite" "$site_dir" false
  [[ "$output" == *"project-a"* ]]
  [[ "$output" == *"project-b"* ]]
  [[ "$output" == *"OK"* ]]
}

@test "main with no args shows status for all sites" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  ln -s "$proj_dir" "$site_dir/app"

  run main
  [ "$status" -eq 0 ]
  [[ "$output" == *"mysite"* ]]
  [[ "$output" == *"OK"* ]]
}

@test "main with no args prints message when no sites exist" {
  run main
  [ "$status" -eq 0 ]
  [[ "$output" == *"No sites found"* ]]
}

@test "status_multi reports BROKEN for dead project symlink" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir/app"
  ln -s "$proj_dir" "$site_dir/app/project-a"
  ln -s "/nonexistent/path" "$site_dir/app/project-b"
  BUTLER_PROJECTS="project-a,project-b"

  run status_multi "mysite" "$site_dir" false
  [[ "$output" == *"BROKEN"* ]]
}
