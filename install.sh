#!/bin/bash

set -e

REPO_URL="https://github.com/f7914823-max/vpctelegram.git"
INSTALL_DIR="/opt/vpctelegram"

# Проверка root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Запусти от root: sudo bash install.sh"
  exit 1
fi

echo "📥 Установка VPC Telegram Panel..."

# Фикс CRLF на лету (если вдруг)
fix_crlf() {
    sed -i 's/\r$//' "$1" 2>/dev/null || true
}

apt-get update -y
apt-get install -y git curl

echo "📦 Скачивание проекта..."
rm -rf "$INSTALL_DIR"
git clone "$REPO_URL" "$INSTALL_DIR"

cd "$INSTALL_DIR"

# Чиним возможные CRLF
fix_crlf "vpctelegram.sh"

chmod +x vpctelegram.sh

echo "⚙️ Установка команды vpctelegram..."
ln -sf "$INSTALL_DIR/vpctelegram.sh" /usr/local/bin/vpctelegram

chmod +x /usr/local/bin/vpctelegram

echo ""
echo "✅ Установка завершена!"
echo ""
echo "👉 Запусти панель:"
echo "vpctelegram"
