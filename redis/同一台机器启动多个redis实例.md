### 启动多个Redis实例

如果不了解redis的基本配置，可以参考这篇文章[Redis的基本配置](https://blog.csdn.net/matrixZCL/article/details/109083029)

#### 首先拷贝并修改redis配置文件

找到redis.conf所在目录，可通过find命令查找

```shell
find / -name redis.conf
```

进入该目录并拷贝一份redis.conf，并编辑

```shell
cp redis.conf redis2.conf
vim redis2.conf
```

端口port，不要跟其他端口冲突，这里我改成6380

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201014191320.png)

进程文件pidfile，redis启动时会自动分配进程号并写入文件，以下配置为了指定进程文件

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201014191047.png)

#### 指定配置文件启动redis

如果是yum或者rpm安装的，可直接用redis-server指定配置文件路径启动。源码编译安装的，需要找到redis-server的目录，采用./redis-server的方式

```shell
redis-server /usr/local/etc/redis2.conf
```

使用redis-cli指定端口连接

```shell
redis-cli -p 6380
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201014192204.png)