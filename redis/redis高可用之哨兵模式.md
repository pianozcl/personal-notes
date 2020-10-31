## 前言

Redis主从复制模式下，一旦主节点发生故障，需要人工干预进行故障转移，故障转移的实时性与准确性都无法保障。Redis2.6版本以上提供了Redis Sentinel（哨兵）来自动发现和转移故障，实现高可用

***

### 相关文章

[启动多个Redis实例](https://blog.csdn.net/matrixZCL/article/details/109083293)

[Redis搭建主从复制](https://blog.csdn.net/matrixZCL/article/details/109100851)

***

### Redis Sentinel配置文件

包含一个主结点，两个从结点，三个Sentinel结点的配置文件，已上传至[GitHub](https://github.com/pianozcl/Redis-Sentinel)

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201016193830.png)

***

## 正文

### 1.Redis Sentinel概述

Redis Sentinel包含若干个Sentinel节点和Redis数据节点，每个Sentinel节点会对其他所有节点进行监控，如果发现不可达节点，会进行标记。当大多数Sentinel节点都认为主节点不可达，会选举出其中一个Sentinel节点进行故障转移工作



### 2.示意图

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201016145930.png)

***

#### 2.1主从模式故障转移

转移流程

* 选出一个从节点，执行slaveof no one命令让其晋升为主节点
* 客户端（client）连接切换到新的主节点
* 客户端命令另一个从节点复制新的主节点
* 旧的主节点恢复后，让它复制新的从节点

主从模式下存在的问题

* 主节点挂掉期间，无法插入数据导致部分数据丢失，无法查询也会导致应用报错

#### 2.2哨兵模式故障转移

转移流程

* 多个Sentinel节点会对主节点进行监控
* 当大部分节点发现主节点不可达，选取一个Sentinel进行故障转移
* 转移步骤和主从模式一样，区别是整个过程是自动完成的

***

### 3. 哨兵模式部署

>#### 注意：生产环境Sentinel节点应当部署在不同的物理机器上。这里我在一台机器上启多个进程模拟

#### 3.1 部署主从数据节点

我这里本机启动三个redis进程（数据节点）来模拟，端口6379（主），6380/6381（从）。还不知道如何启动多个Redis可以参考前言说明文章

* 连接主节点执行info replication查看主从关系，如下图标示，再主节点视角可以看到两个从节点信息

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201016152757.png)

#### 3.2 部署哨兵（Sentinel）节点

部署哨兵节点跟redis数据节点方式大同小异，都是先copy配置文件，再修改配置。可再安装目录找到名为redis-sentinel.conf的配置文件模版

* 配置文件参数说明	

| 参数                                            | 端口号                                                       |
| :---------------------------------------------- | ------------------------------------------------------------ |
| daemonize yes                                   | 是否开启守护进程（后台启动），跟数据节点配置一样             |
| sentinel monitor mymaster 127.0.0.1 6379 2      | 监控的主节点，mymaster为主节点别名，最后的2代表至少需要两个Sentinel节点同意 |
| port 26379                                      | Sentinel进程占用的端口号，默认26379                          |
| dir /tmp                                        | sentinel的工作目录                                           |
| bind 0.0.0.0                                    | 对外开放的IP，0000所有主机均可访问                           |
| sentinel auth-pass mymaster 123456              | 如果master接点有密码，需要配置密码                           |
| sentinel down-after-milliseconds mymaster 30000 | Sentinel会定时发送ping命令检测是否可达，单位毫秒             |
| sentinel parallel-syncs mymaster 1              | 发生故障转移时，同时复制的从节点个数，1为轮询                |

Sentinel配置示例

```vim
bind 0.0.0.0
daemonize yes
protected-mode no
port 26379
dir /tmp
sentinel monitor mymaster 127.0.0.1 6379 2
# sentinel auth-pass mymaster MySUPER--secret-0123passw0rd
sentinel down-after-milliseconds mymaster 30000
sentinel parallel-syncs mymaster 1
```

Sentinel节点启动方式

```shell
redis-sentinel redis-sentinel-26379.conf		//指定配置文件启动
redis-cli -p 26379	//连接哨兵节点
```

连接成功，可以执行 info sentinel命令查看哨兵节点信息。如下图所示，改哨兵节点已经获取到它所监控到主节点信息了

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201016154827.png)

以相同的方式再启动2个Sentinel节点

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201016160250.png)

#### 3.3 数据转移测试

可通过shutdown命令关闭主节点（6379），也可直接kill -9模拟宕机情况，这里我连接主节点执行shutdown命令

如下图所示，在主节点进程关闭后，其中一个从结点自动晋升为主结点，自此哨兵模式已经部署成功

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201016191339.png)





