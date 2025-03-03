#!/bin/bash
# Update paket listesi
sudo apt-get update

# Gerekli bağımlılıkları yükle
sudo apt-get install -y ca-certificates curl

# Docker GPG anahtarını ekle
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker deposunu sistemine ekle
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Paket listelerini güncelle
sudo apt-get update

# Docker ve gerekli bileşenleri yükle
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker grubuna ubuntu kullanıcısını ekle
sudo usermod -aG docker ubuntu

# Grup değişikliklerini etkinleştir
newgrp docker

# Docker socket için izinleri ayarla
sudo chmod 777 /var/run/docker.sock
