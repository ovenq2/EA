# Event Viewer loglarının maksimum boyutu (250MB)
$maxLogSizeInBytes = 250MB

# Tüm log gruplarını al
$logGroups = Get-WinEvent -ListLog *

# Her bir log grubunun maksimum boyutunu değiştir
foreach ($logGroup in $logGroups) {
    $logGroupName = $logGroup.LogName
    Write-Host "Setting max log size for log group: $logGroupName"
    
    # Maksimum log boyutunu ayarla
    $logGroup | ForEach-Object {
        $_.MaximumSizeInBytes = $maxLogSizeInBytes
        $_.LogFilePath = $_.LogFilePath -replace "MaxSize\d+", "MaxSize$($maxLogSizeInBytes/1MB)"
        $_.SaveChanges()
    }

    # Onay mesajı
    Write-Host "Max log size set to 250MB for log group: $logGroupName"
}




