FROM php:7.4-apache

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN apt-get -y update \
&& apt-get install -y libicu-dev libpng-dev git
RUN docker-php-ext-configure intl
RUN docker-php-ext-install pdo pdo_mysql gd intl
RUN pecl install xdebug-3.1.5 && docker-php-ext-enable xdebug
RUN a2enmod rewrite headers
