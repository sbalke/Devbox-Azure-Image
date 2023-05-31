Start-Transcript -Path "installdocker.log"

if($useChoco) {
    choco install -y docker-desktop
} else {
    winget install Docker.DockerDesktop --silent --source winget --accept-package-agreements --accept-source-agreements
}

Stop-Transcript