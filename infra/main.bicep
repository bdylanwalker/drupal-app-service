@description('Base name used for all resource names. Must produce a globally unique App Service and MySQL name.')
param appName string

@description('Azure region for all resources.')
param location string = resourceGroup().location

@description('Public IP address of your workstation. Used for App Service and MySQL firewall rules.')
param allowedIpAddress string

@description('MySQL administrator username.')
param dbAdminUser string = 'drupaladmin'

@secure()
@description('MySQL administrator password. Supply at deploy time — do not commit to source control.')
param dbAdminPassword string

@description('Drupal database name.')
param dbName string = 'drupal'

@description('PHP runtime version for App Service.')
param phpVersion string = 'PHP|8.3'

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    appName: appName
    location: location
  }
}

module mysql 'modules/mysql.bicep' = {
  name: 'mysql'
  params: {
    appName: appName
    location: location
    adminUser: dbAdminUser
    adminPassword: dbAdminPassword
    dbName: dbName
    allowedIpAddress: allowedIpAddress
  }
}

module appservice 'modules/appservice.bicep' = {
  name: 'appservice'
  params: {
    appName: appName
    location: location
    phpVersion: phpVersion
    allowedIpAddress: allowedIpAddress
    dbHost: mysql.outputs.fqdn
    dbName: dbName
    dbUser: dbAdminUser
    dbPassword: dbAdminPassword
    storageAccountName: storage.outputs.storageAccountName
    storageAccountKey: storage.outputs.storageAccountKey
    fileShareName: storage.outputs.fileShareName
  }
}

output appServiceUrl string = appservice.outputs.url
output mysqlFqdn string = mysql.outputs.fqdn
output webAppName string = appservice.outputs.webAppName