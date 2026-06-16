#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  . "$BIN_DIR/site-add"
}

# --- main (error paths) ---

@test "main -h exits 0" {
  run main -h
  [ "$status" -eq 0 ]
}

@test "main exits 1 for nonexistent template" {
  run main -t nosuchtemplate -n mysite
  [ "$status" -eq 1 ]
}

@test "main exits 1 when site already exists" {
  mkdir -p "$SITES_DIR/mysite"
  run main -t php8.3 -n mysite -r /dev/null
  [ "$status" -eq 1 ]
}

@test "main exits 1 for non-alphabetic context" {
  run main -t php8.3 -n mysite -c 1invalid -r /dev/null
  [ "$status" -eq 1 ]
}

# --- add_single ---

@test "add_single creates site dir from template" {
  local site_dir proj_dir
  site_dir="$SITES_DIR/mysite"
  proj_dir="$PROJECTS_DIR/mysite"

  add_single "$site_dir" "$ROOT_DIR/templates/php8.3" "$proj_dir" ""
  [ -f "$site_dir/docker-compose.yml" ]
}

@test "add_single creates project dir" {
  local site_dir proj_dir
  site_dir="$SITES_DIR/mysite"
  proj_dir="$PROJECTS_DIR/mysite"

  add_single "$site_dir" "$ROOT_DIR/templates/php8.3" "$proj_dir" ""
  [ -d "$proj_dir" ]
}

@test "add_single creates app symlink pointing at project dir" {
  local site_dir proj_dir
  site_dir="$SITES_DIR/mysite"
  proj_dir="$PROJECTS_DIR/mysite"

  add_single "$site_dir" "$ROOT_DIR/templates/php8.3" "$proj_dir" ""
  [ -L "$site_dir/app" ]
  [ "$(readlink "$site_dir/app")" = "$proj_dir" ]
}

@test "add_single clones repository when provided" {
  local site_dir proj_dir repo
  site_dir="$SITES_DIR/mysite"
  proj_dir="$PROJECTS_DIR/mysite"
  repo="$(mktemp -d)"
  git init --bare "$repo" >/dev/null 2>&1

  add_single "$site_dir" "$ROOT_DIR/templates/php8.3" "$proj_dir" "$repo"
  [ -d "$proj_dir/.git" ]
}

# --- add_multi ---

@test "add_multi creates site dir from template" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  local proj_names=("project-a" "project-b")
  local proj_dirs=("$PROJECTS_DIR/project-a" "$PROJECTS_DIR/project-b")
  local proj_repos=("" "")

  add_multi "$site_dir" "$ROOT_DIR/templates/php8.3" proj_names proj_dirs proj_repos
  [ -f "$site_dir/docker-compose.yml" ]
}

@test "add_multi creates symlink per project inside app/" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  local proj_names=("project-a" "project-b")
  local proj_dirs=("$PROJECTS_DIR/project-a" "$PROJECTS_DIR/project-b")
  local proj_repos=("" "")

  add_multi "$site_dir" "$ROOT_DIR/templates/php8.3" proj_names proj_dirs proj_repos
  [ -L "$site_dir/app/project-a" ]
  [ -L "$site_dir/app/project-b" ]
}

@test "add_multi symlinks resolve to correct project dirs" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  local proj_names=("project-a")
  local proj_dirs=("$PROJECTS_DIR/project-a")
  local proj_repos=("")

  add_multi "$site_dir" "$ROOT_DIR/templates/php8.3" proj_names proj_dirs proj_repos
  [ "$(readlink "$site_dir/app/project-a")" = "$PROJECTS_DIR/project-a" ]
}

@test "add_multi writes BUTLER_PROJECTS to site .env" {
  local site_dir
  site_dir="$SITES_DIR/mysite"
  local proj_names=("project-a" "project-b")
  local proj_dirs=("$PROJECTS_DIR/project-a" "$PROJECTS_DIR/project-b")
  local proj_repos=("" "")

  add_multi "$site_dir" "$ROOT_DIR/templates/php8.3" proj_names proj_dirs proj_repos
  grep -q "^BUTLER_PROJECTS=project-a,project-b" "$site_dir/.env"
}

@test "add_multi clones repository when provided" {
  local site_dir repo
  site_dir="$SITES_DIR/mysite"
  repo="$(mktemp -d)"
  git init --bare "$repo" >/dev/null 2>&1
  local proj_names=("project-a")
  local proj_dirs=("$PROJECTS_DIR/project-a")
  local proj_repos=("$repo")

  add_multi "$site_dir" "$ROOT_DIR/templates/php8.3" proj_names proj_dirs proj_repos
  [ -d "$PROJECTS_DIR/project-a/.git" ]
}
