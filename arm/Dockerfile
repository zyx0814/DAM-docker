FROM kylinv10/kylin:b09

# ==============================================
# 【修复】麒麟V10专用：禁用不兼容源，使用官方源
# ==============================================
RUN echo "fastestmirror=1" >> /etc/yum/pluginconf.d/fastestmirror.conf && \
    yum install -y wget yum-utils && \
    yum clean all && yum makecache

# ==============================================
# 【关键修复】卸载/屏蔽 CentOS7 不兼容源（EPEL/Remi）
# ==============================================
RUN rpm -e --nodeps epel-release 2>/dev/null || true && \
    rm -rf /etc/yum.repos.d/epel*.repo /etc/yum.repos.d/remi*.repo

# ==============================================
# 【麒麟原生】安装系统依赖（ARM/龙芯全兼容）
# ==============================================
RUN yum -y install \
    rsync supervisor ghostscript ffmpeg ffmpeg-devel memcached nginx unzip sqlite \
    libpng libjpeg-turbo gd-devel \
    OpenEXR-libs gdk-pixbuf2 ilmbase \
    libwmf libwmf-lite glib2 lcms2 lcms2-devel \
    gtk2 gtk2-devel gimp gimp-devel \
    libtiff libtiff-devel cfitsio cfitsio-devel \
    exiv2 exiv2-devel gtkimageview gtkimageview-devel \
    djvulibre djvulibre-devel fftw3 fftw3-devel \
    openexr openexr-devel libzstd libzstd-devel \
    transfig transfig-devel jbigkit jbigkit-devel \
    perl-Archive-Zip libwebp libwebp-devel libwebp-tools \
    freetype freetype-devel libraw libraw-devel \
    ImageMagick ImageMagick-devel

# 字体
RUN yum -y install ghostscript-fonts urw-fonts xorg-x11-font-utils

# ==============================================
# 【麒麟官方源】原生安装 PHP7.4（无兼容问题）
# ==============================================
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

# Nginx 日志
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir -p /run/nginx /var/log/supervisor

# 时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

ADD conf/supervisord.conf /etc/supervisord.conf

RUN rm -rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/ssl /var/www/html && \
    chown -R nginx:root /var/www && chmod -R g=u /var/www

ADD conf/nginx-site.conf /etc/nginx/sites-available/default.conf
ADD conf/nginx-site-ssl.conf /etc/nginx/sites-available/default-ssl.conf
ADD conf/private-ssl.conf /etc/nginx/sites-available/private-ssl.conf
RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# ==============================================
# PHP 配置（适配麒麟原生 PHP，路径修正）
# ==============================================
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
CMD ["/usr/bin/supervisord","-n","-c",""/etc/supervisord.conf"]