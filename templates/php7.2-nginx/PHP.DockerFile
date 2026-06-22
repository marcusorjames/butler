FROM php:7.2-fpm

RUN useradd -m user
RUN ln -s /run/secrets/user_ssh /home/user/.ssh

RUN docker-php-ext-install pdo pdo_mysql
RUN pecl install xdebug-3.1.5 && docker-php-ext-enable xdebug

USER user
