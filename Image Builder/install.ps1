$useChoco = true

if($useChoco) {
    & .\installchoco.ps1;
} else {
    & .\installwinget.ps1;
}
& .\installNotepadplusplus.ps1