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
  local site_dir
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

@test "link_site links single-project site" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  mkdir -p "$PROJECTS_DIR/mysite"
  rmdir "$PROJECTS_DIR/mysite"
  mv "$proj_dir" "$PROJECTS_DIR/mysite"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"

  link_site "mysite" "$site_dir" false
  [ -L "$site_dir/app" ]
  [ "$(readlink -f "$site_dir/app")" = "$PROJECTS_DIR/mysite" ]
}

@test "link_site returns 1 when project does not exist" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"

  run link_site "mysite" "$site_dir" false
  [ "$status" -eq 1 ]
}

@test "link_site links multi-project site via site.env" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  mkdir -p "$PROJECTS_DIR/proj-a"
  rmdir "$PROJECTS_DIR/proj-a"
  mv "$proj_dir" "$PROJECTS_DIR/proj-a"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  echo "BUTLER_PROJECTS=proj-a" >"$site_dir/site.env"

  link_site "mysite" "$site_dir" false
  [ -L "$site_dir/app/proj-a" ]
  [ "$(readlink -f "$site_dir/app/proj-a")" = "$PROJECTS_DIR/proj-a" ]
}

@test "link_site links multi-project site via .env" {
  local proj_dir site_dir
  proj_dir="$(mktemp -d)"
  mkdir -p "$PROJECTS_DIR/proj-b"
  rmdir "$PROJECTS_DIR/proj-b"
  mv "$proj_dir" "$PROJECTS_DIR/proj-b"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  echo "BUTLER_PROJECTS=proj-b" >"$site_dir/.env"

  link_site "mysite" "$site_dir" false
  [ -L "$site_dir/app/proj-b" ]
}

@test "link_all links all single-project sites" {
  local proj_a proj_b
  proj_a="$(mktemp -d)"
  proj_b="$(mktemp -d)"
  mkdir -p "$PROJECTS_DIR/site-a" "$PROJECTS_DIR/site-b"
  rmdir "$PROJECTS_DIR/site-a" "$PROJECTS_DIR/site-b"
  mv "$proj_a" "$PROJECTS_DIR/site-a"
  mv "$proj_b" "$PROJECTS_DIR/site-b"
  mkdir -p "$SITES_DIR/site-a" "$SITES_DIR/site-b"

  link_all false false
  [ -L "$SITES_DIR/site-a/app" ]
  [ -L "$SITES_DIR/site-b/app" ]
}

@test "link_all with --fix repairs broken symlinks across sites" {
  local proj_dir
  proj_dir="$(mktemp -d)"
  mkdir -p "$PROJECTS_DIR/mysite"
  rmdir "$PROJECTS_DIR/mysite"
  mv "$proj_dir" "$PROJECTS_DIR/mysite"
  mkdir -p "$SITES_DIR/mysite"
  ln -s "/nonexistent/path" "$SITES_DIR/mysite/app"

  link_all true false
  [ -L "$SITES_DIR/mysite/app" ]
  [ "$(readlink -f "$SITES_DIR/mysite/app")" = "$PROJECTS_DIR/mysite" ]
}

@test "link_all silently skips sites with no matching project" {
  local proj_dir
  proj_dir="$(mktemp -d)"
  mkdir -p "$PROJECTS_DIR/good-site"
  rmdir "$PROJECTS_DIR/good-site"
  mv "$proj_dir" "$PROJECTS_DIR/good-site"
  mkdir -p "$SITES_DIR/good-site" "$SITES_DIR/no-project"

  run link_all false false
  [ "$status" -eq 0 ]
  [ -L "$SITES_DIR/good-site/app" ]
  ! echo "$output" | grep -q "no-project"
}

@test "link_all verbose shows skipped sites with no matching project" {
  mkdir -p "$SITES_DIR/no-project"

  run link_all false true
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "no-project"
}

@test "link_all prints message when no sites exist" {
  run link_all false false
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "No sites found"
}
