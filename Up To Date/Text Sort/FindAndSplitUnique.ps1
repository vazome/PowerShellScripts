#2020
function AddTheContent {
    param ( 
        [String]$pathsqlfinalcontent)
    process {
    $( ,$_; Get-Content $pathsqlfinalcontent -ea SilentlyContinue) | Out-File $pathsqlfinalcontent
    }
}
Write-Host "Please specify file(s) location.`nFor a single file just insert the file path`nIf you want to scan multiple files:`n1. Please create a separate folder and put the files there`n2. Use wildcard symbol in the end (this will affect all folder's content, be aware) - C:\MyFolder\*" -ForegroundColor Black -BackgroundColor DarkYellow
#Let's ask for current search scope
$Yes = "Yes"
$No = "No"
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
$pathfinalcount = "$HOME\Documents\FindAndSplitOutput.txt"
$pathsqlfinalcontent = "$HOME\Documents\SQLFindAndSplitOutput.txt"
$tocount -replace '[^A-Za-z0-9]' | Select-Object -Unique | Sort-Object -Descending | Out-File $pathfinalcount
$getfinalcount = Get-Content $pathfinalcount
$getfinalcount = $getfinalcount | Where-Object{$_ -ne ""}
$done = Write-Host 'Done' -ForegroundColor DarkGreen
$yesorno = Read-Host -Prompt "Would you like convert this to SQL query format"
if ($yes -match  $yesorno) {
    foreach($piece in $getfinalcount) {
        $piece = $piece.Insert(0,"'")
        $piece += "'" + ","
        Write-Output $piece | Out-File $pathsqlfinalcontent -Append
    }
    $removelast = Get-Content $pathsqlfinalcontent 
    for($i = $removelast.count;$i -ge 0;$i--){
        if($removelast[$i] -match ","){$removelast[$i] = $removelast[$i] -replace ","; break}
    }
        $removelast | Out-File $pathsqlfinalcontent -Force
    "(" | AddTheContent $pathsqlfinalcontent
    Add-Content $pathsqlfinalcontent -Value ")" 
    Write-Host 'Provided with "Yes"'"`nConverted`nThe path is - \Documents\SQLFindAndSplitOutput.txt" -ForegroundColor Black -BackgroundColor DarkYellow
    $done
}
ElseIf ($No -match $yesorno) {
    Write-Host 'Provided with "No"' -ForegroundColor Black -BackgroundColor DarkYellow
    $done
}
else {
    Write-Host 'Answer is not in the scope, finishing' -ForegroundColor Black -BackgroundColor DarkYellow
    $done
}
