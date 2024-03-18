# IIS yönetici modülünü yükle
Import-Module WebAdministration

# Tüm web sitelerini al
$sites = Get-Website

# IIS üzerinde çalışmayan ve çalışan web sitelerini kontrol et
foreach ($site in $sites) {
    $siteName = $site.Name
    $siteState = $site.State
    $sitePhysicalPath = $site.physicalPath
    if ($siteState -ne "Started") {
        Write-Host "Web sitesi '$siteName' çalışmıyor. Fiziksel Yol: $sitePhysicalPath" -ForegroundColor Red
    }
    else {
        Write-Host "Web sitesi '$siteName' çalışıyor. Fiziksel Yol: $sitePhysicalPath" -ForegroundColor Yellow
    }
}

# Boşluk ekle
Write-Host ""

# Tüm sertifikaları al
$certPath = "Cert:\LocalMachine\My"
if (Test-Path $certPath) {
    $certificates = Get-ChildItem -Path $certPath
    # Sertifika bilgilerini yazdır
    Write-Host "`nSertifika Bilgileri:"
    $index = 1
    foreach ($certificate in $certificates) {
        $subject = $certificate.Subject
        $thumbprint = $certificate.Thumbprint
        $expirationDate = $certificate.GetExpirationDateString()
        Write-Host "$index. Konu: $subject, Parmak İzi: $thumbprint, Bitiş Tarihi: $expirationDate"
        $index++
    }
} else {
    Write-Host "Sertifikalar bulunamadı." -ForegroundColor Yellow
}

# Boşluk ekle
Write-Host ""

# IIS servisinin durumunu kontrol et
$iisStatus = Get-Service -Name W3SVC
if ($iisStatus.Status -eq "Running") {
    Write-Host "IIS servisi çalışıyor." -ForegroundColor Yellow
}
else {
    Write-Host "IIS servisi çalışmıyor." -ForegroundColor Red
}



