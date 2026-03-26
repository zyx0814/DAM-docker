FROM kylinv10/kylin:b09

# ==============================
# 【修复1】跳过不存在的文件 + 极简依赖
# ==============================
RUN yum install -y wget && \
    yum clean all && \
    yum makecache

# ==============================
# 【修复2】彻底屏蔽所有第三方源冲突
# ==============================
RUN rpm -e --nodeps epel-release remi-release 2>/dev/null || true && \
    rm -rf /etc/yum.repos.d/epel*.repo /etc/yum.repos.d/remi*.repo

# ==============================
# 【修复3】麒麟官方源安装全套依赖（无兼容问题）
# ==============================
RUN yum -y install \
    rsync supervisor ghostscript ffmpeg ffmpeg-devel memcached nginx unzip sqlite \
    libpng libjpeg-turbo gd-devel libwebp libwebp-devel \
    libtiff libtiff-devel freetype freetype-devel \
    ImageMagick ImageMagick-devel perl-Archive-Zip \
    ghostscript-fonts urw-fonts xorg-x11-font-utils

# ==============================
# 【修复4】麒麟原生 PHP7.4（直接安装）
# ==============================
RUN yum -y install \
    php-fpm \
    php-cli \
    php-common \
    php-gd \
    php-curl \
    php-mysqlnd \
    php-mbstring \
    php-xml \
    php-json \
    php-intl \
    php-zip \
    php-imagick \
    php-memcached

RUN yum clean all

# ==============================
# Nginx 日志与目录
# ==============================
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir -p /run/nginx /var/log/supervisor

# ==============================
# 时区
# ==============================
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# ==============================
# 配置文件
# ==============================
ADD conf/supervisord.conf /etc/supervisord.conf
RUN rm -rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/ssl /var/www/html && \
    chown -R nginx:root /var/www && chmod -R g=u /var/www

ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
ADD conf/nginx-site-ssl.conf /etc/nginx/sites-available/default-ssl.conf
ADD conf/private-ssl.conf /etc/nginx/sites-available/private-ssl.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# ==============================
# PHP 配置（麒麟原生路径）
# ==============================
RUN sed -i 's/disable_functions = .*/disable_functions = passthru,system,chroot,chgrp,chown,shell_exec,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /etc/php.ini && \
    sed -i 's/user = apache/user = nginx/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/group = apache/group = nginx/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/php-fpm.d/www.conf && \
    sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/php-fpm.d/www.conf

RUN echo "cgi.fix_pathinfo=1" > /etc/php.d/custom.ini && \
    echo "upload_max_filesize = 512M" >> /etc/php.d/custom.ini && \
    echo "post_max_size = 512M" >> /etc/php.d/custom.ini && \
    echo "memory_limit = 512M" >> /etc/php.d/custom.ini && \
    echo "max_execution_time = 3600" >> /etc/php.d/custom.ini && \
    echo "max_input_time = 3600" >> /etc/php.d/custom.ini && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = 50/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 10/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 10/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 30/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 500/g" \
        /etc/php-fpm.d/www.conf

VOLUME /var/www/html
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisord.conf"]