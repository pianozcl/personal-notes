### 一.安装相关依赖

```shell
yum -y install policycoreutils openssh-server openssh-clients postfix
```

### 二.下载rpm包并安装

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-8.0.0-ce.0.el7.x86_64.rpm
rpm -i gitlab-ce-8.0.0-ce.0.el7.x86_64.rpm
```

### 三.配置服务器端口

进入配置文件进行以下配置

```shell
vim  /etc/gitlab/gitlab.rb
```

1.对外暴露的端口，将来通过9090访问管理页面

```shell
external_url 'http://localhost:9090'       
```

2.一些服务的端口配置，默认8080，端口被其他服务占用会产生502等问题

```shell
gitlab_git_http_server['auth_backend'] = "http://localhost:8081"
unicorn['port'] = 8081
```

### 四.使配置生效并重启

```shell
gitlab-ctl reconfigure
gitlab-ctl restart
```

### 五.重置密码

访问上面配置的external_url,进入gitlab页面，用初始账号/密码登录 root/5iveL!fe

