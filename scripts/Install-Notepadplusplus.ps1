Start-Transcript -Path "C:\buildartifacts\installnotepad++.log"

if($useChoco) {
    choco install -y notepadplusplus
} else {
    winget install Notepad++.Notepad++ -h --disable-interactivity --accept-package-agreements --accept-source-agreements
}

Stop-Transcript
