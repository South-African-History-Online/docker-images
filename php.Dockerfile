FROM bitnami/minideb:latest

# Run as root
USER root

# Install PHP
ARG PHP_VERSION="8.2"
RUN \
    apt update && \
    apt upgrade -y && \
    install_packages \
        software-properties-common \
        gettext-base \
        patch \
        wget \
        curl \
        procps \
        default-mysql-client \
    && \
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg && \
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    apt update && \
    install_packages \
        php${PHP_VERSION} \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-readline \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-igbinary \
        php${PHP_VERSION}-apcu \
        php${PHP_VERSION}-imagick \
        php${PHP_VERSION}-yaml \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-mysqlnd \
        php${PHP_VERSION}-mysqli \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-bz2 \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-msgpack \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-redis \
        php${PHP_VERSION}-igbinary \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-opcache \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-exif \
        php${PHP_VERSION}-xsl \
        php${PHP_VERSION}-gettext \
        php${PHP_VERSION}-cgi \
        php${PHP_VERSION}-dom \
        php${PHP_VERSION}-ftp \
        php${PHP_VERSION}-iconv \
        php${PHP_VERSION}-pdo \
        php${PHP_VERSION}-simplexml \
        php${PHP_VERSION}-tokenizer \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-xmlwriter \
        php${PHP_VERSION}-xmlreader \
        php${PHP_VERSION}-fileinfo \
        php${PHP_VERSION}-uploadprogress \
    && \
    # Symlink the php-fpm${PHP_VERSION} binary to php-fpm
    if [ ! -f /usr/sbin/php-fpm ]; then ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/sbin/php-fpm; fi && \
    # Cleanup
    rm -rf /tmp/* /src && \
    # Add config for APCu
    echo "apc.enabled=1" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.enable_cli=1" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.serializer=igbinary" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.shm_size=128M" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.shm_segments=1" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.ttl=0" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.num_files_hint=10000" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.file_update_protection=2" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.max_file_size=2M" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.stat_ctime=1" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    echo "apc.mmap_file_mask=/tmp/apc.XXXXXX" >> /etc/php/${PHP_VERSION}/mods-available/apcu.ini && \
    # Use igbinary
    echo "session.serialize_handler=igbinary" >> /etc/php/${PHP_VERSION}/mods-available/redis.ini && \
    # Raise realpath cache size
    echo "realpath_cache_size=256k" >> /etc/php/${PHP_VERSION}/mods-available/opcache.ini && \
    echo "realpath_cache_ttl=3600" >> /etc/php/${PHP_VERSION}/mods-available/opcache.ini && \
    # JIT
    sed -i "s/opcache.jit=off/opcache.jit=1255/g" /etc/php/${PHP_VERSION}/mods-available/opcache.ini && \
    echo "opcache.jit_buffer_size=100M" >> /etc/php/${PHP_VERSION}/mods-available/opcache.ini

# Set workdir
WORKDIR /app

# Copy in production configs
ARG PHP_VERSION="8.2"
COPY php-fpm/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY php-fpm/php-fpm.conf.tmpl /etc/php/${PHP_VERSION}/fpm/php-fpm.conf.tmpl
COPY php-fpm/php.ini.tmpl /etc/php/${PHP_VERSION}/fpm/php.ini.tmpl

# Copy in entrypoint
COPY php-fpm/php-fpm.sh /entrypoint-fpm.sh
COPY php-fpm/entrypoint.sh /entrypoint.sh

# Make entrypoints executable and fix the PHP version number
ARG PHP_VERSION="8.2"
RUN chmod +x /entrypoint-fpm.sh /entrypoint.sh && \
    # Replace PHPVERSION with the variable ${PHP_VERSION}
    sed -i "s/PHPVERSION/${PHP_VERSION}/g" /entrypoint-fpm.sh /etc/php/${PHP_VERSION}/fpm/php-fpm.conf

WORKDIR /app
EXPOSE 9000
ENTRYPOINT [ "/entrypoint.sh" ]
ARG PHP_VERSION="8.2"
ENV PHP_VERSION=${PHP_VERSION}
ARG PHP_MEMORY_LIMIT="768M"
ENV PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT}
CMD [ "/entrypoint-fpm.sh" ]
