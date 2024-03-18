import os
import paramiko
import re
import time
import subprocess

# rich kütüphanesini kontrol etme ve yükleme
try:
    import rich
except ImportError:
    print("rich kütüphanesi yüklü değil, yükleniyor...")
    subprocess.check_call(["pip", "install", "rich"])

from rich import print

# SSH bağlantısı kurma fonksiyonu
def ssh_baglan(hostname, kullaniciadi, sifre):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname, username=kullaniciadi, password=sifre)
    return ssh

# Sürüm bilgisi alma fonksiyonu
def surum_bilgisi_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show version")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# Hostname alma fonksiyonu
def hostname_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show running-config | include hostname")
    cikti = stdout.read().decode()
    eslesme = re.search(r"hostname\s+(.+)", cikti)
    return eslesme.group(1).strip() if eslesme else "[red]Veri alınamadı[/red]"

# Route bilgisi alma fonksiyonu
def route_bilgisi_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show ip route")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# VLAN bilgisi alma fonksiyonu
def vlan_bilgisi_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show vlan")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# Sistem saati alma fonksiyonu
def sistem_saati_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show clock")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# SNMP trap bilgisi alma fonksiyonu
def snmp_trap_bilgisi_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show snmp trap")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# Switch uptime bilgisi alma fonksiyonu
def switch_uptime_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show uptime")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# Hardware sağlık durumu bilgisi alma fonksiyonu
def hardware_durumu_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show environment")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# CPU Kullanımı bilgisi alma fonksiyonu
def cpu_kullanimi_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show system resource-utilization | include CPU")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# Bellek Kullanımı bilgisi alma fonksiyonu
def bellek_kullanimi_al(ssh):
    stdin, stdout, stderr = ssh.exec_command("show system resource-utilization | include Memory")
    cikti = stdout.read().decode()
    return cikti if cikti else "[red]Veri alınamadı[/red]"

# Ana fonksiyon
def main():
    switch_listesi = [
        ("10.0.50.14", "admin", "@s7SVI+sk[;Z9"),
        ("10.0.50.13", "admin", "@s7SVI+sk[;Z9"),
        # Diğer switchlerin IP adresleri, kullanıcı adları ve şifreleri
        # Örnek: ("10.0.50.15", "admin", "şifre123"),
    ]

    for hostname, kullaniciadi, sifre in switch_listesi:
        ssh = ssh_baglan(hostname, kullaniciadi, sifre)
        if ssh:
            print(f"[green]{hostname} adresine SSH bağlantısı başarılı. Bilgiler alınıyor...[/green]\n")
            
            surum_bilgisi = surum_bilgisi_al(ssh)
            print("[yellow]Sürüm Bilgisi Alınıyor...[/yellow]")
            print(surum_bilgisi)
            print()
            
            hostname = hostname_al(ssh)
            print("[yellow]Hostname Alınıyor...[/yellow]")
            print("[red]Hostname:[/red]", hostname)
            print()
            
            route_bilgisi = route_bilgisi_al(ssh)
            print("[yellow]Route Bilgisi Alınıyor...[/yellow]")
            print("[red]Route Bilgisi:\n[/red]", route_bilgisi)
            print()
            
            vlan_bilgisi = vlan_bilgisi_al(ssh)
            print("[yellow]VLAN Bilgisi Alınıyor...[/yellow]")
            print("[red]VLAN Bilgisi:\n[/red]", vlan_bilgisi)
            print()
            
            sistem_saati = sistem_saati_al(ssh)
            print("[yellow]Sistem Saati Alınıyor...[/yellow]")
            print("[red]Sistem Saati:[/red]", sistem_saati)
            print()
            
            snmp_trap_bilgisi = snmp_trap_bilgisi_al(ssh)
            print("[yellow]SNMP Trap Bilgisi Alınıyor...[/yellow]")
            print("[red]SNMP Trap Bilgisi:\n[/red]", snmp_trap_bilgisi)
            print()
            
            switch_uptime = switch_uptime_al(ssh)
            print("[yellow]Switch Uptime Bilgisi Alınıyor...[/yellow]")
            print("[red]Switch Uptime Bilgisi:\n[/red]", switch_uptime)
            print()
            
            hardware_durumu = hardware_durumu_al(ssh)
            print("[yellow]Hardware Sağlık Durumu Alınıyor...[/yellow]")
            print("[red]Hardware Sağlık Durumu:\n[/red]", hardware_durumu)
            print()
            
            cpu_kullanimi = cpu_kullanimi_al(ssh)
            print("[yellow]CPU Kullanımı Bilgisi Alınıyor...[/yellow]")
            print("[red]CPU Kullanımı Bilgisi:\n[/red]", cpu_kullanimi)
            print()
            
            bellek_kullanimi = bellek_kullanimi_al(ssh)
            print("[yellow]Bellek Kullanımı Bilgisi Alınıyor...[/yellow]")
            print("[red]Bellek Kullanımı Bilgisi:\n[/red]", bellek_kullanimi)
            print()
            
            ssh.close()
        else:
            print(f"[red]{hostname} adresine SSH bağlantısı başarısız.[/red]")

        # Çıktıları bir txt dosyasına yazma işlemi
        dosya_adi = f"{hostname}_{time.strftime('%Y-%m-%d_%H-%M-%S')}.txt"
        klasor_adi = "Health Check Reports"
        if not os.path.exists(klasor_adi):
            os.makedirs(klasor_adi)
        dosya_yolu = os.path.join(klasor_adi, dosya_adi)
        with open(dosya_yolu, "w") as dosya:
            dosya.write(f"Sürüm Bilgisi:\n{surum_bilgisi}\n\n")
            dosya.write(f"Hostname: {hostname}\n\n")
            dosya.write(f"Route Bilgisi:\n{route_bilgisi}\n\n")
            dosya.write(f"VLAN Bilgisi:\n{vlan_bilgisi}\n\n")
            dosya.write(f"Sistem Saati: {sistem_saati}\n\n")
            dosya.write(f"SNMP Trap Bilgisi:\n{snmp_trap_bilgisi}\n\n")
            dosya.write(f"Switch Uptime Bilgisi:\n{switch_uptime}\n\n")
            dosya.write(f"Hardware Sağlık Durumu:\n{hardware_durumu}\n\n")
            dosya.write(f"CPU Kullanımı Bilgisi:\n{cpu_kullanimi}\n\n")
            dosya.write(f"Bellek Kullanımı Bilgisi:\n{bellek_kullanimi}\n\n")
            dosya.write(f"Scriptin çalıştırıldığı tarih: {time.strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            dosya.write(f"Dosya {os.getcwd()} klasörüne kaydedildi.")
            print(f"[bold green]Çıktılar '{dosya_yolu}' adlı belgeye kaydedildi.[/bold green]")

    print("\n[bold red]Ekran 30 saniye sonra kapanacak...[/bold red]")
    time.sleep(30)

# Scriptin başlangıcı
if __name__ == "__main__":
    main()
