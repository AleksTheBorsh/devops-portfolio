# Личный VPN сервер (VLESS + TCP + REALITY) через 3X-UI

Этот проект разворачивает удобную веб-панель 3X-UI для управления VPN-соединениями на базе ядра Xray. Используется протокол VLESS в связке с маскировкой REALITY, что делает трафик невидимым для систем глубокого анализа (DPI) и блокировок.

## Быстрый старт
Запуск контейнера (используется `network_mode: "host"` для максимальной производительности сети):
```bash
docker compose up -d
##Веб интерфейс
Обязательно проверить доступность порта 443 и не занят ли он другим процессом (ss -tulpn | grep :443)
Адрес веб-интерфейса http://ваш_адрес:2053

## Настройки Inbound (Подключения) в панели 3X-UI
При добавлении нового подключения (Inbound) выставляем следующие параметры:
Базовые настройки:
  Протокол: vless
  Порт: 443
  Sniffing: Включен -> отмечаем http, tls, quic -> отмечаем Route Only.
Секция Reality:
  Reality: Включен (тумблер)
  Dest / Target: www.microsoft.com:443
  Server Names / SNI: www.microsoft.com (то же самое, без порта)
  Private / Public Key: Сгенерировать новые.
  Short IDs: Вписать один короткий (например: 1a2b3c4d).
  Секция Client (Настройки пользователя):
  Email: Любое понятное имя (например, MyPhone)
  Flow: xtls-rprx-vision


Такие сервисы как Gemini, ChatGPT и Claude часто блокируют IP-адреса дата-центров (VDS/VPS). Чтобы получить к ним доступ через ваш VPN, необходимо точечно направить этот трафик через сеть Cloudflare WARP.
Настройка Xray (в веб-панели)
Перейдите в веб-интерфейс 3X-UI: Настройки X-ray-> Расширенный шаблон

1. Добавление канала WARP (outbounds)
Найдите массив outbounds и добавьте в него новый узел для маршрутизации трафика на локальный SOCKS5:

JSON
{
  "tag": "warp",
  "protocol": "socks",
  "settings": {
    "servers": [
      {
        "address": "127.0.0.1",
        "port": 1080
      }
    ]
  }
}
(Важно: Убедитесь, что правило с тегом direct остается самым первым в списке outbounds, чтобы обычный трафик шел напрямую).

2. Настройка маршрутов (routing)
Найдите массив rules внутри блока routing и добавьте правило, которое будет отлавливать запросы к ИИ-сервисам и отправлять их в канал warp:

JSON
{
  "type": "field",
  "outboundTag": "warp",
  "domain": [
    "domain:gemini.google.com",
    "domain:generativelanguage.googleapis.com",
    "domain:googleapis.com", 
    "domain:gstatic.com",
    "domain:firebaseio.com",
    "domain:app-measurement.com",
    "geosite:openai",
    "geosite:anthropic"
  ]
}
