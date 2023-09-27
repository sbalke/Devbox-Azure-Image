Start-Transcript -Path "C:\BuildArtifacts\installdocker.log";

Set-ExecutionPolicy Bypass -Scope Process -Force;
choco install -y docker-desktop --version 4.23 --ia \'--quiet --accept-license\';


Stop-Transcript;