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
        type: 'PowerShell'
        name: 'CreateBuildArtifacts'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/createArtifactsFolder.ps1'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installnotepadplusplus.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installNotepadplusplus.ps1'
        sha256Checksum: 'b498b2e101ca2a93729d0dedd05e5a3935d9cb7e5e09a7613ad9025d3927672b'
        name: 'cppynpp'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installDocker.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installDocker.ps1'
        sha256Checksum: '150939b13f8318c2a2d5ac16a81c73e4293ed325493e3fcb9d19354172c744ad'
        name: 'copydocker'
      }
      {
        type: 'File'
        destination: 'c:\\buildartifacts\\installSSMS.ps1'
        sourceUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/installSSMS.ps1'
        sha256Checksum: '150939b13f8318c2a2d5ac16a81c73e4293ed325493e3fcb9d19354172c744ad'
        name: 'copyssms'
      }
      {
        type: 'PowerShell'
        name: 'Install'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/Image%20Builder/install.ps1'
        sha256Checksum: ''
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
          base_image_sku: sku
        }
      }
    ]
    buildTimeoutInMinutes: 240
  }
}
