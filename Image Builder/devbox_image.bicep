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
      hyperVGeneration: 'V2'
      architecture: 'x64'
      features: [
        {
          name: 'SecurityType'
          value: 'TrustedLaunch'
        }
      ]
      osType: 'Windows'
      osState: 'Generalized'
      identifier: {
        offer: 'Windows11'
        publisher: 'Etchasoft'
        sku: '${name}_Win11-VS-SSMS'
      }
      recommended: {
        vCPUs: {
          min: 4
          max: 16
        }
        memory: {
          min: 16
          max: 64
        }
      }
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
  dependsOn: []

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
      {
        type: 'PowerShell'
        name: 'Create BuildArtifacts Directory'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/scripts/Create-ArtifactsFolder.ps1'
      }
      {
        type: 'PowerShell'
        name: 'Copy Files '
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/scripts/Copy-Files.ps1'
      }
      {
        type: 'File'
        name: 'COpy ${name}'
        destination: 'C:\\BuildArtifacts\\Install-${name}.ps1'
        sourceUri: installName
      }
      {
        type: 'PowerShell'
        name: 'Install Chocolatey'
        inline: [
          'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString(\'https://chocolatey.org/install.ps1\'));'
        ]
      }
      {
        type: 'PowerShell'
        name: 'Install Software'
        inline: [
          'Set-ExecutionPolicy Bypass -Scope Process -Force;'
          'cd \\BuildArtifacts\\' 
          '& C:\\BuildArtifacts\\Install-${name}.ps1'         
        ]
      }
/*
      {
        type: 'PowerShell'
        name: 'Install Docker-Desktop'
        inline: [
          'Set-ExecutionPolicy Bypass -Scope Process -Force;'
          'choco install -y docker-desktop --ia \'--quiet --accept-license\';'
        ]
      } 
      {
        type: 'WindowsRestart'
        name: 'Restart Computer'
        restartTimeout: '10m'
      }
      {
        type:'PowerShell'
        name: 'WSL Update'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/scripts/Install-WSL-Kernel-Update.ps1'
        
      }
      {
        type: 'PowerShell'
        name: 'Fix Docker'
        inline: [
          'Start-Transcript -Path "C:\\buildArtifacts\\installFixDocker.log";'
          'Set-ExecutionPolicy Bypass -Scope Process -Force;'
          'write-host "********************************************************************";'
          'net localgroup docker-users'
           'net localgroup docker-users "NT AUTHORITY\\Authenticated Users" /add'
          'net localgroup docker-users'
          'write-host "********************************************************************";'
          'Stop-Transcript;'
        ]
      }
      {
        type: 'PowerShell'
        name: 'update wsl'
        runElevated: true
        runAsSystem: true
        inline: [
          'Start-Transcript -Path "C:\\buildArtifacts\\wslupdate.log";'
          'wsl --update;'
          'Stop-Transcript";'
        ]
      }
      {
        type: 'PowerShell'
        name: 'Install SQL Server Management Studio'
        inline: [
          'Set-ExecutionPolicy Bypass -Scope Process -Force;'
          'choco install -y sql-server-management-studio --ia \'--quiet --accept-license\';'
        ]
      }
      {
        type: 'PowerShell'
        name: 'Install Notepad++'
        inline: [
          'Set-ExecutionPolicy Bypass -Scope Process -Force;'
          'choco install -y notepadplusplus --ia \'--quiet --accept-license\';'
        ]
      }
      {
        type: 'PowerShell'
        name: 'Install Visual Studio 2022 Ent'
        scriptUri: 'https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/scripts/Install-VS2022.ps1'
      }
      {
        type: 'PowerShell'
        name: 'Install Azure Storage Explorer'
        inline: [
          'Set-ExecutionPolicy Bypass -Scope Process -Force;'
          'choco install -y microsoftazurestorageexplorer'
        ]
      }
      {
        type: 'PowerShell'
        name: 'Fix Sysprep call'
        inline: [
          'try { ((Get-Content -path C:\\DeprovisioningScript.ps1 -Raw) -replace \'Sysprep.exe /oobe /generalize /quiet /quit\', \'Sysprep.exe /oobe /generalize /quiet /quit /mode:vm\' ) | Set-Content -Path C:\\DeprovisioningScript.ps1;     write-log \'Sysprep Mode:VM fix applied\'; } catch { $ErrorMessage = $_.Exception.message; write-log \'Error updating script: $ErrorMessage\';  }'
        ]
      }
      {
        type: 'WindowsRestart'
        name: 'Restart Computer'
        restartTimeout: '10m'
      }
      {
        type: 'PowerShell'
        name: 'Sleep'
        inline: [
          'Start-Sleep -Seconds 60'
        ]
      }
      {
        type: 'PowerShell'
        name: 'Sleep'
        inline: [
          'Get-AppxPackage -Name *NotepadPlusPlus* | Remove-AppxPackage'
        ]
      }*/
      {
        type: 'PowerShell'
        name: 'Fix Sysprep call'
        inline: [
          'try { ((Get-Content -path C:\\DeprovisioningScript.ps1 -Raw) -replace \'Sysprep.exe /oobe /generalize /quiet /quit\', \'Sysprep.exe /oobe /generalize /quiet /quit /mode:vm\' ) | Set-Content -Path C:\\DeprovisioningScript.ps1;     write-log \'Sysprep Mode:VM fix applied\'; } catch { $ErrorMessage = $_.Exception.message; write-log \'Error updating script: $ErrorMessage\';  }'
        ]
      }
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0'
        filters: [
          'exclude:$_.Title -like \'*Preview*\''
          'include:$true'
        ]
        updateLimit: 20
      }
      {
        type: 'WindowsRestart'
        name: 'Reboot After Updates'
        restartTimeout: '10m'
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        excludeFromLatest: true
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
    buildTimeoutInMinutes: 120

  }
}

output imageId string = gallery::image.id



