$dist = foreach ($group in (Get-DistributionGroup -Filter {name -like "*"})) {Get-DistributionGroupMember $group | Select @{Label="Group";Expression={$Group.Name}},@{Label="GroupEmail";Expression={$Group.PrimarySmtpAddress}},@{Label="User";Expression={$_.Name}},SamAccountName, PrimarySmtpAddress}
$dist | Sort Group,User | Export-Csv -Path "$HOME\Documents\DistGroupExport.csv" -Encoding UTF8
