#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  . "$BIN_DIR/site-clone"
}

@test "main -h exits 0" {
  run main -h
  [ "$status" -eq 0 ]
}

@test "main exits 1 when site does not exist" {
  run main nosuchsite https://example.com/repo.git
  [ "$status" -eq 1 ]
}

@test "main exits 1 for multi-project site" {
  local site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"
  echo "BUTLER_PROJECTS=proj-a,proj-b" >"$site_dir/site.env"

  run main mysite https://example.com/repo.git
  [ "$status" -eq 1 ]
  echo "$output" | grep -qi "multi-project"
}

@test "main clones repo and creates app symlink" {
  local site_dir repo_dir
  site_dir="$SITES_DIR/mysite"
  mkdir -p "$site_dir"

  repo_dir="$(mktemp -d)"
  git init --bare "$repo_dir" >/dev/null 2>&1

  run main mysite "$repo_dir"
  [ "$status" -eq 0 ]
  [ -L "$site_dir/app" ]
  [ -d "$site_dir/app/.git" ]
}

@test "main skips link when app symlink already valid" {
  local site_dir proj_dir repo_dir
  site_dir="$SITES_DIR/mysite"
  proj_dir="$(mktemp -d)"
  mkdir -p "$site_dir"
  ln -s "$proj_dir" "$site_dir/app"

  repo_dir="$(mktemp -d)"
  git init --bare "$repo_dir" >/dev/null 2>&1

  # proj_dir already exists so confirm_existing_project_dir would prompt —
  # override CURRENT_PROJ_DIR to a fresh temp dir so the clone path is taken
  # but the symlink check fires because app already exists
  run main mysite "$repo_dir"
  [ "$status" -eq 0 ]
  echo "$output" | grep -qi "skip"
}
