Start-Transcript -Path "C:\buildartifacts\installwinget.log"

$currentLocation = Get-Location
Set-Location -Path \buildartifacts

$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'


if (!$hasPackageManager) {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    #Install NuGet Package Provider. For future use
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    #Install Package Provider Source. For future use
    Register-PackageSource -provider NuGet -name nugetRepository -location https://www.nuget.org/api/v2

    # download
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile 'Microsoft.VCLibs.x64.14.00.Desktop.appx' -UseBasicParsing
  
    $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1

    Invoke-WebRequest -Uri $($latestRelease.browser_download_url) -OutFile 'Microsoft.DesktopAppInstaller.msixbundle' -UseBasicParsing

    Install-Package Microsoft.UI.Xaml -RequiredVersion 2.7.3 

    Add-AppxPackage -Path 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Add-AppxPackage -Path 'Microsoft.DesktopAppInstaller.msixbundle'

    # delete file
    Remove-Item 'Microsoft.DesktopAppInstaller.msixbundle'
    Remove-Item 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
}

Set-Location -Path $currentLocation
Stop-Transcript