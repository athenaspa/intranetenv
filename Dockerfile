
FROM php:fpm

RUN apt-get update && apt-get install -y \
        bsdtar \
        apt-transport-https \
        ca-certificates \
        locales \
        gnupg \
        wget \
        curl \
        net-tools \
        tzdata \
        zip \
        unzip \
        bzip2 \
        moreutils \
        dnsutils \
        openssh-client \
        rsync \
        git \
        imagemagick \
        graphicsmagick \
        ghostscript \
        nano

        # Libraries
RUN apt-get install -y \
        libldap-2.4-2 \
        libxslt1.1 \
        zlib1g \
        libpng-dev \
        libmcrypt4 \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        # dev and headers
        libbz2-dev \
        libicu-dev \
        libldap2-dev \
        libldb-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libaio1 \
        libcurl4-openssl-dev \
        pkg-config \
        libssl-dev

ADD oracle/*.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
        unzip /tmp/instantclient-sdk-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
        unzip /tmp/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip -d /usr/local/ && \
        ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
        ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so && \
        ln -s /usr/local/instantclient/lib* /usr/lib && \
        ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

RUN mkdir -p /usr/src/php_oci && \
        cd /usr/src/php_oci && \
        wget http://php.net/distributions/php-$PHP_VERSION.tar.gz && \
        tar xfvz php-$PHP_VERSION.tar.gz && \
        cd php-$PHP_VERSION/ext/pdo_oci && \
        phpize && \
        ./configure --with-pdo-oci=instantclient,/usr/local/instantclient,12.1 && \
        make && \
        make install && \
        echo extension=pdo_oci.so > /usr/local/etc/php/conf.d/pdo_oci.ini && \
        php -v

# Install extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
        docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient && \
        docker-php-ext-install  && \
        oci8 \
        bcmath \
        bz2 \
        calendar \
        exif \
        intl \
        gettext \
        mysql-client \
        hash \
        pcntl \
        pdo_mysql \
        soap \
        sockets \
        tokenizer \
        sysvmsg \
        sysvsem \
        sysvshm \
        shmop \
        xsl \
        zip \
        gd \
        gettext \
        opcache

RUN pecl install apcu \
        && pecl install redis \
        && pecl install mongodb \
        && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini \
        && echo extension=redis.so > /usr/local/etc/php/conf.d/redis.ini \
        && echo extension=mongodb.so > /usr/local/etc/php/conf.d/mongodb.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

VOLUME /etc/tnsnames.ora
