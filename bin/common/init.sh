#!/bin/bash
init() {
  if [ -f "$ROOT_DIR/.env" ]; then
    set -a
    . "$ROOT_DIR/.env"
    set +a
  else
    echo "No .env file found" && exit 0
  fi

  # TODO: Dry the directory env sanitisation up
  # TODO: .env validation e.g. does BUTLER_SITES_DIR have a value

  # Strip trailing slash
  SITES_DIR=${BUTLER_SITES_DIR%/}
  # Replace ~
  SITES_DIR="${SITES_DIR/\~/$HOME}"

  # Ensure sites directory exists
  mkdir -p "$SITES_DIR"

  # Strip trailing slash
  PROJECTS_DIR=${BUTLER_PROJECTS_DIR%/}
  # Replace ~
  PROJECTS_DIR="${PROJECTS_DIR/\~/$HOME}"

  # Ensure projects directory exists
  mkdir -p "$PROJECTS_DIR"

  # TODO: Check that fzf is installed and if not issue a warning that experience is better with it
  # TODO: add site cd
}

init_site() {
  local site_dir="$1"
  [ -z "$site_dir" ] && return 0

  export CURRENT_SITE_DIR="$site_dir"

  # site.env: committed site defaults (BUTLER_PROJECTS, BUTLER_APP_CONTAINER, etc.)
  if [ -f "${site_dir}/site.env" ]; then
    set -a
    . "${site_dir}/site.env"
    set +a
  fi

  # .env: local overrides (passwords, domain overrides, TLD, etc.)
  if [ -f "${site_dir}/.env" ]; then
    set -a
    . "${site_dir}/.env"
    set +a
  fi

  # For multi-project sites, auto-export a var per project so docker-compose.yml
  # can reference them like single-project sites use $BUTLER_PROJECT.
  # e.g. BUTLER_PROJECTS=project-a,project-b
  #   -> BUTLER_PROJECT_PROJECT_A=project-a
  #   -> BUTLER_PROJECT_PROJECT_B=project-b
  # Override a domain by setting BUTLER_PROJECT_PROJECT_A=other-name in .env
  if [ -n "$BUTLER_PROJECTS" ]; then
    local p var
    for p in ${BUTLER_PROJECTS//,/ }; do
      var="BUTLER_PROJECT_$(echo "$p" | tr '[:lower:]-' '[:upper:]_')"
      [ -z "${!var}" ] && export "$var"="$p"
    done
  fi

  export CURRENT_PROJ_DIR="${PROJECTS_DIR}/${BUTLER_PROJECT}"
  [ -n "$BUTLER_PROJECT_DIR" ] && export CURRENT_PROJ_DIR="$BUTLER_PROJECT_DIR"
  return 0
}

resolve_container() {
  local candidate="${1:-}"

  # Single-project: ensure default is set
  # returns 1: candidate not used
  if [ -z "$BUTLER_PROJECTS" ]; then
    BUTLER_APP_CONTAINER="${BUTLER_APP_CONTAINER:-php}"
    return 1
  fi

  # Multi-project: try explicit candidate first
  # returns 0: candidate used
  if [ -n "$candidate" ]; then
    local p
    for p in ${BUTLER_PROJECTS//,/ }; do
      if [ "$p" = "$candidate" ]; then
        BUTLER_APP_CONTAINER="$candidate"
        return 0
      fi
    done
  fi

  # Multi-project: infer from CWD project name
  # returns 1: candidate not used
  if [ -n "$BUTLER_PROJECT" ]; then
    local p
    for p in ${BUTLER_PROJECTS//,/ }; do
      if [ "$p" = "$BUTLER_PROJECT" ]; then
        BUTLER_APP_CONTAINER="$BUTLER_PROJECT"
        return 1
      fi
    done
  fi

  # Multi-project: fzf picker or numbered prompt
  if command -v fzf >/dev/null 2>&1; then
    BUTLER_APP_CONTAINER=$(echo "${BUTLER_PROJECTS//,/$'\n'}" | fzf --prompt="Select project: ")
  else
    local i=1 p
    echo "Select project:"
    for p in ${BUTLER_PROJECTS//,/ }; do
      echo "  $i) $p"
      i=$((i + 1))
    done
    printf "Enter number: "
    read -r choice
    i=1
    for p in ${BUTLER_PROJECTS//,/ }; do
      [ "$i" = "$choice" ] && BUTLER_APP_CONTAINER="$p" && break
      i=$((i + 1))
    done
  fi

  [ -z "$BUTLER_APP_CONTAINER" ] && echo "No project selected." && return 2
  return 1
}

# Scan SITES_DIR for a site whose app symlink (single) or app/<name> symlink
# (multi) resolves to the current working directory. Prints "site_dir:proj_name"
# on success so the caller can extract both without a second scan.
# Multi-project sites are checked first so they win over stale single-project
# sites that share the same project directory.
find_site_by_cwd_symlink() {
  local cwd
  cwd="$(pwd -P)"
  local site_dir app_path link target single_match=""

  for site_dir in "$SITES_DIR"/*/; do
    site_dir="${site_dir%/}"
    app_path="$site_dir/app"

    if [ -d "$app_path" ] && [ ! -L "$app_path" ]; then
      # Multi-project: check each named symlink inside app/
      for link in "$app_path"/*/; do
        link="${link%/}"
        [ -L "$link" ] || continue
        target="$(readlink -f "$link" 2>/dev/null)"
        if [ "$target" = "$cwd" ]; then
          echo "$site_dir:$(basename "$link")"
          return 0
        fi
      done
    elif [ -L "$app_path" ]; then
      # Single-project: record as fallback, keep scanning for multi match
      target="$(readlink -f "$app_path" 2>/dev/null)"
      if [ "$target" = "$cwd" ] && [ -z "$single_match" ]; then
        single_match="$site_dir:$(basename "$site_dir")"
      fi
    fi
  done

  [ -n "$single_match" ] && echo "$single_match" && return 0
  return 1
}

resolve_site() {
  local candidate="${1:-}"
  local site_dir match

  # Try explicit site name arg first
  if [ -n "$candidate" ] && site_dir="$(get_site_dir "$candidate" 2>/dev/null)"; then
    BUTLER_PROJECT="$candidate"
    init_site "$site_dir"
    return 0
  fi

  # Scan symlinks to find which site owns the current working directory
  if match="$(find_site_by_cwd_symlink 2>/dev/null)"; then
    site_dir="${match%%:*}"
    BUTLER_PROJECT="${match##*:}"
    init_site "$site_dir"
    return 1
  fi

  # Fall back to name-based CWD resolution
  if site_dir="$(get_site_dir "$BUTLER_PROJECT" 2>/dev/null)"; then
    init_site "$site_dir"
  fi

  return 1
}
