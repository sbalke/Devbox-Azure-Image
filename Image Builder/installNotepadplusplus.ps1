Start-Transcript -Path "C:\buildartifacts\installdocker.log"

winget install Notepad++.Notepad++ -h --disable-interactivity --accept-package-agreements --accept-source-agreements

Stop-Transcript
