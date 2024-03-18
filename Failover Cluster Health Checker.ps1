# Renk tanımları
$colorYellow = "Yellow"
$colorRed = "Red"
$colorDefault = "White"
$colorGreen = "Green"
$colorBlack = "Black"

# Cluster bilgilerini al
$clusters = Get-Cluster

# Her bir cluster için işlemleri yap
foreach ($cluster in $clusters) {
  $clusterName = $cluster.Name

  Write-Host "Cluster Adı: $clusterName" -ForegroundColor $colorGreen

  # Node'ların durumunu kontrol et
  Write-Host "Node Durumu:"
  $nodes = Get-ClusterNode -Cluster $clusterName
  foreach ($node in $nodes) {
    $nodeState = $node.State
    if ($nodeState -eq "Up") {
      Write-Host "$($node.Name): $nodeState" -ForegroundColor $colorYellow
    } else {
      Write-Host "$($node.Name): $nodeState" -ForegroundColor $colorRed
    }
  }

  # Network durumunu kontrol et ve subnet bilgilerini al
  Write-Host "`nNetwork Durumu ve Subnet Bilgileri:"
  $networks = Get-ClusterNetwork -Cluster $clusterName
  foreach ($network in $networks) {
    $networkState = $network.State
    if ($networkState -eq "Up") {
      $networkColor = $colorYellow
    } else {
      $networkColor = $colorRed
    }

    Write-Host "Network Adı: $($network.Name)" -ForegroundColor $colorGreen
    Write-Host " Durum: $networkState" -ForegroundColor $networkColor

    # Subnet bilgisi
    $subnet = $network.Address
    Write-Host " Subnet: $subnet" -ForegroundColor $networkColor
  }

  # File Share Witness durumunu kontrol et
  Write-Host "`nFile Share Witness Durumu:"
  $witness = Get-ClusterResource -Cluster $clusterName | Where-Object { $_.ResourceType -eq "File Share Witness" }
  if ($witness) {
    Write-Host "Var" -ForegroundColor $colorYellow
  } else {
    Write-Host "Yok" -ForegroundColor $colorRed
  }

  # Node'ların IP adreslerini kontrol et
  Write-Host "`nNode IP Adresleri:"
  foreach ($node in $nodes) {
    $nodeIPs = $node | Get-ClusterNetworkInterface | Where-Object { $_.Address -ne "" } | Select-Object -ExpandProperty Address
    Write-Host "$($node.Name) IP adres(ler)i: $($nodeIPs -join ', ')" -ForegroundColor $colorYellow
  }

  # Servislerin Durumu
  $services = "Windows Time", "SQL Server (MSSQLSERVER)", "SQL Server Agent (MSSQLSERVER)", "SQL Full-text Filter Daemon Launcher (MSSQLSERVER)", "Cluster Service"
  foreach ($service in $services) {
    $serviceState = Get-Service $service -ErrorAction SilentlyContinue
    if ($serviceState -ne $null) {
      if ($serviceState.Status -eq "Running") {
        Write-Host "`n$service Servisi Durumu: Çalışıyor" -ForegroundColor $colorGreen
      } else {
        Write-Host "`n$service Servisi Durumu: Durmuş" -ForegroundColor $colorRed
      }
    } else {
      Write-Host "`n$service servisi bulunamadı." -ForegroundColor $colorRed
    }
  }

  # Rollerin Durumu
  Write-Host "`nRollerin Durumu:"
  $roles = Get-ClusterGroup -Cluster $clusterName
  foreach ($role in $roles) {
    $roleState = $role.State
    if ($roleState -eq "Online") {
      Write-Host "$($role.Name): $roleState" -ForegroundColor $colorYellow
    } else {
      Write-Host "$($role.Name): $roleState" -ForegroundColor $colorRed
    }
  }

  # Cluster Listener IP Adresleri ve Bilgileri
  Write-Host "`nCluster Listener IP Adresleri ve Bilgileri:"
  $clusterListeners = Get-ClusterResource -Cluster $clusterName | Where-Object { $_.ResourceType -eq "Network Name" }
  foreach ($listener in $clusterListeners) {
    $listenerName = $listener.Name
    $listenerState = $listener.State
    $listenerIP = $listener | Select-Object -ExpandProperty Name
    Write-Host "Listener Adı: $listenerName" -ForegroundColor $colorGreen
    Write-Host " Durum: $listenerState" -ForegroundColor $colorGreen
    Write-Host " IP Adresi: $listenerIP" -ForegroundColor $colorYellow
  }
}
