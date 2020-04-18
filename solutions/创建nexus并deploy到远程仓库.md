1.安装docker（使用环境为Centos7）

```shell
sudo yum update
sudo yum install docker
docker -v
```

***

2.启动docker并设置为开机启动

```shell
systemctl start docker
systemctl enable docker
```

***

3.查找nexus镜像

```shell
docker search nexus
```

![](https://raw.githubusercontent.com/matrixZCL/personal-notes/master/img/20200418202830.png)

***

4.拉取nexus3镜像，并查看镜像

```shell
docker pull docker.io/sonatype/nexus3
docker images
```

![](https://raw.githubusercontent.com/matrixZCL/personal-notes/master/img/image-20200418165951698.png)

***

5.创建守护式容器

>-id：创建守护式容器
>
>--privileged=true：授予容器root权限
>
>--name：容器名
>
>-p：端口号映射（宿主机端口：容器端口）
>
>-v：宿主机目录：容器目录  目录挂载 
>
>57a6261043b9：镜像id

```shell
docker run -id --privileged=true --name=nexus3 -p 8081:8081 -v /home/nexus-data:/var/nexus-data 57a6261043b9
```

***

6.修改nexus密码，登录守护式容器，找到初始密码，用初始密码登录并修改密码

![](https://raw.githubusercontent.com/matrixZCL/personal-notes/master/img/image-20200418172640409.png)

```
docker exec -it 553e05fbf184 /bin/bash
```

![](https://raw.githubusercontent.com/matrixZCL/personal-notes/master/img/image-20200418173119809.png)

***

7.向远程仓库deploy jar包

>在settings.xml文件中配置nexus认证信息
>
>```xml
>		<servers>
>        <server>
>            <id>maven-releases</id>
>            <username>admin</username>
>            <password>password</password>
>        </server>
>    </servers>
>```
>
>deploy jar包到远程仓库，groupId,artifactId,version与本地仓库一致
>
>>-s：指定含有认证配置的settings文件
>>
>>-Dfile：指定jar包路径
>>
>>-Durl：maven远程仓库地址
>>
>>-DrepositoryId：为仓库唯一标示，与远程仓库以settings.xml配置id保持一致
>
>```shell
>mvn -s "/Users/software/apache-maven-3.6.1/conf/settings.xml" deploy:deploy-file -DgroupId=com.zzz -DartifactId=test-jar  -Dversion=0.0.1  -Dpackaging=jar -Dfile=/Users/chenliangzhou/Desktop/Note/test-jar.jar  -Durl=http://www.my-nexus.com/repository/maven-releases/ -DrepositoryId=maven-releases
>```
>
>

