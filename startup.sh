#!/bin/bash
# Azure App Service Linux PHP startup script.
# Redirects the Apache document root from /home/site/wwwroot to /home/site/wwwroot/web
# so Drupal's composer-based layout (web/ as docroot) is served correctly.

set -e

CONFIG=/etc/apache2/sites-enabled/000-default.conf

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: Apache config not found at $CONFIG" >&2
  exit 1
fi

# Update document root
sed -i 's|DocumentRoot /home/site/wwwroot$|DocumentRoot /home/site/wwwroot/web|g' "$CONFIG"

# Update Directory directive to match (controls .htaccess, AllowOverride, etc.)
sed -i 's|<Directory /home/site/wwwroot>|<Directory /home/site/wwwroot/web>|g' "$CONFIG"

# Ensure .htaccess overrides are honoured (required for Drupal clean URLs)
sed -i 's|AllowOverride None|AllowOverride All|g' "$CONFIG"

# Enable mod_rewrite
a2enmod rewrite

echo "Apache config updated. Document root set to /home/site/wwwroot/web"

service apache2 restart