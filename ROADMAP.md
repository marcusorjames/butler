# Roadmap

## v1

- ~~**Script discoverability** — `butler scripts` lists scripts available for the current site; unknown commands auto-dispatch to site scripts, with built-in commands always taking precedence~~
- ~~**TTY detection** — append `-T` to `docker compose exec` when stdin is not a terminal, preventing TTY errors in non-interactive contexts (e.g. CI scripts)~~
- ~~**Stacked compose files** — `BUTLER_COMPOSE_FILES` env var (colon-separated) appends extra `-f` flags to every compose invocation, allowing per-project overrides without modifying the main `docker-compose.yml`~~

## Future

- **Auto-start on boot** — register nginx-proxy and the domain watcher as a system service (systemd on Linux, launchd on macOS) so `.test` domains resolve and sites start booting before a terminal is opened
- **butler.toml** — static per-site config: stack preset, required shared services, and site metadata. Presets (e.g. `laravel`, `wordpress`) unlock built-in CLI commands for that stack. Required services replace manual `hooks/up` scripts
- **Laravel preset** — built-in `artisan`, `composer`, and queue/scheduler commands, unlocked by `preset = "laravel"` in `butler.toml` (blocked by butler.toml)
- **In-project docker-compose** — fall back to a `docker-compose.yml` in the project root when no site directory exists, supporting teams that manage their own compose setup
- **fzf install hint** — when fzf is not installed and a picker is needed, show a one-time hint suggesting `fzf` for a better experience (fallback to numbered prompt already works)
