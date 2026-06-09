#!/usr/bin/env bash

setup() {
  SITES_DIR="$(mktemp -d)"
  PROJECTS_DIR="$(mktemp -d)"
  DIR="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  COMMON="$DIR/bin/common"
  main() { :; }
  . "$DIR/bin/common/colours.sh"
  . "$DIR/bin/common/functions.sh"
  . "$DIR/bin/common/statusline.sh"
  . "$DIR/bin/common/init.sh"
  if declare -f setup_extra > /dev/null 2>&1; then setup_extra; fi
}

teardown() {
  rm -rf "$SITES_DIR" "$PROJECTS_DIR"
}
