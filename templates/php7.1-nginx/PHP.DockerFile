FROM php:7.1-fpm

RUN useradd -m user
RUN ln -s /run/secrets/user_ssh /home/user/.ssh

RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
           -e 's|security.debian.org|archive.debian.org/|g' \
           -e '/stretch-updates/d' /etc/apt/sources.list
RUN apt-get update -y && apt-get install -y libpng-dev libicu-dev libxml2-dev

RUN docker-php-ext-install gd intl json mbstring \
    pdo_mysql opcache xml zip
RUN pecl install xdebug-2.5.1 && docker-php-ext-enable xdebug

USER user
