#!/bin/bash

set -e

REPO_URL="https://github.com/USERNAME/vpctelegram.git"
INSTALL_DIR="/opt/vpctelegram"

echo "📥 Установка VPC Telegram Panel..."

apt update
apt install -y git curl

echo "📦 Скачивание проекта..."
rm -rf $INSTALL_DIR
git clone $REPO_URL $INSTALL_DIR

cd $INSTALL_DIR

chmod +x vpctelegram.sh

echo "⚙️ Установка команды vpctelegram..."
ln -sf $INSTALL_DIR/vpctelegram.sh /usr/local/bin/vpctelegram

echo "✅ Установка завершена!"
echo ""
echo "👉 Запусти панель командой:"
echo "vpctelegram"