#!/usr/bin/env bash

setup() {
  SITES_DIR="$(mktemp -d)"
  PROJECTS_DIR="$(mktemp -d)"
  ROOT_DIR="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  BIN_DIR="$ROOT_DIR/bin"
  COMMON_DIR="$BIN_DIR/common"
  main() { :; }
  . "$COMMON_DIR/colours.sh"
  . "$COMMON_DIR/functions.sh"
  . "$COMMON_DIR/statusline.sh"
  . "$COMMON_DIR/init.sh"
  if declare -f setup_extra > /dev/null 2>&1; then setup_extra; fi
}

teardown() {
  rm -rf "$SITES_DIR" "$PROJECTS_DIR"
}
