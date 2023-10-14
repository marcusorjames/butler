setup()
{
  if [ -f "$DIR/.env" ]; then
    export $(cat "$DIR/.env" | xargs)
  else
    echo "No .env file found" && exit 0;
  fi

  # TODO: Dry the directroy env santisation up
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

  CURRENT_SITE_DIR="${SITES_DIR}/${CURRENT_PROJ}"
  CURRENT_PROJ_DIR="${PROJECTS_DIR}/${CURRENT_PROJ}"

  # Ensure sites directory exists
  mkdir -p $PROJECTS_DIR
# TODO: Check the env file is working as this is just defined in site add...
# TODO: Check that fzf is installed and if not issue a warning that experince is better with it
# TODO: add site cd
}
