#!/bin/bash
#
# DNSCrypt-Proxy DNS Check Utility
# Проверяет работу DNS и анонимность
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     DNSCrypt-Proxy DNS Check                  ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}\n"

# 1. Проверка службы
echo -e "${YELLOW}[1/5] Проверка службы dnscrypt-proxy...${NC}"
if systemctl is-active --quiet dnscrypt-proxy; then
    echo -e "${GREEN}✓ Служба работает${NC}\n"
else
    echo -e "${RED}✗ Служба не запущена!${NC}"
    echo -e "Запустите: ${YELLOW}sudo systemctl start dnscrypt-proxy${NC}\n"
    exit 1
fi

# 2. Тест резолва
echo -e "${YELLOW}[2/5] Тест DNS резолва...${NC}"
if dig +short google.com @127.0.0.1 > /dev/null 2>&1; then
    RESULT=$(dig +short google.com @127.0.0.1 | head -n1)
    echo -e "${GREEN}✓ DNS работает${NC} (google.com → ${RESULT})\n"
else
    echo -e "${RED}✗ DNS не резолвит!${NC}\n"
    exit 1
fi

# 3. Проверка Q-Name Minimisation
echo -e "${YELLOW}[3/5] Проверка Q-Name Minimisation...${NC}"
QNAME=$(dig +short txt qnamemintest.internet.nl @127.0.0.1 2>/dev/null | tr -d '"')
if [[ "$QNAME" == *"HOORAY"* ]]; then
    echo -e "${GREEN}✓ Q-Name Minimisation включён${NC}\n"
else
    echo -e "${YELLOW}⚠ Q-Name Minimisation не обнаружен${NC}\n"
fi

# 4. Проверка DNSSEC
echo -e "${YELLOW}[4/5] Проверка DNSSEC...${NC}"
if dig +dnssec google.com @127.0.0.1 | grep -q "RRSIG"; then
    echo -e "${GREEN}✓ DNSSEC валидация работает${NC}\n"
else
    echo -e "${YELLOW}⚠ DNSSEC не обнаружен${NC}\n"
fi

# 5. Проверка утечек DNS
echo -e "${YELLOW}[5/5] Проверка утечек DNS...${NC}"
if command -v curl &> /dev/null; then
    echo -e "${BLUE}Запускается тест утечек DNS (может занять 10-30 сек)...${NC}\n"
    curl -s https://raw.githubusercontent.com/macvk/dnsleaktest/master/dnsleaktest.sh | bash
else
    echo -e "${YELLOW}⚠ curl не установлен, пропускаем тест утечек${NC}"
    echo -e "Проверьте вручную: ${BLUE}https://dnsleaktest.com${NC}\n"
fi

# Итог
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Проверка завершена!                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Дополнительные тесты:${NC}"
echo -e "   ${YELLOW}https://dnsleaktest.com${NC}"
echo -e "   ${YELLOW}https://ipleak.net${NC}"
echo ""
echo -e "${BLUE}📋 Логи:${NC}"
echo -e "   ${YELLOW}sudo tail -f /var/log/dnscrypt-proxy/query.log${NC}"
echo ""
```

---

## 📄 Файл 6: `LICENSE`
```
MIT License

Copyright (c) 2025 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
