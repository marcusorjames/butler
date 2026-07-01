# Butler TODO

- Add site script discoverability: a command to list scripts available for the current site, and auto-expose them as butler commands — guarded against clashes with built-in commands
- Add butler.toml for static site config (preset, required services etc.) — TOML over YAML for readability. Presets (laravel, wordpress etc.) unlock built-in CLI commands for that stack. Required services would start shared services automatically, replacing manual hooks/up scripts
- Add laravel preset (blocked by script discoverability and butler.toml)
- add ability to use in project docker compose as well - fall back to docker-composer commands like the laravel one?
- Look at laravels one as it might help tidy up the code
