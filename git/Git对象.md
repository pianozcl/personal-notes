### 探秘Git对象，commit，tree，blob

***

要想真正理解Git对象，首先要知道暂存区(.git/index)实际上是一个包含文件索引的目录树，而真正存储数据的地方是(.git/object)，而比如HEAD->master分支，简单来说就是一系列指针，指向objects的数据或者叫对象，而objects是一个简单的key-value数据库

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200612235622.png)

***

首先初始化一个git仓库，并进入到.git/object目录下一探究竟

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613004104.png)

进入到objects目录，可以看到 Git 对 `objects` 目录进行了初始化，并创建了 `pack` 和 `info` 子目录，但均为空

***

然后创建一个文件，写入v1，并进行add，此刻先不要commit

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613021235.png)

会发现，新增了62文件夹，以及文件夹下的一串，其实就是SHA128哈希函数生成的hashcode

而且得出了一个结论:  <big>**添加到暂存区的改动，实际数据是存储到.git/objects下了**</big>

***

可以用git cat-file来查看这个hashcode对应的文件类型

```shell
git cat-file -p 626799f0f   //查看文件内容
git cat-file -t 626799f0f		//查看文件类型
```

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613021329.png)

可以看到，类型为blob，这就是Git的数据对象，接下来我们创建一个空文件夹并add到暂存区

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613005429.png)

objects文件夹下并没有新内容增加，这是因为对于Git来说，文件夹只是一个索引，直接存到.git/index了

***

然后进行提交commit，在观察该目录下的改动

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613012028.png)

这次多了出两个hashcode，分别看这两个hashcode的类型和内容

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613012306.png)

其中一个为tree对象，通过-p可以看出其内容为一个blob数据对象，而这个blob的内容就是我们一开始存的字符v1

然后我们创建一个名为folder的文件夹，并在folder下创建file2.txt写入v2

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613013837.png)

发现多处了若干个hashcode，其中有commit类型的，通过-p查看其内容，其中包含一个b99开头的tree，查看这个tree的tree发现里面又是blob和tree，这正好对应我们刚才创建的目录，因此Git的存储结构如下图

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613015045.png)

一个commit对象，会包含其父节点commit引用，还有根节点的tree的引用，tree下面又包含若干blob和tree，对应目录下的文件和文件夹，具体一点就是下图这种模型

![](https://raw.githubusercontent.com/pianozcl/personal-notes/master/img/20200613015855.png)

