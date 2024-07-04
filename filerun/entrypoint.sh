#!/bin/bash
set -eux

# Check if user exists
if ! id -u ${WEB_RUN_USER} > /dev/null 2>&1; then
        echo "The user ${WEB_RUN_USER} does not exist, creating..."
        groupadd -f -g ${WEB_RUN_GROUP_ID} ${WEB_RUN_GROUP}
        useradd -u ${WEB_RUN_USER_ID} -g ${WEB_RUN_GROUP} ${WEB_RUN_USER}
fi

# Install FileRun on first run
if [ ! -e /var/www/html/index.php ];  then
        echo "[Downloading latest FileRun version]"
  curl -o /filerun.zip -L 'https://filerun.com/download-latest-docker'
        unzip -q /filerun.zip -d /var/www/html/
        cp /filerun/overwrite_install_settings.temp.php /var/www/html/system/data/temp/
        rm -f /filerun.zip
        chown -R ${WEB_RUN_USER}:${WEB_RUN_GROUP} /var/www/html
        chown ${WEB_RUN_USER}:${WEB_RUN_GROUP} /user-files
        echo "Open this server in your browser to complete the FileRun installation."
fi

# Generate SSL Certificate
openssl req -x509 -nodes -days 365 -newkey rsa:4096 -subj "/C=US/ST=Name/L=Location/O=Organization/CN=localhost" -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
mkdir -p /var/log/php-fpm
chown -R ${WEB_RUN_USER}:${WEB_RUN_GROUP} /var/log/php-fpm
sed -i 's/^worker_processes.*/worker_processes 8;/' /etc/nginx/nginx.conf
cp -f /filerun/php-fpm.d/* /usr/local/etc/php-fpm.d/
cp -f /filerun/sites-enabled/* /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

exec "$@"
