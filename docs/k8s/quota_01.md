k8s资源配额
========================

> K8s资源配额主要是用于限制命名空间/pod/容器中对象使用的资源量, 可以按照内存/cpu/数量设置资源的配额. 通过资源配额可以避免不同的命名空间之间因为资源而相互影响. 资源配额在K8s中通过ResourceQuota对象来定义的. k8s资源配额是通过Admission Control(准入控制器)来控制的, 配额管理提供了LimitRanger和ResourceQuota准入控制器, 分别作用于Pod/Container和Namespace上. 

## ResourceQuota Controller
资源配额是基于ResourceQuota Controller实现的, ResourceQuota Controller资源配额控制器用于确保资源对象在任何时候都不会超量的占用系统上的物理资源.

ResourceQuota作用对象
- 容器  
  对单个容器进行cpu和memory进行限制. 
- Pod  
  对pod内所有的容器进行资源限制.
- Namespace  
  对某个命名空间下的资源总量进行限制.
  ```yaml
    apiVersion: v1
    kind: ResourceQuota # 作用于namespace级别
    metadata:
      name: quota-cpu-memory
      namespace: ns-quota
    spec:
      hard:
        pods: 5 # 命名空间内pod最大数量
        requests.cpu: "1"
        requests.memory: 1Gi
        limits.cpu: "2"
        limits.memory: 4Gi
    ---
    apiVersion: v1
    kind: Pod
    metadata:
      name: quota-mem-cpu-demo
      namespace: ns-quota
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        resources:
        limits:
          memory: "512Mi"
          cpu: "800m" 
        requests:
          memory: "256Mi" # 如果设置2Gi就会超额, 超额就会被ResourceQuota拦截, 创建就会失败.
          cpu: "400m"
  ```

## 计算资源
CPU和内存统称为计算资源. 如下所示, 在Pod中可以通过resources来限制容器对cpu和memory的使用. 其中cpu属于可压缩资源(即使cpu资源不足, 也不会被kill掉, 会处于一种"饥饿"状态), memory属于不可压缩资源(pod会因为内存不足出现OOM, 然后被kill掉). 

```yaml
...
resources:
  limits:
    cpu: 1
    memory: 512Mi
  requests:
    cpu: 1
    memory: 1024Mi
```

## 存储资源
限制存储相关资源  

| 名称 | 描述|
|---|---|
| requests.storage | 存储资源不能超过该值 |
| persistentvolumeclaims | 最大pvc数量 |
| <storageclass-name>.storageclass.storage.k8s.io/requests.storage| 某个storage class中pvc使用限制 |
| <storageclass-name>.storageclass.storage.k8s.io/persistentvolumeclaims | 某个storage class中pvc数量限制 |

## 数量资源
  限制命名空间内的对象数量  

  | 名称 | 描述 |
  | --- | --- |
  | configmaps | cm最大数量 |
  | persistentVolumeclaims | pvc最大数量 |
  | pods | 允许存在非终止状态的Pod最大数量 | 
  | replicationcontrollers | rc最大数量 |
  | resourcequotas| resource quotas 最大数量|
  | services | 最大service数量 |
  | nodeports | node port类型的service数量 |
  | sercrets | sercret数量 |

  ```yaml
  apiVersion: v1
  kind: ResourceQuota # 作用于namespace级别
  metadata:
    name: quota-numbers
    namespace: ns-quota
  spec:
    hard:
      pods: 5 # 命名空间内pod最大数量
      configmaps: 10 # cm最大数量
    ...
  ```
## Qos服务质量

k8s根据requests和limits的设置，将pod划分到不同的Qos模型中。[Qos](https://mylog.taozhang.net.cn/archives/330.html)主要用于在宿主机资源紧张的时候，对pod进行资源回收。

- Guaranteed: requests等于limits(这种模式可以通过cpuset方式绑定cpu，减少cpu的切换，能提高工作效率)
- Burstable: 只设置了requests
- BestEffort: 既没有设置requests也没有设置limits

