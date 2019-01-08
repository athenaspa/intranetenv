
FROM webdevops/php:7.2

RUN apt-get update && apt-get install -y \
        sudo \
        mysql-client \
        libaio1 \
        nano

ADD oracle/*.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
        unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
        unzip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
        ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
        ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so && \
        ln -s /usr/local/instantclient/lib* /usr/lib && \
        ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

RUN  docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient && \
        docker-php-ext-install oci8

RUN mkdir -p /usr/src/php_oci && \
        cd /usr/src/php_oci && \
        wget http://php.net/distributions/php-$PHP_VERSION.tar.gz && \
        tar xfvz php-$PHP_VERSION.tar.gz && \
        cd php-$PHP_VERSION/ext/pdo_oci && \
        phpize && \
        ./configure --with-pdo-oci=instantclient,/usr/local/instantclient,12.1 && \
        make && \
        make install && \
        echo extension=pdo_oci.so > /usr/local/etc/php/conf.d/pdo_oci.ini

RUN docker-run-bootstrap && \
        docker-image-cleanup

RUN usermod -aG sudo ${APPLICATION_USER} \
        && echo "${APPLICATION_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${APPLICATION_USER}

VOLUME /etc/tnsnames.ora

WORKDIR ${APPLICATION_PATH}
