#!/usr/bin/env bash
# [VM] Шаг 4.1: bash ~/kr2/scripts/final-check.sh
sudo -v
echo '$ (cd ~/devops-course-2026 && scripts/audit.sh); echo $?'
(cd ~/devops-course-2026 && scripts/audit.sh); echo $?
echo
echo '$ diff <(sudo ufw status numbered) ~/ufw-before-kr2.txt && echo "правила UFW не изменены"'
diff <(sudo ufw status numbered) ~/ufw-before-kr2.txt && echo "правила UFW не изменены"
echo
echo '$ sudo ls -l /etc/ssl/private/kr2.key ~/kr2/.env'
sudo ls -l /etc/ssl/private/kr2.key ~/kr2/.env
echo
echo '$ # поиск действующего пароля в доставленных файлах (сам пароль не выводится)'
pw=$(sed -n 's/^REDIS_PASSWORD=//p' ~/kr2/.env)
if [ -z "$pw" ]; then echo "REDIS_PASSWORD не задан"
else grep -rlF --exclude=.env -- "$pw" ~/kr2; rc=$?
     case $rc in 0) echo "ПАРОЛЬ НАЙДЕН в перечисленных файлах";;
                 1) echo "пароль в файлах проекта не найден";;
                 *) echo "ошибка поиска";; esac
fi
unset pw rc
