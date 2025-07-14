# 欧奥DAM Docker 部署

### 实现数据持久化——创建数据目录并在启动时挂载
```
mkdir /data
docker run -d -p 80:80 --restart=always -v /data:/var/www/html oaooa/dam 
```
### 以https方式启动
- 使用已有ssl证书
- 证书格式必须是 fullchain.pem  privkey.key
```
   docker run -d -p 443:443 --restart=always  -v "你的证书目录":/etc/nginx/ssl -v /data:/var/www/html --name DAM oaooa/dam
 ```
### 使用docker-compose同时部署数据库（推荐）
```
git clone https://github.com/zyx0814/Dam-docker.git
cd ./Dam-docker/compose/
docker-compose up -d
```
- 默认root密码：root;可以修改docker-compose.yaml，设置数据库root密码（MYSQL_ROOT_PASSWORD=root密码）
- 默认数据库端口3307；站点端口8088；根据需要修改docker-compose.yaml中的ports
- 修改mysql_db.txt,mysql_user.txt,mysql_password.txt 修改数据库名称，用户和密码
- **注：同时部署数据库时，数据库链接地址可以使用数据库容器名(db)**