# 1. 必须用 ARM64 基础镜像
FROM arm64v8/centos:7

# 2. 先安装 wget + 基础工具（解决无curl问题）
RUN yum install -y wget && \
    rm -rf /etc/yum.repos.d/* && \
    wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-altarch-7.repo && \
    wget -O /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7-arm64.repo && \
    yum clean all && yum makecache

# 3. 安装仓库
RUN yum -y install epel-release && \
    yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum-config-manager --enable remi-php74

# 4. 安装基础工具
RUN yum -y install \
    rsync \
    supervisor \
    ghostscript \
    ffmpeg \
    ffmpeg-devel \
    memcached \
    nginx \
    unzip \
    sqlite

# 5. 安装依赖（已删除 ARM 不支持的包）
RUN yum -y install \
    libpng* libjpeg* gd-devel \
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

# 6. 安装字体
RUN yum -y install ghostscript-fonts urw-fonts xorg-x11-font-utils

# 7. 安装 PHP 7.4
RUN yum -y install \
    php74-php-fpm \
    php74-php-cli \
    php74-php-common \
    php74-php-gd \
    php74-php-curl \
    php74-php-mysqlnd \
    php74-php-mbstring \
    php74-php-xml \
    php74-php-json \
    php74-php-intl \
    php74-php-pecl-zip \
    php74-php-pecl-imagick \
    php74-php-pecl-memcached

# 8. 清理
RUN yum clean all

# 9. Nginx 配置
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir -p /run/nginx /var/log/supervisor

# 10. 时区
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

# 11. PHP 配置
RUN ln -s /usr/bin/php74 /usr/bin/php && \
    ln -s /opt/remi/php74/root/sbin/php-fpm /usr/sbin/php-fpm && \
    sed -i 's/disable_functions = .*/disable_functions = passthru,system,chroot,chgrp,chown,shell_exec,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /etc/opt/remi/php74/php.ini && \
    sed -i 's/user = apache/user = nginx/g' /etc/opt/remi/php74/php-fpm.d/www.conf && \
    sed -i 's/group = apache/group = nginx/g' /etc/opt/remi/php74/php-fpm.d/www.conf && \
    sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g' /etc/opt/remi/php74/php-fpm.d/www.conf && \
    sed -i 's/;listen.owner = nobody/listen.owner = nginx/g' /etc/opt/remi/php74/php-fpm.d/www.conf && \
    sed -i 's/;listen.group = nobody/listen.group = nginx/g' /etc/opt/remi/php74/php-fpm.d/www.conf && \
    sed -i 's/;listen.mode = 0660/listen.mode = 0660/g' /etc/opt/remi/php74/php-fpm.d/www.conf

RUN echo "cgi.fix_pathinfo=1" > /etc/opt/remi/php74/php.d/custom.ini && \
    echo "upload_max_filesize = 512M" >> /etc/opt/remi/php74/php.d/custom.ini && \
    echo "post_max_size = 512M" >> /etc/opt/remi/php74/php.d/custom.ini && \
    echo "memory_limit = 512M" >> /etc/opt/remi/php74/php.d/custom.ini && \
    echo "max_execution_time = 3600" >> /etc/opt/remi/php74/php.d/custom.ini && \
    echo "max_input_time = 3600" >> /etc/opt/remi/php74/php.d/custom.ini && \
    sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
        -e "s/pm.max_children = 5/pm.max_children = 50/g" \
        -e "s/pm.start_servers = 2/pm.start_servers = 10/g" \
        -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 10/g" \
        -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 30/g" \
        -e "s/;pm.max_requests = 500/pm.max_requests = 500/g" \
        /etc/opt/remi/php74/php-fpm.d/www.conf

VOLUME /var/www/html
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisord.conf"]