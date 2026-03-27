#!/bin/sh

# 检查证书是否存在，并动态切换 Nginx 配置
if [ -f "/etc/nginx/ssl/server.crt" ] && [ -f "/etc/nginx/ssl/server.key" ]; then
    echo "Found SSL certificates. Enabling HTTPS config."
    cp /etc/nginx/templates/nginx-https.conf /etc/nginx/conf.d/default.conf
else
    echo "SSL certificates not found. Using HTTP config."
    cp /etc/nginx/templates/nginx-http.conf /etc/nginx/conf.d/default.conf
fi

# 启动 PHP-FPM
php-fpm -D

# 启动 Nginx (在前台运行以防止容器退出)
nginx -g "daemon off;"
