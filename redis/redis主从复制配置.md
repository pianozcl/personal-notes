### 前置条件

在生产环境，Redis结点通常是单独部署在不同的物理机器上。想要在一台机器上模拟多节点，可以参考这篇文章[同一台机器上启动多个Redis实例](https://blog.csdn.net/matrixZCL/article/details/109083293)

***

### Redis结点的主从复制

* Redis实例可划分为主结点（master）和从结点（slave）
* 一个主结点可以有多个从结点，一个从结点只能有一个主结点
* 默认情况下，从结点只读

#### 1.启动redis实例

这里我启动两个实例，端口分别是6379和6380

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201015160544.png)

***

#### 2.建立主从关系

1.指定端口连接实例

```shell
redis-cli -p 6380
```

2.在6380示例执行以下命令，代表6380为6379的从结点

* 执行slaveof会先保存主结点信息，后续复制异步执行

```shell
slaveof 127.0.0.1 6379
```

3.可以看到6379插入的数据能在6380实例获取到

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201015162004.png)

4.也可以直接在redis.conf文件中配置主从关系。具体方式是，打开从结点的conf文件，找到slaveof，格式同以上命令

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201015162324.png)

***

#### 3.查看复制状态信息

```shell
info replication
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201015162723.png)

***

#### 4.断开复制

1.在从结点执行以下命令

```
slaveof no one
```

#### 5.只读

在配置文件中有slave-read-only配置，yes代表只读，对于从结点不建议修改这个值

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201015163247.png)

#### 6.复制过程

执行slaveof命令后，会进执行以下步骤

* 保存主结点信息
* 主从建立socket连接
* 发送ping命令验证连接是否建立成功
* 验证权限，对于设置了requirepass的主结点，从结点需要密码认证
* 同步数据
* 同步命令，保证数据一致性