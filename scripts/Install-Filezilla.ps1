Start-Transcript -Path "C:\BuildArtifacts\installfilezilla.log";

Set-ExecutionPolicy Bypass -Scope Process -Force;
choco install -y filezilla

Stop-Transcript;