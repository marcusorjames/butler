# Butler TODO

- Improve composer command to check if composer.phar exists, if so use that, otherwise check composer if not
  return 1 "composer.phar or composer does not exist on container"
- Add config for keyfile
- Check if there is an option on docker compose to not create directories for mounts if they don't exist
    and instead fail out
- REWRITE: Sail literally everything is a docker-compose command. Because I want
to be able to call without the site name from the project directory this should be the default
therefore `butler up jamgolf` no longer is possible we should instead by default
assume we are in the project directory otherwise this can be overriden by --site
THEN we can assume all other arguments are being sent to docker compose
- Add site config, for example for domain
- Add command to auto link all sites
- use that thing that automatically creates hostfile entries
- add ability to use in project docker compose as well - fall back to docker-composer commands like the laravel one?
- Look at laravels one as it might help tidy up the code
- Add --site to docker-compose exec passthrough
- Remove extra scripts checks from docker-compose passthrough which is only relavent to "up"
- Add custom commands to Sites/ e.g. "butler artisan" which can be aliased to butler run php /app/artisan
- Add laravel, currently have a laravel script to run the build url
- source env file in makefile
    It worked for me because I have run butler, butler exports the env vars
    We should probably prefix the env vars when we export them so that they don't clash
    We can then move that exporting to a new common bin and execute that before running the make file
    We can exit with an error if the env file does not exist, or run a setup
- need a domain config as if the site and project dir are different it doesn't work
- auto create networks
- I wonder if there could be some kinda watcher on domains so if you
  browse to example.local and a site exists for that domain it boots it
- When running exec on a container ensure container is up first
- Tidy up site fix etc. as they use common functions, pull these out
