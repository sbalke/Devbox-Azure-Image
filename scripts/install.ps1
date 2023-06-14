$useChoco = $true

if($useChoco) {
    & C:\BuildArtifacts\installchoco.ps1;
} else {
    & C:\BuildArtifacts\installwinget.ps1;
}
& C:\BuildArtifacts\installNotepadplusplus.ps1
#& C:\BuildArtifacts\installDocker.ps1
& C:\BuildArtifacts\installSSMS.ps1
#& C:\BuildArtifacts\installteams.ps1