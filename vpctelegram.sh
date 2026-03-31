#!/bin/bash

PROXY_DIR="/opt/mtproto-proxy"
SERVICE_NAME="mtproto-proxy"

DOMAINS=(
"google.com" "wikipedia.org" "habr.com" "github.com"
"coursera.org" "udemy.com" "medium.com" "stackoverflow.com"
"bbc.com" "cnn.com" "reuters.com" "nytimes.com"
"lenta.ru" "rbc.ru" "ria.ru" "kommersant.ru"
"stepik.org" "duolingo.com" "khanacademy.org" "ted.com"
)

get_ip() {
    curl -s ifconfig.me
}

generate_secret() {
    head -c 16 /dev/urandom | xxd -ps
}

install_proxy() {
    echo "Выберите домен для маскировки:"
    select DOMAIN in "${DOMAINS[@]}"; do
        break
    done

    echo "Выберите порт:"
    echo "1) 443"
    echo "2) 8443"
    echo "3) Свой"
    read -p "Ваш выбор: " port_choice

    case $port_choice in
        1) PORT=443 ;;
        2) PORT=8443 ;;
        3) read -p "Введите порт: " PORT ;;
        *) echo "Неверный выбор"; return ;;
    esac

    SECRET=$(generate_secret)

    echo "Установка зависимостей..."
    apt update
    apt install -y git curl build-essential

    echo "Скачивание MTProxy..."
    rm -rf $PROXY_DIR
    git clone https://github.com/TelegramMessenger/MTProxy $PROXY_DIR
    cd $PROXY_DIR || exit

    make

    echo "Создание сервиса..."

    cat <<EOF > /etc/systemd/system/$SERVICE_NAME.service
[Unit]
Description=MTProto Proxy
After=network.target

[Service]
ExecStart=$PROXY_DIR/objs/bin/mtproto-proxy -u nobody -p 8888 -H $PORT -S $SECRET --aes-pwd proxy-secret proxy-multi.conf -M 1 --domain $DOMAIN
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable $SERVICE_NAME
    systemctl restart $SERVICE_NAME

    IP=$(get_ip)

    echo ""
    echo "✅ Прокси установлен!"
    echo "IP: $IP"
    echo "Порт: $PORT"
    echo "Секрет: $SECRET"
    echo ""
    echo "Ссылка:"
    echo "tg://proxy?server=$IP&port=$PORT&secret=ee$SECRET"
}

update_proxy() {
    echo "Обновление прокси..."
    cd $PROXY_DIR || exit
    git pull
    make
    systemctl restart $SERVICE_NAME
    echo "✅ Обновлено!"
}

remove_proxy() {
    echo "Удаление прокси..."
    systemctl stop $SERVICE_NAME
    systemctl disable $SERVICE_NAME
    rm -f /etc/systemd/system/$SERVICE_NAME.service
    rm -rf $PROXY_DIR
    systemctl daemon-reload
    echo "❌ Прокси удалён"
}

menu() {
    clear
    echo "===== VPC TELEGRAM PANEL ====="
    echo "1) Установить прокси"
    echo "2) Обновить прокси"
    echo "3) Удалить прокси"
    echo "4) Выход"
    echo "=============================="

    read -p "Выберите действие: " choice

    case $choice in
        1) install_proxy ;;
        2) update_proxy ;;
        3) remove_proxy ;;
        4) exit ;;
        *) echo "Неверный выбор" ;;
    esac
}

menu