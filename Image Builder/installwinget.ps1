$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'

if(!$hasPackageManager)
{
    # download
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile 'Microsoft.VCLibs.x64.14.00.Desktop.appx' -UseBasicParsing
    
    Add-AppxPackage -Path 'Microsoft.VCLibs.x64.14.00.Desktop.appx'

    $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1

    Invoke-WebRequest -Uri $($latestRelease.browser_download_url) -OutFile 'Microsoft.DesktopAppInstaller.msixbundle' -UseBasicParsing

    Add-AppxPackage -Path 'Microsoft.DesktopAppInstaller.msixbundle'

    # delete file
    Remove-Item 'Microsoft.DesktopAppInstaller.msixbundle'
    Remove-Item 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
}