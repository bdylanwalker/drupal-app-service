param appName string
param location string
param adminUser string

@secure()
param adminPassword string

param dbName string
param allowedIpAddress string

var serverName = '${appName}-mysql'

resource mysqlServer 'Microsoft.DBforMySQL/flexibleServers@2023-12-30' = {
  name: serverName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: adminUser
    administratorLoginPassword: adminPassword
    version: '8.4'
    storage: {
      storageSizeGB: 20
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}

resource database 'Microsoft.DBforMySQL/flexibleServers/databases@2023-12-30' = {
  parent: mysqlServer
  name: dbName
  properties: {
    charset: 'utf8mb4'
    collation: 'utf8mb4_unicode_ci'
  }
}

// Disable SSL requirement for dev simplicity; re-enable and configure CA cert for production
resource sslConfig 'Microsoft.DBforMySQL/flexibleServers/configurations@2023-12-30' = {
  parent: mysqlServer
  name: 'require_secure_transport'
  properties: {
    value: 'OFF'
    source: 'user-override'
  }
  dependsOn: [database]
}

// Allow Azure services (IP 0.0.0.0 is the Azure sentinel value for this)
resource allowAzureServices 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-12-30' = {
  parent: mysqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
  dependsOn: [sslConfig]
}

// Allow developer workstation
resource allowDevMachine 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2023-12-30' = {
  parent: mysqlServer
  name: 'AllowDevMachine'
  properties: {
    startIpAddress: allowedIpAddress
    endIpAddress: allowedIpAddress
  }
  dependsOn: [sslConfig]
}

output fqdn string = mysqlServer.properties.fullyQualifiedDomainName
output serverName string = mysqlServer.name