# Butler TODO

- Write scripts to automatically add sites
- use that thing that automatically creates hostfile entries
- add ability to use in project docker compose as well
- Add --site to docker-compose exec passthrough
- Remove extra scripts checks from docker-compose passthrough which is only relavent to "up"
- Add custom commands to Sites/ e.g. "butler artisan" which can be aliased to butler run php /app/artisan
- Add ngrok command
  Currently this works
  ngrok:
    image: ngrok/ngrok:alpine
    command: 'http sycal-oms:80'
    environment:
      NGROK_AUTHTOKEN: rUgBCryjNXCBmHc7eWmQ_MRbt5hFM6pxmPx4A6bU8
    ports:
        - '4040:4040'
    expose:
        - '4040'
    where sycal-oms is the web container name (ngninx), but really would be better just in a docker run command
