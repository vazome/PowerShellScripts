#Copyright (c) 2020 Daniel Vazome
#MIT Lincence 
#IMPORTANT
<#
This tool was created to simplify the overal workflow and daily life of me and my coworkers
Unfortunately the abilities of this tool are limited by some servers that DO NOT have up to date verion of PowerShell (Stable 5.1 or CrossPlatform .NET Core 7.0.3)
This will resolve after initial upgrade to at least Windows Server 2016
Because of that script was made in more universal way and somewhere has archaic fashioned code
#>
#IMPORTANT END

Add-Type -AssemblyName System.Windows.Forms #Adding .NET namespace of WinForms to have ability to save with GUI
$script:append = New-Object System.Text.StringBuilder #Adding .NET namespace to have another ways to read/write
$script:error700 = 'ERROR 700: The answer is out of borders'
$script:error100 = 'ERROR 500: No file selected'
#Special thanks to Boe Prox (proxb) for notification system
Function Invoke-BalloonTip {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True, HelpMessage = "The message text to display. Keep it short and simple.")]
        [string]$Message,
  
        [Parameter(HelpMessage = "The message title")]
        [string]$Title = "Attention $env:username",
  
        [Parameter(HelpMessage = "The message type: Info,Error,Warning,None")]
        [System.Windows.Forms.ToolTipIcon]$MessageType,
     
        [Parameter(HelpMessage = "The path to a file to use its icon in the system tray")]
        [string]$SysTrayIconPath = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',     
  
        [Parameter(HelpMessage = "The number of milliseconds to display the message.")]
        [int]$Duration = 2000
    )

    If (-NOT $global:balloon) {
        $global:balloon = New-Object System.Windows.Forms.NotifyIcon
  
        #Mouse double click on icon to dispose
        [void](Register-ObjectEvent -InputObject $balloon -EventName MouseDoubleClick -SourceIdentifier IconClicked -Action {
                #Perform cleanup actions on balloon tip
                Write-Verbose 'Disposing of balloon'
                $global:balloon.dispose()
                Unregister-Event -SourceIdentifier IconClicked
                Remove-Job -Name IconClicked
                Remove-Variable -Name balloon -Scope Global
            })
    }
  
    #Need an icon for the tray
    $path = Get-Process -id $pid | Select-Object -ExpandProperty Path
  
    #Extract the icon from the file
    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($SysTrayIconPath)
  
    #Can only use certain TipIcons: [System.Windows.Forms.ToolTipIcon] | Get-Member -Static -Type Property
    $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]$MessageType
    $balloon.BalloonTipText = $Message
    $balloon.BalloonTipTitle = $Title
    $balloon.Visible = $true
  
    #Display the tip and specify in milliseconds on how long balloon will stay visible
    $balloon.ShowBalloonTip($Duration)
  
    Write-Verbose "Ending function"
  
}
#NOTIFICATION REMIDERS
#Invoke-BalloonTip -Message 'An error occured' -Title 'Error' -MessageType 'Error'
#Invoke-BalloonTip -Message 'Out of logic' -Title 'Warning' -MessageType 'Warning'
#Invoke-BalloonTip -Message 'Step Done' -Title 'Information' -MessageType 'Info'
function Select-OneFile {
    #GUI SELECT ONE FILE
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $FileBrowser.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory() # Get current directory where UI selection window will present
    $FileBrowser.Filter = 'All files (*.*)| *.*' #Specify multiple 
    $FileBrowser.Title = 'Select file to process' #One file to choose (actually you can do multiple but another way "function Select-MultipleFiles" already in presence)
    $importresult = $FileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
    $importresult # Lauching variable to get output at work
    if ($importresult -eq "OK") {      
        $script:tocount = [System.IO.File]::ReadAllLines($FileBrowser.FileName)
        $script:onefilelocation = $FileBrowser.FileName

    }
    else {
        Write-Error -Message $error100
        Invoke-BalloonTip -Message 'File selection error occured' -Title 'Error' -MessageType 'Error'
    }
}
function Select-MultipleFiles {
    #GUI SELECT MULTIPLE FILES
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ #a way to specify methods by a hash table
        Multiselect      = $true # Multiple files can be chosen
        Filter           = 'All files (*.*)| *.*' # Specified file types
        Title            = 'Select files to process'
        InitialDirectory = [System.IO.Directory]::GetCurrentDirectory() #Gets current directory
    }
    [void]$FileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
    $script:PathMultipleFiles = $FileBrowser.FileNames
}
function Save-To {
    #GUI File Saving
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $ExpresionFunction
    )
    $Dialog = New-Object System.Windows.Forms.SaveFileDialog
    $Dialog.filter = "Text Files (*.txt)|*.txt"
    $Dialog.InitialDirectory = "$HOME\Documents"
    $Result = $Dialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))    
    $script:SaveToPath = $Dialog.FileName
    if ($Result -eq 'OK') { 
        Set-Content $Dialog.FileName -Value ($ExpresionFunction)
    }
    else {
        Write-Error -Message $error100
        Invoke-BalloonTip -Message 'File selection error occured' -Title 'Error' -MessageType 'Error'
        exit
    } 
}
function Find-InHuge {
    #No parameters specified to allow multiple patterns by comma
    $script:PatternFirst = (Read-Host -Prompt 'Provide first scope (e.g. method) or just press [ENTER]').Split(',') | ForEach-Object { $_.trim() }
    $script:PatternLast = (Read-Host -Prompt 'You can split patterns by comma').Split(',') | ForEach-Object { $_.trim() }
    if (-not [string]::IsNullOrWhiteSpace($PatternFirst)) {
        $script:tempfindinhuge = [IO.Path]::GetTempFileName()
        $tempfindinhuge
        $patternfirstsearch = Select-String -Pattern $PatternFirst -Path $PathMultipleFiles
        Set-Content $tempfindinhuge -value ($patternfirstsearch)
        $script:hugelogsearchfinal = Select-String -Pattern $PatternLast -Path $tempfindinhuge | Select-Object -ExpandProperty Line
        Invoke-BalloonTip -Message 'Scope + Pattern: Done' -Title 'Information' -MessageType 'Info'
    }
    elseif ([string]::IsNullOrWhiteSpace($PatternFirst)) {
        $script:hugelogsearchfinal = Select-String -Pattern $PatternLast -Path $PathMultipleFiles
        Invoke-BalloonTip -Message 'Pattern: Done' -Title 'Information' -MessageType 'Info'
    } 
    else {
        Invoke-BalloonTip -Message 'Step Done' -Title 'Information' -MessageType 'Info'
    }
    
}

function Get-Values {
    $options = [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::CultureInvariant #We don't care about searched word's case and ignoring culture
    $searchformethod = (Read-Host -Prompt 'Provide first scope (e.g. method) or just press [ENTER]').Split(',') | ForEach-Object { $_.trim() }
    $searchforvalue = Read-Host -Prompt 'Specify a value type you are looking for'
    $yesorno = Read-Host -Prompt "Remove duplicates and create an additional file (y/n)?"
    #https://regexr.com/59s8q - The visualization of this regex
    $regex = '(?<="' + [regex]::Escape($searchforvalue) + '":"|"' + [regex]::Escape($searchforvalue) + '\\":\\")[^\\"]+' #WE DO REGEX SEARCH
    if (-not [string]::IsNullOrWhiteSpace($searchformethod)) {
        $script:temp1nomethod = [IO.Path]::GetTempFileName()
        $temp1nomethod
        Set-Content -Path $temp1nomethod -Value (Select-String -Pattern $searchformethod -Path $onefilelocation)
        $tocount = [System.IO.File]::ReadAllLines($temp1nomethod)
        $script:regexsearch = [regex]::Matches($tocount, $regex, $options) #Pointing to: text extraction variable, regex formula, search option
    }
    elseif ([string]::IsNullOrWhiteSpace($searchformethod)) {
        $script:regexsearch = [regex]::Matches($tocount, $regex, $options) #Pointing to: text extraction variable, regex formula, search option
    }
    else {
        $error100
        Invoke-BalloonTip -Message 'An error occured' -Title 'Error' -MessageType 'Error'
    }
    #Start-Sleep -Seconds 1 #A pause to give our brain keep up with the cold-blooded machine
    Write-Verbose 'IN PROGRESS'-Verbose
    if ($yesorno -like 'y*') {
        $script:temp1o = [IO.Path]::GetTempFileName()
        $temp1o
        Save-To $regexsearch.value
        if (-not [string]::IsNullOrWhiteSpace($searchformethod)) {
            Remove-Item $temp1nomethod
        }
        Write-Host 'REMOVING DUPLICATES'
        $sortedunique = $regexsearch.value | Sort-Object | Get-Unique #Removing duplicates
        Set-Content -Path $temp1o -Value ($sortedunique)
        Invoke-BalloonTip -Message 'Step Done' -Title 'Information' -MessageType 'Info'
        $script:sqlyesorno = Read-Host -Prompt "Would you like convert this to SQL query format (y/n)?"
        if ($sqlyesorno -like 'y*') {
            $script:getforsql = [System.IO.File]::ReadAllLines($temp1o)
            Convert-SQL
        }
        elseif ($sqlyesorno -like 'n*') {
            $script:Lines = [System.IO.File]::ReadAllLines($temp1o)
            Save-To $Lines
            Remove-Item $temp1o -Force
        }
        else {
            Write-Error -Message $error700 -Category SyntaxError
            Invoke-BalloonTip -Message 'Out of logic' -Title 'Warning' -MessageType 'Warning'
            Start-Sleep 2
            $script:Lines = [System.IO.File]::ReadAllLines($temp1o)
            Save-To $Lines
            Remove-Item $temp1o -Force
        }
    }
    elseif ($yesorno -like 'n*') {
        Write-Verbose 'Provided with "No"' -Verbose
        Save-To $regexsearch.value
        exit
    }

    else {
        Write-Error -Message $error700
        Invoke-BalloonTip -Message 'Out of logic' -Title 'Warning' -MessageType 'Warning'
        exit
    }
}
function Convert-SQL {
    foreach ($i in $getforsql) {
        $null = $append.AppendLine("'$i',")
    }
    $script:temp2i = [IO.Path]::GetTempFileName()
    $temp2i
    $script:temp2o = [IO.Path]::GetTempFileName()
    $temp2o
    $outputstring = $append.ToString()
    Set-Content $temp2i -Value ($outputstring) -Encoding UTF8
    Write-Verbose 'Trimming step' -Verbose
    $removelast = Get-Content $temp2i
    for ($i = $removelast.count; $i -ge 0; $i--) {
        if ($removelast[$i] -match ",") { $removelast[$i] = $removelast[$i] -replace ","; break }
    }
    Set-Content $temp2o -Value ($removelast) -Encoding UTF8
    Write-Verbose 'Brackets step' -Verbose
    #An another way to add "("
    #"(" | AddTheContent  $temp2o
    $plusbracket = "(" + (Get-Content $temp2o -Raw)
    $plusbracket.Split('', [System.StringSplitOptions]::RemoveEmptyEntries) | Set-Content  $temp2o -Encoding UTF8
    Add-Content $temp2o -Value ")" 
    $readbracket = [System.IO.File]::ReadAllLines($temp2o)
    Save-To $readbracket
    Remove-Item $temp2i, $temp2o
}

function Compare-Files {
    $script:temp3 = [IO.Path]::GetTempFileName()
    $temp3
    $Refr = $Refr -replace '^"(.*)"$', '$1'
    $Difr = $Difr -replace '^"(.*)"$', '$1'
    $Propr = $Propr -replace '^"(.*)"$', '$1'
    (Compare-Object -ReferenceObject (Import-Csv $Refr) -DifferenceObject (Import-Csv $Difr) -Property $Propr -PassThru |
        ForEach-Object {
            $_.SideIndicator = $_.SideIndicator -replace '=>', 'Only in Difference file' -replace '<=', 'Only in Reference file'
            $_
        }) > $temp3
    $script:compared = [System.IO.File]::ReadAllLines($temp3)
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
    $scanfilesandhuge_choice = [System.Management.Automation.Host.ChoiceDescription]::new('&Search', "Basic search, regex, deep and quick search")
    $getvalues_choice = [System.Management.Automation.Host.ChoiceDescription]::new('&Get values and X..', "Find values and do some processing, you will be asked for:`nGive a search scope,`nTo choose to remove duplicates or not,`nConvert to SQL`n")
    $convert_choice = [System.Management.Automation.Host.ChoiceDescription]::new('&Convert my list of values to SQL', "If you already have a clear list of values you can convert it to SQL`nIn the end you will have your origianl file and the one that been processed`n")
    $differentiate_choice = [System.Management.Automation.Host.ChoiceDescription]::new('&Differentiate side by side two files', "Compares side by side and shows the diffrence in values`nFor numeric values .csv is recomended`n")
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($scanfilesandhuge_choice, $getvalues_choice, $convert_choice, $differentiate_choice)

    $result = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    switch ($result) {
        0 {
            Select-MultipleFiles
            Find-InHuge -PatternFirst $SpecifyFirstPattern -PatternLast $SpecifyLastPattern
            Save-To -ExpresionFunction $hugelogsearchfinal
        }
        1 {
            Select-OneFile
            Get-Values
        }
        2 {
            Select-OneFile
            $script:getforsql = [System.IO.File]::ReadAllLines($onefilelocation)
            Convert-SQL
        }
        3 {
            #MULTICHOICE TO DO
            Write-Warning -Message "Only .CSVs with headers are currently supported for this operation"
            Select-OneFile
            $Refr = Read-Host -Prompt "Reference file"
            $Difr = Read-Host -Prompt "Difference file"
            $Propr = Read-Host -Prompt "Specify header name to compare like Id, SKU, GTIN..."
            Compare-Files 
            Save-To $compared
            Remove-Item $temp3
        }

    }
}
Measure-Command -Expression {
    $script:pathfinalcountwhole = "$HOME\Documents\All-Values.txt"
    $script:pathfinalcountnoduplicates = "$HOME\Documents\NoDuplicates-Values.txt"
    $script:pathsqlfinalcontent = "$HOME\Documents\SQL-Formated.txt"
    Show-Menu -Title "LogToolkit 1.0" -Question "What would you like to accomplish?"
    Write-Host 'Done! Here is your statistics:' -ForegroundColor DarkGreen -BackgroundColor White
} | Select-Object @{n = "Elapsed"; e = { $_.Minutes, "Minutes", $_.Seconds, "Seconds" -join " " } }

<# AN ANOTHER WAY TO ADD A BRACKET
function AddTheContent {
    param ( 
        [String]$pathsqlfinalcontent)
    process {
        $( , $_
        Get-Content $pathsqlfinalcontent -Raw -ea SilentlyContinue) | Set-Content $pathsqlfinalcontent -Encoding UTF8
    }
}
#>

<# REMOVING DUPLICATES BY HASHSET AND UNION
$script:Lines = [System.Collections.Generic.HashSet[string]]::new()
$Lines.UnionWith([string[]][System.IO.File]::ReadAllLines($temp1i))
[System.IO.File]::WriteAllLines($temp1o, $Lines)
#>
