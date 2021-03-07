#First, connect your HDD or SSD
#If CristalDisk Info was started we are stopping it
Stop-Process -Name DiskInfo64
#Cleaning whole drive and removing partitions
#WARNING CHANGE THE DISK NUMBER VALUE TO ACCORDING VALUE IN ORDER TO PREVENT UNINTENTINAL DATA LOOSE
Clear-Disk -Number 1 -RemoveData
#Closing all incomming windows signaling that we have connected our drive and cleaned it
Stop-Process -Name explorer
Start-Process explorer -ArgumentList "/n,/select,%SystemDrive%"
#Start crystal disk to check drive
Start-Process -FilePath "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\CrystalDiskInfo\CrystalDiskInfo (64bit).lnk"
get-disk
