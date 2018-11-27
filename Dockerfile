
FROM php:fpm

RUN apt-get update && apt-get -y install wget bsdtar libaio1 && \
 wget -qO- https://raw.githubusercontent.com/caffeinalab/php-fpm-oci8/master/oracle/instantclient-basic-linux.x64-12.2.0.1.0.zip | bsdtar -xvf- -C /usr/local && \
 wget -qO- https://raw.githubusercontent.com/caffeinalab/php-fpm-oci8/master/oracle/instantclient-sdk-linux.x64-12.2.0.1.0.zip | bsdtar -xvf-  -C /usr/local && \
 wget -qO- https://raw.githubusercontent.com/caffeinalab/php-fpm-oci8/master/oracle/instantclient-sqlplus-linux.x64-12.2.0.1.0.zip | bsdtar -xvf- -C /usr/local && \
 ln -s /usr/local/instantclient_12_2 /usr/local/instantclient && \
 ln -s /usr/local/instantclient/libclntsh.so.* /usr/local/instantclient/libclntsh.so && \
 ln -s /usr/local/instantclient/lib* /usr/lib && \
 ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus && \
 docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient && \
 docker-php-ext-install oci8 && \
 rm -rf /var/lib/apt/lists/* && \
 php -v

RUN	mkdir -p /usr/src/php_oci && \
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

RUN apt-get install -y \
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
        # Dev and headers
        libbz2-dev \
        libicu-dev \
        libldap2-dev \
        libldb-dev \
        libmcrypt-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libpng-dev

    # Install extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        intl \
        gettext \
        mysqli \
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
    && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini \
    && echo extension=redis.so > /usr/local/etc/php/conf.d/redis.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

VOLUME /etc/tnsnames.ora
