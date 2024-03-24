FROM bitnami/minideb:latest

# Run as root
USER root

# Install base packages
RUN \
    apt update && \
    apt upgrade -y && \
    install_packages \
        software-properties-common \
        gettext-base \
        patch \
        wget \
        curl \
    && \
    curl -sSLo /usr/share/keyrings/deb.sury.org-nginx.gpg https://packages.sury.org/nginx/apt.gpg && \
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-nginx.gpg] https://packages.sury.org/nginx/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/nginx.list' && \
    apt update && \
    install_packages \
        nginx \
    && \
    mkdir -p /var/cache/nginx

# Set workdir
WORKDIR /app

# Copy in production configs
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy in the Drupal config
COPY nginx/drupal.conf.tmpl /etc/nginx/conf.d/www.conf.tmpl

# Copy in entrypoint
COPY nginx/entrypoint.sh /entrypoint.sh
COPY nginx/nginx.sh /entrypoint-nginx.sh

# Make entrypoints executable
RUN chmod +x /entrypoint.sh /entrypoint-nginx.sh

WORKDIR /app
EXPOSE 80
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/entrypoint-nginx.sh" ]
