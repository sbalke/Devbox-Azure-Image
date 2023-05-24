@description('Specifies the location for resources.')
param location string = resourceGroup().location
param publisher string //= 'microsoftvisualstudio'
param offer string //= 'visualstudioplustools'
param sku string //= 'vs-2022-pro-general-win11-m365-gen2'
param version string //= 'latest'
//param galleryId string = '/subscriptions/1c3e9cd3-5139-4478-b55b-8c632168518e/resourceGroups/DevBoxes/providers/Microsoft.Compute/galleries/DevBox_Compute_Gallery/images/Win11_VS2022Pro_Docker_SSMS_AIB'
param galleryImageId string //= '/subscriptions/1c3e9cd3-5139-4478-b55b-8c632168518e/resourceGroups/DevBoxes/providers/Microsoft.Compute/galleries/DevBox_Compute_Gallery/images/Win11_VS2022Pro_Docker_SSMS_AIB/versions/0.0.1'
//param resourceGroup string = 'DevBoxes'

resource gallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: resourceGroup().name
  location: location

  resource image 'images' = {
    name: 'Test'
    location: location
    properties: {
      osType: 'Windows'
      identifier: {
        offer: 'Windows11'
        publisher: 'Etchasoft'
        sku: 'Win11-VS-SSMS'
      }
      osState: 'Generalized'
    }
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: 'AIB_Devbox'
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
      vmSize: 'Standard_DS1_v2'
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
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/createArtifactsFolder.ps1'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installchoco.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installchoco.ps1'
        name: 'cppychoco'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installnotepadplusplus.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installNotepadplusplus.ps1'
        name: 'cppynpp'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installDocker.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installDocker.ps1'
        name: 'copydocker'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installSSMS.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installSSMS.ps1'
        name: 'copyssms'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installwinget.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installwinget.ps1'
        name: 'copywinget'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\fixsysprep.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/fixsysprep.ps1'
        name: 'copywinget'
      }
      {
        type: 'PowerShell'
        name: 'Install'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/install.ps1'
        runElevated: true
        runAsSystem: true
      }
      {
        type: 'WindowsRestart'
        name: 'afterinstallsrestart'
      }
      {
        type: 'PowerShell'
        name: 'fixsysprep'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/fixsysprep.ps1'
        runElevated: true
        runAsSystem: true
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: gallery::image.id
        runOutputName: 'runOutputSharedImage'
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
