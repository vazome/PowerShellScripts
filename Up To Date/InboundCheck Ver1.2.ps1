#InboundCheck is a tool written in PowerShell by @Daniel Vazome from the Support Team for internal usage
#This is a version of this tool but without interanal secrets and connection strigs.
#Edited for GitHub Upload -  is a sign that I modified this string to make script more faceless 
#Import of ancient UI sorry about not using WPF
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Write-Host "Up to date documentation available here:`nhttps://" -ForegroundColor Green #Edited for GitHub Upload
function Test-SqlConnection {
    param(
        [Parameter(Mandatory)]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [Security.SecureString]$PasswordForSQlTest
    )


    $ErrorActionPreference = 'Stop'

    try {
        $Username = 'user' #Edited for GitHub Upload
        $password = (New-Object PSCredential "userDummy", $PasswordForSQlTest).GetNetworkCredential().Password
        $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$Username,$password #Edited for GitHub Upload
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
        $sqlConnection.Open()
        ## This will run if the Open() method does not throw an exception
        $true
        write-host "Authentification is successful"
      
    } catch {
        $false
        write-host "Authentification failed, you will be prompted again"
    } finally {
        ## Close the connection when we're done
        $sqlConnection.Close()
    }
} 
do {
    $script:Pwd = read-host -AsSecureString -Prompt "#Edited for GitHub Upload" #Edited for GitHub Upload
    $PasswordConditionTest = Test-SqlConnection -ServerName '#Edited for GitHub Upload' -DatabaseName '#Edited for GitHub Upload' -PasswordForSQlTest $Pwd #Edited for GitHub Upload
    $PasswordConditionTest
    Start-Sleep -Seconds 2
} until ($PasswordConditionTest -eq $true)

while ($true) {
    function Select-Dates {
        $form = New-Object Windows.Forms.Form -Property @{
            StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
            Size          = New-Object Drawing.Size 243, 230
            Text          = 'First Date'
            Topmost       = $true
        }

        $calendarStart = New-Object Windows.Forms.MonthCalendar -Property @{
            ShowTodayCircle   = $false
            MaxSelectionCount = 1
        }
        $form.Controls.Add($calendarStart)

        $okButton = New-Object Windows.Forms.Button -Property @{
            Location     = New-Object Drawing.Point 38, 165
            Size         = New-Object Drawing.Size 75, 23
            Text         = 'OK'
            DialogResult = [Windows.Forms.DialogResult]::OK
        }
        $form.AcceptButton = $okButton
        $form.Controls.Add($okButton)

        $cancelButton = New-Object Windows.Forms.Button -Property @{
            Location     = New-Object Drawing.Point 113, 165
            Size         = New-Object Drawing.Size 75, 23
            Text         = 'Cancel'
            DialogResult = [Windows.Forms.DialogResult]::Cancel
        }
        $form.CancelButton = $cancelButton
        $form.Controls.Add($cancelButton)

        $result = $form.ShowDialog()

        if ($result -eq [Windows.Forms.DialogResult]::OK) {
            $script:dateStart = $calendarStart.SelectionStart
            Write-Host "First Date selected: $($dateStart.DateTime)"
        }
        ###########################SECOND_DATE#############################################
        $form = New-Object Windows.Forms.Form -Property @{
            StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
            Size          = New-Object Drawing.Size 243, 230
            Text          = 'Last Date'
            Topmost       = $true
        }

        $calendarEnd = New-Object Windows.Forms.MonthCalendar -Property @{
            ShowTodayCircle   = $false
            MaxSelectionCount = 1
        }
        $form.Controls.Add($calendarEnd)

        $okButton = New-Object Windows.Forms.Button -Property @{
            Location     = New-Object Drawing.Point 38, 165
            Size         = New-Object Drawing.Size 75, 23
            Text         = 'OK'
            DialogResult = [Windows.Forms.DialogResult]::OK
        }
        $form.AcceptButton = $okButton
        $form.Controls.Add($okButton)

        $cancelButton = New-Object Windows.Forms.Button -Property @{
            Location     = New-Object Drawing.Point 113, 165
            Size         = New-Object Drawing.Size 75, 23
            Text         = 'Cancel'
            DialogResult = [Windows.Forms.DialogResult]::Cancel
        }
        $form.CancelButton = $cancelButton
        $form.Controls.Add($cancelButton)

        $result = $form.ShowDialog()

        if ($result -eq [Windows.Forms.DialogResult]::OK) {
            $script:dateEnd = $calendarEnd.SelectionStart
            Write-Host "Last date selected: $($dateEnd.DateTime)"
        }
    }

    function ConvertFrom-Json2 {
        <#
	.SYNOPSIS
		The ConvertFrom-Json cmdlet converts a JSON-formatted string to a custom object (PSCustomObject) that has a property for each field in the JSON 

	.DESCRIPTION
		The ConvertFrom-Json cmdlet converts a JSON-formatted string to a custom object (PSCustomObject) that has a property for each field in the JSON 

	.PARAMETER InputObject
		Specifies the JSON strings to convert to JSON objects. Enter a variable that contains the string, or type a command or expression that gets the string. You can also pipe a string to ConvertFrom-Json.
	
	.PARAMETER MaxJsonLength
		Specifies the MaxJsonLength, can be used to extend the size of strings that are converted.  This is the main feature of this cmdlet vs the native ConvertFrom-Json2

	.EXAMPLE
		Get-Date | Select-Object -Property * | ConvertTo-Json | ConvertFrom-Json
	
		DisplayHint : 2
	
		DateTime    : Friday, January 13, 2012 8:06:31 PM
	
		Date        : 1/13/2012 8:00:00 AM
	
		Day         : 13
	
		DayOfWeek   : 5
	
		DayOfYear   : 13
	
		Hour        : 20
	
		Kind        : 2
	
		Millisecond : 400
	
		Minute      : 6
	
		Month       : 1
	
		Second      : 31
	
		Ticks       : 634620819914009002
	
		TimeOfDay   : @{Ticks=723914009002; Days=0; Hours=20; Milliseconds=400; Minutes=6; Seconds=31; TotalDays=0.83786343634490734; TotalHours=20.108722472277776; TotalMilliseconds=72391400.900200009; TotalMinutes=1206.5233483366667;TotalSeconds=72391.4009002}
	
		Year        : 2012
	
		This command uses the ConvertTo-Json and ConvertFrom-Json cmdlets to convert a DateTime object from the Get-Date cmdlet to a JSON object.

		The command uses the Select-Object cmdlet to get all of the properties of the DateTime object. It uses the ConvertTo-Json cmdlet to convert the DateTime object to a JSON-formatted string and the ConvertFrom-Json cmdlet to convert the JSON-formatted string to a JSON object..
	
	.EXAMPLE
		PS C:\>$j = Invoke-WebRequest -Uri http://search.twitter.com/search.json?q=PowerShell | ConvertFrom-Json
	
		This command uses the Invoke-WebRequest cmdlet to get JSON strings from a web service and then it uses the ConvertFrom-Json cmdlet to convert JSON content to objects that can be  managed in Windows PowerShell.

		You can also use the Invoke-RestMethod cmdlet, which automatically converts JSON content to objects.
		Example 3
		PS C:\>(Get-Content JsonFile.JSON) -join "`n" | ConvertFrom-Json
	
		This example shows how to use the ConvertFrom-Json cmdlet to convert a JSON file to a Windows PowerShell custom object.

		The command uses Get-Content cmdlet to get the strings in a JSON file. It uses the Join operator to join the strings in the file into a single string that is delimited by newline characters (`n). Then it uses the pipeline operator to send the delimited string to the ConvertFrom-Json cmdlet, which converts it to a custom object.

		The Join operator is required, because the ConvertFrom-Json cmdlet expects a single string.

	.NOTES
		Author: Reddit community
		Version History:
			1.0 - Initial release
		Known Issues:
			1.0 - Does not convert nested objects to psobjects
	.LINK
#>

        [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

        param
        (  
            [parameter(
                ParameterSetName = 'object',
                ValueFromPipeline = $true,
                Mandatory = $true)]
            [string]
            $InputObject,
            [parameter(
                ParameterSetName = 'object',
                ValueFromPipeline = $true,
                Mandatory = $false)]
            [int]
            $MaxJsonLength = 67108864

        )#end param

        BEGIN { 
	
            #Configure json deserializer to handle larger then average json conversion
            [void][System.Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')        
            $jsonserial = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer 
            $jsonserial.MaxJsonLength = $MaxJsonLength

        } #End BEGIN

        PROCESS {
            if ($PSCmdlet.ParameterSetName -eq 'object') {
                $deserializedJson = $jsonserial.DeserializeObject($InputObject)

                # Convert resulting dictionary objects to psobjects
                foreach ($desJsonObj in $deserializedJson) {
                    $psObject = New-Object -TypeName psobject -Property $desJsonObj

                    $dicMembers = $psObject | Get-Member -MemberType NoteProperty

                    # Need to recursively go through members of the originating psobject that have a .GetType() Name of 'Dictionary`2' 
                    # and convert to psobjects and replace the current member in the $psObject tree

                    $psObject
                }
            }


        }#end PROCESS

        END {
        }#end END

    }
    function Invoke-LogSearch {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$MainServerName, #Edited for GitHub Upload

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$Edited2ServerName, #Edited for GitHub Upload

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$OrderNumber #Edited for GitHub Upload
        )
        Write-Progress -Activity "Log Search" -Status "Connecting"
        Write-Verbose -Message "Please select first and last date range" -Verbose 
        Start-Sleep -Seconds 1
        Select-Dates 
        #$regexForError = "\bERROR\b.*\b" + [regex]::Escape($OrderNumber) + "\b"
        Write-Progress -Activity "Log search" -Status "Remote logsearch (Edited2 Service Logs)"
        #Invoking log search and creating the naming convention for filenames we will create in output (1/3)
        $searchEdited2 = Invoke-Command -ComputerName $Edited2ServerName -ScriptBlock { param( $OrderNumber, $dateStart, $dateEnd) Get-ChildItem -Path "#Edited for GitHub Upload" -Exclude *error* |  Where-Object { $_.LastWriteTime -gt $dateStart -and $_.LastWriteTime -lt $dateEnd } | Select-String -Pattern $OrderNumber -Context 2 | Select-Object -ExpandProperty Line | Out-String } -ArgumentList  $OrderNumber, $dateStart, $dateEnd 
        $filePath = "$HOME\Documents\" + "$OrderNumber" + " " + "$(get-date -f yy-MM-dd).txt" 
        "LogSearch-Edited2-Started at: $(get-date -f yy-MM-ddTHH:mm:ss)`n" | Out-File -FilePath $filePath -Append
        $searchEdited2 | Out-File -FilePath $filePath -Append
        "LogSearch-Edited2-Finished at: $(get-date -f yy-MM-ddTHH:mm:ss)" | Out-File -FilePath $filePath -Append
        Write-Host "Search has been finished on Edited2, result is here: $filePath" 
        Write-Progress -Activity "Log search" -Status "Remote logsearch (#Edited for GitHub Upload)"
        switch ($TaskDistinguisher) {
            {$_ -in 2, 3} {#Invoking log search and creating the naming convention for filenames we will create in output (2/3)
            Write-Warning -Message "Keep in mind that LogSearch excludes 'error.log' files"
            #Declaring search in #Edited for GitHub Upload
            $searchEdited = Invoke-Command -ComputerName $EditedServerName -ScriptBlock { param( $OrderNumber, $dateStart, $dateEnd) Get-ChildItem -Path "#Edited for GitHub Upload" -Exclude *error* |  Where-Object { $_.LastWriteTime -gt $dateStart -and $_.LastWriteTime -lt $dateEnd } | Select-String -Pattern $OrderNumber -Context 2 | Select-Object -ExpandProperty Line | Out-String } -ArgumentList  $OrderNumber, $dateStart, $dateEnd 
            $filePath = "$HOME\Documents\" + "$OrderNumber" + " " + "$(get-date -f yy-MM-dd).txt" 
            "LogSearch-#Edited for GitHub Upload-Started (#Edited for GitHub Upload) at: $(get-date -f yy-MM-ddTHH:mm:ss)`n" | Out-File -FilePath $filePath -Append
            $searchEdited | Out-File -FilePath $filePath -Append
            "LogSearch-#Edited for GitHub Upload-Finished (#Edited for GitHub Upload) at: $(get-date -f yy-MM-ddTHH:mm:ss)" | Out-File -FilePath $filePath -Append
            #Declaring search in #Edited for GitHub Upload
            $searchEdited = Invoke-Command -ComputerName $EditedServerName -ScriptBlock { param( $OrderNumber, $dateStart, $dateEnd) Get-ChildItem -Path "E:\Detego\Website\detego.Edited.Service\log" -Exclude *error* |  Where-Object { $_.LastWriteTime -gt $dateStart -and $_.LastWriteTime -lt $dateEnd } | Select-String -Pattern $OrderNumber -Context 2 | Select-Object -ExpandProperty Line | Out-String } -ArgumentList  $OrderNumber, $dateStart, $dateEnd 
            $filePath = "$HOME\Documents\" + "$OrderNumber" + " " + "$(get-date -f yy-MM-dd).txt" 
            "LogSearch-#Edited for GitHub Upload-Started (#Edited for GitHub Upload) at: $(get-date -f yy-MM-ddTHH:mm:ss)`n" | Out-File -FilePath $filePath -Append
            $searchEdited | Out-File -FilePath $filePath -Append
            "LogSearch-#Edited for GitHub Upload-Finished (#Edited for GitHub Upload) at: $(get-date -f yy-MM-ddTHH:mm:ss)" | Out-File -FilePath $filePath -Append
            Write-Host "Search has been finished on #Edited for GitHub Upload, result is here: $filePath"
            Start-Process notepad++ $filePath}
            Default { Write-Host "Nothing was provided"}
        }
    }

    function Download-RbmqEdited2 {
        [CmdletBinding()]
        param (
            $username = "#Edited for GitHub Upload", #Edited for GitHub Upload
            $password = "#Edited for GitHub Upload", #Edited for GitHub Upload
            [string]$RBMQOption
        )
        #GTINInspector option made for EPC harvesting from in payloads
        $GTINInspector = "#Edited for GitHub Upload"
        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential($username, $secpasswd)
        $uri = "https://#Edited for GitHub Upload" + "$SpecifyServer" + "#Edited for GitHub Upload/get" #Edited for GitHub Upload
        if ($RBMQOption -Contains $GTINInspector) {
        $POSTParams = @{
            "vhost"    = "#Edited for GitHub Upload" #Edited for GitHub Upload
            "count"    = "1500"
            "requeue"  = "true"
            "encoding" = "auto"
            "truncate" = "50000"
            "name"     = "#Edited for GitHub Upload" #Edited for GitHub Upload
        } | ConvertTo-Json
            $uri = "https://#Edited for GitHub Upload" + "$SpecifyServer" + "#Edited for GitHub Upload/get"
            $response = Invoke-RestMethod -Uri $uri -Credential $credential -Method POST -ContentType "application/json" -Body $POSTParams
            if ($response.PSObject.TypeNames -match "String") {
                    $response | ConvertFrom-Json2 |  Where-Object { $_.payload -like "*$numberVal*"} | Select-Object -ExpandProperty payload -OutVariable ForRegexSearch | Out-Null
                    #REGEX
                    $options = [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::CultureInvariant
                    $regex = '(?<="Gtin":"|"Gtin\\":\\")[^\\"]+'
                    $ExtractedGTIN = [regex]::Matches($ForRegexSearch, $regex, $options)
                    $script:FinalGTINList = $ExtractedGTIN | foreach-object {$_.Value} | Sort-Object -Unique
                    Write-Host "$numberVal presents on #Edited for GitHub Upload" #Edited for GitHub Upload
                    Write-Host "Unique GTINs found:" $FinalGTINList.Count | Out-Host
                    }
            else {
                    $response |  Where-Object { $_.payload -like "*$numberVal*"} | Select-Object -ExpandProperty payload -OutVariable ForRegexSearch | Out-Null
                    #REGEX
                    $options = [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::CultureInvariant
                    $regex = '(?<="Gtin":"|"Gtin\\":\\")[^\\"]+'
                    $ExtractedGTIN = [regex]::Matches($ForRegexSearch, $regex, $options)
                    $script:FinalGTINList = $ExtractedGTIN | foreach-object {$_.Value} | Sort-Object -Unique
                    Write-Host "$numberVal presents on #Edited for GitHub Upload"  #Edited for GitHub Upload
                    Write-Host "Unique GTIN's found:" $FinalGTINList.Count | Out-Host
                }
            }
        
        else{
            $POSTParams = @{
                "vhost"    = "#Edited for GitHub Upload" #Edited for GitHub Upload
                "count"    = "$messageCountRBMQ"
                "requeue"  = "true"
                "encoding" = "auto"
                "truncate" = "50000"
                "name"     = "#Edited for GitHub Upload" #Edited for GitHub Upload
            } | ConvertTo-Json
            $response = Invoke-RestMethod -Uri $uri -Credential $credential -Method POST -ContentType "application/json" -Body $POSTParams
            if ($response.PSObject.TypeNames -match "String") {
                if ($response | ConvertFrom-Json2 |  Where-Object { $_.payload -like "*$numberVal*" }) {
                    Write-Host "$numberVal is presented on #Edited for GitHub Upload's #Edited for GitHub Upload" #Edited for GitHub Upload
                }
                else {
                    Write-Host "Nothing was found"
                }
            }
            else {
                if ($response |  Where-Object { $_.payload -like "*$numberVal*" }) {
                    Write-Host "$numberVal is presented on #Edited for GitHub Upload's #Edited for GitHub Upload" #Edited for GitHub Upload
                }
                else {
                    Write-Host "Nothing was found"
                }
            }
        }
    }

    function Download-RbmqEdited {
        [CmdletBinding()]
        param (
            $username = "#Edited for GitHub Upload", #Edited for GitHub Upload
            $password = "#Edited for GitHub Upload", #Edited for GitHub Upload
            [string]$RBMQOption  
        )
        #GTINInspector option made for EPC harvesting from in payloads
        $GTINInspector = "GTINInspector"
        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential($username, $secpasswd)
        #If we need look into UpSync
        if ($RBMQOption -Contains $GTINInspector) {
        $uri = "https://#Edited for GitHub Uploadget"
        $POSTParams = @{
            "vhost"    = "#Edited for GitHub Upload"
            "count"    = "2000"
            "requeue"  = "true"
            "encoding" = "auto"
            "truncate" = "50000"
            "name"     = "#Edited for GitHub Upload"
        } | ConvertTo-Json
        $response = Invoke-RestMethod -Uri $uri -Credential $credential -Method POST -ContentType "application/json" -Body $POSTParams
        if ($response.PSObject.TypeNames -match "String") {
                $response | ConvertFrom-Json2 |  Where-Object { $_.payload -like "*$numberVal*" } | Select-Object -ExpandProperty payload -OutVariable ForRegexSearch | Out-Null
                #REGEX
                $options = [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::CultureInvariant
                $regex = '(?<="Gtin":"|"Gtin\\":\\")[^\\"]+'
                $ExtractedGTIN = [regex]::Matches($ForRegexSearch, $regex, $options)
                $script:FinalGTINList = $ExtractedGTIN | foreach-object {$_.Value} | Sort-Object -Unique
                Write-Host "$numberVal presents on #Edited for GitHub Upload" 
                Write-Host "Unique GTIN's found:" $FinalGTINList.Count | Out-Host
        }
        else {
                $response | Where-Object { $_.payload -like "*$numberVal*" } | Select-Object -ExpandProperty payload -OutVariable ForRegexSearch | Out-Null
                #REGEX
                $options = [Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [Text.RegularExpressions.RegexOptions]::CultureInvariant
                $regex = '(?<="Gtin":"|"Gtin\\":\\")[^\\"]+'
                $ExtractedGTIN = [regex]::Matches($ForRegexSearch, $regex, $options)
                $script:FinalGTINList = $ExtractedGTIN | foreach-object {$_.Value} | Sort-Object -Unique
                Write-Host "$numberVal presents on #Edited for GitHub Upload"
                Write-Host "Unique GTIN's found:" $FinalGTINList.Count | Out-Host
            }
        }
      #If we don't need UpSync
      else {
        $uri = "https://#Edited for GitHub Upload" + "$SpecifyServer" + "/get"
        $POSTParams = @{
            "vhost"    = "#Edited for GitHub Upload"
            "count"    = "$messageCountRBMQ"
            "requeue"  = "true"
            "encoding" = "auto"
            "truncate" = "50000"
            "name"     = "#Edited for GitHub Upload" + "$SpecifyServer"
        } | ConvertTo-Json

        $response = Invoke-RestMethod -Uri $uri -Credential $credential -Method POST -ContentType "application/json" -Body $POSTParams
        if ($response.PSObject.TypeNames -match "String") {
            if ($response | ConvertFrom-Json2 |  Where-Object { $_.payload -like "*$numberVal*" }) {
                Write-Host "$numberVal presents on #Edited for GitHub Upload.$SpecifyServer"
            }
            else {
                Write-Host "Nothing was found in #Edited for GitHub Upload.$SpecifyServer"
            }
        }
        else {
            if ($response |  Where-Object { $_.payload -like "*$numberVal*" }) {
                Write-Host "$numberVal presents on #Edited for GitHub Upload.$SpecifyServer"
            }
            else {
                Write-Host "Nothing was found in #Edited for GitHub Upload.$SpecifyServer"
            }
        }
      }
    }

    function Invoke-ResendASN {  #Edited for GitHub Upload
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$ValueToTrigger
        )
        #Something that we did before with WCF Test client now is automated right now.
        #https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/new-webserviceproxy?view=powershell-5.1
        Write-Host "Triggring call from #Edited for GitHub Upload"
        $service = New-WebServiceProxy -uri "https://#Edited for GitHub Upload.svc" 
        $service.Resend($ValueToTrigger) #Edited for GitHub Upload
    } 

    function Invoke-GTINInspector {
        [CmdletBinding()]
        param (
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$ValueToFailureExpectation, #Edited for GitHub Upload
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string]$InspectorOption #Edited for GitHub Upload
        )
        switch ($InspectorOption) {
            "#Edited for GitHub Upload" {
                Write-Host "GTINInspector-Start"
                Write-Host "It will:`n1. Trigger #Edited for GitHub Upload from #Edited for GitHub Upload to #Edited for GitHub Upload`n2. Will find a failed #Edited for GitHub Upload`n3. Collect #Edited for GitHub Upload and compare it with "
                Invoke-ResendASN -ValueToTrigger $numberVal | Out-Host
                Download-RbmqEdited -RBMQOption "GTINInspector"
                Start-Sleep -Seconds 2
                $script:collatesBrackets = foreach($Obj in $FinalGTINList) {       
                    $begin = "("
                    $end = ")"
                    $begin + $Obj + $end 
                    }
                $script:collate = $collatesBrackets -join ", "
                #SQLBLOCK
                Write-Host "Here is the list of missing GTINs on Edited"
                $Username = '#Edited for GitHub Upload' #Edited for GitHub Upload
                $password = (New-Object PSCredential "userDummy", $Pwd).GetNetworkCredential().Password
                $ServerName = '#Edited for GitHub Upload'
                $DatabaseName = '#Edited for GitHub Upload'
                $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $ServerName,$DatabaseName,$Username,$password #Edited for GitHub Upload
                $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString #Edited for GitHub Upload
                $QueryEdited = @"
                SELECT * FROM
                #Edited for GitHub Upload #Edited for GitHub Upload
                EXCEPT #Edited for GitHub Upload
                SELECT Gtin  #Edited for GitHub Upload
                FROM [#Edited for GitHub Upload].[#Edited for GitHub Upload].[#Edited for GitHub Upload]; #Edited for GitHub Upload
"@
                $command = new-object system.data.sqlclient.sqlcommand($QueryEdited,$sqlConnection)
                $sqlConnection.Open()
                $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
                $dataset = New-Object System.Data.DataSet
                $adapter.Fill($dataSet) | Out-Null
                $sqlConnection.Close()
                $dataSet.Tables | Format-Table -AutoSize
            }
            "#Edited for GitHub Upload" {
                Write-Host "GTINInspector-Start"
                Download-RbmqEdited2 -RBMQOption "GTINInspector"
                Start-Sleep -Seconds 2 
                $collatesBrackets = foreach($Obj in $FinalGTINList) {       
                    $begin = "("
                    $end = ")"
                    $begin + $Obj + $end 
                    }
                $script:collate = $collatesBrackets -join ", "
                #SQLBLOCK
                Write-Host "Here is the #Edited for GitHub Uploadg GTINs on $PlaceholderEdited2Short"
                $ServerName = $PlaceholderEdited2Short
                $DatabaseName = "#Edited for GitHub Upload"
                $connectionString = 'Data Source={0};database={1};Integrated Security=SSPI;' -f $ServerName,$DatabaseName
                $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString
                $QueryEdited2 = @"
                SELECT * FROM
                #Edited for GitHub Upload
                EXCEPT
                SELECT #Edited for GitHub Upload 
                FROM [#Edited for GitHub Upload].[#Edited for GitHub Upload].[#Edited for GitHub Upload];
"@
                $command = new-object system.data.sqlclient.sqlcommand($QueryEdited2,$sqlConnection)
                $sqlConnection.Open()
                $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
                $dataset = New-Object System.Data.DataSet
                $adapter.Fill($dataSet) | Out-Null
                $sqlConnection.Close()
                $dataSet.Tables | Format-Table -AutoSize
            }
            Default {
                Write-Verbose -Message "GTINInspector - no value provided"
            }
        }
    }
    function Invoke-Edited2GoodsReceivingCheck {
        [CmdletBinding()]
        param (
            $script:ReferenceOrAsn = (Read-Host -Prompt "Specify #Edited for GitHub Upload number") #Edited for GitHub Upload
        )
        #a WORKAROUND for Edited2
        #Invoke-Command -ComputerName $PlaceholderEdited2 -ArgumentList $GoodsReceivingEdited2Query -ScriptBlock { param($GoodsReceivingEdited2Query) Invoke-sqlcmd -query $GoodsReceivingEdited2Query} | Select-Object Id
        
        $ReferenceOrAsn = $ReferenceOrAsn.Split(',') | ForEach-Object { $_.trim() }
        foreach ($script:numberVal in $ReferenceOrAsn) {
            $script:GoodsReceivingEdited2Query = "SELECT id, SiteGln FROM [#Edited for GitHub Upload].[#Edited for GitHub Upload].[#Edited for GitHub Upload] where Id = '${numberVal}'"
            $script:PlaceholderEdited = "#Edited for GitHub Upload"
            $script:EdiMessageEditedQuery = "SELECT #Edited for GitHub Upload, #Edited for GitHub Upload, #Edited for GitHub Upload, #Edited for GitHub Upload FROM#Edited for GitHub Upload where = '${numberVal}'"
            $script:Username = "rfid"
            if ($numberVal -like "AR*") {
                Write-Verbose -Message "Value starts#Edited for GitHub Upload, doing #Edited for GitHub Upload check up on Edited" -Verbose
                $script:EdiMessageEditedQueryARU = "#Edited for GitHub Upload = '${numberVal}'"
                $SqlResultsEditedARU = Invoke-sqlcmd  -ServerInstance $PlaceholderEdited -Username $Username -Password (New-Object PSCredential "userDummy", $Pwd).GetNetworkCredential().Password -Query $EdiMessageEditedQueryARU
                $SqlResultsEditedARU | Format-Table -AutoSize
            }
            else {
                Write-Progress -Activity "Getting #Edited for GitHub Upload" -Status "..."
                #Edited SQL Connection #Edited for GitHub Upload
                $SqlResultsEdited = Invoke-sqlcmd -ServerInstance $PlaceholderEdited -Username $Username -Password (New-Object PSCredential "userDummy", $Pwd).GetNetworkCredential().Password -Query $EdiMessageEditedQuery
                #Edited2 SQL Connection #Edited for GitHub Upload
                $script:SpecifyServer = $SqlResultsEdited | Select-Object -ExpandProperty ReceipientGLN -First 1
                $script:PlaceholderEdited2Full = "#Edited for GitHub Upload" + $SpecifyServer + "#Edited for GitHub Upload" #Edited for GitHub Upload
                $script:PlaceholderEdited2Short = "#Edited for GitHub Upload" + $SpecifyServer + "#Edited for GitHub Upload" #Edited for GitHub Upload
                try {
                    $SpecifyServer
                }
                catch [System.Data.SqlClient.SqlException] {
                    Write-Warning -Message "The script has encountered SQL error : #Edited for GitHub Upload" #Edited for GitHub Upload
                    Write-Host "Let's see your value on #Edited for GitHub Upload:" 
                    $SqlResultsEdited | Format-Table -AutoSize
                    if (-not $SqlResultsEdited) {
                        Write-Host "Zero result, #Edited for GitHub Upload `nStartig GTINInspector:" #Edited for GitHub Upload
                        Write-Progress -Activity "GTINInspector" -Status "In Process"
                        Invoke-GTINInspector -ValueToFailureExpectation $numberVal -InspectorOption "Edited"
                        break
                    }

                }
                $SqlResultsEdited2 = Invoke-sqlcmd -hostname $PlaceholderEdited2Full -ServerInstance $PlaceholderEdited2Short -query $GoodsReceivingEdited2Query
                Write-Progress -Activity "#Edited for GitHub Upload" -Status "Connecting"
                if ($SqlResultsEdited2) {
                    Write-Host "Here is your#Edited for GitHub Upload result:"
                    $SqlResultsEdited2 | Format-Table -AutoSize
                    Write-Progress -Activity "#Edited for GitHub Upload" -Status "Done" -Completed
                }
                else {
                    Write-Progress -Activity "#Edited for GitHub Upload" -Status "Failed" -Completed
                    Write-Progress  -Activity "#Edited for GitHub Upload" -Status "Connecting"
                    Write-Host "The record wasn't found o#Edited for GitHub Upload! Doing additional check up: #Edited for GitHub Upload"#Edited for GitHub Upload
                    if ($SqlResultsEdited | Where-Object #Edited for GitHub Upload -like "01*") {#Edited for GitHub Upload
                        $SqlResultsEdited | Format-Table -AutoSize
                        Write-Host "#Edited for GitHub Upload starts from #Edited for GitHub Upload, probably a message #Edited for GitHub Upload" #Edited for GitHub Upload
                        $script:defaultValueCountRBMQ = '100'
                        $script:messageCountRBMQ = Read-Host "Provide your number of messages to download or press [ENTER] to keep with default 100"#Edited for GitHub Upload
                        $script:messageCountRBMQ = ($defaultValueCountRBMQ, $messageCountRBMQ)[[bool]$messageCountRBMQ] | ForEach-Object { $_.trim() }
                        Download-RbmqEdited2
                        Download-RbmqEdited
                        Write-Host "By the given output, would you like to restart RBMQ #Edited for GitHub Upload?" #Edited for GitHub Upload
                        $answer = Read-Host -Prompt "(y/n)" 
                        if ($answer -like "y*") {
                            Write-Progress  -Activity "Edited2 $PlaceholderEdited2Short RBMQ service restart" -Status "Connecting"#Edited for GitHub Upload
                            Invoke-Command -ComputerName $PlaceholderEdited2Short -ScriptBlock { Restart-Service -Name RabbitMQ }
                            Write-Progress  -Activity "Edited2 $PlaceholderEdited2Short RBMQ service restart" -Status "Done"#Edited for GitHub Upload
                        }
                        Write-Verbose "Would you like to check missing #Edited for GitHub Upload?" -Verbose#Edited for GitHub Upload
                        $answer = Read-Host -Prompt "(y/n)" 
                        if ($answer -like "y*") {
                            Invoke-GTINInspector -ValueToFailureExpectation $numberVal -InspectorOption "Edited2"
                        }
                    }
                    elseif ($SqlResultsEdited | Where-Object #Edited for GitHub Upload -like "F*") {
                        $script:TaskDistinguisher = 2
                        $SqlResultsEdited | Format-Table -AutoSize
                        Write-Verbose "#Edited for GitHub Upload starts from #Edited for GitHub Upload, #Edited for GitHub Upload" -Verbose #Edited for GitHub Upload
                    }
                    elseif ([DBNull]::Value.Equals($SqlResultsEdited.#Edited for GitHub Upload)) {
                        $script:TaskDistinguisher = 3
                        Write-Warning "Here is SQl #Edited for GitHub Upload results, #Edited for GitHub Upload $numberVal is NULL:"
                        $SqlResultsEdited | Format-Table -AutoSize
                        Write-Host "Checking #Edited for GitHub Upload"
                        Write-Progress  -Activity "#Edited for GitHub Upload" -Status "Connecting"
                        $script:EdiMessageDCQuery = "#Edited for GitHub Upload = '${numberVal}'"
                        $SqlResultsDC = Invoke-sqlcmd  -ServerInstance $PlaceholderEdited -Username $Username -Password (New-Object PSCredential "userDummy", $Pwd).GetNetworkCredential().Password -Query $EdiMessageDCQuery
                        Write-Host "Here is your #Edited for GitHub Upload:"
                        $SqlResultsDC | Format-Table -AutoSize
                        Write-Verbose "Would you like to trigger#Edited for GitHub Upload" -Verbose
                        $answer = Read-Host -Prompt "(y/n)" 
                        if ($answer -like "y*") {  
                            Write-Progress  -Activity "Triggering #Edited for GitHub Upload" -Status "In Process"
                            Invoke-ResendASN -ValueToTrigger $numberVal
                        }
                    }
                    else {
                            Write-Host "Here is SQL Edited results"
                            $SqlResultsEdited | Format-Table -AutoSize
                            Write-Warning "You run into final else statement, meaning checking#Edited for GitHub Upload:" -Verbose
                            $EdiMessageDCQuery = "#Edited for GitHub Upload = '${numberVal}'"
                            Write-Progress  -Activity "#Edited for GitHub Upload" -Status "Connecting"
                            $SqlResultsDC = Invoke-sqlcmd  -ServerInstance $PlaceholderEdited -Username $Username -Password (New-Object PSCredential "userDummy", $Pwd).GetNetworkCredential().Password -Query $EdiMessageDCQuery
                            $SqlResultsDC | Format-Table -AutoSize
                            if ($answer -like "y*") {
                                Write-Progress  -Activity "Triggering ASN" -Status "In Process"
                                Invoke-ResendASN -ValueToTrigger $numberVal
                            }
                        }
                    }
                    Write-Host "Would you like to use advanced log search?"
                    $answer = Read-Host -Prompt "(y/n)" 
                    if ($answer -like "y*") {
                        $script:EditedServerName = "#Edited for GitHub Upload0"
                        Invoke-LogSearch -MainServerName $EditedServerName -Edited2ServerName $PlaceholderEdited2Full -OrderNumber $numberVal
                    }
                    Write-Progress  -Activity "Search" -Status "Done" -Completed
                }
            }
            Write-Progress  -Activity "Script" -Status "Done" -Completed
        }

    Write-Host "===========================================InboundCheckUp-Start======================================================="
    Invoke-Edited2GoodsReceivingCheck
    Write-Host "===========================================InboundCheckUp-End========================================================="
}