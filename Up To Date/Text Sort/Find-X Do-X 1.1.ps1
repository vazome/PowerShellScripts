#2020
#Declaring fucntion to add round bracket
using namespace System.Management.Automation.Host
function Get-Values {
    #Let's ask for current search scope
    Write-Host "Please specify file(s) location.`nFor a single file just insert the file path`nIf you want to scan multiple files:`n1. Please create a separate folder and put files there`n2. Use wildcard symbol in the end (this will affect all folder contents, be aware) - C:\MyFolder\*" -ForegroundColor Black -BackgroundColor DarkYellow
    $FileOrFolderName = Read-Host -Prompt 'Specify the file/folder'
    $SpecifyRecord = (Read-Host -Prompt 'What record are you looking for (if multiple separate them by ", ")').split(',') | ForEach-Object { $_.trim() }
    $Delimiter_1 = Read-Host -Prompt 'Please provide structural delimiter for example comma "," or colon ":"'
    $Delimiter_2 = Read-Host -Prompt 'And second structural delimiter for example comma "," or colon ":"'
    Write-Host 'Here is your input:' -ForegroundColor Black -BackgroundColor DarkYellow
    $FileOrFolderName = $FileOrFolderName -replace '^"(.*)"$', '$1'
    $FileOrFolderName
    $SpecifyRecord
    $Delimiter_1
    $Delimiter_2
    Start-Sleep -Seconds 1
    #We have to obtain file(s) content, just in case remove "", delimit the content and select by pattern
    $tempfile = New-TemporaryFile
    $tempfile.FullName
    Write-Host 'Step 1: Delimiting, scoping'
    $tocount = [System.IO.File]::ReadLines($FileOrFolderName)
    $delimatch = foreach ($s in $tocount) {
        $s -split $Delimiter_1 -match $SpecifyRecord
    }
    [System.IO.File]::WriteAllLines($tempfile.FullName, $delimatch)
    Write-Host 'Step 2: Delimiting, sorting unique, matching'
    #Delimiting
    $getfinalcount = [System.IO.File]::ReadLines($tempfile.FullName)
    $delimreplregx = foreach ($i in $getfinalcount) {
        $i -split $Delimiter_2 -replace '[^A-Za-z0-9]' -notmatch $SpecifyRecord
    }
    [System.IO.File]::WriteAllLines($pathfinalcountwhole, $delimreplregx)
    Remove-Item $tempfile.FullName -Force
    Do {
        $yesorno = Read-Host -Prompt "Remove duplicates and create an additional file? (y/n)"
        if ($yesorno -like 'y*') {
            #Removing duplicates
            $Lines = [System.Collections.Generic.HashSet[string]]::new()
            $Lines.UnionWith([string[]][System.IO.File]::ReadLines($pathfinalcountwhole))
            [System.IO.File]::WriteAllLines($pathfinalcountnoduplicates, $Lines)
        }
        Convert-SQL
        return
    
    }
    Until ($yesorno -like 'n*')
    Write-Host 'Provided with "No"' -ForegroundColor Black -BackgroundColor DarkYellow
}
function AddTheContent {
    param ( 
        [String]$pathsqlfinalcontent)
    process {
        $( , $_; Get-Content $pathsqlfinalcontent -Raw -ea SilentlyContinue) | Set-Content $pathsqlfinalcontent
    }
}
#Declaring fucntion to make it SQL like
function Convert-SQL () {
    Write-Host 'Step 3: Converting to SQL'
    Do {
        if (!$specifolder) {
            $yesorno = Read-Host -Prompt "Would you like convert this to SQL query format (y/n)"
        }
        if ($yesorno -like 'y*') {
            Write-Host 'Provided with "Yes"'"`nConverted`nThe path is - \Documents\SQLFindAndSplitOutput.txt" -ForegroundColor Black -BackgroundColor DarkYellow
            $append = New-Object System.Text.StringBuilder
            $getforsql = [System.IO.File]::ReadLines($pathfinalcountnoduplicates)
            foreach ($i in $getforsql) {
                $null = $append.AppendLine("'$i',")
            }
            $tempfile2 = New-TemporaryFile
            $tempfile2.FullName
            $outputstring = $append.ToString()
            $outputstring | Set-Content $tempfile2.FullName
            Write-Host 'Step 4: Trimming'
            $removelast = Get-Content $tempfile2.FullName
            for ($i = $removelast.count; $i -ge 0; $i--) {
                if ($removelast[$i] -match ",") { $removelast[$i] = $removelast[$i] -replace ","; break }
            }
            $removelast | Set-Content $pathsqlfinalcontent
            Write-Host 'Step 5: brackets'
            #An another way to add "("
            #"(" | AddTheContent $pathsqlfinalcontent
            $plusbracket = "(" + (Get-Content $pathsqlfinalcontent -Raw)
            [System.IO.File]::WriteAllLines($pathsqlfinalcontent, $plusbracket.Split('', [System.StringSplitOptions]::RemoveEmptyEntries))
            Add-Content $pathsqlfinalcontent -Value ")" 
            Remove-Item $tempfile2.FullName -Force
            return
        }
    }
    Until ($yesorno -like 'n*')
    Write-Host 'Provided with "No"' -ForegroundColor Black -BackgroundColor DarkYellow
}
function Compare-Files {
    $temp3 = New-TemporaryFile
    $temp3.FullName
    $Refr = $Refr -replace '^"(.*)"$', '$1'
    $Difr = $Difr -replace '^"(.*)"$', '$1'
    $Propr = $Propr -replace '^"(.*)"$', '$1'
    (Compare-Object -ReferenceObject (Import-Csv $Refr) -DifferenceObject (Import-Csv $Difr) -Property $Propr -PassThru |
        ForEach-Object {
            $_.SideIndicator = $_.SideIndicator -replace '=>', 'Only in Difference file' -replace '<=', 'Only in Reference file'
            $_
        }) > $temp3.FullName
    $compared = Get-Content $temp3.FullName
    Add-Type -AssemblyName System.Windows.Forms
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.filter = "Text Files (*.txt)|*.txt|CSV Files (*.csv)|*.csv"
    $dialog.InitialDirectory = "$HOME\Documents"
    $result = $dialog.ShowDialog()    
    $result 
    if($result -eq 'OK') { 
        $compared | Out-File -FilePath $dialog.FileName
    }
    else { Write-Host "File Save Dialog Cancelled!" -ForegroundColor Yellow} 
    Remove-Item $temp3.FullName -Force
}
function Show-Menu {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Question
    )
    
    $allval = [ChoiceDescription]::new('&Find values and X..', "Find values and do some processing, you will be asked for:`nGive a search scope,`nTo choose to remove duplicates or not,`nConvert to SQL`n")
    $sqlval = [ChoiceDescription]::new('Convert my list of values to &SQL', "If you already have a clear list of values you can convert it to SQL`nIn the end you will have your origianl file and the one that been processed`n")
    $diffto = [ChoiceDescription]::new('&Differentiate side by side two files', "Compares side by side and shows the diffrence in values`nFor numeric values .csv is recomended`n")

    $options = [ChoiceDescription[]]($allval, $sqlval, $diffto)

    $result = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    switch ($result) {
        0 { Get-Values }
        1 {
            $specifolder = Read-Host -Prompt "Please specify your file location"
            $pathfinalcountnoduplicates = $specifolder -replace '^"(.*)"$', '$1'
            $yesorno = 'y'
            Convert-SQL
        }
        2 {
            Write-Warning -Message "Only .CSVs with headers are currently supported for this operation"
            $Refr = Read-Host -Prompt "Reference file"
            $Difr = Read-Host -Prompt "Difference file"
            $Propr = Read-Host -Prompt "Specify header name to compare like Id, SKU, GTIN..."
            Compare-Files 
        }
    }
}
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$pathfinalcountwhole = "$HOME\Documents\All-X-Values.txt"
$pathfinalcountnoduplicates = "$HOME\Documents\NoDuplicates-X-Values.txt"
$pathsqlfinalcontent = "$HOME\Documents\SQL-X-Formated.txt"
Show-Menu -Title "Find-X/Do-X By Daniel Vazome For Detego" -Question "What would you like to accomplish?"
Write-Host 'Done! Here is you performance index:' -ForegroundColor DarkGreen -BackgroundColor White
$stopwatch
#End
