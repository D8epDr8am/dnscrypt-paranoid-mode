# dnscrypt-paranoid-mode
Автоматическая настройка DNSCrypt-Proxy для максимальной приватности и анонимности DNS-запросов.
# 🔒 DNSCrypt-Proxy Paranoid Mode

Автоматическая настройка DNSCrypt-Proxy для максимальной приватности и анонимности DNS-запросов.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/bash-5.0+-blue.svg)](https://www.gnu.org/software/bash/)

## ✨ Возможности

- 🔐 **Шифрование DNS** через DNSCrypt и DNS-over-HTTPS (DoH)
- 🎭 **Анонимизация** через relay-серверы (аналог Tor для DNS)
- 🛡️ **DNSSEC валидация** для защиты от подмены
- 🚫 **Блокировка** рекламы, трекеров и вредоносных доменов
- 📊 **No-logging** серверы без логирования запросов
- ⚡ **Кэширование** для ускорения повторных запросов
- 🔄 **Автообновление** списков блокировки

## 🚀 Быстрая установка
```bash
curl -sL https://raw.githubusercontent.com/D8epDr8am/dnscrypt-paranoid/main/install.sh | sudo bash
```

Или клонируйте репозиторий:
```bash
git clone https://github.com/D8epDr8am/dnscrypt-paranoid.git
cd dnscrypt-paranoid
sudo bash install.sh
```

## 📋 Требования

- Linux (Debian/Ubuntu/Arch/Fedora)
- DNSCrypt-Proxy установлен (`sudo apt install dnscrypt-proxy`)
- Root права для установки

## 🔍 Проверка работы

После установки проверьте DNS:
```bash
# Базовая проверка
dig google.com

# Проверка Q-Name Minimisation
dig +short txt qnamemintest.internet.nl

# Проверка утечек DNS
curl -s https://raw.githubusercontent.com/macvk/dnsleaktest/master/dnsleaktest.sh | bash
```

**Веб-проверка:**
- https://dnsleaktest.com
- https://ipleak.net
- https://www.dnsleaktest.org

## 📁 Файлы конфигурации

- Основной конфиг: `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`
- Логи: `/var/log/dnscrypt-proxy/`
- Блокировочные списки: `/etc/dnscrypt-proxy/blocked-*.txt`
- Автообновление: `/etc/cron.weekly/dnscrypt-blocklists`

## ⚙️ Управление
```bash
# Перезапуск
sudo systemctl restart dnscrypt-proxy

# Статус
sudo systemctl status dnscrypt-proxy

# Проверка конфига
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check

# Обновление списков блокировки
sudo /etc/cron.weekly/dnscrypt-blocklists

# Мониторинг логов
sudo tail -f /var/log/dnscrypt-proxy/query.log
```

## 🎛️ Настройка

### Отключить анонимизацию (для скорости)

Откройте `/etc/dnscrypt-proxy/dnscrypt-proxy.toml` и закомментируйте:
```toml
# anonymized_dns = { routes = [...] }
```

Перезапустите: `sudo systemctl restart dnscrypt-proxy`

### Изменить DNS серверы
```toml
server_names = [
    'cloudflare',
    'quad9-dnscrypt-ip4-nofilter-pri',
    'nixnet-uncensored-lv'
]
```

Список доступных серверов: https://dnscrypt.info/public-servers

### Автоматический выбор серверов

Закомментируйте `server_names` — dnscrypt-proxy автоматически выберет лучшие серверы.

## 🔧 Решение проблем

### DNS не резолвит
```bash
# Остановите systemd-resolved если конфликтует
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved

# Проверьте порт 53
sudo ss -tulpn | grep :53
```

### Медленная скорость

- Уменьшите количество relay в `anonymized_dns`
- Отключите IPv6: `block_ipv6 = true`
- Увеличьте кэш: `cache_size = 16384`

### Восстановить бэкап
```bash
sudo cp /etc/dnscrypt-proxy/dnscrypt-proxy.toml.backup.* /etc/dnscrypt-proxy/dnscrypt-proxy.toml
sudo systemctl restart dnscrypt-proxy
```

Подробнее: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## 📖 Документация

- [Инструкция по установке](docs/INSTALL.md)
- [Руководство по настройке](docs/CONFIGURATION.md)
- [Решение проблем](docs/TROUBLESHOOTING.md)

## 🛡️ Безопасность

Что защищает этот конфиг:

- ✅ Провайдер **НЕ видит** ваши DNS запросы
- ✅ DNS трафик **зашифрован** (DNSCrypt/DoH)
- ✅ Запросы **анонимизированы** через relay
- ✅ Серверы **не логируют** запросы
- ✅ **DNSSEC** защита от подмены
- ✅ Блокировка рекламы и трекеров
- ✅ Защита от **DNS fingerprinting**

## 🤝 Вклад

Баг-репорты и pull requests приветствуются на GitHub: https://github.com/YOUR_USERNAME/dnscrypt-paranoid

## 📜 Лицензия

MIT License - см. [LICENSE](LICENSE)

## 🙏 Благодарности

- [DNSCrypt](https://dnscrypt.info/) за отличный инструмент
- [Hagezi DNS Blocklists](https://github.com/hagezi/dns-blocklists) за списки блокировки
- Сообществу за вклад в приватность

## ⚠️ Disclaimer

Этот инструмент предназначен для повышения приватности DNS. Автор не несёт ответственности за использование в незаконных целях.

---

**Сделано с ❤️ для приватного интернета**
