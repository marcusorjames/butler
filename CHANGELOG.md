<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to Butler are documented here.

## [beta] — June 2026

### Added

- Pre-flight check on docker-compose commands that fails early with a `butler site link` repair hint when the app symlink is missing or broken
- `app_link_status` shared across site-link, site-status, and docker-compose via `bin/common/functions.sh`
- GitHub Actions CI running format check, lint, and tests on every push and PR
- Branch protection on master requiring CI to pass before merge

### Changed

- nginx-proxy `client_max_body_size` increased to 50M

### Fixed

- `butler dns uninstall` no longer attempts to restart dnsmasq without its config — stops it cleanly instead
- Pre-commit hooks now run against the full file set rather than a `*.sh` glob that never matched

---

## [0.7] — June 2026

### Added

- `butler dns install/uninstall/status` — configures dnsmasq for automatic wildcard `*.<BUTLER_TLD>` resolution; no more manual hosts entries after `butler site add`
- Platform support: macOS (brew + `/etc/resolver/`), Linux with systemd-resolved (routed via port 5300 to avoid conflict with resolved), Linux with NetworkManager
- Guides WSL2 users without systemd through enabling it
- Detects Arch Linux default where `/etc/dnsmasq.conf` has `conf-dir` commented out and enables it automatically
- `butler site add` shows a tip to run `butler dns install` if DNS is not yet configured

---

## [0.6] — June 2026

### Added

- SSH Docker secrets pattern applied to all 11 custom-build templates — host `~/.ssh` mounted as a Docker secret and symlinked inside the container; no plaintext key copies
- All templates updated to use `${BUTLER_PROJECT}` and `${BUTLER_TLD:-test}` so generated sites work without manual editing
- `php8.3` template fixed to use the correct 8.3-fpm-alpine base image

---

## [0.5] — June 2026

### Added

- 72 bats unit tests covering `functions`, `init`, `site-add`, `site-link`, `site-status`, `site-convert`, and `dns`
- `ROOT_DIR` / `BIN_DIR` / `COMMON_DIR` path variables standardised across all bin scripts
- `add_single` and `add_multi` extracted from `bin/site-add` for testability; multi-project input collected before execution with repo pre-validation via `git ls-remote`
- Shared helper functions extracted to `bin/common/functions.sh`
- Dead code and unused `getopt.sh` removed

---

## [0.4] — May 2026

### Added

- `butler site add --multi` — multi-project sites where `app/` is a directory of per-project symlinks rather than a single link
- `butler site convert` — converts an existing single-project site to multi-project layout in place
- `BUTLER_APP_CONTAINER` — per-site override for the target container name used by exec commands
- Per-site `.env` support for `BUTLER_PROJECT` and `BUTLER_PROJECT_DIR` overrides
- `find_site_by_cwd_symlink` — infers the active site from `$PWD` when no site name is passed
- Centralised site resolution in the main dispatcher; all site-aware commands share a single resolution path
- Toolchain managed via mise: `just`, `shfmt`, `shellcheck`, `bats`, `lefthook`, `markdownlint-cli2`
- `just fmt` / `just lint` / `just test` targets
- lefthook pre-commit hooks for shfmt (auto-fix + re-stage) and shellcheck

### Fixed

- macOS compatibility: portable `readlink` and CRLF-safe `.env` loading for WSL
- `BUTLER_REQUIRED_CONTEXT` check and repository validation in `butler site add`

---

## [0.3] — May 2026

### Added

- `butler proxy` — tunnels the current site through ngrok
- `butler ftp` — runs an FTP server against the current site
- `butler sftp` — runs an SFTP server against the current site with relative path support
- `BUTLER_TLD` env var — configure a custom local TLD; default changed from `.local` to `.test`
- Autocomplete extended with file path completion for `exec` and `php`
- MySQL timezone configured in the mysql shared service

---

## [0.2] — December 2023

### Added

- `butler site cd` — changes directory to the site in a new shell session
- `butler site status` — shows symlink health with coloured output
- `butler site link` — creates or repairs the `app` symlink between site and project directories
- `butler exec` / `butler exect` / `butler shell` — container exec shortcuts; `exect` for non-TTY use
- `butler php` — runs PHP in the site container
- `butler composer` — runs Composer via Docker against the current site
- `butler mysql` — MySQL shell with query logging, configurable SQL mode, and timezone
- `butler restart` — restarts the container stack
- `HOST_UID` / `HOST_GID` exported to containers so file ownership matches the host user
- php7.2-apache, commerce, commerce-5.6, php8.2, php8.3-apache, and engine templates
- Xdebug updated to 3.x config format across all PHP templates
- Docker Compose V2 CLI migration (`docker compose` instead of `docker-compose`)
- Coloured output in `site add` prompt

### Fixed

- Xdebug config for CLI use
- Autocomplete on fresh install
- MySQL SQL mode for commerce projects
- Site cd path resolution

---

## [0.1] — March 2023

### Added

- `butler site add` — creates a new site from a template, clones the repository, and creates the `app` symlink
- Docker Compose passthrough — all `docker compose` commands available via butler with automatic site context
- nginx-proxy as a shared reverse proxy — multiple sites served simultaneously under `.local` domains without port conflicts
- `butler run` — runs a named script from the site or global scripts directory
- Templates: wordpress (with Xdebug), php5.4-apache, php7.1-nginx, php7.2-nginx, php7.4-apache, php8.0-nginx
- mailhog shared service template
- Bash autocomplete
- Container names derived from `BUTLER_PROJECT`
- Xdebug configured across all PHP templates
