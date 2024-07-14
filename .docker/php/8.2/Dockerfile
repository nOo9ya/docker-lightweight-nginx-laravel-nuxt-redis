FROM php:8.2-fpm-alpine

ARG APP_ENV
ARG WORK_DIR
ARG UID
ARG GID
ARG USER
ARG TZ

ENV APP_ENV=${APP_ENV}
ENV WORK_DIR=${WORK_DIR}
ENV UID=${UID}
ENV GID=${GID}
ENV USER=${USER}
ENV TZ=${TZ}

ENV PHP_VERSION=8.2
ENV FILE_UPLOADS=On
ENV MEMORY_LIMIT=512M
ENV UPLOAD_MAX_FILESIZE=128M
ENV POST_MAX_SIZE=128M
ENV MAX_EXECUTION_TIME=600
ENV COMPOSER_MEMORY_LIMIT='-1'

WORKDIR ${WORK_DIR}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 알파인 리눅스의 다이얼아웃 그룹은 맥OS 그룹의 gid와 충돌하여 그룹삭제
RUN delgroup dialout

# 환경에 맞춘 그룹과 사용자 생성
RUN usermod -u 1000 ${USER}
RUN addgroup -g ${GID} --system ${USER}
RUN adduser -G ${USER} --system -D -s /bin/sh -u ${UID} ${USER}

# php-fpm 사용자 변경
#RUN sed -i "s/user = www-data/user = '${USER}'/g" /usr/local/etc/php-fpm.d/www.conf
#RUN sed -i "s/group = www-data/group = '${USER}'/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i "s/memory_limit = 128M/memory_limit = ${MEMORY_LIMIT}/g" /usr/local/etc/php/php.ini

RUN apk update && apk upgrade
RUN apk add --update --no-cache \
    $PHPIZE_DEPS \
    wget  \
    bash  \
    curl \
    build-base \
    bind-tools \
    pcre-dev \
    zip  \
    libzip-dev  \
    unzip \
    zlib-dev \
    libmcrypt-dev \
    libgsasl-dev \
    libxml2-dev \
    openssl-dev \
    icu-dev \
    gmp-dev

#####################################
# PHP Extension install
#####################################
RUN docker-php-ext-configure zip
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure gmp
#RUN docker-php-ext-install mysqli
RUN docker-php-ext-install zip pdo pdo_mysql bcmath soap intl gmp
RUN docker-php-ext-install exif xml
# -------------------------- pcntl start --------------------------
# pcntl(프로세스 제어) : php는 자동으로 쓰레드를 할당하므로 웹에서는 특별한 작업외에는 쓸일이 그렇게 없다.
# RUN docker-php-ext-install pcntl

# redis extension 설치
#RUN mkdir -p /usr/src/php/ext/redis \
#    && curl -fsSL https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
#    && echo 'redis' >> /usr/src/php-available-exts \
#    && docker-php-ext-install redis

RUN pecl install -o -f redis
RUN docker-php-ext-enable redis

# GD install
RUN apk add --update --no-cache \
    libjpeg-turbo-dev \
    libpng-dev \
    freetype-dev \
    libwebp-dev \
    libxpm-dev
RUN docker-php-ext-configure gd --enable-gd --with-webp --with-jpeg --with-xpm --with-freetype
RUN docker-php-ext-install -j$(nproc) gd

# Imagemagick install
RUN apk add --update --no-cache \
    imagemagick \
    imagemagick-libs \
    imagemagick-dev
RUN pecl install -o -f imagick
RUN docker-php-ext-enable imagick

# Memcached install
#RUN apk add --update --no-cache \
#    libmemcached-dev
#RUN pecl install -o -f memcached
#RUN docker-php-ext-enable memcached

# Postgresql install
#RUN apk add --update --no-cache \
#    postgresql \
#    postgresql-client \
#    libpq-dev
#RUN docker-php-ext-configure pgsql
#RUN docker-php-ext-install pdo_pgsql pgsql

# Debug install
# Add sqlite
RUN apk add --no-cache sqlite-libs
RUN apk add --no-cache icu sqlite
RUN apk add --no-cache --virtual .build-deps sqlite-dev curl-dev
RUN docker-php-ext-install \
        ctype \
        pdo_sqlite
RUN docker-php-ext-enable pdo_sqlite

# Add xdebug
RUN apk add --no-cache linux-headers \
	&& apk add --update --no-cache --virtual .build-dependencies $PHPIZE_DEPS\
	&& pecl install xdebug \
	&& docker-php-ext-enable xdebug \
	&& pecl clear-cache \
	&& apk del .build-dependencies

COPY ./.docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini


# App permission check
RUN mkdir -p ${WORK_DIR}/storage/logs \
    ${WORK_DIR}/storage/framework \
    ${WORK_DIR}/bootstrap/cache

RUN chown -R ${USER}:${USER} ${WORK_DIR}/storage/framework/cache/data
RUN chown -R ${USER}:${USER} ${WORK_DIR}/storage/logs
RUN chown -R ${USER}:${USER} ${WORK_DIR}/bootstrap/cache

RUN chmod 755 -R ${WORK_DIR}/storage/*
RUN chmod 755 -R ${WORK_DIR}/bootstrap/cache

#####################################
# Composer Install
#####################################
RUN curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

#####################################
# Laravel Schedule Cron Job:
#####################################
RUN echo "* * * * * ${USER} /usr/local/bin/php ${WORK_DIR}/artisan schedule:run
 >>
/dev/null 2>&1"  >> /var/spool/cron/crontabs/laravel-scheduler
RUN chmod 0644 /var/spool/cron/crontabs/laravel-scheduler

#####################################
# initailization Start
#####################################
# Install Cron
RUN apk add --update --no-cache dcron supervisor logrotate;
RUN touch /var/log/cron.log &&\
    mkdir /var/log/supervisor &&\
    touch /var/log/supervisor/supervisord.log

RUN rm -rf /var/cache/apk/* && rm -rf /tmp/pear
RUN apk del --purge autoconf g++ make

COPY ./.docker/php/logrotate/supervisor_log.conf /etc/logrotate.d/supervisor
COPY ./.docker/php/logrotate/laravel-worker_log.conf /etc/logrotate.d/laravel-worker
COPY ./.docker/php/$PHP_VERSION/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /etc/supervisor/conf.d/supervisord.conf

COPY ./.docker/php/$PHP_VERSION/start-service.sh /usr/local/bin/start-service.sh
RUN chmod +x /usr/local/bin/start-service.sh

RUN rm -rf /var/cache/apk/* && rm -rf /tmp/pear
RUN apk del --purge autoconf g++ make


ENTRYPOINT ["start-service.sh"]

EXPOSE 9000
CMD ["php-fpm"]