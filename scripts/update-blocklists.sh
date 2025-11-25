#!/bin/bash
#
# DNSCrypt-Proxy Blocklist Updater
# Автоматически обновляет списки блокировки
#

set -e

BLOCKED_NAMES="/etc/dnscrypt-proxy/blocked-names.txt"
BLOCKED_IPS="/etc/dnscrypt-proxy/blocked-ips.txt"

echo "[$(date)] Updating DNSCrypt blocklists..."

# Скачивание списков
wget -q https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro.txt -O "$BLOCKED_NAMES.tmp"
wget -q https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt -O "$BLOCKED_IPS.tmp"

# Проверка что файлы не пустые
if [ -s "$BLOCKED_NAMES.tmp" ] && [ -s "$BLOCKED_IPS.tmp" ]; then
    mv "$BLOCKED_NAMES.tmp" "$BLOCKED_NAMES"
    mv "$BLOCKED_IPS.tmp" "$BLOCKED_IPS"
    
    # Перезагрузка конфига
    systemctl reload dnscrypt-proxy
    
    echo "[$(date)] Blocklists updated successfully"
    logger "DNSCrypt blocklists updated successfully"
else
    echo "[$(date)] Error: Downloaded files are empty!"
    logger "DNSCrypt blocklists update failed"
    rm -f "$BLOCKED_NAMES.tmp" "$BLOCKED_IPS.tmp"
    exit 1
fi
