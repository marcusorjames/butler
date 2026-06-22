FROM php:8.0-fpm

RUN useradd -m user
RUN ln -s /run/secrets/user_ssh /home/user/.ssh

RUN docker-php-ext-install pdo pdo_mysql
RUN pecl install xdebug && docker-php-ext-enable xdebug

USER user
