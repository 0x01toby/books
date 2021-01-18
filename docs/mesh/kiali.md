kiali可观测平台
====

> kiali为istio提供了查看相关服务与配置提供了统一化的可视化界面，并且能在其中展示他们的关联；同时还提供了界面, 可以很方便的验证 istio 配置与错误提示. 

## 安装

```bash
helm install \
--set cr.create=true \
--set cr.namespace=istio-system \
--namespace istio-system \
--repo https://kiali.org/helm-charts \
kiali-operator \
kiali-operator

# 配置OIDC配置
kubectl create secret generic kiali --from-literal="oidc-secret=${CLIENT_SECRET}" -n istio-system
```

下面是个人的配置，可以根据[官方的配置](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml)文件去自定义．
```bash
kubectl -n kube-monitor apply -f https://www.taozhang.net.cn/mesh/files/kiali/deploy.yaml
```

![kiali示意图](images/20210116232801.png)