#Define build-specific parameters. Base and dependencies versions, installation paths, etc
ARG PHP_BASE_VERSION=8.2
ARG ORA_INSTANT_CLIENT_VERSION=linux.x64-21.9.0.0.0dbru
ARG OCI8_PECL_VERSION=3.3.1
ARG ORACLE_HOME=/opt/oracle/instantclient

FROM thecodingmachine/php:${PHP_BASE_VERSION}-v4-cli-node16
ARG PHP_BASE_VERSION
ARG ORA_INSTANT_CLIENT_VERSION
ARG OCI8_PECL_VERSION
ARG ORACLE_HOME

#Switch to privileged user
USER root

#Install Oracle (OCI) extension dependencies. Those are should be installed before php-oci8 extension being built
RUN mkdir -p ${ORACLE_HOME} && \
    cd ${ORACLE_HOME} && \
    curl -O https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-basic-${ORA_INSTANT_CLIENT_VERSION}.zip && \
    curl -O https://download.oracle.com/otn_software/linux/instantclient/219000/instantclient-sdk-${ORA_INSTANT_CLIENT_VERSION}.zip && \
    unzip -j instantclient-basic-${ORA_INSTANT_CLIENT_VERSION}.zip && \
    unzip -j instantclient-sdk-${ORA_INSTANT_CLIENT_VERSION}.zip && \
    echo ${ORACLE_HOME} > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    rm -f instantclient-basic-*.zip instantclient-sdk-*.zip

ENV ORACLE_HOME=${ORACLE_HOME}

#Build and install all necessary additional PHP extensions and binaries including oci8, swoole, supervisor
RUN DEBIAN_FRONTEND=noninteractive && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    apt-get update && \
    apt-get install -y php${PHP_BASE_VERSION}-dev php${PHP_BASE_VERSION}-mysqlnd libaio1 && \
    ldconfig && \
    echo "instantclient,${ORACLE_HOME}" | pecl install oci8-${OCI8_PECL_VERSION} && \
    echo "extension=oci8.so" > /etc/php/${PHP_BASE_VERSION}/cli/conf.d/30-oci8.ini && \
    pecl install openswoole && \
    echo "extension=openswoole.so" > /etc/php/${PHP_BASE_VERSION}/cli/conf.d/30-swoole.ini && \
    apt-get install --no-install-recommends -y openssh-server && \
    apt-get purge -y php-pear build-essential php${PHP_BASE_VERSION}-dev pkg-config && \
    apt-get autoremove -y && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Setup SSH access within App Service environment as described in official documentation.
#For more information see link below:
#https://learn.microsoft.com/en-us/azure/app-service/configure-custom-container?tabs=debian&pivots=container-linux#enable-ssh
RUN echo "root:Docker!" | chpasswd

COPY resources/templates/sshd_config /etc/ssh/
RUN mkdir -p /tmp
COPY resources/bin/sshd_setup.sh /tmp
RUN chmod +x /tmp/sshd_setup.sh \
    && (sleep 1;/tmp/sshd_setup.sh 2>&1 > /dev/null)

#Set custom entrypoint and startup routines (app configuration, migrations, seeds, etc)
COPY resources/bin/init_*.sh /etc/container/
COPY resources/bin/startup.sh /etc/container/
COPY resources/bin/entrypoint.sh /etc/container/

RUN chmod +x /etc/container/*.sh

#Switch to non-privileged user used during application runtime
USER docker
WORKDIR /usr/src/app

#Propagate required php extensions set via environment variables
ENV PHP_EXTENSION_GD=1 \
    PHP_EXTENSION_IMAGICK=1 \
    PHP_EXTENSION_LDAP=1 \
    PHP_EXTENSION_MCRYPT=1 \
    PHP_EXTENSION_SWOOLE=1 \
    PHP_EXTENSION_OCI8=1

#Get application source
COPY --chown=docker:docker ./src .

#Install application-specific dependencies
RUN composer install --no-dev

#Build frontend templates required during execution
RUN npm ci && npm run prod

CMD ["/etc/container/entrypoint.sh"]
