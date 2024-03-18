# Execution Policy'yi bypass et
Set-ExecutionPolicy Bypass -Scope Process -Force

# User Access Control'ü devre dışı bırak
Write-Host "User Access Control devre dışı bırakılıyor..."
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -PropertyType DWORD -Force
Write-Host "User Access Control başarıyla devre dışı bırakıldı."

# Internet Explorer Enhanced Security Configuration ayarlarını kapatma
Write-Host "Internet Explorer Enhanced Security Configuration kapatılıyor..."
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
Write-Host "Internet Explorer Enhanced Security Configuration kapatıldı."

# Time Zone ayarının İstanbul +3 olarak güncellenmesi
Write-Host "Zaman Dilimi güncelleniyor..."
Set-TimeZone -Id "Turkey Standard Time"
Write-Host "Zaman Dilimi başarıyla güncellendi."

# Network adaptörlerinde RSS kontrolü
Write-Host "Network adaptörlerinde RSS kontrolü yapılıyor..."
$adapters = Get-NetAdapter
foreach ($adapter in $adapters) {
    $rssEnabled = $adapter | Get-NetAdapterAdvancedProperty -DisplayName "Receive Side Scaling" | Select-Object -ExpandProperty DisplayValue
    if ($rssEnabled -eq 'Disabled') {
        Write-Host "RSS kapalı: $($adapter.Name)"
        Write-Host "RSS açılıyor..."
        $adapter | Set-NetAdapterAdvancedProperty -DisplayName "Receive Side Scaling" -RegistryValue 1
        Write-Host "RSS başarıyla açıldı."
    }
    else {
        Write-Host "RSS açık: $($adapter.Name)"
    }
}

# Microsoft Edge Browser'u varsayılan tarayıcı yapma
Write-Host "Microsoft Edge varsayılan tarayıcı olarak ayarlanıyor..."
$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
Start-Process $edgePath -ArgumentList "--make-default-browser"
Write-Host "Microsoft Edge varsayılan tarayıcı olarak ayarlandı."

# Tüm network adaptörlerinde IPV6'yı kapatma
Write-Host "Tüm network adaptörlerinde IPV6 devre dışı bırakılıyor..."
$adapters = Get-NetAdapter
foreach ($adapter in $adapters) {
    Disable-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6
}
Write-Host "Tüm network adaptörlerinde IPV6 başarıyla devre dışı bırakıldı."

# NTP seçimi
$ntpAddress = ""
$selectedLocation = Read-Host "Lütfen bir konum seçiniz (1: Gebze / 2: Ankara)"
switch ($selectedLocation.ToLower()) {
    "1" { $ntpAddress = "172.24.6.1" }
    "2" { $ntpAddress = "10.200.0.2" }
    default { Write-Host "Geçersiz konum seçimi." }
}

if ($ntpAddress -ne "") {
    Write-Host "NTP adresi ayarlanıyor: $ntpAddress"
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "NtpServer" -Value $ntpAddress
    Write-Host "NTP adresi başarıyla ayarlandı."

    # NTP servisinin yeniden başlatılması
    Write-Host "NTP servisi yeniden başlatılıyor..."
    Restart-Service w32time
    Write-Host "NTP servisi başarıyla yeniden başlatıldı."
}



# Güvenlik duvarlarının durumunu kontrol etme
Write-Host "Güvenlik Duvarlarının Durumu Kontrol Ediliyor..."

$firewallProfiles = Get-NetFirewallProfile

foreach ($profile in $firewallProfiles) {
    Write-Host "Profil: $($profile.Name)"
    if ($profile.Enabled) {
        Write-Host "Durum: Açık"
    } else {
        Write-Host "Durum: Kapalı"
    }
}


# Bilgisayar isminin yazdırılması
Write-Host "Bilgisayar İsmi: $($env:COMPUTERNAME)"


# YENİDEN BAŞLATMA GEREKLİDİR uyarısı
Write-Host -ForegroundColor Red "**************************"
Write-Host -ForegroundColor Red "YENİDEN BAŞLATMA GEREKLİDİR"
Write-Host -ForegroundColor Red "**************************"



