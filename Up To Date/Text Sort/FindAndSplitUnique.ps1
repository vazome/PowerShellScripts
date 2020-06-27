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
#2020
Write-Host "Please specify file(s) location.`nFor a single file just insert the file path`nIf you want to scan multiple files:`n1. Please create a separate folder and put the files there`n2. Use wildcard symbol in the end (this will affect all folder's content, be aware) - C:\MyFolder\*" -ForegroundColor Black -BackgroundColor DarkYellow
#Let's ask for current search scope
$FileOrFolderName = Read-Host -Prompt 'Specify the file/folder'
$SpecifyRecord = (Read-Host -Prompt 'What record are you looking for (if multiple separate them by ", ")').split(',') | ForEach-Object {$_.trim()}
$Delimiter_1 = Read-Host -Prompt 'Please provide structural delimiter for example comma "," or colon ":"'
$Delimiter_2 = Read-Host -Prompt 'And second structural delimiter for example comma "," or colon ":"'
<#Param(
    [Parameter(Mandatory = $true, HelpMessage="Specify the file/folder")]
        [ValidateNotNullorEmpty()]
        [string[]]$FileOrFolderName,
    [Parameter(Mandatory = $true, HelpMessage="For what record type do you looking for (provide name)")]
        [ValidateNotNullorEmpty()]
        [string[]]$SpecifyRecord,
    [Parameter(Mandatory = $true, HelpMessage='Please provide structural delimiter for example comma "," or colon ":"')]
        [ValidateNotNullorEmpty()]
        [string[]]$Delimiter_1,
    [Parameter(Mandatory = $true, HelpMessage='And second structural delimiter for example comma "," or colon ":"')]
        [ValidateNotNullorEmpty()]
        [string[]]$Delimiter_2)#>
Write-Host 'Your input is:' -ForegroundColor Black -BackgroundColor DarkYellow
$FileOrFolderName
$SpecifyRecord
$Delimiter_1
$Delimiter_2
Start-Sleep -Seconds 1
#We have to obtain file(s) content, just in case remove "" input in $askfolder, delimit the content and select by pattern
$tocount = (Get-Content ($FileOrFolderName -replace '^"(.*)"$', '$1')) -split $Delimiter_1 | Select-String -Pattern $SpecifyRecord
$tocount = $tocount -split $Delimiter_2 | Select-String -NotMatch $SpecifyRecord
$finalcount = $tocount -replace '[^A-Za-z0-9]'
$finalcount | Select-Object -Unique | Sort-Object -Descending | Out-File $HOME\Documents\FindAndSplitOutput.txt -Append 
Write-Host 'Done' -ForegroundColor DarkGreen
