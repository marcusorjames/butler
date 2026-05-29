# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What Butler Is

Butler is a bash CLI tool that manages local development stacks. It wraps Docker Compose with site/project lifecycle management, running nginx-proxy as a shared reverse-proxy so multiple sites can be served under `.test` domains simultaneously.

## Installation

```bash
mise install   # install toolchain (just, shfmt, shellcheck, bats, lefthook)
just install   # symlinks butler to /usr/local/bin, installs autocomplete and git hooks
```

Copy `.env.dist` to `.env` and set your paths before first use:

```bash
BUTLER_SITES_DIR=~/Sites/
BUTLER_PROJECTS_DIR=~/Projects/
BUTLER_REQUIRED_CONTEXT=false   # if true, site add requires a context subdirectory
BUTLER_TLD=test
NGROK_AUTHTOKEN=changeme
MYSQL_PASSWORD=secret
```

Toolchain: `just fmt` (shfmt), `just lint` (shellcheck), `just test` (bats). Formatting and linting are enforced on commit via lefthook.

## Two-Directory Model

Butler maintains two separate directory trees:

- **Sites** (`BUTLER_SITES_DIR`) — Docker Compose config directories, one per site. Each site contains `docker-compose.yml`, optional `scripts/`, and an `app` symlink pointing to the project directory.
- **Projects** (`BUTLER_PROJECTS_DIR`) — Git repository clones (the actual code). Optionally nested under context subdirs (e.g. `Projects/personal/mysite`) when `BUTLER_REQUIRED_CONTEXT=true`.

`butler site add` copies a template into Sites, clones the repo into Projects, and creates the `app` symlink. `butler site link` repairs or creates broken/missing `app` symlinks.

Per-site config overrides live in a `.env` inside the site directory (see `site.env.dist`):

```bash
BUTLER_PROJECT=custom-name          # override inferred project name
BUTLER_PROJECT_DIR=/custom/path     # override resolved project directory
```

## Architecture

### Entry point and dispatch

`butler` (root) sources `bin/common/init.sh`, `colours.sh`, `functions.sh`, then dispatches via a `case` statement. Subcommands are **sourced** (`. $DIR/bin/...`), not executed, so they share the parent shell's variables. Exception: `site-cd` is a standalone executable because it needs to `cd` in a new shell.

### Initialisation flow

1. `init()` — loads `.env` from the butler root, resolves `SITES_DIR` / `PROJECTS_DIR` (strips trailing slash, expands `~`), creates both directories.
2. `init_site <site_dir>` — called before docker-compose commands; loads the site's `.env` and sets `CURRENT_SITE_DIR`, `CURRENT_PROJ_DIR`, optionally overriding `BUTLER_PROJECT` or `BUTLER_PROJECT_DIR`.

### Common library (`bin/common/`)

| File | Purpose |
|------|---------|
| `init.sh` | `init()` and `init_site()` |
| `functions.sh` | `get_dir`, `get_site_dir`, `get_project_dir`, `site_exists`, `die_with_error` |
| `colours.sh` | ANSI colour variables; semantic aliases `CError`/`CWarn`/`CSuccess` |
| `statusline.sh` | `statusLine` (progress line) and `statusBadge` (name + coloured badge) |
| `fzfread.sh` | Interactive prompt that uses `fzf` if available, falls back to `read` |
| `getopt.sh` | Helper for getopts-style option parsing (less commonly used) |

### Docker Compose integration (`bin/docker-compose`)

The passthrough uses the pre-resolved `$CURRENT_SITE_DIR` (set by `resolve_site` in `butler` before dispatch), ensures nginx-proxy is running, sources `<site-dir>/scripts/<cmd>` if it exists, then delegates to `docker compose --project-directory <site-dir>`.

### Scripts (`scripts/` and `<site-dir>/scripts/`)

`butler run <name>` looks for `<site-dir>/scripts/<name>` first, then falls back to the global `scripts/` directory. Global scripts currently include `composer` and `gulp`. Site scripts are also auto-sourced by the docker-compose passthrough before the compose command runs.

### Templates (`templates/`)

Copied verbatim into Sites by `butler site add`. Available templates include various PHP+nginx/apache combinations (`php7.x`, `php8.x`), `wordpress`, `commerce`, and shared service templates (`mysql`, `mailhog`, `nginx-proxy`). Each contains a `docker-compose.yml`; PHP templates also include a `PHP.DockerFile` and Xdebug config.

## Commit Hook

The `commit-msg` hook runs `aspell` to check spelling and warns (non-blocking) if no Jira ticket reference (`[PROJECT-123]`) is found. It does not block commits.
