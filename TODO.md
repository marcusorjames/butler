# Butler TODO

- add ability to use in project docker compose as well - fall back to docker-composer commands like the laravel one?
- Look at laravels one as it might help tidy up the code
- Remove extra scripts checks from docker-compose passthrough which is only relavent to "up"
- Add custom commands to Sites/ e.g. "butler artisan" which can be aliased to butler run php /app/artisan
- Add laravel, currently have a laravel script to run the build url
- Move from mailhog to mailtrap
- I wonder if there could be some kinda watcher on domains so if you
  browse to example.local and a site exists for that domain it boots it
