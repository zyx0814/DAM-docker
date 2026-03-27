# PHP 7.4 + Nginx 全功能多媒体 Web 服务容器

这是一个高度优化的 Docker 环境，专为处理图像、视频和专业媒体资产而设计。它集成了 PHP 7.4-FPM、Nginx、ImageMagick、FFmpeg，并支持多架构（AMD64/ARM64）。基于 Debian Bullseye 以获得更好的现代格式（如 HEIC/AVIF）支持。

## 核心特性

- **PHP 7.4-FPM**: 预装了所有必需的基础扩展以及 `mbstring`, `gd`, `zip`, `curl`, `tidy`, `xsl`, `imagick`, `redis`, `mysqli` 等。
- **Nginx**: 高性能 Web 服务器，支持 HTTP/HTTPS。
- **ImageMagick**: 支持各种专业图像格式，包括 RAW, CR2, DNG, PSD, WebP, TIFF, HEIC/HEIF 等。
- **FFmpeg**: 完整的视频处理支持，可用于转码、生成缩略图等。
- **多平台支持**: 兼容 `linux/amd64` 和 `linux/arm64` (Apple Silicon)。
- **动态 HTTPS**: 根据挂载目录是否存在证书文件，自动切换 HTTP 或 HTTPS 配置。
- **性能优化**: 预配置了优化的 PHP-FPM 进程管理和 PHP Opcache。
- **无日志模式**: 容器内默认不生成日志文件，防止存储空间被占满。

## 快速开始

### 1. 运行服务
确保您已安装 Docker 和 Docker Compose，然后在项目根目录下运行：

```bash
docker-compose up -d --build
```

启动后，您可以通过 `http://localhost:8080` 访问服务。

### 2. 启用 HTTPS (可选)
本环境支持动态切换到 HTTPS。只需在项目根目录执行以下操作：

1. 创建 `ssl` 文件夹。
2. 将证书文件命名为 `server.crt` 和 `server.key` 并存入 `ssl` 文件夹。
3. 运行 `docker-compose up -d`。

如果 `ssl` 目录下存在证书，容器启动时会自动切换到 HTTPS 配置并强制重定向 80 端口。

## 目录结构

- `Dockerfile`: 容器构建定义。
- `docker-compose.yml`: 编排配置，定义端口映射和卷挂载。
- `config/`: 配置文件目录。
  - `entrypoint.sh`: 容器启动脚本，包含动态 SSL 切换逻辑。
  - `nginx-http.conf`: HTTP 模式下的 Nginx 配置模板。
  - `nginx-https.conf`: HTTPS 模式下的 Nginx 配置模板。
  - `custom-php.ini`: 优化的 PHP 配置文件。
  - `php-fpm-www.conf`: 优化的 PHP-FPM 进程池配置。
- `index.php`: 测试页面，显示 `phpinfo()`。

## 媒体处理示例

### 处理 PSD/HEIC 转换为 JPG (PHP)
```php
// 处理 PSD
$im = new Imagick('input.psd[0]');
$im->setImageFormat('jpg');
$im->writeImage('output_psd.jpg');

// 处理 HEIC
$im = new Imagick('input.heic');
$im->setImageFormat('jpg');
$im->writeImage('output_heic.jpg');
```

### 处理视频缩略图 (FFmpeg)
```bash
# 在容器内运行
ffmpeg -i video.mp4 -ss 00:00:01 -vframes 1 thumb.jpg
```

## PHP CLI 支持
容器预装了 **Composer** 和必备的 CLI 扩展（readline, posix, pcntl）。

- **运行 Composer**: `docker exec -it php74-web-service composer <command>`
- **进入容器**: `docker exec -it php74-web-service bash`

## 日志说明
为了保持容器精简，所有 Nginx 和 PHP 的日志均已重定向到 `/dev/null`。如需开启，请修改相应的配置文件（`nginx-http.conf`, `nginx-https.conf`, `custom-php.ini`）并重建容器。
