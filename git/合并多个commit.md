### 通过git rebase合并多个commit

#### 1.初始化版本库

为了方便演示，初始化一个git版本库并创建三个commit，对这三个commit进行合并操作

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201005001910.png)

#### 2.进行合并

* -i : interactive的意思，键入该参数会进入vi编辑界面（需要了解vim编辑保存退出等基本操作）
* HEAD~3：代表操作最近两次提交

```shell
git rebase -i HEAD~2
```

1.键入命令会进入以下vim界面

* 其中#注释部分是对命令的说明
* 前两行代表对这两次commit的操作，默认pick，如果这时候wq保存退出，git记录和原来一样
* squash命令，代表合并当前commit到之前到commit

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201005003444.png)

2.把commit 3的pick修改为s，也就是squash的简写，代表 commit 3会合并到commit 2当中

修改完wq保存退出，又会进入到另外一个vim，用于对合并后的commit进行编辑

可以看到，vim默认保留了之前commit的描述

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201005004849.png)

3.修改描述，将合并后的描述改为new commit 2，wq保存退出

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201005005100.png)

#### 3.查看合并后的git记录

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201005005244.png)

