#!/bin/bash

if ! [ $(id -u) = 0 ]; then
    echo "Esse script deve ser executado pelo root!"
    exit 1
fi

reg='^[0-9]+$'
if ! [[ $1 =~ $reg ]]; then
    echo "A cota deve ser um numero!"
    exit 1
fi

quotas_path="/var/local/print-quotas"
logs_path="/var/local/print-logs"
renew_quota_path="/usr/bin/print-renew.sh"
max_quota_path="/var/local/print-max-quota"
max_quota=$1

# create files with users and quotas
touch $quotas_path
chown root:root $quotas_path
chmod 744 $quotas_path
awk -v maxquota=$1 -F: '$2 ~ "\$" {print $1"="maxquota}' /etc/shadow | tee --append $quotas_path
echo "Arquivo de cotas de usuários criado"

touch $logs_path
chown root:root $logs_path
chmod 744 $logs_path
echo "Arquivo de logs dos usuários criado"

touch $max_quota_path
chown root:root $max_quota_path
chmod 744 $max_quota_path
echo "$max_quota" | tee $max_quota_path
echo "Arquivo com cota padrão criado"

chown root:root print-info-user.sh
chmod 744 print-info-user.sh
cp print-info-user.sh /usr/bin/print-info-user.sh

chown root:root print-renew.sh
chmod 744 print-renew.sh
cp print-renew.sh /usr/bin/print-renew.sh

chown root:root print.sh
chmod 744 print.sh
cp print.sh /usr/bin/print.sh
echo "Scripts copiados para bin"

# setup cron
crontab_call=$(crontab -l)
if [ "$?" -eq 0 ]; then
    crontab -l > "cron.temp"
fi

echo "0 0 1 * * bash $renew_quota_path"
crontab "cron.temp"
rm "cron.temp"
echo "Cron configurado"
