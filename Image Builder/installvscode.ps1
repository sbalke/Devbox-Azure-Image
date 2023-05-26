Start-Transcript -Path "C:\buildartifacts\installvscode.log"

if($useChoco) {
    choco install -y vscode
} else {
    winget install vscode --silent --source winget --accept-package-agreements --accept-source-agreements
}

Stop-Transcript