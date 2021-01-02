使用frpc进行内网穿透
=========================

> [frp](https://github.com/fatedier/frp)是一个专注于内网穿透的反向代理应用，可用于TCP, UDP, HTTP, HTTPS等多种协议。将内网服务安全的通过腾讯云主机暴露到公网中。具体可看[frp官方文档](https://github.com/fatedier/frp/blob/dev/README_zh.md)。


#### 下载
```bash
VERSION=0.34.2
curl -LJO  https://github.com/fatedier/frp/releases/download/v${VERSION}/frp_${VERSION}_linux_amd64.tar.gz
tar -zxvf frp_${VERSION}_linux_amd64.tar.gz
cp frp_${VERSION}_linux_amd64/frpc /usr/local/bin/
cp frp_${VERSION}_linux_amd64/frps /usr/local/bin/
chmod +x /usr/local/bin/frpc
chmod +x /usr/local/bin/frps
```

#### 服务端配置

服务端安装在云主机上。

```bash
mkdir -p /etc/frps/
mkdir -p /var/log/frps
chmod -R 777 /var/log/frps


TOKEN=
cat > /etc/frps/common.ini <<EOF
[common]
bind_addr = 0.0.0.0
bind_port = 7000
vhost_https_port = 8443
vhost_http_port = 8080
token = ${TOKEN}
log_file = /var/log/frps/common.log
log_level = info 
log_max_days = 3
EOF

cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=Frp Server Service
After=network.target

[Service]
Type=simple
User=nobody
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/frps -c /etc/frps/common.ini

[Install]
WantedBy=multi-user.target
EOF
systemctl enable frps
systemctl start frps
```

#### 客户端配置

客户端安装在本地机器上。

```bash
mkdir -p /etc/frpc/
mkdir -p /var/log/frpc
chmod -R 777 /var/log/frpc

# 配置token
TOKEN=
cat > /etc/frpc/common.ini <<EOF
[common]
server_addr = 106.55.148.123
server_port = 7000
token = ${TOKEN}
log_file = /var/log/frpc/common.log
log_level = info
log_max_days = 3
use_compression = true

[cloud]
type = https
local_ip = 172.16.0.12
local_port = 8006
custom_domains = cloud.taozhang.net.cn

[k8s]
type = http
local_ip = 172.16.0.200
local_port = 80
# 下面是我本地的一些域名
custom_domains = k8s.taozhang.net.cn,pg.taozhang.net.cn,keycloak.taozhang.net.cn,pma.taozhang.net.cn,redis.taozhang.net.cn,harbor.taozhang.net.cn,kibana.taozhang.net.cn,minio.taozhang.net.cn,kiali.taozhang.net.cn,grafana.taozhang.net.cn,drone.taozhang.net.cn,git.taozhang.net.cn,traefik.taozhang.net.cn,micro.taozhang.net.cn,jaeger.taozhang.net.cn,book.taozhang.net.cn,draw.taozhang.net.cn

[gitea]
type = tcp
local_ip = 172.16.0.200
local_port = 422
remote_port = 8032
EOF

cat > /etc/systemd/system/frps.service <<EOF
[Unit]
Description=Frp client Service
After=network.target
[Service]
Type=simple
User=nobody
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/frps -c /etc/frpc/common.ini
[Install]
WantedBy=multi-user.target
EOF
systemctl enable frps
systemctl start frps
```

frp服务端的配置比较简单，客户端的比较复杂，具体的配置见[官方例子](https://gofrp.org/docs/examples/)。