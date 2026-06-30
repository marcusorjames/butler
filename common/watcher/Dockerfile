FROM python:3-alpine
RUN apk add --no-cache docker-cli docker-cli-compose
WORKDIR /app
COPY watcher.py style.css ./
CMD ["python3", "watcher.py"]
