Start-Transcript -Path "C:\BuildArtifacts\installazurestorageexpolorer.log";

Set-ExecutionPolicy Bypass -Scope Process -Force;

$ProgressPreference = 'SilentlyContinue'	# hide any progress output

$appName = "Azure Storage Explorer"
$installerName = "StorageExplorer-windows-x64.exe"
$installerPath = Join-Path -Path $env:TEMP -ChildPath $installerName

Write-Host "[${env:username}] Downloading ${appName} ..."
(new-object net.webclient).DownloadFile('https://go.microsoft.com/fwlink/?linkid=2216182&clcid=0x409', $installerPath)

Write-Host "[${env:username}] Installing ${appName} ..."
$process = Start-Process -FilePath $installerPath -ArgumentList `
	"/SILENT", `
	"/ALLUSERS", `
	"/NORESTART", `
	-NoNewWindow -Wait -PassThru

exit $process.ExitCode

Stop-Transcript;