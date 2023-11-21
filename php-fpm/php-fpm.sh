#!/bin/sh

set -e

# Create /run/php directory if it doesn't exist
if [ ! -d /run/php ]; then
    mkdir -p /run/php
fi

# Set ENV vars for php-fpm.conf
envsubst "$(env | sed -e 's/=.*//' -e 's/^/$/g')" < /etc/php/PHPVERSION/fpm/php-fpm.conf.tmpl > /etc/php/PHPVERSION/fpm/php-fpm.conf
# Set ENV vars for php.ini
envsubst "$(env | sed -e 's/=.*//' -e 's/^/$/g')" < /etc/php/PHPVERSION/fpm/php.ini.tmpl > /etc/php/PHPVERSION/fpm/php.ini

# Start fpm
/usr/sbin/php-fpm -R -F -y /etc/php/PHPVERSION/fpm/php-fpm.conf -c /etc/php/PHPVERSION/fpm/php.ini
