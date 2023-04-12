Start-Transcript -Path "C:\buildartifacts\installssms.log"

if($useChoco) {
    choco install -y sql-server-management-studio
} else {
    winget install Microsoft.SQLServerManagementStudio -h --disable-interactivity --accept-package-agreements --accept-source-agreements
}

Stop-Transcript