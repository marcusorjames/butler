FROM php:7.1-fpm

RUN apt-get update -y && apt-get install -y libpng-dev libicu-dev libxml2-dev

RUN docker-php-ext-install gd intl json mbstring \
    pdo_mysql opcache xml zip
RUN pecl install xdebug-2.5.1 && docker-php-ext-enable xdebug
