# Butler

**Your friendly dev stack helper** — a bash CLI that wraps Docker Compose to manage local development stacks. Runs nginx-proxy as a shared reverse-proxy so multiple sites can be served under `.test` domains simultaneously.

## Prerequisites

[mise](https://mise.jdx.dev) is the only required dependency. It manages all other tools (just, shellcheck, shfmt, bats, lefthook).

```bash
curl https://mise.run | sh
```

Then add mise activation to your shell config (`~/.zshrc`, `~/.bashrc`):

```bash
eval "$(mise activate zsh)"   # or bash
```

## Installation

```bash
mise install       # install toolchain
just install       # symlink butler to /usr/local/bin, install autocomplete and git hooks
```

Copy `.env.dist` to `.env` and set your paths:

```bash
cp .env.dist .env
```

```bash
BUTLER_SITES_DIR=~/Sites/          # where Docker Compose site configs live
BUTLER_PROJECTS_DIR=~/Projects/    # where Git repos live
BUTLER_REQUIRED_CONTEXT=false      # if true, site add requires a context subdirectory
BUTLER_TLD=test                    # local domain TLD (sites served at <name>.test)
NGROK_AUTHTOKEN=changeme           # ngrok token for butler proxy
MYSQL_PASSWORD=secret              # shared MySQL password
```

## Usage

```bash
butler COMMAND [SITE] [ARGS...]
```

If `SITE` is omitted from site commands, butler infers the site from your current working directory.

### Management

| Command | Description |
| --- | --- |
| `butler install` | First-time setup wizard |
| `butler site add` | Add a new site |
| `butler site list` | List all sites |
| `butler site clone [-c CONTEXT] [SITE] <REPO>` | Clone a repo and link it to an existing site |
| `butler site add --multi` | Add a new multi-project site |
| `butler site convert [SITE]` | Convert single-project site to multi-project |
| `butler site cd` | Change directory to a site |
| `butler site status [SITE]` | Show status of site(s) |
| `butler site link [SITE]` | Link or repair app symlinks; omit SITE to process all sites |
| `butler dns install` | Configure dnsmasq for automatic `*.test` resolution |
| `butler dns uninstall` | Remove butler DNS configuration |
| `butler dns status` | Show DNS configuration and resolution state |

### Site Commands

| Command | Description |
| --- | --- |
| `butler up [SITE]` | Start container stack |
| `butler down [SITE]` | Stop container stack |
| `butler restart [SITE]` | Restart container stack |
| `butler exec [SITE] [PROJECT] <cmd>` | Execute command on app container |
| `butler shell [SITE] [PROJECT]` | Open a shell in the app container |
| `butler php [SITE] <args>` | Run php on the container |
| `butler composer [SITE] [PROJECT] <args>` | Run composer on the container |
| `butler run [SITE] <script>` | Run a custom script |
| `butler proxy [SITE]` | Proxy site through ngrok |

### Other Commands

| Command | Description |
| --- | --- |
| `butler templates` | List available site templates |
| `butler mysql` | Open a MySQL shell |
| `butler ftp` | Run an ephemeral FTP server |
| `butler sftp` | Run an ephemeral SFTP server |

## Local DNS

Butler can configure [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) to resolve all `*.<BUTLER_TLD>` domains to `127.0.0.1` automatically — no manual `/etc/hosts` entries needed after `butler site add`.

```bash
butler dns install     # configure dnsmasq for *.test resolution
butler dns uninstall   # remove butler DNS configuration
butler dns status      # show configuration and resolution state
```

Install dnsmasq first if it is not already present (`brew install dnsmasq`, `sudo pacman -S dnsmasq`, `sudo apt install dnsmasq`, etc.), then run `butler dns install`.

| Platform | Routing mechanism |
| --- | --- |
| macOS | `/etc/resolver/<tld>` pointing to dnsmasq on port 5300 |
| Linux + systemd-resolved | `/etc/systemd/resolved.conf.d/butler.conf` routing `~<tld>` to dnsmasq |
| Linux + NetworkManager | `/etc/NetworkManager/dnsmasq.d/butler.conf` |
| WSL2 | Requires systemd enabled — `butler dns install` will guide you if it is not |

Without DNS configured, add entries to `/etc/hosts` manually:

```text
127.0.0.1 mysite.test
```

## Two-Directory Model

Butler maintains two separate directory trees:

- **Sites** (`BUTLER_SITES_DIR`) — Docker Compose configs, one per site. Each contains `docker-compose.yml`, optional `scripts/`, and an `app` symlink (single-project) or `app/` directory of named symlinks (multi-project) pointing to the project(s).
- **Projects** (`BUTLER_PROJECTS_DIR`) — Git repository clones. Optionally nested under context subdirs (e.g. `Projects/work/mysite`) when `BUTLER_REQUIRED_CONTEXT=true`.

Butler resolves the current site by scanning `app` symlinks in `BUTLER_SITES_DIR` — so running `butler shell` from anywhere inside a project directory just works.

### Single-project sites

A site's `app` is a symlink to one project directory. The project name is inferred from the current working directory, or overridden in `site.env`:

```bash
# Sites/mysite/site.env
BUTLER_PROJECT=custom-name           # override inferred project name
BUTLER_PROJECT_DIR=/custom/path      # override resolved project directory
BUTLER_APP_CONTAINER=php             # container name for exec/shell/composer
```

Use `.env` in the site directory for local overrides (passwords, domain overrides) that should not be committed.

### Multi-project sites

A multi-project site has `app/` as a directory of named symlinks, one per project. Declare the projects in `site.env`:

```bash
# Sites/mysite/site.env
BUTLER_PROJECTS=project-a,project-b
```

Butler automatically exports `BUTLER_PROJECT_<NAME>` for each project, which `docker-compose.yml` can use for domains — the same way single-project sites use `$BUTLER_PROJECT`:

```yaml
services:
  project-a:
    environment:
      VIRTUAL_HOST: "${BUTLER_PROJECT_PROJECT_A}.${BUTLER_TLD:-test}"
  project-b:
    environment:
      VIRTUAL_HOST: "${BUTLER_PROJECT_PROJECT_B}.${BUTLER_TLD:-test}"
```

Override a domain without changing `docker-compose.yml` by setting the var in `.env`:

```bash
# Sites/mysite/.env
BUTLER_PROJECT_PROJECT_A=other-domain   # serves as other-domain.test instead
```

For `exec`, `shell`, and `composer`, butler selects the container automatically when run from inside a project directory. From outside, pass the project name as an argument or choose from the picker:

```bash
butler shell mysite project-a        # explicit
butler shell mysite                  # fzf/numbered picker
```

## Development

```bash
just fmt     # format all shell scripts with shfmt
just lint    # lint all shell scripts with shellcheck
just test    # run bats test suite
```

Formatting and linting are enforced automatically on every commit via lefthook.
