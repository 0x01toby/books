配置freeipa
======================

> FreeIPA是一款集成的安全信息管理解决方案。FreeIPA包含389 Directory Server MIT Kerberos, NTP, DNS, Dogtag (Certificate System)等等身份，认证和策略功能。

freeipa是为后面k8s集群的各种应用提供统一身份解决方案.

#### centos7配置freeipa

docker部署freeipa, 基本部署完。

```bash
ADMIN_PASSWORD=
DS_PASSWORD=
docker run -itd \
--name helloworld \
--entrypoint /usr/local/sbin/init \
--hostname="ipa.taozhang.net.cn"  \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
freeipa/freeipa-server:centos-8-4.8.7 \
ipa-server-install --unattended \
--domain=taozhang.net.cn \
--realm=TAOZHANG.NET.CN \
--admin-password="${ADMIN_PASSWORD}" \
--ds-password=${DS_PASSWORD} --no-ntp
```

![alt "ipa软件"](images/20210102222923.png)

#### 开启OTP认证

/ipa/ui/#/e/otptoken/search > Authentication > OTP Tokens > Add

###### 配置OTP
![alt "添加otp配置"](images/20210106112006.png)


###### 使用freeotp扫码绑定

![alt "扫码"](images/20210106112221.png "二维码已经打码")