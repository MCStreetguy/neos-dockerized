# INSTALLER STAGE
FROM mcstreetguy/php-builder:7.3 as installer

# Install 'imagick' php extension
RUN apk add --no-cache imagemagick-dev && \
    pecl-install-extension imagick

# MAIN STAGE
FROM mcstreetguy/carrier:alpine-3.11
LABEL maintainer="security@mcstreetguy.de"

# Requirements & preparation
RUN apk add --no-cache \
      acl \
      apache2 \
      apache2-ctl \
      apache2-http2 \
      curl \
      grep \
      imagemagick \
      php7 \
      php7-apache2 \
      php7-bz2 \
      php7-curl \
      php7-dom \
      php7-fileinfo \
      php7-json \
      php7-mbstring \
      php7-opcache \
      php7-openssl \
      php7-pdo_mysql \
      php7-posix \
      php7-phar \
      php7-session \
      php7-tidy \
      php7-tokenizer \
      php7-xml \
      php7-xmlreader \
      php7-xmlwriter \
      php7-zip \
      unzip \
    && \
    rm -rf /var/cache/apk/* && \
    sed -i 's+#LoadModule rewrite_module modules/mod_rewrite.so+LoadModule rewrite_module modules/mod_rewrite.so+g' /etc/apache2/httpd.conf && \
    sed -i 's+#LoadModule remoteip_module modules/mod_remoteip.so+LoadModule remoteip_module modules/mod_remoteip.so+g' /etc/apache2/httpd.conf && \
    sed -i 's+#LoadModule session_module modules/mod_session.so+LoadModule session_module modules/mod_session.so+g' /etc/apache2/httpd.conf && \
    sed -i 's+#LoadModule session_cookie_module modules/mod_session_cookie.so+LoadModule session_cookie_module modules/mod_session_cookie.so+g' /etc/apache2/httpd.conf && \
    sed -i 's+#LoadModule session_crypto_module modules/mod_session_crypto.so+LoadModule session_crypto_module modules/mod_session_crypto.so+g' /etc/apache2/httpd.conf && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    echo "127.0.0.1 ${PUBLIC_DOMAIN}" >> /etc/hosts

# Add required files
COPY --from=installer /usr/lib/php7/modules/* /usr/lib/php7/modules/
COPY --from=installer /usr/include/php7/ext/ /usr/include/php7/ext/
COPY ./app/config/ /etc/

# Add dynamic files
COPY ./app/dynamic/Settings.yaml /var/www/neos/Configuration/

# Ports & Volumes
EXPOSE 80
VOLUME [ "/var/www/neos/Data" ]

# Setup required variable names to keep for environment isolation
ENV KEEP_ENV "PUBLIC_DOMAIN PUBLIC_PORT FLOW_CONTEXT"

# Appends Neos Version env var
ARG NEOS_VERSION="^4.3"
ENV NEOS_VERSION "${NEOS_VERSION}"

# Build arguments for database connection
ONBUILD ARG DB_HOST
ONBUILD ARG DB_NAME=db_neos
ONBUILD ARG DB_PASS
ONBUILD ARG DB_PORT=3306
ONBUILD ARG DB_USER=usr_neos

# Validate that all build arguments are set
ONBUILD RUN test -n "${DB_HOST}"
ONBUILD RUN test -n "${DB_NAME}"
ONBUILD RUN test -n "${DB_PASS}"
ONBUILD RUN test -n "${DB_PORT}"
ONBUILD RUN test -n "${DB_USER}"

# Pass the build arguments to the environment
ONBUILD ENV DB_HOST "${DB_HOST}"
ONBUILD ENV DB_NAME "${DB_NAME}"
ONBUILD ENV DB_PASS "${DB_PASS}"
ONBUILD ENV DB_USER "${DB_USER}"
ONBUILD ENV DB_PORT "${DB_PORT}"

# Apply dynamic values to Neos configuration
ONBUILD RUN sed -i "s/%DB_HOST/${DB_HOST}/" /var/www/neos/Configuration/Settings.yaml && \
            sed -i "s/%DB_NAME/${DB_NAME}/" /var/www/neos/Configuration/Settings.yaml && \
            sed -i "s/%DB_PASSWORD/${DB_PASS}/" /var/www/neos/Configuration/Settings.yaml && \
            sed -i "s/%DB_USER/${DB_USER}/" /var/www/neos/Configuration/Settings.yaml && \
            sed -i "s/%DB_PORT/${DB_PORT}/" /var/www/neos/Configuration/Settings.yaml