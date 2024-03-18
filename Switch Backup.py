import os
from datetime import datetime
from netmiko import ConnectHandler

# Fonksiyon, cihaz adını almak için show running-config çıktısını analiz eder
def get_hostname(config_output):
    lines = config_output.split("\n")
    for line in lines:
        if line.startswith("hostname"):
            return line.split()[1].strip()
    return "unknown"

# Eski yedekleri silme fonksiyonu
def delete_old_backups(target_dir, keep=10):
    # Hedef klasördeki dosyaları ve alt klasörleri listele
    for root, dirs, files in os.walk(target_dir, topdown=False):
        # Dosyaları tarihe göre sırala
        files.sort(key=lambda x: os.path.getmtime(os.path.join(root, x)))
        
        # En eski dosyaları sil
        num_files = len(files)
        if num_files > keep:
            files_to_delete = files[:num_files - keep]
            for file_name in files_to_delete:
                file_path = os.path.join(root, file_name)
                os.remove(file_path)
                print(f"'{file_name}' dosyası silindi.")

today = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
target_dir = os.path.join(os.getcwd(), "Switch Backups")
num_backups_to_keep = 10

if not os.path.isdir(target_dir):
    os.makedirs(target_dir)
    print(f"\nCreated {target_dir} klasör oluşturuldu.")
else:
    print(f"\n{target_dir} klasör zaten var.")

# Aruba cihazları için bilgiler
aruba_devices = [
    {
        "device_type": "hp_procurve",
        "ip": "10.0.50.14",
        "username": "admin",
        "password": "@s7SVI+sk[;Z9",
        "fast_cli": False,
    },
    {
        "device_type": "hp_procurve",
        "ip": "10.0.50.13",
        "username": "admin",
        "password": "@s7SVI+sk[;Z9",
        "fast_cli": False,
    },
    # Diğer Aruba cihazları için aynı şekilde devam edebilirsiniz
]

# Her bir cihaz için yapılandırmaları yedekleme
for aruba_device in aruba_devices:
    print(f'\n#### Bağlanılıyor {aruba_device["ip"]} ####\n')
    with ConnectHandler(**aruba_device) as ssh_conn:
        running_config = ssh_conn.send_command("show running-config")
        hostname = get_hostname(running_config)
        
    # Cihazın yedeğini alınan hostname klasörü altında sakla
    device_folder = os.path.join(target_dir, hostname)
    if not os.path.isdir(device_folder):
        os.makedirs(device_folder)
    output_file = os.path.join(device_folder, f'{aruba_device["ip"]}_{hostname}_{today}.txt')
    
    with open(output_file, "w") as outfile:
        outfile.write(running_config.lstrip())
    print(f'Konfigürasyon backup alındı. {aruba_device["ip"]}\n')

# Eski yedekleri sil
delete_old_backups(target_dir, keep=num_backups_to_keep)
