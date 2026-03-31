#!/bin/bash

set -e

REPO_URL="https://github.com/f7914823-max/vpctelegram.git"
INSTALL_DIR="/opt/vpctelegram"

echo "📥 Установка VPC Telegram Panel..."

apt-get update -y
apt-get install -y git curl

echo "📦 Скачивание проекта..."
rm -rf "$INSTALL_DIR"
git clone "$REPO_URL" "$INSTALL_DIR"

cd "$INSTALL_DIR"

chmod +x vpctelegram.sh

ln -sf "$INSTALL_DIR/vpctelegram.sh" /usr/local/bin/vpctelegram
chmod +x /usr/local/bin/vpctelegram

echo ""
echo "✅ Установка завершена!"
echo "👉 Введи: vpctelegram"
