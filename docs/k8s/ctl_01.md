k8s Controller
=====================

k8s中，控制器通过监控集群的状态，致力于将当前状态转变为期望的状态。在机器人和自动化领域，控制回路(Contro Loop)是一个非终止回路，用于调节系统的状态。k8s控制器就是一个control loop(监控集群的状态)，每个控制器都试图将当前集群状态转变为期望状态, 而k8s controller manager就是一系列控制器的组合。

Contro Loop在k8s中称为通用编排模式，大致过程如下：k8s的控制器会监听资源的 insert/update/delete事件，并触发Reconcile函数（Reconcile Loop或者Sync Loop）。Reconcile的作用是确保资源对象的实际状态和定义的yaml文件的状态保证一致。

## ReplicaSet Controller 

> ReplicaSet Controller与Replication Controller 基本一致，但是在Pod选择器的表达能力更强，是Replication Controller(只支持等式的labels)的加强版。现在基本都是使用ReplicaSet而不是Replication, Deployment就是控制ReplicaSet Controller上实现滚动更新和水平伸缩。

ReplicaSet 就是维护一组pod副本的运行，保证pod数与期望的值一致。

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx
  labels:
    app: nginx
    version: latest
spec:
  # ReplicaSet Controller 会保证Pod的副本数跟期望的副本数保持一致。
  replicas: 3 
  selector: # 匹配要控制的Pod labels, 需要和下面template中的labels
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

- minReadySeconds  
  控制应用升级的速度。pod启动后（readness成功后）等待多久进行下一轮替换。默认0， 有些场景设置为0会认为pod启动起来，就可以对外提供服务，可能会造成服务异常。这个值的长度应该是pod中的应用能够对接受流量提供服务。

## Deployment Controller 

Depoyment与ReplicaSet的yaml编写基本一致，Deployment通过控制ReplicaSet来保证Pod与期望的值一致， 还具有水平伸缩/扩展的能力。

| 特性 | 说明 | 
| --- | --- |
| 事件和状态 | 可以查看到deploy对象升级的进度和状态 |
| 回滚 | 支持将应用回滚到前一个或者指定的版本 |
| 版本记录 | 每一次的deploy都会记录 |
| 暂停和启动 | 对于每一次的升级，能够随时暂定和启动 |
| 多种更新策略 | 支持Recreate和RollingUpdate两种更新策略 |

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
  labels:
    app: nginx
    version: latest
spec:
  # ReplicaSet Controller 会保证Pod的副本数跟期望的副本数保持一致。
  replicas: 3 
  minReadySeconds: 3
  selector: # 匹配要控制的Pod labels, 需要和下面template中的labels
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
```

##### 水平伸缩/扩展

Deployment通过ReplicaSet调整replicas可以很方便的实现水平伸缩/扩展的能力。

```bash
kubectl scale deployment nginx-deploy --replicas=4
```

##### 滚动更新

> 滚动更新，每次只更新一小部分副本，成功后再更新更多的副本，最终完成所有副本更新。滚动更新的最大好处是零停机，整个更新过程中始终有副本运行，保证了业务的连续性。

k8s中业务更新都是基于镜像实现的。以下面nginx为例子，将nginx镜像从nginx:1.16-alpine升级到nginx:1.18-alpine。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
  labels:
    app: nginx
    version: latest
spec:
  #保证Pod的副本数跟期望的副本数保持一致。
  replicas: 3 
  minReadySeconds: 3
  # 匹配要控制的Pod labels, 需要和下面template中的labels
  selector: 
    matchLabels:
      app: nginx
  # 滚动更新
  strategy:
    # 策略：RollingUpdate, Recreate
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.18-alpine # old nginx:1.16-alpine
        ports:
        - containerPort: 80
---
... 
滚动更新增加了一下配置
minReadySeconds: 3
strategy:
  # 策略：RollingUpdate, Recreate
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

- type  
  - RollingUpdate  
  滚动更新策略，也是默认策略。
  - Recreate  
  重建策略，将旧的pod停止删除后，用新的版本替换。不能保证业务的连续性（一般需要停服升级，可以通过这种方式）。
- maxSurge  
  表示升级过程中，最多比原先设置的值(replicas)多的Pod数。比如maxSurge=1，replicas=3, k8s会先启动一个pod再删除一个pod，那么在升级过程中就会有4个pod。
- maxUnavailable  
  升级过程中，最多有多少个pod处于无法提供服务的状态。

##### 其他命令介绍

```bash
# 查看滚动更新的状态
kubectl rollout status deployment/nginx-deploy
# 暂定滚动更新
kubectl rollout pause deployment/nginx-deploy
# 恢复滚动更新
kubectl rollout resume deployment/nginx-deploy
# 查看历史版本
kubectl rollout history deployment nginx-deploy
# 回滚到某个历史版本
kubectl rollout undo deployment nginx-deploy --to-revision=1
```

## StatefulSet Controller 
  StatefulSet 是有状态服务（相对于Deployment无状态服务）。无状态服务（web计算层）很容编排，有状态服务（一般是计算与存储绑定，mysql这种）需要考虑很多。

## DaemonSet Controller 
  DaemonSet 是用来部署守护程序的，Daemonset Controller会在每个节点都部署一个Pod副本。前面k8s环境搭建，部署网络插件cilium，就是使用的DaemonSet每个节点都部署一个Pod。需要获取每个节点的指标，可以通过DaemonSet方式每个节点部署node exporter。

## Job Controller 
  Job 保证仅仅执行一次任务。
## CronJob Controller
  CronJob 在Job的基础上增加了时间调度。
## HPA Controller 
  hpa全称Horizontal Pod Autoscaling（Pod 水平自动伸缩）。前面Deployment可以通过kubectl scale的方式手动实现Pod扩缩容。
  hpa通过获取pod的资源使用率，自动实现水平自动伸缩（从已有线上的表现来看，对于徒增的流量，用处不大）。hap依赖metrics server获取pod使用的cpu和内存指标。

##### 安装Metrics Server

```bash
# 安装metrics server 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.4.1/components.yaml
```

##### hap例子

为上面nginx-deploy创建一个hap, 下面例子：最小副本为3，最大副本为8，当cpu使用率为60%的时候动态的增加/减少Pod数量。
```bash
kubectl autoscale deployment nginx-deploy --cpu-percent=60 --min=3 --max=8
```

##### hap操作频率

hap 操作频率可以通过kube controller manager组件的--horizontal-pod-autoscaler-downscale-stabilization参数来设置操作频率。参数默认值5分钟。
