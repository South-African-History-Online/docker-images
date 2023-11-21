#!/bin/sh

set -e

# Create the www.conf
envsubst "$(env | sed -e 's/=.*//' -e 's/^/$/g')" < /etc/nginx/conf.d/www.conf.tmpl > /etc/nginx/conf.d/www.conf

/usr/sbin/nginx -c /etc/nginx/nginx.conf
