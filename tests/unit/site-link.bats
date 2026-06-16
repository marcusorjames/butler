#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  . "$BIN_DIR/site-link"
}

@test "link_single creates app symlink when none exists" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"

  link_single "mysite" "$site_dir" "$proj_dir" false
  [ -L "$site_dir/app" ]
  [ "$(readlink "$site_dir/app")" = "$proj_dir" ]
}

@test "link_single skips when symlink already exists and is valid" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"

  ln -s "$proj_dir" "$site_dir/app"

  link_single "mysite" "$site_dir" "$proj_dir" false
  [ -L "$site_dir/app" ]
  [ "$(readlink "$site_dir/app")" = "$proj_dir" ]
}

@test "link_single reports broken symlink without --fix" {
  local proj_dir site_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  ln -s "/nonexistent/path" "$site_dir/app"

  run link_single "mysite" "$site_dir" "/nonexistent/path" false
  [ "$status" -ne 0 ]
}

@test "link_single repairs broken symlink with --fix" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  ln -s "/nonexistent/path" "$site_dir/app"

  link_single "mysite" "$site_dir" "$proj_dir" true
  [ -L "$site_dir/app" ]
  [ "$(readlink "$site_dir/app")" = "$proj_dir" ]
}

@test "link_multi creates per-project symlinks inside app/" {
  local proj_a proj_b site_dir
  proj_a="$(mktemp -d)"
  proj_b="$(mktemp -d)"
  mkdir -p "$PROJECTS_DIR/project-a" "$PROJECTS_DIR/project-b"
  rmdir "$PROJECTS_DIR/project-a" "$PROJECTS_DIR/project-b"
  mv "$proj_a" "$PROJECTS_DIR/project-a"
  mv "$proj_b" "$PROJECTS_DIR/project-b"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  BUTLER_PROJECTS="project-a,project-b"

  link_multi "$site_dir" false
  [ -L "$site_dir/app/project-a" ]
  [ -L "$site_dir/app/project-b" ]
}

@test "link_multi repairs broken per-project symlink with --fix" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  mkdir -p "$PROJECTS_DIR/myproject"
  rmdir "$PROJECTS_DIR/myproject"
  mv "$proj_dir" "$PROJECTS_DIR/myproject"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir/app"
  ln -s "/nonexistent/path" "$site_dir/app/myproject"
  BUTLER_PROJECTS="myproject"

  link_multi "$site_dir" true
  [ -L "$site_dir/app/myproject" ]
  [ "$(readlink -f "$site_dir/app/myproject")" = "$PROJECTS_DIR/myproject" ]
}
