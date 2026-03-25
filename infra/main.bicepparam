using './main.bicep'

// appName becomes the App Service name and prefix for all other resources.
// App Service names must be globally unique across Azure.
param appName = 'drupal-app-service'

param location = 'centralus'

// Replace with your workstation's public IP: curl -s https://api.ipify.org
param allowedIpAddress = '108.253.241.223'

param dbAdminUser = 'drupaladmin'

// Read the password from an environment variable so it is never stored in source control.
// Set it before deploying:
//   export DRUPAL_DB_PASSWORD='<password>'
//   az deployment group create \
//     -g drupal-app-service-rg \
//     --template-file infra/main.bicep \
//     --parameters infra/main.bicepparam
param dbAdminPassword = readEnvironmentVariable('DRUPAL_DB_PASSWORD')