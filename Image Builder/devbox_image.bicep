@description('Specifies the location for resources.')
param publisher string //= 'microsoftvisualstudio'
param offer string //= 'visualstudioplustools'
param sku string //= 'vs-2022-pro-general-win11-m365-gen2'
param version string //= 'latest'
param galleryName string
param name string

var urlBase = 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/'
var installName = '${urlBase}install${name}.ps1'
var location = resourceGroup().location

resource gallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: galleryName
  location: location
  resource image 'images@2022-03-03' = {
    name: '${name}Image'
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
        scriptUri: '${urlBase}createArtifactsFolder.ps1'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installchoco.ps1'
        sourceUri: '${urlBase}installchoco.ps1'
        name: 'cppychoco'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installnotepadplusplus.ps1'
        sourceUri: '${urlBase}installNotepadplusplus.ps1'
        name: 'cppynpp'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installDocker.ps1'
        sourceUri: '${urlBase}installDocker.ps1'
        name: 'copydocker'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installSSMS.ps1'
        sourceUri: '${urlBase}installSSMS.ps1'
        name: 'copyssms'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installwinget.ps1'
        sourceUri: '${urlBase}installwinget.ps1'
        name: 'copywinget'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installvscode.ps1'
        sourceUri: '${urlBase}installvscode.ps1'
        name: 'copyvscode'
      }
      {
        type: 'PowerShell'
        name: 'Install'
        scriptUri: installName
        runElevated: true
        runAsSystem: true
      }
//      {
//        type: 'WindowsRestart'
//        name: 'afterinstallsrestart'
//      }
      {
        type: 'PowerShell'
        name: 'fixsysprep'
        scriptUri: '${urlBase}fixsysprep.ps1'
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
