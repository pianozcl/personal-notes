## 前言

传统方式部署集群，你需要在每台机器搭建环境，配置各种中间件，这样不但效率低下，而且很难保证环境的一致性，而且配置如果有改动，需要挨个机器修改。

有了Docker，上述问题都能解决。但是官方镜像大多时候并不能满足需求，因此需要自己构建适用于应用的镜像。构建镜像可以以交互式方式启动并进入容器，对容器修改后退出容器并通过commit命令提交一个新的镜像，但是这种方式构建的镜像不利于后期维护。我们通常是通过编辑**Dockerfile**，再通过build命令来构建镜像，后面只需要看Dockerfile，镜像信息便一目了然。

#### 有了镜像如何部署集群？

* 第一种方式：（集群无法连接外网的情况下）可以把构建好的镜像，通过save命令把镜像文件保存下来，通过外部介质拷贝到机器上面，再通过load命令加载
* 第二种方式：把打包好的镜像，push到DockerHub，直接在集群的结点拉取镜像即可，也是最简单的方式

***



## 正文

***

### 1. 什么是Docker镜像

安装过操作系统的同学，应该对这个概念比较熟悉。我们安装操作系统，通常是把镜像文件刻录到U盘，然后可以在多个机器上安装操作系统。有了Docker镜像，我们也可以在不同机器上启动容器，这是两者的相似之处。

Docker与虚拟机也非常相似，他们最重要的区别就是虚拟机是基于硬件的，而Docker容器是基于内核的

#### 1.1. Docker的文件系统层

Docker镜像结构类似于Linux的虚拟化栈，可以看到第一层（栈底）为Linux内核，接着是引导文件系统。第二层是基础镜像，它可以是某种系统（Centos，Ubuntu等）。基于基础镜像，进而可以构建出更多的镜像，第三层，第四层等。但是对外只暴露栈顶的文件系统

#### 1.2. 写时复制

镜像层的文件系统都是只读的，启动容器时，会把最外层镜像复制到读写层（writeable container），容器便在这个栈区域运行，提交新的镜像也相当于压栈的过程

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201031222814.png)

***

### 2. 使用Dockerfile构建镜像

以下示例，我会基于Centos的基础镜像，构建出一个集成了nginx的镜像

#### 前置条件

* 机器上安装有Docker环境
* 创建一个文件夹（用于构建镜像），创建Dockerfile文件（名字必须为Dockerfile）

#### 2.1. 拉取Centos镜像

```shell
docker pull centos   //这里我拉取默认版本，也可以指定需要的系统以及版本号
docker images        //查看获取的镜像
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201031230345.png)



#### 2.2. 编辑Dockerfile

Dockerfile内容

* FROM：基于某个镜像
* MAINTAINER：作者，以及作者的信息
* RUN：相当于在容器中执行命令（后面有详细说明）
* EXPOSE：对外的端口（如果启动容器不指定 -p参数，容器会把自己的80端口，随机映射到宿主机的某个端口），启动命令指定-p端口，会覆盖EXPOSE的作用

```shell
FROM centos
MAINTAINER zcl "pianozcl@gmail.com"
RUN yum install -y nginx
RUN echo "I am in your container" >/usr/share/nginx/html/index.html
EXPOSE 80
```



#### 2.3. 使用build命令构建

**注意后面的（点）'.'**用于指定Dockerfile位置，我的在当前文件夹下所以是点，也可以替换成远程的git仓库，前提是该仓库根目录下有Dockerfile

```shell
docker build -t="pianozcl/test_nginx:v1" .				//格式为"镜像仓库/镜像名词：版本"
```

执行完以上命令会执行Dockerfile中的指令，最后构建生成如下新镜像

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201031232005.png)



#### 2.4. 启动容器

* -p:  端口映射（宿主机端口：容器端口）
* nginx -g "daemon off;" ：nginx启动参数，nginx默认以守护进程方式启动，指定该参数改为nginx在前台运行，这样docker容器才能感知到nginx进程，没有该参数容器将会立即关闭。**注意；别漏了**

```shell
docker run -d -p 80:80 --name nginx_test pianozcl/test_nginx:v1 nginx -g "daemon off;"  //启动   
```

***docker ps -l***   可以查看到当前启动的容器，以及端口映射

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201031233304.png)

打开浏览器可以看到我们在dockerfile中写入的信息

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201031233511.png)

***



### 3. Dockerfile指令

#### 3.1 CMD

CMD和RUN类似，后面跟着需要执行的指令。不同的是RUN作用于构建镜像过程，而CMD是容器启动时指定的命令

```shell
docker run -i -t pianozcl/centos /bin/bash
//以上命令等同于以下---------------------------------------
在Dockerfile中写入CMD ["/bin/bash"]
然后启动容器执行docker run -i -t pianozcl/centos
```

* Dockerfile只能指定一条CMD命令，如果有多条也只会执行最后一条
* docker run命令如果指定了命令，会覆盖Dockerfile中的CMD命令



#### 3.2. ENTRYPOINT

ENTRYPOINT和CMD同样时之行命令的参数，区别是CMD会被docker run命令参数覆盖，而ENTRYPOINT会接收docker run命令的参数，并能结合使用

```shell
例如：
Dockerfile中的命令为：	ENTRYPOINT ["nginx"]
启动命令为：						docker run -t -i pianozcl/test_nginx -g "daemon off;"
//以上操作相当于以下命令-----------------------------------------
docker run -t -i pianozcl/test_nginx nginx -g "daemon off;"
```

ENTRYPOINT还可以结合CMD使用

* 当docker run没有指定命令参数，ENTRYPOINT会结合CMD起作用
* 指定的话，ENTRYPOINT会结合命令行参数起作用，覆盖CMD作用

```shell
如果Dockerfile命令为：
ENTRYPOINT ["nginx"]
CMD ["-h"]
---------------------------------------------
docker run -t -i pianozcl/test_nginx
相当于
docker run -t -i pianozcl/test_nginx nginx -h
---------------------------------------------
docker run -t -i pianozcl/test_nginx -g "daemon off;"
相当于
docker run -t -i pianozcl/test_nginx nginx -g "daemon off;"
```

#### 3.3. WORKDIR

RUN和ENTRYPOINT执行时候的工作目录，例如如下Dockerfile

```shell
WORKDIR /home/test1		  		
RUN bundle install				//第二条命令作用在test1目录下
WORKDIR /home/test2
ENTRYPOINT [ "rackup" ]		//第四条命令作用在test2目录下
```

也可以在docker run启动通过-w参数覆盖Dockerfile指定的目录

```shell
sudo docker run -ti -w /var/log ubuntu pwd /var/log				
```

#### 3.4. ENV

配置环境变量，就像指定了命令所在目录的前缀

```shell
Dockerfile
ENV JAVA_HOME /home/mybin
-----------------------------------------
RUN test.sh
相当于
RUN /home/mybin/test.sh
```

#### 3.5. ADD & COPY

两者都是将当前构建环境上的文件，打包复制打包进镜像中，区别是ADD复制过程中，如果是会对原本的压缩文件进行提取解压操作，COPY则是原封不动的复制

```shell
COPY app.jar /opt/application/app.jar			//把当前目录jar文件复制到容器的application目录下
```





