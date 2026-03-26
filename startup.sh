#!/bin/bash
# Azure App Service Linux PHP startup script.
#
# The platform's /opt/startup/startup.sh starts nginx (with root=/home/site/wwwroot)
# and then calls this script before starting php-fpm. We patch the nginx config
# to point at Drupal's web/ subdirectory and add try_files for clean URLs,
# then reload nginx.

NGINX_CONF=/etc/nginx/sites-enabled/default

# Fix document root to Drupal's web/ subdirectory
sed -i 's|root /home/site/wwwroot;|root /home/site/wwwroot/web;|g' "$NGINX_CONF"

# Add try_files for Drupal clean URLs
sed -i 's|index  index.php index.html index.htm hostingstart.html;|try_files $uri /index.php?$query_string;|' "$NGINX_CONF"

nginx -s reload

echo "Startup: nginx patched for Drupal (docroot + try_files)"
