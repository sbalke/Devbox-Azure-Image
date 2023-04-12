Start-Transcript -Path "C:\buildartifacts\installssms.log"

winget install Microsoft.SQLServerManagementStudio -h --disable-interactivity --accept-package-agreements --accept-source-agreements

Stop-Transcript