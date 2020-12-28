## 前言

***

跳跃表是一种有序数据结构，查找和插入操作的平均时间复杂度都是O(log n)。与常用的自平衡搜索树相比，例如红黑树，跳跃表通过多层链表实现，其结构简单易于实现，其查询删除效率通常堪比红黑树。本篇文章会对跳跃表简要说明，并重点分析Redis跳跃表核心源码

其他文章：[Redis简单动态字符串SDS源码解析](https://blog.csdn.net/matrixZCL/article/details/109877167)



## 正文

***

### 1. 跳跃表

跳跃表是通过多层有序链表实现的。如下图的有序链表，假设需要查找等于7的元素，必须从头结点（元素为1）依次遍历链表，共经过**7次查询比较**，找出目标结点。也就是其查询时间复杂度为O(1)，删除同理

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201228000443.png)

**假如给单个有序链表加索引会怎么样？**

如下图，基于单个有序列表，又添加了几层有序列表，可以理解为索引。那么其查询过程为

* 第一次，1<7,next=9>7，降级
* 第二次，1.next=5<7，5.next=9>7,降级
* 第三次，5.next=7，查找到目标结果

可以看到，只需经过**四次查询，三次比较**即可找出结果，一个设计良好的跳跃表，其时间复杂度能达到**O(logn)**。这就是跳跃表，道理就是这么简单。那么下面会详细介绍Redis跳跃表的具体实现，其细节还是比较多的

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201228001649.png)

### 2. Redis跳跃表数据结构

#### 2.1 跳跃表整体结构

Redis跳跃表的结构如下图，对照着示意图，先对其结构进行简要说明，再分析源码

* header：	指向表头的指针
* tail：指向表尾的指针
* level：层数最大的结点，不包含表头，在图中也就是包含后三个结点
* BW：backward，后退指针，指向后一个结点
* score：分值，就是我们用ZADD命令插入时设置的score，1.0，2.0.....等
* sds指针：对应图中o1,o2....，其数据结构为sds，可参考前言

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201228002802.png)

#### 2.2 跳跃表结点源码

zskiplistNode为跳跃表的结点，定义在server.h文件中，其中

* ele为sds类型字符串，其作用是存储数据
* level为层级，定义为数组，其中每个元素包含前进指针，和span。**注意：层级不包含头节点，头节点再Redis5.0创建跳跃表时会初始化为最大值，也就是64**
* span为当前层当前结点与下一个结点之前跨过的元素个数，span的目的是为了计算rank（排位），也就是第几个元素。例如前面说查询元素7，**那么怎么知道7是第几个元素？**，每个层结点维护了一个span变量，所以即使跨元素查找，也能通过计算得出rank

```c
/* ZSETs use a specialized version of Skiplists */
typedef struct zskiplistNode {
    sds ele;
    double score;
    struct zskiplistNode *backward;
    struct zskiplistLevel {
        struct zskiplistNode *forward;
        unsigned long span;
    } level[];
} zskiplistNode;
---------------------------------------------------
//在头文件引入sds数据结构  
typedef char *sds;
```

#### 2.3 跳跃表结构源码

有了节点的定义，需要一个结构管理这些节点，Redis定义zskiplist跳跃表结构。如下图，就像上面说明那样，其维护了两个指针，分别指向表头，表尾；还有跳表的长度和层高

```c
typedef struct zskiplist {
    struct zskiplistNode *header, *tail;
    unsigned long length;
    int level;
} zskiplist;
```

***

### 3. 创建跳跃表

#### 3.1 创建跳跃表结构

可以看到，创建跳跃表结构分为以下几个步骤

* 声明结构指针，分配空间
* 初始化结构层级为1（跳表最大层级），长度初始化为0（跳表长度）
* 创建表头节点，初始化表头层级为ZSKIPLIST_MAXLEVEL=64
* 将表头的每层的forward指针初始化为null，将span初始化为0
* 最后将后退指针，以及表尾指针初始化为null

```c
/* Create a new skiplist. */
zskiplist *zslCreate(void) {
    int j;
    zskiplist *zsl;

    zsl = zmalloc(sizeof(*zsl));
    zsl->level = 1;
    zsl->length = 0;
    zsl->header = zslCreateNode(ZSKIPLIST_MAXLEVEL,0,NULL);
    for (j = 0; j < ZSKIPLIST_MAXLEVEL; j++) {
        zsl->header->level[j].forward = NULL;
        zsl->header->level[j].span = 0;
    }
    zsl->header->backward = NULL;
    zsl->tail = NULL;
    return zsl;
}
```

#### 3.2 zslCreateNode创建节点方法

该方法会创建一个指定层级，指定分数，指定字符串元素的节点

* 可以看到首先声明zn指针，并指向一块分配好的内存块，通过malloc函数分配，其内存块大小为在zn指针基础上，偏量为移层数 x 每层大小。然后给其元素赋值并返回指针

```c
/* Create a skiplist node with the specified number of levels.
 * The SDS string 'ele' is referenced by the node after the call. */
zskiplistNode *zslCreateNode(int level, double score, sds ele) {
    zskiplistNode *zn =
        zmalloc(sizeof(*zn)+level*sizeof(struct zskiplistLevel));
    zn->score = score;
    zn->ele = ele;
    return zn;
}
```

***

### 4. 插入节点

我们知道在单链表中，插入一个结点n需要维护前一个结点信息，以便改变指针实现插入。Redis跳表同样的道理，不过它维护的是一个长度为64的数组update[]，还需要维护一个rank[]数组用来计算排位。其源码如下

从**zslInsert**方法看起，它传入zskiplist结构指针，代表向哪个跳跃表插入元素，需要插入元素的分数，和字符串值。首先声明两个数组就是上面说的。可以看到首先定义一个zskiplistNode指针类型x，从头部依次遍历

#### 4.1 查找要插入的位置

* 意思为**最高层**开始，每次循环降低一层
* 重点关注其中的while循环，如果forward指向的下个元素分数小于等于当前分数，则向后继续向后遍历
* while循环同时还会**计算排位**，可以看到rank排位是**通过当前层的span累加得出**
* 最后赋值update

``` c
for (i = zsl->level-1; i >= 0; i--) {
        /* store rank that is crossed to reach the insert position */
        rank[i] = i == (zsl->level-1) ? 0 : rank[i+1];
        while (x->level[i].forward &&
                (x->level[i].forward->score < score ||
                    (x->level[i].forward->score == score &&
                    sdscmp(x->level[i].forward->ele,ele) < 0)))
        {
            rank[i] += x->level[i].span;
            x = x->level[i].forward;
        }
        update[i] = x;
    }
```

#### 4.2 生成随机层高

这里的算法类似**幂次定律**，层高概率为，越高的层概率越小。其中ZSKIPLIST_P=0.25。整个算法过程为

* 生成随机数取低16位，与0.25 x 0xffff比较，来判断是否level+1。

```c
/* Returns a random level for the new skiplist node we are going to create.
 * The return value of this function is between 1 and ZSKIPLIST_MAXLEVEL
 * (both inclusive), with a powerlaw-alike distribution where higher
 * levels are less likely to be returned. */
int zslRandomLevel(void) {
    int level = 1;
    while ((random()&0xFFFF) < (ZSKIPLIST_P * 0xFFFF))
        level += 1;
    return (level<ZSKIPLIST_MAXLEVEL) ? level : ZSKIPLIST_MAXLEVEL;
}
```

#### 4.3 调整最大层级

当插入的结点level大于跳表最大层高，需要更新level

```c
if (level > zsl->level) {
        for (i = zsl->level; i < level; i++) {
            rank[i] = 0;
            update[i] = zsl->header;
            update[i]->level[i].span = zsl->length;
        }
        zsl->level = level;
    }
```

#### 4.4 插入节点

其方式跟单链表插入大同小异

* 把x当前层的forward指针指向update的当前层下一个结点
* 再将update当前层的forward指向x
* 最后是更新span的值

```c
x = zslCreateNode(level,score,ele);
for (i = 0; i < level; i++) {
    x->level[i].forward = update[i]->level[i].forward;
    update[i]->level[i].forward = x;

    /* update span covered by update[i] as x is inserted here */
    x->level[i].span = update[i]->level[i].span - (rank[0] - rank[i]);
    update[i]->level[i].span = (rank[0] - rank[i]) + 1;
 }
```

#### 4.5 收尾工作

* 更新上层span值
* 调整backward指针，update[0]相当于第一层，用来存储backward指针

```c
/* increment span for untouched levels */
    for (i = level; i < zsl->level; i++) {
        update[i]->level[i].span++;
    }

    x->backward = (update[0] == zsl->header) ? NULL : update[0];
    if (x->level[0].forward)
        x->level[0].forward->backward = x;
    else
        zsl->tail = x;
    zsl->length++;
```

完整的插入代码如下

```c
//插入整体代码
/* Returns a random level for the new skiplist node we are going to create.
 * The return value of this function is between 1 and ZSKIPLIST_MAXLEVEL
 * (both inclusive), with a powerlaw-alike distribution where higher
 * levels are less likely to be returned. */
int zslRandomLevel(void) {
    int level = 1;
    while ((random()&0xFFFF) < (ZSKIPLIST_P * 0xFFFF))
        level += 1;
    return (level<ZSKIPLIST_MAXLEVEL) ? level : ZSKIPLIST_MAXLEVEL;
}

zskiplistNode *zslInsert(zskiplist *zsl, double score, sds ele) {
    zskiplistNode *update[ZSKIPLIST_MAXLEVEL], *x;
    unsigned int rank[ZSKIPLIST_MAXLEVEL];
    int i, level;

    serverAssert(!isnan(score));
    x = zsl->header;
    for (i = zsl->level-1; i >= 0; i--) {
        /* store rank that is crossed to reach the insert position */
        rank[i] = i == (zsl->level-1) ? 0 : rank[i+1];
        while (x->level[i].forward &&
                (x->level[i].forward->score < score ||
                    (x->level[i].forward->score == score &&
                    sdscmp(x->level[i].forward->ele,ele) < 0)))
        {
            rank[i] += x->level[i].span;
            x = x->level[i].forward;
        }
        update[i] = x;
    }
    /* we assume the element is not already inside, since we allow duplicated
     * scores, reinserting the same element should never happen since the
     * caller of zslInsert() should test in the hash table if the element is
     * already inside or not. */
    level = zslRandomLevel();
    if (level > zsl->level) {
        for (i = zsl->level; i < level; i++) {
            rank[i] = 0;
            update[i] = zsl->header;
            update[i]->level[i].span = zsl->length;
        }
        zsl->level = level;
    }
    x = zslCreateNode(level,score,ele);
    for (i = 0; i < level; i++) {
        x->level[i].forward = update[i]->level[i].forward;
        update[i]->level[i].forward = x;

        /* update span covered by update[i] as x is inserted here */
        x->level[i].span = update[i]->level[i].span - (rank[0] - rank[i]);
        update[i]->level[i].span = (rank[0] - rank[i]) + 1;
    }

    /* increment span for untouched levels */
    for (i = level; i < zsl->level; i++) {
        update[i]->level[i].span++;
    }

    x->backward = (update[0] == zsl->header) ? NULL : update[0];
    if (x->level[0].forward)
        x->level[0].forward->backward = x;
    else
        zsl->tail = x;
    zsl->length++;
    return x;
}
```

***

### 5. 删除结点

根据分值来删除结点的代码如下

* 首先第一个for跟创建结点前的查找逻辑相似
* 然后比较分值，如果相同则通过**zslDeleteNode**删除结点

```c
int zslDelete(zskiplist *zsl, double score, sds ele, zskiplistNode **node) {
    zskiplistNode *update[ZSKIPLIST_MAXLEVEL], *x;
    int i;

    x = zsl->header;
    for (i = zsl->level-1; i >= 0; i--) {
        while (x->level[i].forward &&
                (x->level[i].forward->score < score ||
                    (x->level[i].forward->score == score &&
                     sdscmp(x->level[i].forward->ele,ele) < 0)))
        {
            x = x->level[i].forward;
        }
        update[i] = x;
    }
    /* We may have multiple elements with the same score, what we need
     * is to find the element with both the right score and object. */
    x = x->level[0].forward;
    if (x && score == x->score && sdscmp(x->ele,ele) == 0) {
        zslDeleteNode(zsl, x, update);
        if (!node)
            zslFreeNode(x);
        else
            *node = x;
        return 1;
    }
    return 0; /* not found */
}
```

zslDeleteNode为真正删除结点的函数，源代码如下

* 删除结点前，首先更新前一个结点每层的的span
* 然后将每层的前一个结点的forward指向被删除结点只想的结点（基础的链表删除元素操作）
* else语句说明update[i]大于当前层高，因此删除结点需要更新当前层span值，减1
* 最后是调整被删除元素下一个元素的backward指针

```c
/* Internal function used by zslDelete, zslDeleteByScore and zslDeleteByRank */
void zslDeleteNode(zskiplist *zsl, zskiplistNode *x, zskiplistNode **update) {
    int i;
    for (i = 0; i < zsl->level; i++) {
        if (update[i]->level[i].forward == x) {
            update[i]->level[i].span += x->level[i].span - 1;
            update[i]->level[i].forward = x->level[i].forward;
        } else {
            update[i]->level[i].span -= 1;
        }
    }
    if (x->level[0].forward) {
        x->level[0].forward->backward = x->backward;
    } else {
        zsl->tail = x->backward;
    }
    while(zsl->level > 1 && zsl->header->level[zsl->level-1].forward == NULL)
        zsl->level--;
    zsl->length--;
}
```

***

## 总结

跳跃表是有序集合的实现方式之一，由zskiplist，zskiplistNode两个构成，zskiplist可以看作是一种管理跳表的数据结构，而zskiplistNode为跳跃表结点的数据结构。其更多的API源代码实现，可以参考t_zset.c源文件