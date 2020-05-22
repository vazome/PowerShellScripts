#Let's specify basic Yes and No values
$Yes = "Yes"
$No = "No"
Set-ExecutionPolicy -ExecutionPolicy "RemoteSigned"
#Let's check the timezone
$DefaultTimeZone = Get-TimeZone
Write-Host "Checking Time"
$DefaultTimeZone
$DefaultSystemLanguage = Get-WinSystemLocale
Write-Host "Checking Language"
$DefaultSystemLanguage

If  ($DefaultTimeZone -eq "Russian Standard Time") {
    Write-Host "TimeZone is ok"
}
Else {
    Set-TimeZone -Id "Russian Standard Time"
}
Read-Host "Press Enter"
If ($DefaultSystemLanguage -eq "en-US") {
    Write-Host "We will set your locale and language settings to main US"
    $culture = Get-Culture
    $culture.DateTimeFormat.ShortDatePattern = 'dd/MM/yyyy'
    $culture.DateTimeFormat.LongDatePattern = 'dddd, d MMMM yyyy'
    $culture.DateTimeFormat.ShortTimePattern = 'HH:mm'
    $culture.DateTimeFormat.LongTimePattern = 'HH:mm:ss'
    $culture.DateTimeFormat.FirstDayOfWeek = 'Monday'
    Set-Culture $culture
    Set-WinSystemLocale -SystemLocale en-US
    Set-WinUILanguageOverride -Language en-US
    Set-WinUserLanguageList  en-US, ru-RU -Force
    Set-WinHomeLocation -GeoId 203
}
else {
    Write-Host "Everything is ok"}

Write-Host "Do you want to change the current Computer Name" 
Start-Sleep -Seconds 3
$PCNameStatus = Read-Host -Prompt "Yes/No"
If ($Yes -match $PCNameStatus) {
    $PCNAME = Read-Host -Prompt "Please specify the name you want to assign"
    Rename-Computer -NewName $PCNAME
}

ElseIf ($No -match $PCNameStatus) {
    Write-Host "It's time to reboot"
    Start-Sleep -Seconds 10
    Restart-Computer
}

Else {
    Write-Host "The answer wasn't in Yes/No format"
    Write-Host "It's time to reboot"
    Start-Sleep -Seconds 10
    Restart-Computer
}
