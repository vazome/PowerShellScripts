#2020
#Declaring fucntion to add round bracket
function AddTheContent {
    param ( 
        [String]$pathsqlfinalcontent)
    process {
        $( , $_; Get-Content $pathsqlfinalcontent -ReadCount 1000 -ea SilentlyContinue) | Set-Content $pathsqlfinalcontent
    }
}
#Declaring fucntion to make it SQL like
function ToSQL () {
    $done = Write-Host 'Step 3: Converting to SQL' -ForegroundColor Black -BackgroundColor DarkYellow
    Do {
        $yesorno = Read-Host -Prompt "Would you like convert this to SQL query format (y/n)"
        if ($yesorno -like 'y*') {
            foreach ($piece in $getfinalcount) {
                $piece = $piece.Insert(0, "'")
                $piece += "'" + ","
                Write-Output $piece | Out-File $pathsqlfinalcontent -Append
            }
            $removelast = Get-Content $pathsqlfinalcontent -ReadCount 1000
            $removelast = $removelast.Trim()
            for ($i = $removelast.count; $i -ge 0; $i--) {
                if ($removelast[$i] -match ",") { $removelast[$i] = $removelast[$i] -replace ","; break }
            }
            $removelast | Out-File $pathsqlfinalcontent -Force
            "(" | AddTheContent $pathsqlfinalcontent
            Add-Content $pathsqlfinalcontent -Value ")" 
            Write-Host 'Provided with "Yes"'"`nConverted`nThe path is - \Documents\SQLFindAndSplitOutput.txt" -ForegroundColor Black -BackgroundColor DarkYellow
            $done
            return
        }

    }
    Until ($yesorno -like 'n*')
    Write-Host 'Provided with "No"' -ForegroundColor Black -BackgroundColor DarkYellow
    $done
}
Write-Host "Please specify file(s) location.`nFor a single file just insert the file path`nIf you want to scan multiple files:`n1. Please create a separate folder and put the files there`n2. Use wildcard symbol in the end (this will affect all folder's content, be aware) - C:\MyFolder\*" -ForegroundColor Black -BackgroundColor DarkYellow
#Let's ask for current search scope
$FileOrFolderName = Read-Host -Prompt 'Specify the file/folder'
$SpecifyRecord = (Read-Host -Prompt 'What record are you looking for (if multiple separate them by ", ")').split(',') | ForEach-Object { $_.trim() }
$Delimiter_1 = Read-Host -Prompt 'Please provide structural delimiter for example comma "," or colon ":"'
$Delimiter_2 = Read-Host -Prompt 'And second structural delimiter for example comma "," or colon ":"'
<# To be modified
Param(
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
$FileOrFolderName = $FileOrFolderName -replace '^"(.*)"$', '$1'
$FileOrFolderName
$SpecifyRecord
$Delimiter_1
$Delimiter_2
Start-Sleep -Seconds 1
#We have to obtain file(s) content, just in case remove "" input in $askfolder, delimit the content and select by pattern
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$pathfinalcount = "$HOME\Documents\FindAndSplitOutput.txt"
$pathsqlfinalcontent = "$HOME\Documents\SQLFindAndSplitOutput.txt"
$tempfile = New-TemporaryFile
$tempfile.FullName
$tocount = [System.IO.File]::ReadLines($FileOrFolderName)
$done = Write-Host 'Step 1: Delimiting, scoping' -ForegroundColor Black -BackgroundColor DarkYellow
$tocount | foreach {$_ -split $Delimiter_1 | Select-String -Pattern $SpecifyRecord } | Set-Content $tempfile.FullName
$stopwatch
$done = Write-Host 'Step 2: Delimiting, sorting unique, matching' -ForegroundColor Black -BackgroundColor DarkYellow
$getfinalcount = [System.IO.File]::ReadLines($tempfile.FullName)
$getfinalcount | foreach {([System.Collections.Generic.HashSet[string]] $_) -split $Delimiter_2 -replace '[^A-Za-z0-9]' | Select-String -NotMatch $SpecifyRecord} | Set-Content $pathfinalcount
$getfinalcount = [System.IO.File]::ReadLines($pathfinalcount)
Remove-Item $tempfile.FullName -Force
$done = Write-Host 'Finished! Here is you performance index:'
$stopwatch
ToSQL
$done = Write-Host 'Done! Here is you performance index:' -ForegroundColor DarkGreen -BackgroundColor White
$stopwatch
#End
