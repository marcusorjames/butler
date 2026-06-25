#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  . "$BIN_DIR/site-list"
}

@test "site list shows all sites" {
  mkdir -p "$SITES_DIR/alpha" "$SITES_DIR/beta"

  run main
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "alpha"
  echo "$output" | grep -q "beta"
}

@test "site list prints message when no sites exist" {
  run main
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "No sites found"
}

@test "site list -h exits 0" {
  run main -h
  [ "$status" -eq 0 ]
}
