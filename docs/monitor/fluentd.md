fluentd
=============

## 安装  

以DaemonSet方式，将Fluentd安装到每个Node节点．　 
```bash
kubectl -n kube-monitor apply -f https://www.taozhang.net.cn/monitor/files/fluentd/deploy.yaml
kubectl -n kube-monitor apply -f https://www.taozhang.net.cn/monitor/files/fluentd/cm.yaml
``` 
![部署](images/20210118230804.png)