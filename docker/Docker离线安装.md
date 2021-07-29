### CentOS7/8无法联网，通过RPM安装Docker

首先找一台能联网的机器

下载安装包

```shell
//联网的服务器上
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yumdownloader --resolve docker-ce docker-ce-cli containerd.io
tar cf docker-ce.offline.tar *.rpm      //打包所需依赖


内网机器上
tar xf docker-ce.offline.tar
sudo rpm -ivh --replacefiles --replacepkgs *.rpm
sudo systemctl start docker 
```

