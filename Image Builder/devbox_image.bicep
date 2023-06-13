@description('Specifies the location for resources.')
param publisher string //= 'microsoftvisualstudio'
param offer string //= 'visualstudioplustools'
param sku string //= 'vs-2022-pro-general-win11-m365-gen2'
param version string //= 'latest'
param galleryName string
param name string
param location string = resourceGroup().location

var urlBase = 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/scripts/'
var installName = '${urlBase}Install-${name}.ps1'

resource gallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: galleryName
  location: location
  resource image 'images@2022-03-03' = {
    name: '${name}-DevBox-Image'
    location: location
    properties: {
      osType: 'Windows'
      identifier: {
        offer: 'Windows11'
        publisher: 'Etchasoft'
        sku: '${name}_Win11-VS-SSMS'
      }
      osState: 'Generalized'
      hyperVGeneration: 'V2'
      features: [
        {
          name: 'SecurityType'
          value: 'TrustedLaunchSupported'
        }
      ]
      recommended: {
        vCPUs: {
          min: 4
          max: 16
        }
        memory: {
          min: 8
          max: 64
        }
      }
      architecture: 'x64'
    }
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: '${name}_Devbox'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/1c3e9cd3-5139-4478-b55b-8c632168518e/resourcegroups/DevBoxes/providers/Microsoft.ManagedIdentity/userAssignedIdentities/DevBox-ManagedID': {}
    }
  }
  tags: {
    base_image_publisher: publisher
    base_image_offer: offer
    base_image_sku: sku
  }
  properties: {
    vmProfile: {
      vmSize: 'Standard_DS2_v2'
      osDiskSizeGB: 128
    }
    source: {
      type: 'PlatformImage'
      publisher: publisher
      offer: offer
      sku: sku
      version: version
    }
    customize: [
//      {
//        type: 'WindowsUpdate'
//        searchCriteria: 'IsInstalled=0'
//        filters: [
//          'exclude:%_.Title -like \'*Preview*\''
//          'include: $true'
//        ]
//        updateLimit: 40
//      }
      {
        type: 'PowerShell'
        name: 'CreateBuildArtifacts'
        scriptUri: '${urlBase}Create-ArtifactsFolder.ps1'
      }
      {
        type: 'File'
        name: 'Copy Choco'
        sourceUri: '${urlBase}Install-Chocolatey.ps1'
        destination: 'C:\\BuildArtifacts\\Install-Chocolatey.ps1'
      }
      {
        type: 'File'
        name: 'Copy Git'
        sourceUri: '${urlBase}Install-Git.ps1'
        destination: 'C:\\BuildArtifacts\\Install-Git.ps1'
      }
      {
        type: 'File'
        name: 'Copy SSMS'
        sourceUri: '${urlBase}Install-SSMS.ps1'
        destination: 'C:\\BuildArtifacts\\Install-SSMS.ps1'
      }      
      {
        type: 'File'
        name: 'Copy VS2022'
        sourceUri: '${urlBase}Install-VS2022.ps1'
        destination: 'C:\\BuildArtifacts\\Install-VS2022.ps1'
      }
      {
        type: 'File'
        name: 'Copy DotNet'
        sourceUri: '${urlBase}Install-DotNet.ps1'
        destination: 'C:\\BuildArtifacts\\Install-DotNet.ps1'
      }
      {
        type: 'PowerShell'
        name: 'Install'
        scriptUri: installName
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'PowerShell'
        name: 'fixsysprep'
        scriptUri: '${urlBase}Fix-Sysprep.ps1'
        runElevated: true
        runAsSystem: true
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: gallery::image.id
        runOutputName: '${name}SharedImage'
        replicationRegions: [
          location
        ]
        artifactTags: {
          base_image_publisher: publisher
          base_image_offer: offer
          base_image_sku: sku
        }
      }
    ]
    buildTimeoutInMinutes: 240
  }
}

output imageId string = gallery::image.id
