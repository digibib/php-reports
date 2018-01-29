FROM php:5-fpm

ENV MYSQL_USER     admin
ENV MYSQL_PASSWORD secret
ENV MYSQL_HOST     localhost
ENV MYSQL_DATABASE php-reports

RUN apt-get update && apt-get install -y nginx libbz2-dev libmcrypt-dev zlib1g-dev git unzip wget \
    libpng-dev libxslt-dev && \
    docker-php-ext-install bcmath mcrypt zip bz2 mbstring pcntl xsl && \
    apt-get clean

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

WORKDIR /usr/share/nginx/html
COPY composer.json composer.json
RUN composer update && composer install

ADD . /usr/share/nginx/html
COPY docker.config.php /usr/share/nginx/html/config/config.php

# Writable cache dir
RUN mkdir -p cache && chmod 0777 cache

# php requires timezone
RUN printf '[PHP]\ndate.timezone = "Europe/Oslo"\n' > /usr/local/etc/php/conf.d/tzone.ini

COPY docker.vhost.conf /etc/nginx/sites-enabled/default

VOLUME ["/usr/share/nginx/html/sample_reports", "/usr/share/nginx/html/sample_dashboards"]
CMD php-fpm & nginx -g "daemon off;"
