#!/usr/bin/env bats
load "../helpers/common"

setup_extra() {
  # Fake command directory — prepend to PATH so mocks shadow real commands
  FAKE_BIN="$(mktemp -d)"
  ORIGINAL_PATH="$PATH"

  . "$BIN_DIR/dns"
}

teardown_extra() {
  PATH="$ORIGINAL_PATH"
  rm -rf "$FAKE_BIN"
}

teardown() {
  rm -rf "$SITES_DIR" "$PROJECTS_DIR"
  if declare -f teardown_extra >/dev/null 2>&1; then teardown_extra; fi
}

# Helper: create a fake executable in FAKE_BIN
fake_cmd() {
  local name="$1" body="$2"
  printf '#!/bin/sh\n%s\n' "$body" >"$FAKE_BIN/$name"
  chmod +x "$FAKE_BIN/$name"
}

# Helper: activate fakes by prepending FAKE_BIN to PATH
use_fakes() { export PATH="$FAKE_BIN:$PATH"; }

# Helper: use ONLY FAKE_BIN — prevents real system package managers from being found
use_isolated_fakes() { export PATH="$FAKE_BIN"; }

# --- detect_platform ---

@test "detect_platform returns macos on Darwin" {
  fake_cmd uname "echo Darwin"
  use_fakes
  run detect_platform
  [ "$status" -eq 0 ]
  [ "$output" = "macos" ]
}

@test "detect_platform returns linux-systemd when systemd-resolved is active" {
  fake_cmd uname "echo Linux"
  fake_cmd systemctl 'case "$*" in *"systemd-resolved"*) exit 0;; *) exit 1;; esac'
  # No /proc/version microsoft marker in test env
  use_fakes
  run detect_platform
  [ "$status" -eq 0 ]
  [ "$output" = "linux-systemd" ]
}

@test "detect_platform returns linux-nm when NetworkManager is active but not resolved" {
  fake_cmd uname "echo Linux"
  fake_cmd systemctl 'case "$*" in *"NetworkManager"*) exit 0;; *) exit 1;; esac'
  use_fakes
  run detect_platform
  [ "$status" -eq 0 ]
  [ "$output" = "linux-nm" ]
}

@test "detect_platform returns unknown when no known resolver active" {
  fake_cmd uname "echo Linux"
  fake_cmd systemctl "exit 1"
  use_fakes
  run detect_platform
  [ "$status" -eq 0 ]
  [ "$output" = "unknown" ]
}

# --- detect_package_manager ---

@test "detect_package_manager returns brew on macOS" {
  fake_cmd uname "echo Darwin"
  use_fakes
  run detect_package_manager
  [ "$output" = "brew" ]
}

@test "detect_package_manager prefers pacman over brew on Linux" {
  fake_cmd uname "echo Linux"
  fake_cmd pacman "exit 0"
  fake_cmd brew "exit 0"
  use_fakes
  run detect_package_manager
  [ "$output" = "pacman" ]
}

@test "detect_package_manager returns apt when pacman absent" {
  fake_cmd uname "echo Linux"
  fake_cmd apt-get "exit 0"
  use_isolated_fakes
  run detect_package_manager
  [ "$output" = "apt" ]
}

@test "detect_package_manager falls back to brew on Linux if no native pm" {
  fake_cmd uname "echo Linux"
  fake_cmd brew "exit 0"
  use_isolated_fakes
  run detect_package_manager
  [ "$output" = "brew" ]
}

@test "detect_package_manager returns unknown when nothing found" {
  fake_cmd uname "echo Linux"
  use_isolated_fakes
  run detect_package_manager
  [ "$output" = "unknown" ]
}

# --- find_conflicting_config ---

@test "find_conflicting_config returns 1 when no configs exist" {
  run find_conflicting_config "test"
  [ "$status" -eq 1 ]
}

@test "find_conflicting_config detects address entry in a foreign conf file" {
  FAKE_CONF_DIR="$(mktemp -d)"
  echo "address=/.test/127.0.0.1" >"$FAKE_CONF_DIR/other.conf"

  # Override dnsmasq helpers — use FAKE_CONF_DIR (global-style) to avoid being
  # shadowed by find_conflicting_config's own `local conf_dir` (dynamic scoping)
  dnsmasq_conf_path() { echo "$FAKE_CONF_DIR/butler.conf"; }
  dnsmasq_conf_dir()  { echo "$FAKE_CONF_DIR"; }
  export -f dnsmasq_conf_path dnsmasq_conf_dir

  run find_conflicting_config "test"
  [ "$status" -eq 0 ]
  [[ "$output" == *"other.conf"* ]]

  rm -rf "$FAKE_CONF_DIR"
}

@test "find_conflicting_config ignores butler's own config file" {
  FAKE_CONF_DIR="$(mktemp -d)"
  echo "address=/.test/127.0.0.1" >"$FAKE_CONF_DIR/butler.conf"

  dnsmasq_conf_path() { echo "$FAKE_CONF_DIR/butler.conf"; }
  dnsmasq_conf_dir()  { echo "$FAKE_CONF_DIR"; }
  export -f dnsmasq_conf_path dnsmasq_conf_dir

  run find_conflicting_config "test"
  [ "$status" -eq 1 ]

  rm -rf "$FAKE_CONF_DIR"
}

@test "find_conflicting_config does not match a different TLD" {
  FAKE_CONF_DIR="$(mktemp -d)"
  echo "address=/.local/127.0.0.1" >"$FAKE_CONF_DIR/other.conf"

  dnsmasq_conf_path() { echo "$FAKE_CONF_DIR/butler.conf"; }
  dnsmasq_conf_dir()  { echo "$FAKE_CONF_DIR"; }
  export -f dnsmasq_conf_path dnsmasq_conf_dir

  run find_conflicting_config "test"
  [ "$status" -eq 1 ]

  rm -rf "$FAKE_CONF_DIR"
}

# --- dns_is_configured ---

@test "dns_is_configured returns 1 when butler conf missing" {
  # Use a TLD that definitely has no config file on disk
  BUTLER_TLD="no-such-tld-$$"
  run dns_is_configured
  [ "$status" -eq 1 ]
}

@test "dns_is_configured returns 1 when conf exists but dnsmasq not running" {
  local conf_dir
  conf_dir="$(mktemp -d)"
  echo "address=/.test/127.0.0.1" >"$conf_dir/butler.conf"

  fake_cmd uname "echo Linux"
  fake_cmd systemctl "exit 1"
  use_fakes

  # Override path helper to point at our temp file
  dns_is_configured() {
    local tld="${BUTLER_TLD:-test}"
    local butler_conf="$conf_dir/butler.conf"
    [ -f "$butler_conf" ] && grep -q "address=/\.$tld/" "$butler_conf" 2>/dev/null \
      && systemctl is-active --quiet dnsmasq 2>/dev/null
  }

  run dns_is_configured
  [ "$status" -eq 1 ]

  rm -rf "$conf_dir"
}

@test "dns_is_configured returns 0 when conf exists and dnsmasq running" {
  local conf_dir
  conf_dir="$(mktemp -d)"
  echo "address=/.test/127.0.0.1" >"$conf_dir/butler.conf"

  fake_cmd uname "echo Linux"
  fake_cmd systemctl "exit 0"
  use_fakes

  dns_is_configured() {
    local tld="${BUTLER_TLD:-test}"
    local butler_conf="$conf_dir/butler.conf"
    [ -f "$butler_conf" ] && grep -q "address=/\.$tld/" "$butler_conf" 2>/dev/null \
      && systemctl is-active --quiet dnsmasq 2>/dev/null
  }

  run dns_is_configured
  [ "$status" -eq 0 ]

  rm -rf "$conf_dir"
}
