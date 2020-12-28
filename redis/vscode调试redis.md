## 前言

阅读Redis源码避免不了debug，直接使用GDB调试很不方便。本文分享使用Visual Studio Code调试Redis的方式。

环境：MacOSX，Redis5.0



## 正文

***

### 1. 插件市场安装所需编译器

我这里导入源码后到目录结构如下图。首次下载记得进入根目录编译

```shell
cd redis-5.0.0
make
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201126235049.png)



### 2.  添加debug所需配置

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201126235331.png)

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201126235444.png)

**注意** 上图选中redis-server是可执行文件路径，编译后才会有

贴出我的配置

```json
{
    "version": "0.2.0",
    "configurations": [
        
        {
            "name": "(lldb) 启动",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/src/redis-server",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb"
        }
    ]
}
```

### 3. debug

我这里现在src目录t_string.c打上断点，稍后执行set命令会经过这段代码

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201126235907.png)

**注意** 这里要以debug模式启动Redis

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201127000045.png)

在终端通过redis-cli插入数据，可以看到经过断点

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201127000339.png)

