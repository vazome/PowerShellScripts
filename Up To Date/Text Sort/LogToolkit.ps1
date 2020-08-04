#Daniel Vazome 2020
#Declaring fucntion to add round bracket
#^(?=.*\b08334451\b)(?=.*\bOmni\b).*$ - Find a string with these 2 keywords
Add-Type -AssemblyName System.Windows.Forms
$script:append = New-Object System.Text.StringBuilder
$script:error700 = 'ERROR 700: The answear is out of borders'
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
  
}#GitHub

#Invoke-BalloonTip -Message 'An error occured' -Title 'Error' -MessageType 'Error'
#Invoke-BalloonTip -Message 'Out of logic' -Title 'Warning' -MessageType 'Warning'
#Invoke-BalloonTip -Message 'Step Done' -Title 'Information' -MessageType 'Info'
function Show-Dialog {
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $FileBrowser.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory() # Get current directory where UI selection window will present
    $FileBrowser.Filter = 'All files (*.*)| *.*' #Specify multiple 
    $FileBrowser.Title = 'Select file to process' #One file to choose (actually you can do multiple but another way "function Select-MultipleFiles" already in presence)
    $importresult = $FileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
    $importresult # Lauching variable to get output at work
    if ($importresult -eq "OK") {      
        $script:tocount = [System.IO.File]::ReadLines($FileBrowser.FileName)
        $script:topatchdialog = $FileBrowser.FileName

    }
    else {
        Write-Error -Message $error100
        Invoke-BalloonTip -Message 'An error occured' -Title 'Error' -MessageType 'Error'
    }
}
function Select-MultipleFiles {
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ #a way to specify methods by a hash table
        Multiselect      = $true # Multiple files can be chosen
        Filter           = 'All files (*.*)| *.*' # Specified file types
        Title            = 'Select files to process'
        InitialDirectory = [System.IO.Directory]::GetCurrentDirectory()
    }
    [void]$FileBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
    $script:Path = $FileBrowser.FileNames
}
function Save-To {
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
        Write-Host "File Save Dialog Cancelled!" -ForegroundColor Yellow
        Invoke-BalloonTip -Message 'An error occured' -Title 'Error' -MessageType 'Error'
        exit
    } 
}
function Find-InHuge {
    param (
        [Parameter(Mandatory)]
        $Patt
    )
    Select-MultipleFiles
    $script:ExpresionFunction = Select-String -Pattern $Patt -Path $Path
}

function Get-Values {
    #Let's ask for current search scope
    Write-Host "Please specify file(s) location" -ForegroundColor Black -BackgroundColor DarkYellow
    Show-Dialog
    $SpecifyRecord = (Read-Host -Prompt 'What record are you looking for (if multiple separate them by comma)').split(',') | ForEach-Object { $_.trim() }
    $Delimiter_1 = Read-Host -Prompt 'Please provide structural delimiter (Press [Enter] for comma ",")'
    if ([string]::IsNullOrWhiteSpace($Delimiter_1))
    { $Delimiter_1 = ',' }
    $Delimiter_2 = Read-Host -Prompt 'And second structural delimiter (Press [Enter] for colon ":")'
    if ([string]::IsNullOrWhiteSpace($Delimiter_2))
    { $Delimiter_2 = ':' }
    Start-Sleep -Seconds 1
    #We have to obtain file(s) content, just in case remove "", delimit the content and select by pattern
    $script:temp1i = New-TemporaryFile
    $temp1i.FullName
    Write-Verbose 'IN PROGRESS'-Verbose
    $delimatch = foreach ($s in $tocount) {
        $s -split $Delimiter_1 -match $SpecifyRecord -split $Delimiter_2 -notmatch $SpecifyRecord -replace '[^A-Za-z0-9-]'
    }
    $yesorno = Read-Host -Prompt "Remove duplicates and create an additional file (y/n)?"
    if ($yesorno -like 'y*') {
        $script:temp1o = New-TemporaryFile
        $temp1o.FullName
        Set-Content $temp1i.FullName -Value ($delimatch)
        Write-Host 'REMOVING DUPLICATES'
        #Removing duplicates
        $stream = [System.IO.StreamWriter] $temp1o.FullName
        $UniqueItems = [system.collections.generic.list[string]]([System.Collections.Generic.HashSet[string]]([System.IO.File]::ReadLines($temp1i.FullName)))
        $UniqueItems.sort()
        $UniqueItems | ForEach-Object { $Stream.writeline($_) }
        $Stream.close()
        <#$script:Lines = [System.Collections.Generic.HashSet[string]]::new()
        $Lines.UnionWith([string[]][System.IO.File]::ReadLines($temp1i.FullName))
        [System.IO.File]::WriteAllLines($temp1o.FullName, $Lines)#>
        Invoke-BalloonTip -Message 'Step Done' -Title 'Information' -MessageType 'Info'
        $script:sqlyesorno = Read-Host -Prompt "Would you like convert this to SQL query format (y/n)?"
        if ($sqlyesorno -like 'y*') {
            $script:getforsql = [System.IO.File]::ReadLines($temp1o.FullName)
            Convert-SQL
        }
        elseif ($sqlyesorno -like 'n*') {
            $script:Lines = [System.IO.File]::ReadAllLines($temp1o.FullName)
            Save-To $Lines
        }
        else {
            Write-Error -Message $error700 -Category SyntaxError
            Invoke-BalloonTip -Message 'Out of logic' -Title 'Warning' -MessageType 'Warning'
            Start-Sleep 2
            $script:Lines = [System.IO.File]::ReadAllLines($temp1o.FullName)
            Save-To $Lines
            
        }
        Remove-Item $temp1i, $temp1o
    }
    elseif ($yesorno -like 'n*') {
        Write-Verbose 'Provided with "No"' -Verbose
        Save-To $delimatch
        Remove-Item $temp1i
        exit
    }
    else {
        Write-Error -Message $error700
        Invoke-BalloonTip -Message 'Out of logic' -Title 'Warning' -MessageType 'Warning'
        Remove-Item $temp1i
        exit
    }
}
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
function Convert-SQL {
    foreach ($i in $getforsql) {
        $null = $append.AppendLine("'$i',")
    }
    $script:temp2i = New-TemporaryFile
    $temp2i.FullName
    $script:temp2o = New-TemporaryFile
    $temp2o.FullName
    $outputstring = $append.ToString()
    Set-Content $temp2i.FullName -Value ($outputstring) -Encoding UTF8
    Write-Verbose 'Trimming step' -Verbose
    $removelast = Get-Content $temp2i.FullName
    for ($i = $removelast.count; $i -ge 0; $i--) {
        if ($removelast[$i] -match ",") { $removelast[$i] = $removelast[$i] -replace ","; break }
    }
    Set-Content $temp2o.FullName -Value ($removelast) -Encoding UTF8
    Write-Verbose 'Brackets step' -Verbose
    #An another way to add "("
    #"(" | AddTheContent  $temp2o.FullName
    $plusbracket = "(" + (Get-Content $temp2o.FullName -Raw)
    $plusbracket.Split('', [System.StringSplitOptions]::RemoveEmptyEntries) | Set-Content  $temp2o.FullName -Encoding UTF8
    Add-Content $temp2o.FullName -Value ")" 
    $readbracket = [System.IO.File]::ReadAllLines($temp2o.FullName)
    Save-To $readbracket
    Remove-Item $temp2i, $temp2o
}

function Compare-Files {
    $script:temp3 = New-TemporaryFile
    $temp3.FullName
    $Refr = $Refr -replace '^"(.*)"$', '$1'
    $Difr = $Difr -replace '^"(.*)"$', '$1'
    $Propr = $Propr -replace '^"(.*)"$', '$1'
    (Compare-Object -ReferenceObject (Import-Csv $Refr) -DifferenceObject (Import-Csv $Difr) -Property $Propr -PassThru |
        ForEach-Object {
            $_.SideIndicator = $_.SideIndicator -replace '=>', 'Only in Difference file' -replace '<=', 'Only in Reference file'
            $_
        }) > $temp3.FullName
    $script:compared = [System.IO.File]::ReadAllLines($temp3.FullName)
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
            $script:SpecifyForBig = (Read-Host -Prompt "You can split searches by comma").Split(',') | ForEach-Object { $_.trim() }
            Find-InHuge -Patt $SpecifyForBig
            Invoke-BalloonTip -Message 'Step Done' -Title 'Information' -MessageType 'Info'
            Save-To $ExpresionFunction
        }
        1 {
            Get-Values
        }
        2 {
            Show-Dialog
            $script:getforsql = [System.IO.File]::ReadLines($topatchdialog)
            Convert-SQL
        }
        3 {
            #MULTICHOICE TO DO
            Write-Warning -Message "Only .CSVs with headers are currently supported for this operation"
            Show-Dialog
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
    Show-Menu -Title "LogToolkit 0.9" -Question "What would you like to accomplish?"
    Write-Host 'Done! Here is your statistics:' -ForegroundColor DarkGreen -BackgroundColor White
} | Select-Object @{n = "Elapsed"; e = { $_.Minutes, "Minutes", $_.Seconds, "Seconds" -join " " } }
