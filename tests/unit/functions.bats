#!/usr/bin/env bats
load "../helpers/common"

@test "get_site_dir returns path when site exists" {
  mkdir -p "$SITES_DIR/mysite"
  result="$(get_site_dir mysite)"
  [ "$result" = "$SITES_DIR/mysite" ]
}

@test "get_site_dir exits nonzero when site is absent" {
  run get_site_dir mysite
  [ "$status" -ne 0 ]
}

@test "site_exists returns 0 for existing site" {
  mkdir -p "$SITES_DIR/mysite"
  run site_exists "mysite"
  [ "$status" -eq 0 ]
}

@test "site_exists returns nonzero for missing site" {
  run site_exists "mysite"
  [ "$status" -ne 0 ]
}

@test "get_project_dir returns path when project exists" {
  mkdir -p "$PROJECTS_DIR/myproject"
  result="$(get_project_dir myproject)"
  [ "$result" = "$PROJECTS_DIR/myproject" ]
}

@test "get_project_dir exits nonzero when project is absent" {
  run get_project_dir myproject
  [ "$status" -ne 0 ]
}

@test "project_exists returns 0 for existing project" {
  mkdir -p "$PROJECTS_DIR/myproject"
  run project_exists myproject
  [ "$status" -eq 0 ]
}

@test "project_exists returns nonzero for missing project" {
  run project_exists myproject
  [ "$status" -ne 0 ]
}

@test "get_template_dir returns path when template exists" {
  local base
  base="$(mktemp -d)"
  mkdir -p "$base/bin" "$base/templates/mytemplate"
  DIR="$base/bin"

  result="$(get_template_dir mytemplate)"
  [ "$result" = "$base/bin/../templates/mytemplate" ]
}

@test "get_template_dir exits nonzero when template is absent" {
  local base
  base="$(mktemp -d)"
  mkdir -p "$base/bin"
  DIR="$base/bin"

  run get_template_dir nonexistent
  [ "$status" -ne 0 ]
}
