#!/usr/bin/env bash

setup() {
  SITES_DIR="$(mktemp -d)"
  PROJECTS_DIR="$(mktemp -d)"
  DIR="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  . "$DIR/bin/common/colours.sh"
  . "$DIR/bin/common/functions.sh"
  . "$DIR/bin/common/init.sh"
}

teardown() {
  rm -rf "$SITES_DIR" "$PROJECTS_DIR"
}
