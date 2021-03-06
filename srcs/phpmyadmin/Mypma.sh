#!/bin/sh

sed s/__DB_HOST__/$DB_HOST/g /var/www/phpmyadmin/config.inc.php -i

mkdir -p /etc/telegraf
telegraf -sample-config --input-filter cpu:mem:net:swap:diskio --output-filter influxdb > /etc/telegraf/telegraf.conf
sed -i s/'# urls = \["http:\/\/127.0.0.1:8086"\]'/'urls = ["http:\/\/influxdb:8086"]'/ /etc/telegraf/telegraf.conf
sed -i s/'# database = "telegraf"'/'database = "phpmyadmin"'/ /etc/telegraf/telegraf.conf
sed -i s/'omit_hostname = false'/'omit_hostname = true'/ /etc/telegraf/telegraf.conf

nginx
php-fpm7
telegraf &

while sleep 60; do 
    ps aux | grep telegraf | grep -q -v grep
    PROCESS_1_STATUS=$?
    ps aux | grep nginx | grep -q -v grep
    PROCESS_2_STATUS=$?
    ps aux | grep php-fpm | grep -q -v grep
    PROCESS_3_STATUS=$?
    if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 -o $PROCESS_3_STATUS -ne 0 ]; then
        echo "One of the process has already exited."
        exit 1
    fi 
done