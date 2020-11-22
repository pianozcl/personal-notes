## 前言

本篇文章需要了解Docker基础知识，以及Dockerfile的使用

参考文章：[Dockerfile构建镜像与命令详解](https://blog.csdn.net/matrixZCL/article/details/109438430)

## 正文

### 1. 拉取tomcat镜像

```shell
docker search tomcat      //查询可用的tomcat镜像
docker pull tomcat        //这里我选择了star数（人气）最高的版本
```

***



### 2. 启动容器

启动后通过docker ps命令查看已启动的容器，发现容器正在运行，但是访问页面**404**

```shell
docker run -d -p 8080:8080 tomcat     //宿主机端口：容器端口
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101183630.png)

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101183518.png)

#### 404问题解决方案

进入容器一探究竟

| 参数               | 说明                                 |
| ------------------ | ------------------------------------ |
| --interactive , -i | Keep STDIN open even if not attached |
| --tty , -t         | Allocate a pseudo-TTY                |

```shell
docker exec -it 7b323aa /bin/bash					//以交互式进入容器
```

执行以上命令进入容器，并进入webapps文件夹下，发现是空文件夹。在tomcat问价夹下还有一个**webapps.dist**目录，这个才是我们需要的

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101202723.png)

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101202757.png)



重命名空的webapps文件夹，并将webapps.dist命名为webapps

```shell
mv webapps webapps.bak
mv webapps.dist webapps
```



然后进入tomcat bin目录启动shutdown.sh关闭tomcat，此时容器也会关闭并退出到操作系统终端

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101203256.png)



***docker ps -a***	找到该容器id

***docker start <容器id>***   再次启动该容器

然后再次访问127.0.0.1:8080即可看到正常的tomcat页面

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101203858.png)



### 3. 部署war包到tomcat容器

部署war包，更平时部署tomcat一样，只需要把war包让道容器的webapps目录下,重启tomcat即可

可以使用docker cp命令，直接从宿主机拷贝到容器指定目录

* test_docker_cp 宿主机的文件
* 7b323aa139ce:/usr/local/tomcat/webapps     容器id:要传到容器中的目录

```shell
docker  cp test_docker_cp 7b323aa139ce:/usr/local/tomcat/webapps
```

可以以交互式方式进入容器，以确认文件的确传到容器的指定目录了

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101210610.png)

**但是我并不推荐用docker cp的方式传文件，更灵活的方式是通过Dockerfile方式，生产环境通常也是采用Dockerfile来进行部署**



### 4. 使用Dockerfile来部署应用

目前我们已经有一个tomcat的官方镜像了，我把把这个当作基础镜像，在此基础上来把应用集成到镜像中

#### 4.1. 部署前准备

创建一个用于构建目录的镜像，在该目录下创建Dockerfile，我把测试用的war包也放到该目录下了。

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101211848.png)

#### 4.2. Dockerfile

* 关乎Dockerfile命令在前言文章中都有详细解释

```shell
FROM tomcat																															
MAINTAINER zcl "pianozcl@gmail.com"
RUN rm -rf /usr/local/tomcat/webapps
RUN mv /usr/local/tomcat/webapps.dist /usr/local/tomcat/webapps
COPY sample.war   /usr/local/tomcat/webapps
```

#### 4.3. 构建新的镜像

这里顺便一提，如下图展示了基于Dockerfile的构建过程，Docker会把Dockerfile中的每条命令执行并提交成一个新的镜像，只不过对外只暴露最外层的镜像（虚拟栈顶的镜像）。可以参考前言文章对镜像解释，结合构建过程你会对Docker有更深入的认识

```shell
docker build -t="pianozcl/test_tomcat" .		//注意不要忘了后面指定Dockerfile路径，我这里当前目录是点
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101212716.png)



#### 4.4. 启动容器

```shell
docker run -itd  -p 8080:8080 --name test_tomcat_container pianozcl/test_tomcat
```

访问浏览器可以看到，sample.war包已经同样可以成功部署

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201101213318.png)



### 5. 基于Dockerfile构建的优势

介绍了上述构建方式，你应该能明白Dockerfile的优势了，**特别是对于集群**

如果机器比较少，你只需要把集成好应用的镜像上传到Dockerhub，在每个结点只需要拉取镜像，启动镜像，Docker保证了环境的一致性。

对于成千上万结点的集群，有k8s等容器管理应用对容器进行统一部署，统一管理，同样需要Dockerfile的支持

