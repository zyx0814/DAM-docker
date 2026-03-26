#!/bin/sh

set -e

# 检查SSL证书并配置HTTPS
if [ -f /etc/nginx/ssl/fullchain.pem ] && [ -f /etc/nginx/ssl/privkey.pem ] && [ ! -f /etc/nginx/sites-enabled/*-ssl.conf ] ; then
        ln -s /etc/nginx/sites-available/private-ssl.conf /etc/nginx/sites-enabled/
        sed -i "s/#return 301/return 301/g" /etc/nginx/sites-available/default.conf
fi

# 执行传入的命令
exec "$@"
