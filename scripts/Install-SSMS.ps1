Start-Transcript -Path "installssms.log"

#if($useChoco) {
    choco install -y sql-server-management-studio
#} else {
#    winget install Microsoft.SQLServerManagementStudio -h --disable-interactivity --accept-package-agreements --accept-source-agreementss
#}

Stop-Transcript