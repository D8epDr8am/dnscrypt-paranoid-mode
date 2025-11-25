# Инструкция по установке

## Системные требования

- **ОС**: Linux (Debian/Ubuntu/Arch/Fedora/CentOS)
- **Архитектура**: x86_64, ARM, ARM64
- **Права**: root/sudo доступ
- **Соединение**: доступ к интернету

## Установка DNSCrypt-Proxy

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install dnscrypt-proxy
```

### Fedora/CentOS
```bash
sudo dnf install dnscrypt-proxy
```

### Arch Linux
```bash
sudo pacman -S dnscrypt-proxy
```

## Установка Paranoid Mode

### Вариант 1: Автоматическая установка
```bash
curl -sL https://raw.githubusercontent.com/
git clone https://github.com/D8epDr8am/dnscrypt-paranoid-mode.git
/dnscrypt-paranoid-mode/main/install.sh | sudo bash
```

### Вариант 2: Клонирование репозитория
```bash
git clone https://github.com/
git clone https://github.com/D8epDr8am/dnscrypt-paranoid-mode.git
/dnscrypt-paranoid-mode.git
cd dnscrypt-paranoid-mode
sudo bash install.sh
```

### Вариант 3: Ручная установка
```bash
# Скачать конфиг
sudo wget https://raw.githubusercontent.com/
git clone https://github.com/D8epDr8am/dnscrypt-paranoid-mode.git
/dnscrypt-paranoid-mode/main/config/dnscrypt-proxy.toml -O /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# Скачать блокировочные списки
sudo wget https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro.txt -O /etc/

dnscrypt-proxy/blocked-names.txt
sudo wget https://raw.githubusercontent.com/stamparm/ipsum/master/ipsum.txt -O /etc/dnscrypt-proxy/blocked-ips.txt

Перезапустить
sudo systemctl restart dnscrypt-proxy
## Проверка установки
```bash
# Проверка статуса
sudo systemctl status dnscrypt-proxy

# Тест DNS
dig google.com

# Автоматическая проверка
check-dns
```

## Удаление
```bash
# Восстановить бэкап
sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy.toml.backup.* /etc/dnscrypt-proxy/dnscrypt-proxy.toml

# Или удалить полностью
sudo apt remove dnscrypt-proxy
```

## Следующие шаги

- [Настройка конфигурации](CONFIGURATION.md)
- [Решение проблем](TROUBLESHOOTING.md)
