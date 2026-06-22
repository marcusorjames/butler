FROM php:7.4-apache

RUN useradd -m user
RUN ln -s /run/secrets/user_ssh /home/user/.ssh

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

RUN docker-php-ext-install pdo pdo_mysql
RUN pecl install xdebug-3.1.5 && docker-php-ext-enable xdebug
RUN a2enmod rewrite

USER user
