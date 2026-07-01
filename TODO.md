# Butler TODO

- add ability to use in project docker compose as well - fall back to docker-composer commands like the laravel one?
- Look at laravels one as it might help tidy up the code
- Rename site pre-hook directory from scripts/ to hooks/ to distinguish lifecycle hooks from user-facing site commands
- Add butler.toml for static site config (preset, required services etc.) — TOML over YAML for readability. Presets (laravel, wordpress etc.) unlock built-in CLI commands for that stack. Required services replace the current scripts/up pattern for starting shared services
- Add site script discoverability: a command to list scripts available for the current site, and auto-expose them as butler commands — guarded against clashes with built-in commands
- Note PHP focus in README
- Add laravel, currently have a laravel script to run the build url
- Move from mailhog to mailtrap
