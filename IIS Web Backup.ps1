# IIS yapılandırma dosyalarını yedeklemek için kopyalama fonksiyonu
function Backup-IISConfiguration {
    param (
        [string]$backupDirectory
    )
    # IIS yapılandırma dosyalarının bulunduğu dizin
    $iisConfigDir = "$env:SystemDrive\inetpub\history"
    
    # IIS yapılandırma dosyalarını yedekle
    Copy-Item -Path "$iisConfigDir\CFGHISTORY_*" -Destination $backupDirectory -Recurse -Force
}

# Yedeklenecek sitelerin listesi
$webSites = Get-Website

# Yedeklerin kaydedileceği dizin
$backupDirectory = "C:\IISWebBackup"

# Yedek dizinini oluştur
New-Item -ItemType Directory -Force -Path $backupDirectory

# Tarih bilgisi
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# IIS yapılandırma dosyalarını yedekle
Backup-IISConfiguration -backupDirectory $backupDirectory

# Tüm web sitelerinin dosyalarını yedekle
foreach ($site in $webSites) {
    $siteName = $site.Name
    $sitePath = $site.physicalPath
    
    # Fiziksel dizin var mı kontrol et
    if (Test-Path $sitePath) {
        $siteBackupDir = Join-Path -Path $backupDirectory -ChildPath "$siteName\Files_$timestamp"
        
        # Web sitesi dosyalarını yedekle
        Copy-Item -Path $sitePath -Destination $siteBackupDir -Recurse -Force
    }
    else {
        Write-Host "Hata: $siteName web sitesinin fiziksel dizini bulunamadı!"
    }
}

# 7 günden eski yedekleri sil
$oldBackups = Get-ChildItem -Path $backupDirectory | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
foreach ($oldBackup in $oldBackups) {
    Write-Host "Eski yedek siliniyor: $($oldBackup.FullName)"
    Remove-Item -Path $oldBackup.FullName -Recurse -Force
}

Write-Host "Yedekleme işlemi tamamlandı."
