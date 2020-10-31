### Redis的几种安装方式（Linux）

#### yum和rpm

yum本质上是下载rpm包到当前机器，并安装。因此两种安装方式有相同的特点：

* 都会自动添加环境变量，也就是如redis-server，redis-cli之类的命令直接可以执行

```shell
yum install redis
rpm -ivh redis.rpm    //进入到rpm包所在目录，指定包名执行
```

#### 源码编译安装

需下载源码编译，它的特点是：

* 不会自动添加环境变量，执行redis-server，redis-cli需要到该命令下（命令就是可执行文件呢）采用./redis-server的方式执行

### Redis的配置

找到redis.conf所在目录，可通过find命令查找，并用vim编辑

```shell
find / -name redis.conf
vim redis.conf
```

#### 配置守护进程（后台启动）

daemonize no改为daemonize yes

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201014202740.png)

#### 配置端口（默认6379）

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201014202905.png)

#### 设置密码（默认无密码）

去掉#注释，例如requirepass 123456，就是将密码改为123456

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201014203038.png)

#### 设置对外开放

将bind 127.0.0.1注释或者改为bind 0.0.0.0

```vim
bind 127.0.0.1		//只有本季能访问
# bind 127.0.0.1	//任何主机都能访问
bind 0.0.0.0			//任何主机都能访问
```

并将protected-mode yes改为no



