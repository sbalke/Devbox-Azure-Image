$Url = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"


$ProgressPreference = 'SilentlyContinue'	# hide any progress output

$installerName = "wsl_update_x64.msi"
$installerPath = Join-Path -Path $env:TEMP -ChildPath $installerName

Write-Host "[${env:username}] Downloading WSL2 Update ..."
(new-object net.webclient).DownloadFile('https://wslstorestorage.blob.core.windows.net/wslblob/', $installerPath)

Write-Host "[${env:username}] Installing WSL2 Update ..."
$process = Start-Process -FilePath $installerPath -ArgumentList `
    "/quiet" `
    "/passive" `
    "/qn" `
    "/norestart" `
    -NoNewWindow -Wait -PassThru

exit $process.ExitCode