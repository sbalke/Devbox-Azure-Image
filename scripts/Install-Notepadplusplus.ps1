Start-Transcript -Path "C:\buildartifacts\installnotepad++.log"

Set-ExecutionPolicy Bypass -Scope Process -Force;
choco install -y notepadplusplus

Stop-Transcript
