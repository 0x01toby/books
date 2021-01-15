helm工具
=================

> 管理 Kubernetes 应用程序——Helm Charts 帮助您定义、安装和升级最复杂的 Kubernetes 应用程序。

## 安装部署

```yaml
#!/usr/bin/env bash
curl -O https://get.helm.sh/helm-v3.4.0-linux-amd64.tar.gz
tar zxvf helm-v3.4.0-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/
chmod +x /usr/local/bin/helm
rm -rf linux-amd64
rm -rf helm-v3.4.0-linux-amd64.tar.gz
helm repo add stable https://charts.helm.sh/stable
helm plugin install https://github.com/chartmuseum/helm-push.git
```