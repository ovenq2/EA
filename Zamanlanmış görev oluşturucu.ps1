# Görev için ad ve açıklama
$taskName = "Daily Event Log Backup"
$taskDescription = "Daily backup of event logs to C:\DailyEventLogBackup"

# PowerShell scriptinizi içeren dosyanın yolu
$scriptPath = "C:\Path\To\Your\BackupEventLogs.ps1"

# Görevin tetikleyicisi
$trigger = New-ScheduledTaskTrigger -Daily -At "03:00" # 03:00'da her gün çalışacak şekilde ayarlandı.

# Görevin eylemi
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

# Görevi oluştur
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Trigger $trigger -Action $action -RunLevel Highest

Write-Host "Scheduled task created successfully."


