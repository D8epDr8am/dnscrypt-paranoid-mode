#!/bin/bash
#
# DNSCrypt-Proxy Paranoid Mode Installer
# https://github.com/D8epDr8am/dnscrypt-paranoid
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_RAW="https://raw.githubusercontent.com/D8epDr8am/dnscrypt-paranoid/main"

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║     DNSCrypt-Proxy Paranoid Mode Installer               ║
║     https://github.com/D8epDr8am/dnscrypt-paranoid   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}\n"

# Проверка root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[ERROR] Запустите скрипт с sudo!${NC}"
    echo -e "Используйте: ${YELLOW}sudo bash install.sh${NC}"
    exit 1
fi

# Проверка dnscrypt-proxy
if ! command -v dnscrypt-proxy &> /dev/null; then
    echo -e "${YELLOW}[WARNING] dnscrypt-proxy не найден. Устанавливаем...${NC}"
    
    if command -v apt &> /dev/null; then
        apt update && apt install -y dnscrypt-proxy
    elif command -v dnf &> /dev/null; then
        dnf install -y dnscrypt-proxy
    elif command -v pacman &> /dev/null; then
        pacman -S --noconfirm dnscrypt-proxy
    else
        echo -e "${RED}[ERROR] Не удалось определить пакетный менеджер!${NC}"
        echo "Установите dnscrypt-proxy вручную: https://github.com/DNSCrypt/dnscrypt-proxy"
        exit 1
    fi
fi

echo -e "${GREEN}[✓] dnscrypt-proxy найден: $(dnscrypt-proxy -version 2>&1 | head -n1)${NC}\n"

# Бэкап конфига
if [ -f /etc/dnscrypt-proxy/dnscrypt-proxy.toml ]; then
    BACKUP_FILE="/etc/dnscrypt-proxy/dnscrypt-proxy.toml.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}[INFO] Создание бэкапа: ${BACKUP_FILE}${NC}"
    cp /etc/dnscrypt-proxy/dnscrypt-proxy.toml "$BACKUP_FILE"
fi

# Создание директорий
echo -e "${GREEN}[1/7] Создание директорий...${NC}"
mkdir -p /var/log/dnscrypt-proxy /var/cache/dnscrypt-proxy

# Копирование/скачивание конфига
echo -e "${GREEN}[2/7] Установка конфигурации...${NC}"
if [ -f "${SCRIPT_DIR}/config/dnscrypt-proxy.toml" ]; then
    cp "${SCRIPT_DIR}/config/dnscrypt-proxy.toml" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    echo -e "${GREEN}[✓] Конфиг скопирован из локального репозитория${NC}"
else
    wget -q --show-progress "${GITHUB_RAW}/config/dnscrypt-proxy.toml" -O /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    echo -e "${GREEN}[✓] Конфиг скачан с GitHub${NC}"
fi

# Скачивание блокировочных списков
echo -e "${GREEN}[3/7] Скачивание списков блокировки...${NC}"
echo -e "${BLUE}    → Hagezi Pro Blocklist (7+ MB)${NC}"
wget -q --show-progress https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro.txt -O /etc/dnscrypt-proxy/blocked-names.txt

echo -e "${BLUE}    → IPsum Threat Intelligence (3+ MB)${NC}"
wget -q --show-progress https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt -O /etc/dnscrypt-proxy/blocked-ips.txt

# Установка скрипта обновления
echo -e "${GREEN}[4/7] Установка автообновления блокировочных списков...${NC}"
if [ -f "${SCRIPT_DIR}/scripts/update-blocklists.sh" ]; then
    cp "${SCRIPT_DIR}/scripts/update-blocklists.sh" /etc/cron.weekly/dnscrypt-blocklists
else
    cat > /etc/cron.weekly/dnscrypt-blocklists << 'EOFCRON'
#!/bin/bash
wget -q https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro.txt -O /etc/dnscrypt-proxy/blocked-names.txt
wget -q https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt -O /etc/dnscrypt-proxy/blocked-ips.txt
systemctl reload dnscrypt-proxy
logger "DNSCrypt blocklists updated"
EOFCRON
fi
chmod +x /etc/cron.weekly/dnscrypt-blocklists

# Установка скрипта проверки
echo -e "${GREEN}[5/7] Установка утилит...${NC}"
if [ -f "${SCRIPT_DIR}/scripts/check-dns.sh" ]; then
    cp "${SCRIPT_DIR}/scripts/check-dns.sh" /usr/local/bin/check-dns
    chmod +x /usr/local/bin/check-dns
    echo -e "${GREEN}[✓] Команда 'check-dns' установлена${NC}"
fi

# Права доступа
echo -e "${GREEN}[6/7] Установка прав доступа...${NC}"
chown -R dnscrypt-proxy:dnscrypt-proxy /var/log/dnscrypt-proxy /var/cache/dnscrypt-proxy 2>/dev/null || true
chmod 755 /var/log/dnscrypt-proxy /var/cache/dnscrypt-proxy

# Проверка конфига
echo -e "${GREEN}[7/7] Проверка конфигурации...${NC}"
if dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check; then
    echo -e "${GREEN}[✓] Конфигурация валидна${NC}"
else
    echo -e "${RED}[✗] Ошибка в конфигурации!${NC}"
    echo -e "${YELLOW}Восстанавливаем бэкап...${NC}"
    if [ -n "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    fi
    exit 1
fi

# Перезапуск службы
echo -e "\n${GREEN}Перезапуск dnscrypt-proxy...${NC}"
systemctl restart dnscrypt-proxy
systemctl enable dnscrypt-proxy

sleep 2
if systemctl is-active --quiet dnscrypt-proxy; then
    echo -e "${GREEN}[✓] DNSCrypt-Proxy успешно запущен!${NC}"
else
    echo -e "${RED}[✗] Ошибка запуска службы!${NC}"
    echo -e "${YELLOW}Проверьте статус: ${NC}systemctl status dnscrypt-proxy"
    exit 1
fi

# Создание README
cat > /root/dnscrypt-paranoid-README.txt << 'EOFREADME'
╔═══════════════════════════════════════════════════════════╗
║     DNSCrypt-Proxy Paranoid Mode - Установлено!          ║
╚═══════════════════════════════════════════════════════════╝

✓ Конфиг: /etc/dnscrypt-proxy/dnscrypt-proxy.toml
✓ Логи: /var/log/dnscrypt-proxy/
✓ Блокировка: включена (реклама + трекеры + малварь)
✓ Анонимизация: включена (через relay-серверы)

═══════════════════════════════════════════════════════════

БЫСТРАЯ ПРОВЕРКА:

  check-dns                    # Автоматическая проверка
  dig google.com               # Тест резолва
  dig +short txt qnamemintest.internet.nl

Веб-проверка утечек DNS:
  https://dnsleaktest.com
  https://ipleak.net

═══════════════════════════════════════════════════════════

УПРАВЛЕНИЕ:

  sudo systemctl restart dnscrypt-proxy
  sudo systemctl status dnscrypt-proxy
  sudo tail -f /var/log/dnscrypt-proxy/query.log

Документация:
  https://github.com/YOUR_USERNAME/dnscrypt-paranoid

═══════════════════════════════════════════════════════════
EOFREADME

# Финальное сообщение
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Установка завершена! 🚀              ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 Инструкции сохранены в:${NC} ${YELLOW}/root/dnscrypt-paranoid-README.txt${NC}"
echo ""
echo -e "${GREEN}✅ Быстрая проверка:${NC}"
echo -e "   ${YELLOW}check-dns${NC}                    # Автоматическая проверка"
echo -e "   ${YELLOW}dig google.com${NC}               # Тест резолва"
echo ""
echo -e "${GREEN}🌐 Веб-проверка утечек DNS:${NC}"
echo -e "   ${BLUE}https://dnsleaktest.com${NC}"
echo -e "   ${BLUE}https://ipleak.net${NC}"
echo ""
echo -e "${GREEN}📖 Документация и поддержка:${NC}"
echo -e "   ${BLUE}https://github.com/YD8epDr8am/dnscrypt-paranoid${NC}"
echo ""
