Write-Host "Please specify file(s) location.`nFor a single file just insert the file path`nIf you want to scan multiple files:`n1. Please create a separate folder and put the files there`n2. Use wildcard symbol in the end (this will affect all folder's content, be aware) - C:\MyFolder\*" -ForegroundColor Black -BackgroundColor DarkYellow
$askfolder = Read-Host -prompt 'Specify the folder'
Start-Sleep -Seconds 1
$askdelim = Read-Host -prompt 'Please provide structural delimiter for example comma "," or colon ":"'
Start-Sleep -Seconds 1
$askpattern = Read-Host -prompt "For what record type do you looking for (provide name)"
Start-Sleep -Seconds 1
$tocount = (Get-Content ($askfolder -replace '^"(.*)"$', '$1')) -split $askdelim | Select-String -Pattern $askpattern
$finalcount = $tocount -replace '\D+([0-9]*).*','$1'
$finalcount | Select-Object -Unique | Out-File $HOME\Documents\FindAndSplitOutput.txt -Append 
Write-Host 'Done' -ForegroundColor DarkGreen
