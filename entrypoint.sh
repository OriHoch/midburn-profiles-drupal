#!/usr/bin/env bash

rm -f /opt/bitnami/apache2/logs/error_log

cd /opt/bitnami
./ctlscript.sh start php-fpm
./ctlscript.sh start apache

watch_logs() {
    while [ ! -e "${1}" ]; do sleep 1; done
    tail -f "${1}"
}

watch_logs /opt/bitnami/apache2/logs/error_log &
while true; do
    sleep 86400
done
