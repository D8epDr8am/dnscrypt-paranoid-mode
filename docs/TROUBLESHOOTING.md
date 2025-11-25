# Решение проблем

## DNS не резолвит

### Проверка службы
```bash
sudo systemctl status dnscrypt-proxy
```

Если не запущена:
```bash
sudo systemctl start dnscrypt-proxy
```

### Конфликт с systemd-resolved
```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
```

### Проверка порта 53
```bash
sudo ss -tulpn | grep :53
```

Если порт занят другой службой — остановите её.

## Медленная скорость

### 1. Отключить анонимизацию

В `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`:
```toml
# anonymized_dns = { routes = [...] }
```

### 2. Увеличить кэш
```toml
cache_size = 16384
cache_min_ttl = 3600
```

### 3. Выбрать ближайшие серверы
```toml
server_names = [
    'cloudflare',
    'quad9-dnscrypt-ip4-nofilter-pri'
]
```

### 4. Отключить IPv6
```toml
block_ipv6 = true
```

## Ошибки в конфиге

### Проверка синтаксиса
```bash
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check
```

### Восстановить бэкап
```bash
sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy.toml.backup.* /etc/dnscrypt-proxy/dnscrypt-proxy.toml
sudo systemctl restart dnscrypt-proxy
```

## Блокировка не работает

### Проверить списки
```bash
ls -lh /etc/dnscrypt-proxy/blocked-*.txt
```

Если файлы пустые — обновите:
```bash
sudo /etc/cron.weekly/dnscrypt-blocklists
```

### Проверить логи блокировки
```bash
sudo tail -f /var/log/dnscrypt-proxy/blocked-names.log
```

## DNS leak detected

Это **нормально** если вы видите:
- Cloudflare (AS13335)
- Quad9 (AS19281)
- Relay-серверы (Woodynet, etc.)

Это **НЕ нормально** если вы видите своего провайдера.

### Дополнительная проверка
```bash
dig +short txt qnamemintest.internet.nl
```

Должно быть: `"HOORAY - Q name minimisation is enabled"`

## Логи для отладки
```bash
# Query log
sudo tail -f /var/log/dnscrypt-proxy/query.log

# System log
sudo journalctl -u dnscrypt-proxy -f

# Ошибки
sudo journalctl -u dnscrypt-proxy -p err
```

## Не удаётся установить

### Отсутствует dnscrypt-proxy

Установите вручную:

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install dnscrypt-proxy
```

**Arch:**
```bash
sudo pacman -S dnscrypt-proxy
```

### Ошибка скачивания файлов

Скачайте вручную:
```bash
cd /tmp
git clone https://github.com/D8epDr8am/dnscrypt-paranoid.git
cd dnscrypt-paranoid
sudo bash install.sh
```

## Получить помощь

Создайте issue на GitHub с:
- Вывод `sudo systemctl status dnscrypt-proxy`
- Вывод `sudo dnscrypt-proxy -check`
- Содержимое `/var/log/dnscrypt-proxy/`

https://github.com/D8epDr8am/dnscrypt-paranoid-mode/issues
