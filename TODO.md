# Butler TODO

- Add command to auto link all sites
- add ability to use in project docker compose as well - fall back to docker-composer commands like the laravel one?
- Look at laravels one as it might help tidy up the code
- Remove extra scripts checks from docker-compose passthrough which is only relavent to "up"
- Add custom commands to Sites/ e.g. "butler artisan" which can be aliased to butler run php /app/artisan
- Add laravel, currently have a laravel script to run the build url
- source env file in makefile
    It worked for me because I have run butler, butler exports the env vars
    We should probably prefix the env vars when we export them so that they don't clash
    We can then move that exporting to a new common bin and execute that before running the make file
    We can exit with an error if the env file does not exist, or run a setup
- auto create networks
- I wonder if there could be some kinda watcher on domains so if you
  browse to example.local and a site exists for that domain it boots it
- When running exec on a container ensure container is up first
- Tidy up site fix etc. as they use common functions, pull these out
