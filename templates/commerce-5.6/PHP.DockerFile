FROM php:5.6-apache

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN printf '[PHP]\ndate.timezone = "Europe/London"\n' \
    > /usr/local/etc/php/conf.d/tzone.ini

# Update stretch repositories
RUN sed -i -e 's/deb.debian.org/archive.debian.org/g' \
           -e 's|security.debian.org|archive.debian.org/|g' \
           -e '/stretch-updates/d' /etc/apt/sources.list
RUN apt-get -y update \
    && apt-get install -y libicu-dev libpng-dev git libzip-dev
RUN docker-php-ext-install pdo pdo_mysql gd intl zip
RUN git clone -b XDEBUG_2_5_5 https://github.com/xdebug/xdebug.git /root/xdebug \
    && cd /root/xdebug && ./rebuild.sh
RUN a2enmod rewrite
