# Руководство по настройке

## Основной конфиг

Файл: `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`

## Отключение анонимизации (для скорости)

Закомментируйте секцию:
```toml
# anonymized_dns = { routes = [...] }
```

Перезапустите: `sudo systemctl restart dnscrypt-proxy`

## Выбор DNS серверов

### Автоматический выбор (рекомендуется)

Закомментируйте `server_names`:
```toml
# server_names = [...]
```

DNSCrypt автоматически выберет лучшие серверы.

### Ручной выбор
```toml
server_names = [
    'cloudflare',
    'cloudflare-security',
    'quad9-dnscrypt-ip4-nofilter-pri',
    'nixnet-uncensored-lv'
]
```

Список серверов: https://dnscrypt.info/public-servers

## Настройка кэша
```toml
cache_size = 8192          # Увеличьте для большего кэша
cache_min_ttl = 2400       # Минимальное время жизни записи
cache_max_ttl = 86400      # Максимальное время жизни
```

## Логирование

### Включить query log
```toml
[query_log]
file = '/var/log/dnscrypt-proxy/query.log'
format = 'tsv'
```

Просмотр: `sudo tail -f /var/log/dnscrypt-proxy/query.log`

### Отключить логирование

Закомментируйте секцию `[query_log]`

## Блокировка

### Изменить списки блокировки
```toml
[blocked_names]
blocked_names_file = '/etc/dnscrypt-proxy/custom-blocklist.txt'
```

### Отключить блокировку

Закомментируйте секции `[blocked_names]` и `[blocked_ips]`

## Relay серверы

### Добавить больше relay
```toml
anonymized_dns = { routes = [
    { server_name='*', via=['anon-cs-fr', 'anon-cs-de', 'anon-cs-se', 'anon-cs-nl', 'anon-cs-ch'] }
]}
```

### Использовать relay только для определённых серверов
```toml
anonymized_dns = { routes = [
    { server_name='cloudflare', via=['anon-cs-fr'] },
    { server_name='quad9-*', via=['anon-cs-de'] }
]}
```

## IPv6

### Включить IPv6
```toml
ipv6_servers = true
block_ipv6 = false
```

## Применение изменений

После любых изменений:
```bash
# Проверка конфига
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check

# Перезапуск
sudo systemctl restart dnscrypt-proxy
```
