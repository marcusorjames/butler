# Contributing to Butler

Thanks for helping improve Butler. This guide covers setting up a development environment and getting a change merged.

## Setup

[mise](https://mise.jdx.dev) installs every tool the project needs.

```bash
git clone git@github.com:marcusorjames/butler.git
cd butler
mise install   # just, shfmt, shellcheck, bats, lefthook, markdownlint-cli2
just install   # symlink butler, install autocomplete and git hooks
cp .env.dist .env
```

Docker with the Compose plugin is required to run sites, but is not needed for the test suite.

## Project layout

- `butler` — entry point; sources `bin/common/` and dispatches subcommands
- `bin/` — subcommands, sourced by the entry point (`site-cd` is the exception and runs standalone)
- `bin/common/` — shared helpers (`init`, site and project lookups, colours, status output)
- `templates/` — site templates copied into the sites directory by `butler site add`
- `scripts/` — global scripts available through `butler run`
- `tests/` — bats tests; `tests/helpers/common.bash` holds shared fixtures

## Making a change

1. Branch from `main`. Name the branch after the change type: `feat/…`, `fix/…`, `chore/…`, `refactor/…`, `docs/…`.
2. Make the change and add or update tests under `tests/unit/`. New functionality needs tests.
3. Update `README.md` for any user-facing command or option, and `CHANGELOG.md` for any notable change.
4. Run the checks locally:

   ```bash
   just fmt    # shfmt, 2-space indent
   just lint   # shellcheck and markdownlint
   just test   # bats
   ```

5. Open a pull request against `main`. CI runs the same checks and must pass before merge.

Formatting and linting also run on every commit through lefthook.

## Commit messages

Commits follow [Conventional Commits](https://www.conventionalcommits.org): `type(scope): summary`, where type is one of `feat`, `fix`, `chore`, `docs`, `refactor` or `test`. Mark breaking changes with `!` after the type, for example `feat!: …`. The body should explain why the change was made.

The `commit-msg` hook checks spelling with `aspell` and warns when no Jira reference such as `[PROJECT-123]` is present. Both warnings are advisory and do not block the commit.

## Code style

- Bash, formatted with `shfmt -i 2`, and clean under `shellcheck --severity=warning`.
- Command-line behaviour follows the [Command Line Interface Guidelines](https://clig.dev). Subcommands print help with a `print_usage` function: a one-line description, a `Usage:  butler …` line, then options with lowercase descriptions. `-h` and `--help` print help and exit 0.
- Use the colour variables from `bin/common/colours.sh` (`CError`, `CWarn`, `CSuccess`) for status and error output, and `die_with_error` to abort.

## Reporting bugs and requesting features

Use the issue templates on GitHub. For security issues, follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

By contributing you agree that your contributions are licensed under the [MIT License](LICENSE), and that you will follow the [Code of Conduct](CODE_OF_CONDUCT.md).
