Start-Transcript -Path "C:\BuildArtifacts\installdocker.log";

Set-ExecutionPolicy Bypass -Scope Process -Force;
choco install -y docker-desktop --ia \'--quiet --accept-license\';

Stop-Transcript;