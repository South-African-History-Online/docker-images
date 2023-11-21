ARG COMPOSER_VERSION="2.5"
FROM composer:${COMPOSER_VERSION} AS composer
FROM bitnami/minideb:latest

# Run as root
USER root

# Copy in the composer package
COPY --from=composer /usr/bin/composer /usr/bin/composer

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
        default-mysql-client \
    && \
    curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg && \
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
    apt update && \
    install_packages \
        php${PHP_VERSION} \
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
    && \
    # Install drush
    wget https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar && \
    mv drush.phar /usr/local/bin/drush && \
    chmod +x /usr/local/bin/drush && \
    # Shrink binaries
    (find /usr/local/bin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) && \
    (find /usr/local/lib -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) && \
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
