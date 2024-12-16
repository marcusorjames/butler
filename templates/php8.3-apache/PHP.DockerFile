FROM php:8.3-apache

RUN useradd -m user
RUN ln -s /run/secrets/user_ssh /home/user/.ssh
RUN chown -R user:user /home/user/.ssh

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN apt-get update && apt-get install -y libicu-dev git libzip-dev

RUN docker-php-ext-install pdo pdo_mysql zip
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN a2enmod rewrite

USER user
