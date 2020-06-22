## nohup的用法详解

#### 1.Linux下执行程序的方式有如下几种，假如执行的是一个sleep.sh的脚本，在当前目录

```shell
./sleep.sh       //该方式直接执行，如果不加参数ctrl—c便会终止进程
./sleep.sh &     //在当前bash作为任务运行
nohup ./sleep.sh &   //脱机重新连接，进程依旧运行中
```

***

#### 2.以下示例让你彻底了解它们的区别（个人电脑连接远程主机）

>2.1首先创建一个睡眠1000秒的简单脚本sleep.sh，vim编辑并保存
>
>```shell
>echo "sleep start"
>sleep 1000s
>echo "sleep end"
>```
>
>***
>
>2.2先以第一种方式运行，通过jobs -l命令查看进程
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200617004159.png)
>
>可以看到脚本的确启动了，却没有进程，因为ctrl-c终止了进程
>
>***
>
>2.3以第二种和第三种方式运行
>
>![image-20200617014322797](../../../../Library/Application Support/typora-user-images/image-20200617014322797.png)
>
>





