<?php

/**
 * @file
 * Drupal site configuration for Azure App Service.
 *
 * Database credentials and other sensitive values are read from App Service
 * application settings (environment variables), not hardcoded here.
 *
 * Set these in infra/modules/appservice.bicep or via the Azure portal:
 *   DB_HOST, DB_NAME, DB_USER, DB_PASSWORD, DRUPAL_HASH_SALT
 */

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

$databases['default']['default'] = [
  'database'  => getenv('DB_NAME') ?: 'drupal',
  'username'  => getenv('DB_USER') ?: '',
  'password'  => getenv('DB_PASSWORD') ?: '',
  'prefix'    => '',
  'host'      => getenv('DB_HOST') ?: 'localhost',
  'port'      => '3306',
  'driver'    => 'mysql',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload'  => 'core/modules/mysql/src/Driver/Database/mysql/',
  // SSL is disabled on the MySQL server for dev (require_secure_transport = OFF).
  // For production: remove this block and configure MYSQL_ATTR_SSL_CA.
  'pdo' => [
    \PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => FALSE,
  ],
];

// ---------------------------------------------------------------------------
// Security
// ---------------------------------------------------------------------------

$settings['hash_salt'] = getenv('DRUPAL_HASH_SALT') ?: 'CHANGE_THIS_FOR_LOCAL_DEV';

// Allow requests from the App Service default hostname and any custom domain.
// Add custom domains here when you configure them.
$settings['trusted_host_patterns'] = [
  '^.*\.azurewebsites\.net$',
];

// ---------------------------------------------------------------------------
// File system
// ---------------------------------------------------------------------------

// Public files are served from the Azure Files mount.
// The mount path is set in infra/modules/appservice.bicep.
$settings['file_public_path'] = 'sites/default/files';

// Private files: store outside the web root.
// Uncomment and set a path outside web/ if you need private file downloads.
// $settings['file_private_path'] = '/home/site/private';

// ---------------------------------------------------------------------------
// Config sync
// ---------------------------------------------------------------------------

$settings['config_sync_directory'] = '../config/sync';

// ---------------------------------------------------------------------------
// Performance (adjust for production)
// ---------------------------------------------------------------------------

// $config['system.performance']['css']['preprocess'] = TRUE;
// $config['system.performance']['js']['preprocess'] = TRUE;

// ---------------------------------------------------------------------------
// Local overrides (never commit settings.local.php)
// ---------------------------------------------------------------------------

if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}