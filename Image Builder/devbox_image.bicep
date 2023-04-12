@description('Specifies the location for resources.')
param location string = resourceGroup().location
param publisher string //= 'microsoftvisualstudio'
param offer string //= 'visualstudioplustools'
param sku string //= 'vs-2022-pro-general-win11-m365-gen2'
param version string //= 'latest'
//param galleryId string = '/subscriptions/1c3e9cd3-5139-4478-b55b-8c632168518e/resourceGroups/DevBoxes/providers/Microsoft.Compute/galleries/DevBox_Compute_Gallery/images/Win11_VS2022Pro_Docker_SSMS_AIB'
param galleryImageId string //= '/subscriptions/1c3e9cd3-5139-4478-b55b-8c632168518e/resourceGroups/DevBoxes/providers/Microsoft.Compute/galleries/DevBox_Compute_Gallery/images/Win11_VS2022Pro_Docker_SSMS_AIB/versions/0.0.1'
//param resourceGroup string = 'DevBoxes'


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
      {
        type       :'PowerShell'
        name:'CreateBuildArtifacts'
        scriptUri:'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/createArtifactsFolder.ps1'
      }
      {
        type: 'PowerShell'
        name: 'CreateBuildArtifacts'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/createArtifactsFolder.ps1'
      }
      {
        type: 'PowerShell'
        name: 'InstallWinget'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installwinget.ps1'
        runElevated: true
      }
      {
        type: 'WindowsRestart'
        name: 'Restart Windows'
      }
      {
        type:'PowerShell'
        name:'InstallNotepad'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installNotepadplusplus.ps1'
        runElevated: true
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: galleryImageId
        runOutputName: 'runOutputSharedImage'
        replicationRegions: [
          'eastus'
        ]
        artifactTags: {
          base_image_publisher: publisher
          base_image_offer: offer
          base_image_sku : sku
        }
      }
    ]
    buildTimeoutInMinutes: 120
  }
}
