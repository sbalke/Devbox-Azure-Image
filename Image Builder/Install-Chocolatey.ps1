#Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$env:chocolateyUseWindowsCompression = 'false'

Write-Host "Downloading Chocolatey ..."
(new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1', 'C:\Windows\Temp\chocolatey.ps1')

Write-Host "Installing Chocolatey ..."
& C:/Windows/Temp/chocolatey.ps1