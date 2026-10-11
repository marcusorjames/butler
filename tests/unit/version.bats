#!/usr/bin/env bats

setup() {
  ROOT_DIR="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  VERSION="$(cat "$ROOT_DIR/VERSION")"
}

@test "VERSION file holds a semantic version" {
  [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]]
}

@test "--version prints the VERSION file contents" {
  run "$ROOT_DIR/butler" --version
  [ "$status" -eq 0 ]
  [ "$output" = "butler $VERSION" ]
}

@test "-V is a shorthand for --version" {
  run "$ROOT_DIR/butler" -V
  [ "$status" -eq 0 ]
  [ "$output" = "butler $VERSION" ]
}

@test "--help shows the version" {
  run "$ROOT_DIR/butler" --help
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "butler version $VERSION"
}

@test "--version works through a symlink" {
  link="$(mktemp -d)/butler"
  ln -s "$ROOT_DIR/butler" "$link"
  run "$link" --version
  [ "$status" -eq 0 ]
  [ "$output" = "butler $VERSION" ]
}
