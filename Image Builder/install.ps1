$useChoco = $true

if($useChoco) {
    & C:\BuildArtifacts\installchoco.ps1;
} else {
    & C:\BuildArtifacts\installwinget.ps1;
}
& C:\BuildArtifacts\installNotepadplusplus.ps1