harbor镜像托管
==================

> Harbor是由VMware公司开源的企业级的Docker Registry管理项目，相比docker官方拥有更丰富的权限权利和完善的架构设计，适用大规模docker集群部署提供仓库服务。

## 安装部署

```yaml
#!/bin/bash
wget https://github.com/goharbor/harbor/releases/download/v2.1.2/harbor-offline-installer-v2.1.2.tgz
tar -zxvf harbor-offline-installer-v2.1.2.tgz
cd harnor
cp harbor.yml.tmpl  harbor.yml
```
- 修改nginx配置
由于我的harbor是部署在nginx后面，所以需要修改common/config/nginx/nignx.conf  
注释掉proxy_set_header X-Forwarded-Proto $scheme;

- 修改外部URL
  修改common/config/core/env  
  EXT_ENDPOINT=https://harbor.taozhang.net.cn

## 配置SSO(keycloak)

| 配置项 | 配置值|
| --- | --- |
| 认证模式 | OIDC |
| OIDC供应商 | keycloak |
| OIDC Endpoint |https://keycloak.taozhang.net.cn/auth/realms/k8s-openid|
| OIDC 客户端标识 | harbor(keycloak配置) |
| OIDC 客户端密码 | 密码(keycloak配置) |
| 组名称  | groups |
| OIDC Scope | openid,email,profile,offline_access |





