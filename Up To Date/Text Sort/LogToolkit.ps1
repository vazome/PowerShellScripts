#2020
#Declaring fucntion to add round bracket
#^(?=.*\b08334451\b)(?=.*\bOmni\b).*$ - Find a string with these 2 keywords
using namespace System.Management.Automation.Host
Add-Type -AssemblyName System.Windows.Forms
function Show-Dialog {
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $FileBrowser.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory()
    $FileBrowser.Filter = 'All files (*.*)| *.*'
    $FileBrowser.Title = 'Select file to process'
    $importresult = $FileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
    $importresult
    if ($importresult -eq "OK"){      
        $script:tocount = [System.IO.File]::ReadLines($FileBrowser.FileName)

    }
    else {
        Write-Warning "No file proveded"
    }
}

function Get-Values {
    #Let's ask for current search scope
    Write-Host "Please specify file(s) location" -ForegroundColor Black -BackgroundColor DarkYellow
    Show-Dialog
    $SpecifyMethodRecord = (Read-Host -Prompt "Would you like to specify method name or log type name? Press Enter if No").Split(',') | ForEach-Object { $_.trim() }
    $SpecifyRecord = (Read-Host -Prompt 'What record are you looking for (if multiple separate them by comma)').split(',') | ForEach-Object { $_.trim() }
    $Delimiter_1 = Read-Host -Prompt 'Please provide structural delimiter for example comma "," or colon ":"'
    $Delimiter_2 = Read-Host -Prompt 'And second structural delimiter for example comma "," or colon ":"'
    Start-Sleep -Seconds 1
    #We have to obtain file(s) content, just in case remove "", delimit the content and select by pattern
    $tempfile = New-TemporaryFile
    $tempfile.FullName
    Write-Host 'Step 1: Creating the scope'
    if (-not ([string]::IsNullOrEmpty($SpecifyMethodRecord))) {
        $methodmatch = $tocount | Select-String $SpecifyMethodRecord
        $methodmatch | Set-Content $tempfile.FullName -Encoding UTF8
        $tocount = [System.IO.File]::ReadLines($tempfile.FullName)
    }
    $delimatch = foreach ($s in $tocount) {
        $s -split $Delimiter_1 -match $SpecifyRecord -split $Delimiter_2 -notmatch $SpecifyRecord -replace '[^A-Za-z0-9-]'
    }
    Set-Content $pathfinalcountwhole -Value ($delimatch) -Encoding UTF8
    Write-Host 'Step 2: Delimiting and matching'
    Remove-Item $tempfile.FullName -Force
    Do {
        $yesorno = Read-Host -Prompt "Remove duplicates and create an additional file (y/n)?"
        if ($yesorno -like 'y*') {
            Write-Host 'Step 2.1: Removing duplicates (unifying)'
            #Removing duplicates
            $Lines = [System.Collections.Generic.HashSet[string]]::new()
            $Lines.UnionWith([string[]][System.IO.File]::ReadLines($pathfinalcountwhole))
            $Lines | Set-Content $pathfinalcountnoduplicates -Encoding UTF8
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
        $( , $_; Get-Content $pathsqlfinalcontent -Raw -ea SilentlyContinue) | Set-Content $pathsqlfinalcontent -Encoding UTF8
    }
}
#Declaring fucntion that converts to SQL
function Convert-SQL () {
    Write-Host 'Step 3: Converting to SQL'
    Do {
        if ([string]::IsNullOrEmpty($specifolder)) {
            $yesorno = Read-Host -Prompt "Would you like convert this to SQL query format (y/n)?"
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
            $outputstring | Set-Content $tempfile2.FullName -Encoding UTF8
            Write-Host 'Step 4: Trimming'
            $removelast = Get-Content $tempfile2.FullName
            for ($i = $removelast.count; $i -ge 0; $i--) {
                if ($removelast[$i] -match ",") { $removelast[$i] = $removelast[$i] -replace ","; break }
            }
            $removelast | Set-Content $pathsqlfinalcontent -Encoding UTF8
            Write-Host 'Step 5: brackets'
            #An another way to add "("
            #"(" | AddTheContent $pathsqlfinalcontent
            $plusbracket = "(" + (Get-Content $pathsqlfinalcontent -Raw)
            $plusbracket.Split('', [System.StringSplitOptions]::RemoveEmptyEntries) | Set-Content $pathsqlfinalcontent -Encoding UTF8
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
    
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.filter = "Text Files (*.txt)|*.txt|CSV Files (*.csv)|*.csv"
    $dialog.InitialDirectory = "$HOME\Documents"
    $result = $dialog.ShowDialog()    
    $result 
    if($result -eq 'OK') { 
        $compared | Set-Content $dialog.FileName -Encoding UTF8
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
Measure-Command -Expression {
$script:pathfinalcountwhole = "$HOME\Documents\All-Values.txt"
$script:pathfinalcountnoduplicates = "$HOME\Documents\NoDuplicates-Values.txt"
$script:pathsqlfinalcontent = "$HOME\Documents\SQL-Formated.txt"
Show-Menu -Title "Find-X/Do-X By Daniel Vazome For Detego" -Question "What would you like to accomplish?"
Write-Host 'Done! Here is you performance statistics:' -ForegroundColor DarkGreen -BackgroundColor White
} | Select-Object @{n = "Elapsed"; e = { $_.Minutes, "Minutes", $_.Seconds, "Seconds" -join " " } }
