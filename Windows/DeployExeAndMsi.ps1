$locationfiles = Read-Host -Prompt "Specify the .msi or .exe containing folder"
$installers = Get-ChildItem -Path $locationfiles -Filter "*.exe"
foreach ($install in $installers){
    Start-Process -Wait -FilePath ($install.FullName) -PassThru
}
$installers = Get-ChildItem -Path $locationfiles -Filter "*.msi"
foreach ($install in $installers){
    Start-Process -Wait -FilePath ($install.FullName) -PassThru
}
