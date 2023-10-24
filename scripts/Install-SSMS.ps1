Start-Transcript -Path "installssms.log"

Set-ExecutionPolicy Bypass -Scope Process -Force;
choco install -y sql-server-management-studio

Stop-Transcript