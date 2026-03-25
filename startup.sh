#!/bin/bash
# Azure App Service Linux PHP startup script.
# Overwrites the default Apache vhost to set the document root to web/
# (Drupal composer layout) and starts Apache in the foreground.
#
# App Service treats this as the main process — it must not exit, otherwise
# App Service will restart the container and show the default placeholder page.

set -e

# Write a fresh vhost config rather than patching the existing one with sed.
# This is reliable regardless of how the default config is formatted.
cat > /etc/apache2/sites-available/000-default.conf << 'APACHE'
<VirtualHost *:80>
    DocumentRoot /home/site/wwwroot/web

    <Directory /home/site/wwwroot/web>
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /dev/stderr
    CustomLog /dev/stdout combined
</VirtualHost>
APACHE

a2enmod rewrite

echo "Startup: DocumentRoot set to /home/site/wwwroot/web — starting Apache"

# Replace this shell process with Apache running in the foreground.
# App Service monitors this process; if it exits the container restarts.
exec apache2 -D FOREGROUND