using './main.bicep'

// appName becomes the App Service name and prefix for all other resources.
// App Service names must be globally unique across Azure.
param appName = 'drupal-app-service'

param location = 'centralus'

// Replace with your workstation's public IP: curl -s https://api.ipify.org
param allowedIpAddress = '108.253.241.223'

param dbAdminUser = 'drupaladmin'

// dbAdminPassword is intentionally omitted — supply at deploy time:
//   az deployment group create \
//     --resource-group <rg> \
//     --template-file infra/main.bicep \
//     --parameters infra/main.bicepparam \
//     --parameters dbAdminPassword='<password>'