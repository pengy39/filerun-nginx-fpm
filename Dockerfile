FROM library/php:8.1-fpm
ENV FR_DB_HOST=db \
   FR_DB_PORT=3306 \
   FR_DB_NAME=filerun \
   FR_DB_USER=filerun \
   FR_DB_PASS=filerun \
   WEB_RUN_USER=www-data \
   WEB_RUN_USER_ID=33 \
   WEB_RUN_GROUP=www-data \
   WEB_RUN_GROUP_ID=33 \
   LIBREOFFICE_VERSION=7.6.7 \
   PHP_VERSION_SHORT=8.1
VOLUME [/var/www/html /user-files]
RUN apt update &&\
   apt install -y --no-install-recommends \
      cron \
      ffmpeg \
      imagemagick \
      libcurl4-gnutls-dev \
      libde265-dev \
      libexif-dev \
      libfreetype6-dev \
      libgif-dev \
      libheif-dev \
      libimagequant-dev \
      libjpeg62-turbo-dev \
      libldap2-dev \
      libltdl-dev \
      libmagickcore-dev \
      libopenexr-dev \
      libopenjp2-7-dev \
      liborc-0.4-dev \
      libpoppler-glib-dev \
      libraw-bin \
      libraw-dev \
      libreoffice \
      librsvg2-dev \
      libtiff-dev \
      libvips-tools \
      libwebp-dev \
      libzip-dev \
      locales \
      mariadb-client \
      nginx \
      pngquant \
      procps \
      supervisor \
      unzip \
      vim &&\
   mkdir /var/log/supervisord /var/run/supervisord &&\
   docker-php-ext-configure zip &&\
   docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ &&\
   docker-php-ext-configure ldap &&\
   docker-php-ext-install -j$(nproc) pdo_mysql exif zip gd opcache ldap &&\
   docker-php-source delete &&\
   apt clean &&\
   rm -rf /var/lib/apt/lists/* &&\
   rm -rf /tmp/*
RUN echo [Install ionCube] &&\
   curl -o /tmp/ioncube.zip -L https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip &&\
   PHP_EXT_DIR=$(php-config --extension-dir) &&\
   unzip -j /tmp/ioncube.zip ioncube/ioncube_loader_lin_${PHP_VERSION_SHORT}.so -d $PHP_EXT_DIR &&\
   echo "zend_extension=ioncube_loader_lin_${PHP_VERSION_SHORT}.so" >> /usr/local/etc/php/conf.d/00_ioncube_loader_lin_${PHP_VERSION_SHORT}.ini &&\
   rm -rf /tmp/*
COPY ./filerun /filerun
RUN mv /filerun/filerun-optimization.ini /usr/local/etc/php/conf.d/ &&\
   mkdir -p /user-files &&\
   chown www-data:www-data /user-files &&\
   chmod +x /filerun/entrypoint.sh
ENTRYPOINT ["/filerun/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/filerun/supervisord.conf"]
