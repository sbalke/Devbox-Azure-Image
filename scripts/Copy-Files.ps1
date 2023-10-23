$files = @("Clone-Repo.ps1",
"Create-ArtifactsFolder.ps1",
"Fix-Docker.ps1",
"Fix-Sysprep.ps1",
"Generalize-VM.ps1",
"Install-AzureStorageExplorer.ps1"
"Install-Docker.ps1",
"Install-DotNet.ps1",
"Install-Filezilla.ps1"
"Install-Git.ps1",
"Install-GitHub-CLI.ps1",
"Install-GitHubDesktop.ps1",
"Install-Notepadplusplus.ps1",
"Install-SSMS.ps1",
"Install-Teams.ps1",
"Install-VS2022.ps1",
"Install-VSCode.ps1",
"Install-Winget.ps1",
"Install-WSL-Kernel-Update.ps1",
"Remove-AppxPackages.ps1",
"Set-Theme.ps1")


foreach($file in $files) {
    $url = "https://raw.githubusercontent.com/sbalke/Devbox-Azure-Image/main/scripts/$($file)"
    $dest = "C:\BuildArtifacts\$($file)"
    write-host "Getting: $($url)"
    (new-object net.webclient).DownloadFile($url, $dest)

}
