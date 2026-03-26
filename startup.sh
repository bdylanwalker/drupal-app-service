#!/bin/bash
# Azure App Service Linux PHP startup script.
#
# The platform's /opt/startup/startup.sh starts nginx (with root=/home/site/wwwroot)
# and then calls this script before starting php-fpm. We patch the nginx config
# to point at Drupal's web/ subdirectory and reload nginx.

sed -i 's|root /home/site/wwwroot;|root /home/site/wwwroot/web;|g' \
  /etc/nginx/sites-enabled/default

nginx -s reload

echo "Startup: nginx document root updated to /home/site/wwwroot/web"