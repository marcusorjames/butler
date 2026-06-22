FROM php:8.3-fpm-alpine

RUN adduser -D user
RUN ln -s /run/secrets/user_ssh /home/user/.ssh

RUN apk add --update linux-headers
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del -f .build-deps

USER user
