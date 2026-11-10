#!/usr/bin/env bash
# [VM] Запускать на сервере: bash ~/kr2/scripts/publish-https.sh
# Сертификат + сайт kr2 в nginx (задание 3). UFW и devops-site не трогает.
set -euo pipefail
sudo -v
EV="$HOME/kr2-evidence"; mkdir -p "$EV"

# правила UFW до изменений (этап 1 регламента), файл не перезаписывается
[ -f "$HOME/ufw-before-kr2.txt" ] || sudo ufw status numbered > "$HOME/ufw-before-kr2.txt"
sudo sha256sum /etc/nginx/sites-available/devops-site > "$EV/devops-site.sha256"

# самоподписанный сертификат с SAN
if ! sudo test -f /etc/ssl/private/kr2.key; then
  sudo openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout /etc/ssl/private/kr2.key -out /etc/ssl/certs/kr2.crt \
    -subj "/CN=stats.devops.local" \
    -addext "subjectAltName=DNS:stats.devops.local"
fi
sudo chown root:root /etc/ssl/private/kr2.key
sudo chmod 600 /etc/ssl/private/kr2.key

# отдельный сайт + символическая ссылка, проверка и мягкая перезагрузка
sudo install -m 644 -o root -g root "$HOME/kr2/docs/kr2.nginx" /etc/nginx/sites-available/kr2
sudo ln -sfn /etc/nginx/sites-available/kr2 /etc/nginx/sites-enabled/kr2
sudo nginx -t
sudo systemctl reload nginx

echo "devops-site не изменён:"; sudo sha256sum -c "$EV/devops-site.sha256"
echo "PUBLISH_OK"
