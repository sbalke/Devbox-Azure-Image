Set-ExecutionPolicy Bypass -Scope Process -Force;
Start-Transcript -Path "C:\buildArtifacts\installFixDocker.log";
write-host "********************************************************************";
net localgroup docker-users;
wsl --update;
net localgroup docker-users "NT AUTHORITY\Authenticated Users" /add;
net localgroup docker-users;
write-host "********************************************************************";
Stop-Transcript;