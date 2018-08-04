ARG BASE_IMAGE_TAG

FROM anaxexp/base-ruby:${BASE_IMAGE_TAG}

ARG RUBY_DEV

ARG ANAXEXP_USER_ID=1000
ARG ANAXEXP_GROUP_ID=1000

ENV RUBY_DEV="${RUBY_DEV}" \
    SSHD_PERMIT_USER_ENV="yes" \
    \
    FREETYPE_VER="2.8.1-r3" \
    GMP_VER="6.1.2-r1" \
    ICU_LIBS_VER="59.1-r1" \
    IMAGEMAGICK_VER="7.0.7.11-r1" \
    LIBBZ2_VER="1.0.6-r6" \
    LIBJPEG_TURBO_VER="1.5.2-r0" \
    LIBLDAP_VER="2.4.45-r3" \
    LIBMEMCACHED_LIBS_VER="1.0.18-r2" \
    LIBPNG_VER="1.6.34-r1" \
    LIBXSLT_VER="1.1.31-r0" \
    MARIADB_CLIENT_VER="10.1.32-r0" \
    POSTGRESQL_CLIENT_VER="10.4-r0" \
    RABBITMQ_C_VER="0.8.0-r3" \
    YAML_VER="0.1.7-r0"

ENV APP_ROOT="/usr/src/app" \
    CONF_DIR="/usr/src/conf" \
    FILES_DIR="/mnt/files" \
    SSHD_HOST_KEYS_DIR="/etc/ssh" \
    ENV="/home/anaxexp/.shrc" \
    \
    GIT_USER_EMAIL="anaxexp@example.com" \
    GIT_USER_NAME="anaxexp"

RUN set -xe; \
    \
    addgroup -g 82 -S www-data; \
    adduser -u 82 -D -S -G www-data www-data; \
    \
    # Delete existing user/group if uid/gid occupied.
    existing_group=$(getent group "${ANAXEXP_GROUP_ID}" | cut -d: -f1); \
    if [[ -n "${existing_group}" ]]; then delgroup "${existing_group}"; fi; \
    existing_user=$(getent passwd "${ANAXEXP_USER_ID}" | cut -d: -f1); \
    if [[ -n "${existing_user}" ]]; then deluser "${existing_user}"; fi; \
    \
	addgroup -g "${ANAXEXP_GROUP_ID}" -S anaxexp; \
	adduser -u "${ANAXEXP_USER_ID}" -D -S -s /bin/bash -G anaxexp anaxexp; \
	adduser anaxexp www-data; \
	sed -i '/^anaxexp/s/!/*/' /etc/shadow; \
    \
    apk add --update --no-cache -t .ruby-rundeps \
        "freetype=${FREETYPE_VER}" \
        git \
        "gmp=${GMP_VER}" \
        "icu-libs=${ICU_LIBS_VER}" \
        "imagemagick=${IMAGEMAGICK_VER}" \
        less \
        "libbz2=${LIBBZ2_VER}" \
        "libjpeg-turbo=${LIBJPEG_TURBO_VER}" \
        "libjpeg-turbo-utils=${LIBJPEG_TURBO_VER}" \
        "libldap=${LIBLDAP_VER}" \
        "libmemcached-libs=${LIBMEMCACHED_LIBS_VER}" \
        "libpng=${LIBPNG_VER}" \
        "libxslt=${LIBXSLT_VER}" \
        make \
        "mariadb-client=${MARIADB_CLIENT_VER}" \
        nano \
        openssh \
        openssh-client \
        "postgresql-client=${POSTGRESQL_CLIENT_VER}" \
        "rabbitmq-c=${RABBITMQ_C_VER}" \
        patch \
        rsync \
        su-exec \
        sudo \
        tig \
        tmux \
        "yaml=${YAML_VER}"; \
    \
    # Install redis-cli.
    apk add --update --no-cache redis; \
    mkdir -p /tmp/pkgs-bins; \
    mv /usr/bin/redis-cli /tmp/; \
    apk del --purge redis; \
    deluser redis; \
    mv /tmp/redis-cli /usr/bin; \
    \
    { \
        echo 'export PS1="\u@${ANAXEXP_APP_NAME:-ruby}.${ANAXEXP_ENVIRONMENT_NAME:-container}:\w $ "'; \
        # Make sure PATH is the same for ssh sessions.
        echo "export PATH=${PATH}"; \
    } | tee /home/anaxexp/.shrc; \
    \
    # Make sure bash uses the same settings as ash.
    cp /home/anaxexp/.shrc /home/anaxexp/.bashrc; \
    \
    # Configure sudoers
    { \
        echo 'Defaults env_keep += "APP_ROOT FILES_DIR"' ; \
        \
        if [[ -n "${RUBY_DEV}" ]]; then \
            echo 'anaxexp ALL=(root) NOPASSWD:SETENV:ALL'; \
        else \
            echo -n 'anaxexp ALL=(root) NOPASSWD:SETENV: ' ; \
            echo -n '/usr/local/bin/files_chmod, ' ; \
            echo -n '/usr/local/bin/files_chown, ' ; \
            echo -n '/usr/local/bin/files_sync, ' ; \
            echo -n '/usr/local/bin/gen_ssh_keys, ' ; \
            echo -n '/usr/local/bin/init_volumes, ' ; \
            echo -n '/etc/init.d/unicorn, ' ; \
            echo -n '/usr/sbin/sshd, ' ; \
            echo '/usr/sbin/crond' ; \
        fi; \
    } | tee /etc/sudoers.d/anaxexp; \
    \
    # Configure ldap
    echo "TLS_CACERTDIR /etc/ssl/certs/" >> /etc/openldap/ldap.conf; \
    \
    # Create required directories and fix permissions
    install -o anaxexp -g anaxexp -d \
        "${APP_ROOT}" \
        "${CONF_DIR}" \
        /usr/local/etc/unicorn/ \
        /home/anaxexp/.pip \
        /home/anaxexp/.ssh; \
    \
    install -o www-data -g www-data -d \
        /home/www-data/.ssh \
        "${FILES_DIR}/public" \
        "${FILES_DIR}/private"; \
    \
    chmod -R 775 "${FILES_DIR}"; \
    su-exec anaxexp touch /usr/local/etc/unicorn/config.rb; \
    \
    # SSHD
    touch /etc/ssh/sshd_config; \
    chown anaxexp: /etc/ssh/sshd_config; \
    \
    # Crontab
    rm /etc/crontabs/root; \
    touch /etc/crontabs/www-data; \
    chown root:www-data /etc/crontabs/www-data; \
    chmod 660 /etc/crontabs/www-data; \
    \
    # Cleanup
    rm -rf \
        /tmp/* \
        /var/cache/apk/*

USER anaxexp

WORKDIR ${APP_ROOT}
EXPOSE 8000

COPY --chown=anaxexp:anaxexp unicorn.init.d /etc/init.d/unicorn
COPY templates /etc/gotpl/
COPY docker-entrypoint.sh /
COPY bin /usr/local/bin/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/etc/init.d/unicorn"]
