# 𝒵𝒴𝐿𝒪 – мессенджер на LÖVE

Локальный мессенджер на Lua + [LÖVE 11.4](https://love2d.org). Данные хранятся на устройстве (`zylo.dat` в папке сохранений LÖVE).

## Что работает
* Заставка с логотипом → вход / регистрация (пароли: соль + 20 000 итераций SHA-256). Первый созданный аккаунт — администратор.
* Каналы «Общий», «Избранное» и чат с ботом **ZyloBot** (`/help`, `/ping`, `/time`, `/me`, `/echo`). История сохраняется.
* Админ-панель: блокировка и разблокировка пользователей.
* VPN-вкладка (WireGuard через `wg-quick`) — только Linux, root и конфиги `/etc/wireguard/zylo-<код>.conf`.
* Иконка приложения: `src/assets/icon.png` (окно), Android-набор в `icons/android/`.

## Что пока не работает
* Нет сервера и сети: сообщения между разными пользователями/устройствами не ходят.
* Голосовые и видеозвонки, истории — заглушки в коде, интерфейса нет.
* VPN на телефоне (нужен Android `VpnService`).

## Запуск
```bash
git clone https://github.com/yourname/zylo.git
cd zylo
love src
```
Или скачай `zylo.love` из артефактов GitHub Actions (job `package`) и открой его в LÖVE.

## Тесты
```bash
luarocks install busted luacheck
luacheck src test
busted test/
```

## Хук против коммита секретов
```bash
cp hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

Шрифт DejaVu Sans (`src/assets/fonts`) распространяется по своей свободной лицензии, см. `DejaVu-LICENSE.txt`.
