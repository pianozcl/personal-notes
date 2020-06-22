## MySQL 5.7.28安装教程

#### 一.官网下载rpm包

```
https://downloads.mysql.com/archives/community/
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200618180539.png)

***

#### 二.卸载旧的mysql组件

mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar

>1.查看旧版,看到如下mysql组件，不同版本会有差异
>
>```shell
>rpm -qa | grep mysql
>```
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200618182758.png)
>
>2.卸载组件
>
>```shell
>rpm -e --nodeps mysql-community-libs-5.7.30-1.el7.x86_64
>```
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200618183331.png)

***

#### 三.安装mysql

>1.解压刚刚下载的tar包
>
>```shell
>tar -xvf mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar
>```
>
>2.按照依赖顺序安装mysql组件
>
>```shell
>rpm -ivh mysql-community-common-5.7.28-1.el7.x86_64.rpm
>rpm -ivh mysql-community-libs-5.7.28-1.el7.x86_64.rpm
>rpm -ivh mysql-community-client-5.7.28-1.el7.x86_64.rpm
>rpm -ivh mysql-community-server-5.7.28-1.el7.x86_64.rpm
>```
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200618184926.png)
>
>3.查看版本
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200618184949.png)

#### 四.登录并配置root用户

>1.mysql启动，查看状态，停止mysql命令
>
>```shell
>systemctl start mysqld.service
>systemctl status mysqld.service
>systemctl stop mysqld.service
>```
>
>2.查看默认root密码
>
>```shell
>grep 'temporary password' /var/log/mysqld.log
>```
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200618185642.png)
>
>3.用默认密码登录
>
>```shell
>mysql -uroot -p
>```
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200618190250.png)
>
>4.设置密码复杂度策略
>
>```mysql
>set global validate_password_policy=0;  //基于长度判断密码标准
>set global validate_password_length=1;	//设置长度最低为4
>```
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200618191240.png)
>
>5.修改密码，123456为要修改的密码
>
>```mysql
>set password for root@localhost=password('123456');
>```
>
>6.此时root只能本机访问，授予远程访问权限
>
>```mysql
>grant all privileges on *.* to root@'%' identified by '123456';
>```

***

#### 五.创建普通用户并授权

>1.创建普通用户，username为用户名，%代表能在所有主机登录
>
>```mysql
>CREATE USER 'username'@'%' IDENTIFIED BY '123456';
>```
>
>2.授权表操作权限
>
>```mysql
>GRANT ALL ON *.* TO 'username'@'%';        //所有库所有表权限，具体库表权限可修改*.*
>```

