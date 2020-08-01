#2020
#Declaring fucntion to add round bracket
#^(?=.*\b08334451\b)(?=.*\bOmni\b).*$ - Find a string with these 2 keywords
using namespace System.Management.Automation.Host
Add-Type -AssemblyName System.Windows.Forms
$script:append = New-Object System.Text.StringBuilder
$script:error700 = 'ERROR 700: The aswear is out of borders'
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
        Write-Warning "No file proveded" -ErrorAction Stop
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
    $Delimiter_1 = Read-Host -Prompt 'Please provide structural delimiter (Default comma ",")'
    if ([string]::IsNullOrWhiteSpace($Delimiter_1))
    { $Delimiter_1 = ',' }
    $Delimiter_2 = Read-Host -Prompt 'And second structural delimiter (Default colon ":")'
    if ([string]::IsNullOrWhiteSpace($Delimiter_2))
    { $Delimiter_2 = ':' }
    Start-Sleep -Seconds 1
    #We have to obtain file(s) content, just in case remove "", delimit the content and select by pattern
    $script:temp1i = New-TemporaryFile
    $temp1i.FullName
    Write-Verbose 'Creating the scope'-Verbose
    $delimatch = foreach ($s in $tocount) {
        $s -split $Delimiter_1 -match $SpecifyRecord -split $Delimiter_2 -notmatch $SpecifyRecord -replace '[^A-Za-z0-9-]'
    }
    Write-Verbose 'Delimiting and matching' -Verbose
    $yesorno = Read-Host -Prompt "Remove duplicates and create an additional file (y/n)?"
    if ($yesorno -like 'y*') {
        $script:temp1o = New-TemporaryFile
        $temp1o.FullName
        Set-Content $temp1i.FullName -Value ($delimatch)
        Write-Host 'Step 2.1: Removing duplicates (unifying)'
        #Removing duplicates
        $stream = [System.IO.StreamWriter] $temp1o.FullName
        $UniqueItems = [system.collections.generic.list[string]]([System.Collections.Generic.HashSet[string]]([System.IO.File]::ReadLines($temp1i.FullName)))
        $UniqueItems.sort()
        $UniqueItems | ForEach-Object { $Stream.writeline($_) }
        $Stream.close()
        <#$script:Lines = [System.Collections.Generic.HashSet[string]]::new()
        $Lines.UnionWith([string[]][System.IO.File]::ReadLines($temp1i.FullName))
        [System.IO.File]::WriteAllLines($temp1o.FullName, $Lines)#>
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
        Remove-Item $temp1i
        exit
    }
}
<# 
function AddTheContent {
    param ( 
        [String]$pathsqlfinalcontent)
    process {
        $( , $_; Get-Content $pathsqlfinalcontent -Raw -ea SilentlyContinue) | Set-Content $pathsqlfinalcontent -Encoding UTF8
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
    $scanfilesandhuge_choice = [ChoiceDescription]::new('&Search', "Basic search, regex, deep and quick search")
    $getvalues_choice = [ChoiceDescription]::new('&Get values and X..', "Find values and do some processing, you will be asked for:`nGive a search scope,`nTo choose to remove duplicates or not,`nConvert to SQL`n")
    $convert_choice = [ChoiceDescription]::new('&Convert my list of values to SQL', "If you already have a clear list of values you can convert it to SQL`nIn the end you will have your origianl file and the one that been processed`n")
    $differentiate_choice = [ChoiceDescription]::new('&Differentiate side by side two files', "Compares side by side and shows the diffrence in values`nFor numeric values .csv is recomended`n")

    $options = [ChoiceDescription[]]($scanfilesandhuge_choice, $getvalues_choice, $convert_choice, $differentiate_choice)

    $result = $host.ui.PromptForChoice($Title, $Question, $options, 0)

    switch ($result) {
        0 {
            $script:SpecifyForBig = (Read-Host -Prompt "You can split searches by comma").Split(',') | ForEach-Object { $_.trim() }
            Find-InHuge -Patt $SpecifyForBig
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
    Show-Menu -Title "LogToolkit By Daniel Vazome" -Question "What would you like to accomplish?"
    Write-Host 'Done! Here is your statistics:' -ForegroundColor DarkGreen -BackgroundColor White
} | Select-Object @{n = "Elapsed"; e = { $_.Minutes, "Minutes", $_.Seconds, "Seconds" -join " " } }
#Justing the signature
# SIG # Begin signature block
# MIIQQgYJKoZIhvcNAQcCoIIQMzCCEC8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkuB/yaCwLpS101Zzs90FrP1L
# +HKgggu/MIIDIjCCAgqgAwIBAgIQIhim6N5c84xHH2IUyqzLwjANBgkqhkiG9w0B
# AQsFADApMScwJQYDVQQDDB5EYW5pZWwncyBTaWduYXR1cmUgQ2VydGlmaWNhdGUw
# HhcNMjAwNzMxMjMxNDM3WhcNMjEwNzMxMjMzNDM3WjApMScwJQYDVQQDDB5EYW5p
# ZWwncyBTaWduYXR1cmUgQ2VydGlmaWNhdGUwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQDcEqNw9ip5XvhnFLL9nVQQ8AOHSai/1+l4CSNFGUMfu40nPu1h
# 2SaDyobuoCOBBrjynTrLfjUjBEvZwWpJW0z1pG1sDSeyUOVl8zDL8wIvEt1kLPK2
# zQ7Kzj6oRP/yRVnzw5N3N5gA6RpQdhnbb159ntfBsD0bCXEGDYGx0HK38I6EVvJ2
# ORitPC5r9uqgy0QKGWkiDCKr4taDYpb5/sya50QsvPs4o7gjrD8KlEZRRSt18FMA
# kA3PWyXbngXOW87VzOyHXArthI89TljPXyb59uH58vmmMYUcBbAC+oHSwGgefLk+
# EnMKSA34/ttoGdqoD9WTRo9gbpAIk3z174VVAgMBAAGjRjBEMA4GA1UdDwEB/wQE
# AwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUKBNyJugnD7MdFPOb
# xzIrsjnEvhEwDQYJKoZIhvcNAQELBQADggEBAFSpQ0Zlx6OakfTeYxWGRHiUcDUs
# 00NyxxMnOF0cmK132B+7nucTzvjwJpyRmsFJotkF+t3BAFjPZPaRSj8yndpiWj7G
# iPFE2iVhCCWp4WXT2P/ubOxe9ualBSMkS4JwOZwMpbpSIONe96ChArEVyPxELqHw
# Jj3w2S2wW3FdESK63YdZsoGWw4Thqwdo/BJEfVvNyOvsOSeO+ARqAytDx5WT6cYO
# j0MLbyMhz+gk5lBq3GWSTH7PccqVZGAMvSXMLGRgyVsVGnDcr8FDPiDwwwtTXr+n
# rWDrFSh8sR3quoWWhq6qWwjm6buU3LWtpA3chPD7ZtVBgByJTyXur62oAJswggPu
# MIIDV6ADAgECAhB+k+v7fMZOWepLmnfUBvw7MA0GCSqGSIb3DQEBBQUAMIGLMQsw
# CQYDVQQGEwJaQTEVMBMGA1UECBMMV2VzdGVybiBDYXBlMRQwEgYDVQQHEwtEdXJi
# YW52aWxsZTEPMA0GA1UEChMGVGhhd3RlMR0wGwYDVQQLExRUaGF3dGUgQ2VydGlm
# aWNhdGlvbjEfMB0GA1UEAxMWVGhhd3RlIFRpbWVzdGFtcGluZyBDQTAeFw0xMjEy
# MjEwMDAwMDBaFw0yMDEyMzAyMzU5NTlaMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQK
# ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBT
# dGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEAsayzSVRLlxwSCtgleZEiVypv3LgmxENza8K/LlBa+xTCdo5DASVD
# tKHiRfTot3vDdMwi17SUAAL3Te2/tLdEJGvNX0U70UTOQxJzF4KLabQry5kerHIb
# Jk1xH7Ex3ftRYQJTpqr1SSwFeEWlL4nO55nn/oziVz89xpLcSvh7M+R5CvvwdYhB
# nP/FA1GZqtdsn5Nph2Upg4XCYBTEyMk7FNrAgfAfDXTekiKryvf7dHwn5vdKG3+n
# w54trorqpuaqJxZ9YfeYcRG84lChS+Vd+uUOpyyfqmUg09iW6Mh8pU5IRP8Z4kQH
# kgvXaISAXWp4ZEXNYEZ+VMETfMV58cnBcQIDAQABo4H6MIH3MB0GA1UdDgQWBBRf
# mvVuXMzMdJrU3X3vP9vsTIAu3TAyBggrBgEFBQcBAQQmMCQwIgYIKwYBBQUHMAGG
# Fmh0dHA6Ly9vY3NwLnRoYXd0ZS5jb20wEgYDVR0TAQH/BAgwBgEB/wIBADA/BgNV
# HR8EODA2MDSgMqAwhi5odHRwOi8vY3JsLnRoYXd0ZS5jb20vVGhhd3RlVGltZXN0
# YW1waW5nQ0EuY3JsMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQEAwIB
# BjAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMTANBgkq
# hkiG9w0BAQUFAAOBgQADCZuPee9/WTCq72i1+uMJHbtPggZdN1+mUp8WjeockglE
# bvVt61h8MOj5aY0jcwsSb0eprjkR+Cqxm7Aaw47rWZYArc4MTbLQMaYIXCp6/OJ6
# HVdMqGUY6XlAYiWWbsfHN2qDIQiOQerd2Vc/HXdJhyoWBl6mOGoiEqNRGYN+tjCC
# BKMwggOLoAMCAQICEA7P9DjI/r81bgTYapgbGlAwDQYJKoZIhvcNAQEFBQAwXjEL
# MAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYD
# VQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENBIC0gRzIwHhcN
# MTIxMDE4MDAwMDAwWhcNMjAxMjI5MjM1OTU5WjBiMQswCQYDVQQGEwJVUzEdMBsG
# A1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xNDAyBgNVBAMTK1N5bWFudGVjIFRp
# bWUgU3RhbXBpbmcgU2VydmljZXMgU2lnbmVyIC0gRzQwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCiYws5RLi7I6dESbsO/6HwYQpTk7CY260sD0rFbv+G
# PFNVDxXOBD8r/amWltm+YXkLW8lMhnbl4ENLIpXuwitDwZ/YaLSOQE/uhTi5EcUj
# 8mRY8BUyb05Xoa6IpALXKh7NS+HdY9UXiTJbsF6ZWqidKFAOF+6W22E7RVEdzxJW
# C5JH/Kuu9mY9R6xwcueS51/NELnEg2SUGb0lgOHo0iKl0LoCeqF3k1tlw+4XdLxB
# hircCEyMkoyRLZ53RB9o1qh0d9sOWzKLVoszvdljyEmdOsXF6jML0vGjG/SLvtmz
# V4s73gSneiKyJK4ux3DFvk6DJgj7C72pT5kI4RAocqrNAgMBAAGjggFXMIIBUzAM
# BgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMA4GA1UdDwEB/wQE
# AwIHgDBzBggrBgEFBQcBAQRnMGUwKgYIKwYBBQUHMAGGHmh0dHA6Ly90cy1vY3Nw
# LndzLnN5bWFudGVjLmNvbTA3BggrBgEFBQcwAoYraHR0cDovL3RzLWFpYS53cy5z
# eW1hbnRlYy5jb20vdHNzLWNhLWcyLmNlcjA8BgNVHR8ENTAzMDGgL6AthitodHRw
# Oi8vdHMtY3JsLndzLnN5bWFudGVjLmNvbS90c3MtY2EtZzIuY3JsMCgGA1UdEQQh
# MB+kHTAbMRkwFwYDVQQDExBUaW1lU3RhbXAtMjA0OC0yMB0GA1UdDgQWBBRGxmmj
# DkoUHtVM2lJjFz9eNrwN5jAfBgNVHSMEGDAWgBRfmvVuXMzMdJrU3X3vP9vsTIAu
# 3TANBgkqhkiG9w0BAQUFAAOCAQEAeDu0kSoATPCPYjA3eKOEJwdvGLLeJdyg1JQD
# qoZOJZ+aQAMc3c7jecshaAbatjK0bb/0LCZjM+RJZG0N5sNnDvcFpDVsfIkWxumy
# 37Lp3SDGcQ/NlXTctlzevTcfQ3jmeLXNKAQgo6rxS8SIKZEOgNER/N1cdm5PXg5F
# RkFuDbDqOJqxOtoJcRD8HHm0gHusafT9nLYMFivxf1sJPZtb4hbKE4FtAC44Dagp
# jyzhsvRaqQGvFZwsL0kb2yK7w/54lFHDhrGCiF3wPbRRoXkzKy57udwgCRNx62oZ
# W8/opTBXLIlJP7nPf8m/PiJoY1OavWl0rMUdPH+S4MO8HNgEdTGCA+0wggPpAgEB
# MD0wKTEnMCUGA1UEAwweRGFuaWVsJ3MgU2lnbmF0dXJlIENlcnRpZmljYXRlAhAi
# GKbo3lzzjEcfYhTKrMvCMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKAC
# gAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsx
# DjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRmOm9vt5Pf7G4oyQDy5Vni
# Qv4UHDANBgkqhkiG9w0BAQEFAASCAQDMF8e3WjYWg7fJTgRhrLhemgyVkpMmXVe2
# sKrUt3Id/M8/UoVRagTKwgMS7RjLVQW8XzDBSzb+tJKrWd/EZBVGShjcLHOoijpb
# idixDCkVsE+3SzgXjMtWnk4Maan9qpQ0f6Da45d/qzC9O3/EZZOapgyv3PnL+L7p
# /7ThutujkRJx4IUGBkY5kWkf1wr7u8JCFtzCGB+thRvOtwDy9typYmd+6t9UiOgg
# 3RaPa4eoOYq2D0I74L5rNy4nhM1salx0cnlt0Qmo/X+gQECEG2I8R55d1GQJw7XU
# YfLp+9+nQJCdqj3G2Z8pU8yS1Y7NmJ/PetdspJJWO+BZ8AvmeKz1oYICCzCCAgcG
# CSqGSIb3DQEJBjGCAfgwggH0AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoT
# FFN5bWFudGVjIENvcnBvcmF0aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0
# YW1waW5nIFNlcnZpY2VzIENBIC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4D
# AhoFAKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8X
# DTIwMDczMTIzMjQ0OVowIwYJKoZIhvcNAQkEMRYEFC4CMgZBZWrXUt9pIoXGSPPx
# nVrOMA0GCSqGSIb3DQEBAQUABIIBAHpyanbssfm3kQWBGQN0evsXofNTomAyJlz3
# xbLLxIt1wsgr8wRQ9Y43PcjLrfiiN77LnDIpo2TUeWHVRlG0B+yjLeY6Y6tNZEfu
# 8bCPG3HBcyNSXygA3o5kXhWpb1zZ+ufXHTFuqdPMxMKVwMDwRiVvE5Kbdfu1PnXT
# daaypP5BdB5BMYFTZApwA6z0YX03mwZaDjiTAf1szwyJQvSb7ZlPzafQ+B91s4Xo
# O3hWIzvMqfN/hhXCR2gUS4MxkgpNLx6WABzQ4Ybr9RiVio4EyJpbSA9bEiG4gPqO
# 6rCi5WpwqmqJVzpY+/GEYn9+A090A6tG+Z0QYri60vH81ahaLbA=
# SIG # End signature block
