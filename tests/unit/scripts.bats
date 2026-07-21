#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  CURRENT_SITE_DIR="$SITES_DIR/mysite"
  mkdir -p "$CURRENT_SITE_DIR"
  . "$BIN_DIR/scripts"
}

@test "scripts lists site-local scripts" {
  mkdir -p "$CURRENT_SITE_DIR/scripts"
  touch "$CURRENT_SITE_DIR/scripts/deploy"

  run main
  [ "$status" -eq 0 ]
  [[ "$output" == *"deploy"* ]]
}

@test "scripts lists global scripts" {
  local fake_root
  fake_root="$(mktemp -d)"
  mkdir -p "$fake_root/scripts"
  touch "$fake_root/scripts/deploy"
  ROOT_DIR="$fake_root"

  run main
  [ "$status" -eq 0 ]
  [[ "$output" == *"deploy"* ]]
  [[ "$output" == *"(global)"* ]]
}

@test "scripts warns about global scripts shadowed by built-in commands" {
  local fake_root
  fake_root="$(mktemp -d)"
  mkdir -p "$fake_root/scripts"
  touch "$fake_root/scripts/composer"
  ROOT_DIR="$fake_root"

  run main
  [ "$status" -eq 0 ]
  [[ "$output" == *"composer"* ]]
  [[ "$output" == *"shadowed by built-in"* ]]
  [[ "$output" == *"butler run composer"* ]]
}

@test "scripts warns about site-local scripts shadowed by built-in commands" {
  mkdir -p "$CURRENT_SITE_DIR/scripts"
  touch "$CURRENT_SITE_DIR/scripts/composer"

  run main
  [ "$status" -eq 0 ]
  [[ "$output" == *"composer"* ]]
  [[ "$output" == *"shadowed by built-in"* ]]
  [[ "$output" == *"butler run composer"* ]]
}

@test "scripts does not duplicate a script present in both site and global" {
  mkdir -p "$CURRENT_SITE_DIR/scripts"
  touch "$CURRENT_SITE_DIR/scripts/gulp"

  run main
  [ "$status" -eq 0 ]
  count=$(echo "$output" | grep -c "gulp")
  [ "$count" -eq 1 ]
}

@test "scripts site-local script takes precedence over global (no global label)" {
  mkdir -p "$CURRENT_SITE_DIR/scripts"
  touch "$CURRENT_SITE_DIR/scripts/gulp"

  run main
  [ "$status" -eq 0 ]
  ! echo "$output" | grep "gulp" | grep -q "(global)"
}

@test "scripts prints message when no scripts available" {
  # Override ROOT_DIR scripts to empty dir
  local empty_scripts
  empty_scripts="$(mktemp -d)"
  ROOT_DIR="$empty_scripts"

  run main
  [ "$status" -eq 0 ]
  [[ "$output" == *"No scripts available"* ]]
}

@test "scripts -h exits 0" {
  run main -h
  [ "$status" -eq 0 ]
}
