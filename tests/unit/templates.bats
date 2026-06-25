#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  . "$BIN_DIR/templates"
}

@test "templates lists known templates" {
  run main
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "wordpress"
  echo "$output" | grep -q "php8.3"
}

@test "templates -h exits 0" {
  run main -h
  [ "$status" -eq 0 ]
}
