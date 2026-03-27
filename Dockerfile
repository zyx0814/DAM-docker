# 使用 PHP 7.4-FPM 作为基础镜像 (基于 Debian Bullseye)
FROM php:7.4-fpm-bullseye

# 设置工作目录
WORKDIR /var/www/html

# 设置环境变量以避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive


# 合并安装步骤以减少层数并提高稳定性
# 增加重试机制和网络容错，如果安装失败则回退到默认源
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    (apt-get update -y || (sleep 5 && apt-get update -y)) && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    unzip \
    nginx \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libwebp-dev \
    libonig-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    libtidy-dev \
    libxslt1-dev \
    libmagickwand-dev \
    libicu-dev \
    libbz2-dev \
    libxml2-dev \
    libreadline-dev \
    libheif-dev \
    libopenjp2-7-dev \
    imagemagick \
    ffmpeg \
    libraw-bin \
    dcraw \
    ghostscript \
    && rm -rf /var/lib/apt/lists/*

# 配置并安装 PHP 扩展
# 包括要求的扩展及常用的基础扩展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        mbstring \
        gd \
        zip \
        curl \
        tidy \
        xsl \
        mysqli \
        opcache \
        pdo_mysql \
        intl \
        exif \
        sockets \
        pcntl \
        gettext \
        bz2 \
        soap \
        xml \
        simplexml \
        xmlreader \
        xmlwriter \
        dom \
        readline \
        posix

# 安装 PECL 扩展: imagick, redis
RUN pecl install imagick redis \
    && docker-php-ext-enable imagick redis

# 配置 ImageMagick 允许处理相关格式 (RAW, PDF, PSD等)
RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/g' /etc/ImageMagick-6/policy.xml && \
    sed -i 's/rights="none" pattern="EPS"/rights="read|write" pattern="EPS"/g' /etc/ImageMagick-6/policy.xml && \
    sed -i 's/rights="none" pattern="PS"/rights="read|write" pattern="PS"/g' /etc/ImageMagick-6/policy.xml && \
    sed -i 's/rights="none" pattern="XPS"/rights="read|write" pattern="XPS"/g' /etc/ImageMagick-6/policy.xml && \
    # 增加对 RAW 格式的宽限配置
    sed -i 's/rights="none" pattern="RAW"/rights="read|write" pattern="RAW"/g' /etc/ImageMagick-6/policy.xml || true

# 安装 Composer (PHP 依赖管理工具)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 复制 Nginx 配置模板并清理默认配置
RUN mkdir -p /etc/nginx/templates && \
    rm -f /etc/nginx/sites-enabled/default
COPY ./config/nginx-http.conf /etc/nginx/templates/nginx-http.conf
COPY ./config/nginx-https.conf /etc/nginx/templates/nginx-https.conf

# 复制优化的 PHP 和 PHP-FPM 配置
COPY ./config/custom-php.ini /usr/local/etc/php/conf.d/99-custom.ini
COPY ./config/php-fpm-www.conf /usr/local/etc/php-fpm.d/www.conf

# 复制启动脚本
COPY ./config/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 暴露 80 和 443 端口
EXPOSE 80 443

# 使用自定义启动脚本
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
