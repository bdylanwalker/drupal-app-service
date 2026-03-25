param appName string
param location string
param phpVersion string
param allowedIpAddress string
param dbHost string
param dbName string
param dbUser string

@secure()
param dbPassword string

param storageAccountName string

@secure()
param storageAccountKey string

param fileShareName string

var planName = '${appName}-plan'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: planName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true // required for Linux
  }
}

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: phpVersion
      alwaysOn: false // B1 supports alwaysOn; set true if you need it and accept the cost
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      // Runs after app files are in place; sets Apache document root to web/
      appCommandLine: '/bin/bash /home/site/wwwroot/startup.sh'
      appSettings: [
        {
          name: 'DB_HOST'
          value: dbHost
        }
        {
          name: 'DB_NAME'
          value: dbName
        }
        {
          name: 'DB_USER'
          value: dbUser
        }
        {
          name: 'DB_PASSWORD'
          value: dbPassword
        }
        {
          // Derived from resource group ID + app name; stable but not secret — override for prod
          name: 'DRUPAL_HASH_SALT'
          value: uniqueString(resourceGroup().id, appName)
        }
        {
          // Prevent Oryx from re-running composer; we include vendor/ in the deployment zip
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'false'
        }
      ]
      // Mount Azure Files share as the Drupal public files directory
      azureStorageAccounts: {
        drupalfiles: {
          type: 'AzureFiles'
          accountName: storageAccountName
          shareName: fileShareName
          mountPath: '/home/site/wwwroot/web/sites/default/files'
          accessKey: storageAccountKey
        }
      }
      // Restrict inbound traffic to developer machine only
      ipSecurityRestrictions: [
        {
          ipAddress: '${allowedIpAddress}/32'
          action: 'Allow'
          priority: 100
          name: 'AllowDevMachine'
        }
        {
          ipAddress: 'Any'
          action: 'Deny'
          priority: 2147483647
          name: 'DenyAll'
        }
      ]
      // SCM (Kudu/deploy) endpoint is open to all IPs so the Azure DevOps
      // hosted agent can deploy. It is protected by deployment credentials.
      // Must be explicitly set to allow-all — omitting the field does not
      // clear rules already present in Azure from a prior deployment.
      scmIpSecurityRestrictionsUseMain: false
      scmIpSecurityRestrictions: [
        {
          ipAddress: 'Any'
          action: 'Allow'
          priority: 2147483647
          name: 'AllowAll'
        }
      ]
    }
  }
}

output url string = 'https://${webApp.properties.defaultHostName}'
output webAppName string = webApp.name