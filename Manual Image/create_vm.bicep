@description('The name prefix of the virtual machine')
param Name string
@description('The location of the virtual machine')
param Location string = resourceGroup().location
@description('The Resouce Group Name that contains the Virtual Network')
param vnet_rg string = 'NerdioManager'
@description('The ResourceId of the Virtual Network for the virtual machine')
param vnetName string = 'NerdioVnet'
@description('The subnet to use in the virtual network')
param subnetName string = 'DevBox'
@description('The size of the vm to create. (Default: Standard_B4ms)')
param virtualMachineSize string = 'Standard_B4ms'
@description('Username for the Virtual Machine.')
param adminUsername string
@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string
@description('Name of the source image publisher (Default: visualstudio2019plustools)')
param publisher string = 'microsoftvisualstudio'
@description('Offer From publisher (Default: visualstudio2022plustools)')
param offer string = 'visualstudio2022plustools'
@description('SKU from publisher (Default: vs-2019-pro-general-win11-m365-gen2)')
param sku string = 'vs-2022-pro-general-win11-m365-gen2'

resource nic 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: '${Name}-image-nic'
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId(vnet_rg,'Microsoft.Network/virtualNetworks/subnets',vnetName,subnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: '${Name}-image-vm'
  location: Location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    osProfile: {
      computerName: '${Name}-image-vm'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: false
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'Manual'
        }
      }
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: publisher
        offer: offer
        sku: sku
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true  
      }
    }
  }
}
