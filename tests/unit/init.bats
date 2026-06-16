#!/usr/bin/env bats
load "../helpers/common"

# --- init_site ---

@test "init_site exports CURRENT_SITE_DIR" {
  local site_dir
  site_dir="$(mktemp -d)"
  init_site "$site_dir"
  [ "$CURRENT_SITE_DIR" = "$site_dir" ]
}

@test "init_site loads site.env" {
  local site_dir
  site_dir="$(mktemp -d)"
  echo "BUTLER_APP_CONTAINER=custom" >"$site_dir/site.env"
  init_site "$site_dir"
  [ "$BUTLER_APP_CONTAINER" = "custom" ]
}

@test "init_site .env overrides site.env" {
  local site_dir
  site_dir="$(mktemp -d)"
  echo "BUTLER_APP_CONTAINER=from-site-env" >"$site_dir/site.env"
  echo "BUTLER_APP_CONTAINER=from-env" >"$site_dir/.env"
  init_site "$site_dir"
  [ "$BUTLER_APP_CONTAINER" = "from-env" ]
}

@test "init_site auto-exports BUTLER_PROJECT_ vars for each project" {
  local site_dir
  site_dir="$(mktemp -d)"
  echo "BUTLER_PROJECTS=project-a,project-b" >"$site_dir/site.env"
  init_site "$site_dir"
  [ "$BUTLER_PROJECT_PROJECT_A" = "project-a" ]
  [ "$BUTLER_PROJECT_PROJECT_B" = "project-b" ]
}

@test "init_site converts hyphens to underscores in exported var name" {
  local site_dir
  site_dir="$(mktemp -d)"
  echo "BUTLER_PROJECTS=my-project" >"$site_dir/site.env"
  init_site "$site_dir"
  [ "$BUTLER_PROJECT_MY_PROJECT" = "my-project" ]
}

@test "init_site does not overwrite .env override of auto-exported var" {
  local site_dir
  site_dir="$(mktemp -d)"
  echo "BUTLER_PROJECTS=project-a" >"$site_dir/site.env"
  echo "BUTLER_PROJECT_PROJECT_A=override" >"$site_dir/.env"
  init_site "$site_dir"
  [ "$BUTLER_PROJECT_PROJECT_A" = "override" ]
}

# --- find_site_by_cwd_symlink ---

@test "find_site_by_cwd_symlink finds single-project site" {
  local proj_dir site_dir result
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  ln -s "$proj_dir" "$site_dir/app"

  result="$(cd "$proj_dir" && find_site_by_cwd_symlink)"
  [ "$result" = "$site_dir:mysite" ]
}

@test "find_site_by_cwd_symlink finds multi-project site" {
  local proj_dir site_dir result
  proj_dir="$(mktemp -d)"
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir/app"
  ln -s "$proj_dir" "$site_dir/app/myproject"

  result="$(cd "$proj_dir" && find_site_by_cwd_symlink)"
  [ "$result" = "$site_dir:myproject" ]
}

@test "find_site_by_cwd_symlink prefers multi-project over single-project" {
  local proj_dir single_dir multi_dir result
  proj_dir="$(mktemp -d)"
  single_dir="$SITES_DIR/aaa-single"
  multi_dir="$SITES_DIR/bbb-multi"
  mkdir -p "$single_dir"
  ln -s "$proj_dir" "$single_dir/app"
  mkdir -p "$multi_dir/app"
  ln -s "$proj_dir" "$multi_dir/app/myproject"

  result="$(cd "$proj_dir" && find_site_by_cwd_symlink)"
  [ "$result" = "$multi_dir:myproject" ]
}

@test "find_site_by_cwd_symlink returns nonzero when not inside any project" {
  run find_site_by_cwd_symlink
  [ "$status" -ne 0 ]
}

# --- resolve_container ---

@test "resolve_container sets default BUTLER_APP_CONTAINER for single-project site" {
  BUTLER_PROJECTS=""
  BUTLER_APP_CONTAINER=""
  resolve_container || true
  [ "$BUTLER_APP_CONTAINER" = "php" ]
}

@test "resolve_container accepts explicit project argument" {
  BUTLER_PROJECTS="project-a,project-b"
  resolve_container "project-a" || true
  [ "$BUTLER_APP_CONTAINER" = "project-a" ]
}

@test "resolve_container infers container from BUTLER_PROJECT" {
  BUTLER_PROJECTS="project-a,project-b"
  BUTLER_PROJECT="project-b"
  resolve_container || true
  [ "$BUTLER_APP_CONTAINER" = "project-b" ]
}

