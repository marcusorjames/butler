init()
{
  if [ -f "$DIR/.env" ]; then
    export $(cat "$DIR/.env" | tr -d '\r' | xargs)
  else
    echo "No .env file found" && exit 0;
  fi

  # TODO: Dry the directory env sanitisation up
  # TODO: .env validation e.g. does BUTLER_SITES_DIR have a value

  # Strip trailing slash
  SITES_DIR=${BUTLER_SITES_DIR%/}
  # Replace ~
  SITES_DIR="${SITES_DIR/\~/$HOME}"

  # Ensure sites directory exists
  mkdir -p $SITES_DIR

  # Strip trailing slash
  PROJECTS_DIR=${BUTLER_PROJECTS_DIR%/}
  # Replace ~
  PROJECTS_DIR="${PROJECTS_DIR/\~/$HOME}"

  # Ensure projects directory exists
  mkdir -p $PROJECTS_DIR

# TODO: Check that fzf is installed and if not issue a warning that experience is better with it
# TODO: add site cd
}

init_site()
{
  local site_dir="$1"
  [ -z "$site_dir" ] && return 0

  CURRENT_SITE_DIR="$site_dir"
  CURRENT_PROJ_DIR="${PROJECTS_DIR}/${BUTLER_PROJECT}"

  # Per-project env overrides, e.g. BUTLER_PROJECT, BUTLER_PROJECT_DIR
  if [ -f "${site_dir}/.env" ]; then
    export $(cat "${site_dir}/.env" | tr -d '\r' | xargs)
  fi

  [ -n "$BUTLER_PROJECT_DIR" ] && CURRENT_PROJ_DIR="$BUTLER_PROJECT_DIR"
}
