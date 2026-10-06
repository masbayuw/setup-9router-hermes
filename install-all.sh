#!/bin/bash
set -e

echo "=== Update sistem ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl ufw

echo "=== Install Node.js 20 ==="
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

echo "=== Install 9Router ==="
sudo npm install -g 9router

echo "=== Buka port 20128 ==="
sudo ufw allow 20128/tcp
sudo ufw enable

echo "=== Install Hermes ==="
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc

echo ""
echo "✅ Done! Sekarang:"
echo "1. Jalanin: 9router (pilih Hide to Tray)"
echo "2. Buka Security Group Tencent buat port 20128"
echo "3. Akses dashboard: http://$(curl -s ifconfig.me):20128"
echo "4. Jalanin: hermes setup"
