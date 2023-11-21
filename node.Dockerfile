FROM bitnami/minideb:latest

# Run as root
USER root

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
    # Install nodejs 16 from nodesource
    curl -sSLo /tmp/nodesource_setup.sh https://deb.nodesource.com/setup_16.x && \
    bash /tmp/nodesource_setup.sh && \
    apt update && \
    install_packages \
        nodejs \
        npm \
    && \
    # Shrink binaries
    (find /usr/local/bin -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) && \
    (find /usr/local/lib -type f -print0 | xargs -n1 -0 strip --strip-all -p 2>/dev/null || true) && \
    # Cleanup
    rm -rf /tmp/* /src

# Set workdir
WORKDIR /app
