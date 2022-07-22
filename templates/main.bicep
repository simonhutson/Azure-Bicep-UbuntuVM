/* TEMPLATE SCOPE */

targetScope = 'resourceGroup'

/* PARAMETERS */

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'prod'
  'dev'
])
param environment string

@description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param virtual_machine_authentication_type string

@description('Username for the Virtual Machine.')
param virtual_machine_admin_username string

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param virtual_machine_password_or_ssh_key string

param virtual_machine_base64_encoded_script string

@description('Size of the VM')
param virtual_machine_size string

@description('Array of VNET address prefixes')
param virtual_network_address_prefixes array

@description('Array of Subnets')
param virtual_network_subnets array


/* VARIABLES */

var unique_string = uniqueString(tenant().tenantId, subscription().subscriptionId, resourceGroup().id)

var location_prefix = {
  uksouth: 'su'
  ukwest: 'wu'
  westeurope: 'we'
  northeurope: 'ne'
}

var environment_prefix = {
  prod: 'p'
  dev: 'd'
}

var prefix = 'az${location_prefix[location]}-${environment_prefix[environment]}' // azsu-p
var short_prefix = replace(prefix,'-','') // azsup

var storage_account_name = toLower('${short_prefix}st${unique_string}')
var virtual_machine_name = toUpper('${prefix}-VM-${unique_string}-01')
var virtual_machine_computer_name = toLower(substring('${unique_string}01',0,15))
var virtual_machine_os_disk_name = toUpper('${virtual_machine_name}-OSDISK')
var virtual_machine_nic_name = toUpper('${virtual_machine_name}-NIC-01')
var virtual_machine_public_ip_name = toUpper('${virtual_machine_name}-PIP-01')
var virtual_machine_public_ip_dns_name = toLower('${short_prefix}vm${unique_string}')
var virtual_machine_custom_script_extension_name = 'custom_script_extension'
var virtual_network_name = toUpper('${prefix}-VNET-${unique_string}-01')
var virtual_network_subnet_id = resourceId('Microsoft.Network/virtualNetworks/subnets',virtual_network_name, 'VM')
var network_security_group_name = toUpper('${prefix}-NSG-${unique_string}-01')

var virtual_machine_linux_configuration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${virtual_machine_admin_username}/.ssh/authorized_keys'
        keyData: virtual_machine_password_or_ssh_key
      }
    ]
  }
}

/* RESOURCES */

resource virtual_network_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtual_network_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: virtual_network_address_prefixes
    }
    subnets: [for subnet in virtual_network_subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        networkSecurityGroup: subnet.isNSG ? {
          id: network_security_group_resource.id
        } : null
        delegations: []
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
    }]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource network_security_group_resource 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: network_security_group_name
  location: location
  properties: {
    securityRules: [
      {
        name: 'default-allow-22'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'default-allow-80'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1001
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource virtual_machine_public_ip_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: virtual_machine_public_ip_name
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: virtual_machine_public_ip_dns_name
      fqdn: '${virtual_machine_public_ip_dns_name}.uksouth.cloudapp.azure.com'
    }
    ipTags: []
  }
}

resource storage_account_resource 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storage_account_name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource virtual_machine_nic_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: virtual_machine_nic_name
  location: location
  dependsOn: [
    virtual_network_resource
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: virtual_machine_public_ip_resource.id
          }
          subnet: {
            id: virtual_network_subnet_id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource virtual_machine_resource 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtual_machine_name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: virtual_machine_size
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: virtual_machine_os_disk_name
        createOption: 'FromImage'
        caching: 'ReadWrite'
        deleteOption: 'Detach'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtual_machine_computer_name
      adminUsername: virtual_machine_admin_username
      adminPassword: virtual_machine_password_or_ssh_key
      linuxConfiguration: ((virtual_machine_authentication_type == 'password') ? null : virtual_machine_linux_configuration)
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: virtual_machine_nic_resource.id
        }
      ]
    }
  }
}

// https://docs.microsoft.com/azure/virtual-machines/extensions/custom-script-linux
resource virtual_machine_custom_script_extension_resource 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  name: virtual_machine_custom_script_extension_name
  parent: virtual_machine_resource
  location: location
  properties: {
    autoUpgradeMinorVersion:true
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.1'
    settings: {
      script: virtual_machine_base64_encoded_script
    }
  }
}

/*
OUTPUTS
*/

output virtual_network_id string = virtual_network_resource.id
output network_security_group_id string = network_security_group_resource.id
output storage_account_id string = storage_account_resource.id
output virtual_machine_id string = virtual_machine_resource.id
output virtual_machine_nic_id string = virtual_machine_nic_resource.id
output virtual_machine_public_ip_id string = virtual_machine_public_ip_resource.id
