# Ana yedek klasörü yolu
$backupFolderPath = "C:\DailyEventLogBackup"

# Gün sayısı sınırlaması
$daysToKeep = 10

# Bugünün tarihini al
$today = Get-Date

# Ana yedek klasörünü oluştur
if (-not (Test-Path -Path $backupFolderPath)) {
    New-Item -ItemType Directory -Path $backupFolderPath | Out-Null
}

# Bugünün tarihini kullanarak alt klasör adı oluştur
$dailyBackupFolderName = $today.ToString("yyyyMMdd")

# Günlük yedek klasörünün yolu
$dailyBackupFolderPath = Join-Path -Path $backupFolderPath -ChildPath $dailyBackupFolderName

# Günlük yedek klasörünü oluştur
if (-not (Test-Path -Path $dailyBackupFolderPath)) {
    New-Item -ItemType Directory -Path $dailyBackupFolderPath | Out-Null
}

# Tüm log gruplarını al
$logGroups = Get-WinEvent -ListLog *

# Her bir log grubu için işlem yap
foreach ($logGroup in $logGroups) {
    $logGroupName = $logGroup.LogName
    $backupFileName = $logGroupName + "_" + $today.ToString("yyyyMMdd") + ".evtx"
    $backupFilePath = Join-Path -Path $dailyBackupFolderPath -ChildPath $backupFileName

    # Log grubunu yedekle
    wevtutil epl $logGroupName $backupFilePath

    Write-Host "Backup created for $logGroupName log group: $backupFilePath"
}

# 30 günden eski yedek klasörlerini sil
$oldBackupFolders = Get-ChildItem -Path $backupFolderPath | Where-Object {($_.PSIsContainer) -and ($_.Name -lt ($today.AddDays(-$daysToKeep).ToString("yyyyMMdd")))}
foreach ($oldBackupFolder in $oldBackupFolders) {
    Remove-Item -Path $oldBackupFolder.FullName -Force -Recurse
    Write-Host "En eski backup klasoru temizlendi: $($oldBackupFolder.FullName)"
}
