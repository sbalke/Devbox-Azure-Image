Start-Transcript -Path "C:\buildartifacts\installdocker.log"

winget install Docker.DockerDesktop --silent --source winget --accept-package-agreements --accept-source-agreements

Stop-Transcript