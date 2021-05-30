## 前言

***

在业务场景以及日常开发中，ArrayList往往是最频繁使用的List实现类，这由它的结构以及特性决定。ArrayList顾名思义，其底层是由数组实现，因此查询时间复杂度是常数级别的，再加之有一些小优化，查询速度会更快。由于其底层是数组实现，插入和删除都是O（n）级别的。业务场景往往是多读少写的，因此ArrayList就很适合。下面就来解析ArrayList的源码以及常见方法的实现

* 本篇文章基于JDK8



## 正文

***

### 1. 成员变量

首先看一下它的成员变量

* DEFAULT_CAPACITY = 10：默认容量为10，用于在add方法添加第一个元素的时候初始化数组大小
* EMPTY_ELEMENTDATA = {}， DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {}：用于扩容的空数组
* elementData：实际存放元素的数组
* size：包含的元素个数

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201208230739.png)



### 2. 调试源码

#### 2.1 插入元素

这里我先通过测试代码调试add方法的插入过程，因为观察添加元素过程，成员变量和构造方法的作用，自然就会明白

```java
import java.util.ArrayList;
public class Test {
    public static void main(String[] args) {
        ArrayList<Object> objects = new ArrayList<>();
        objects.add(1);
        objects.add("qweqweqweqwe");
        objects.add(3);
        objects.add(4);
        objects.add(5);
        objects.add(6);
        objects.add(7);
        objects.add(8);
        objects.add(9);
        objects.add(10);
        objects.add(11);
        System.out.println(objects.size());
    }
}
```

跟着断点执行，首先会经过new ArrayList()，也就是其默认构造方

* 可以看到，会对elementData数组进行初始化，DEFAULTCAPACITY_EMPTY_ELEMENTDATA就是上面说的空数组成员变量

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201208232834.png)

接着走到第二部，add第一个元素

这里有一个小优化，当元素在-128~127之间，会添加至缓存，对于常用的元素以便提高查询效率

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201208233220.png)

接着便会走到add方法

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201208233629.png)

add方法第一行的ensureCapacityInternal方法，顾名思义，这是一个保证添加元素，不会越界的方法。当然其中包含扩容方法，下面进行说明

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201208233629.png)

可以看到，这个方法在第一次add元素时，会进行一次扩容，其容量就是上述成员变量那个默认值10

* 其中，minCapacity的含义为，当前所需的最小容量

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201208234255.png)

然后会通过grow方法进行扩容，如果说上面是扩容前准备，这是真正的扩容方法

因为是第一次扩容，这里会走如下箭头的方法

注意方法第二行的**位运算**，算术右移一位，相当于除以2，因此整行代码计算出的新容量，会是旧容量的1.5倍

最后一行，对elementData进行扩容，其容量为newCapacity，暂时为使用的初始化为0。copyOf方法示例

```java
public class Test2 {
    public static void main(String[] args) {
        int[] arr={1,2,3,4,5};
        int[] ints = Arrays.copyOf(arr, 10);
        for (int i : ints) {
            System.out.println(i); //1 2 3 4 5 0 0 0 0 0
        }
    }
}
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201208235147.png)

执行完扩容，接着就是添加元素了，第一个元素添加过程就是这样

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209000203.png)



**第二个元素**，我选用了一个字符串，只是为了演示，对于不常用（长度很大）的字符串，是不会走缓存的。当然此时容量为10，而size=1，走了一下ensureCapacityInternal方法检查空间是否足够，也不会扩容

直到加到第十个元素，都不会再进行扩容

**第十一个元素**，因为这时候容量是十，因此会进行扩容，根据上述位运算的扩容方式，新的容量应该是15，如下所示

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209001112.png)

至此，add方法便演示完毕了，总结一下就一个套路，还是很简单的

* 首先调用默认构造方法初始化长度为0的空数组
* 添加第一个元素，会使用默认的成员变量DEFAULT_CAPACITY=10进行扩容
* 继续添加元素，检查容量，如果容量足够，直接添加
* 如果容量不够，进行1.5倍扩容

#### 2.2 删除元素

删除元素分为两种

* remove(Object o)：如果参数为对象，例如字符串，遍历删除第一个符合的元素
* remove(int index)：如果参数为整形，删除该下标元素

首先看一下**remove(Object o)** 的源代码

可以看到，无论是传null，还是非null，就是遍历数组，找到符合的第一个元素删除并返回。删除元素会调用**fastRemove()** 方法

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209125113.png)

**fastRemove()** 的源代码

我们知道，删除数组某个元素，是要移动数组后面的所有元素，因此时间复杂度是O(n)

如下代码中的arraycopy方法便是用来移动数组元素的，其中的参数：

* src：源数组
* srcPos:源数组要复制的起始位置
* dest：目标数组
* destPos：目标数组放置的起始位置
* length：复制的长度，这里通过计算是numMoved

整个删除逻辑是，把index下标后面的元素全部复制提前一位，然后将最后一个元素置为null，自然就会被GC回收

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209125253.png)

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209125739.png)

按照下标删除元素的方式大同小异，源码如下，这里就不再赘述

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209130552.png)

### 3. ArrayList的迭代器

再看迭代器源码前，同样先写出测试代码用于调试

```java
public class TestListIterator {

    public static void main(String[] args) {
        ArrayList arrayList = new ArrayList();
        for (int i = 0; i < 10; i++) {
            arrayList.add(i);
        }

        Iterator<Integer> iterator = arrayList.iterator();
        while (iterator.hasNext()) {
            System.out.println(iterator.next());
            iterator.remove();
        }
    }
}
```

#### 3.1 迭代器的构造方法

可以看到，再调用iterator()方法时，会返回一个迭代器的对象

构造方法将会初始化一些成员变量如下

```java
// 游标，该游标用于遍历集合，每当调用next()方法便会+1
int cursor;       
// 要返回的元素下标，在只是遍历集合的情况下，该变量总是比cursor小1，迭代器的删除方法也有用到
int lastRet = -1; 
//用来判断多线程下数据是否异常
int expectedModCount = modCount;
```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209224646.png)

#### 3.2 next()方法

这里要提一下上面遇到但没有进行说明的**modCount** 变量。ArrayList的新增删除过**modCount** 都会+1，感觉像是记录操作次数的，很容易就能想到是为了处理多线程下产生的异常情况。下面进行debug上面贴出的测试代码，分析迭代器源代码

首先是**hasNext() **方法，该方法没什么好说的，但是可以体现**cursor游标**的其中一个作用

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209231711.png)

接着是**next()** 方法，进入next()方法会先调用**checkForComodification()**，用于检查集合是否被修改。刚才说过，构造方法初始化的时候，会把modCount赋值给expectedModCount，假设遍历过程中，集合被其他线程修改，那么modCount值会改变，因此下面方法就会抛出异常。当然单线程也会出现以下异常，下面会进行说明

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209232326.png)

**next()** 方法很简单，就是每次调用游标+1，然后返回当前（lastRet）下标下的元素

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209233244.png)

#### 3.3 remove() 方法

首先看一下try语句的第一行，它会调用ArrayList的remove，上文有讲过，其实就是最终调用System.arraycopy方法，把lastRet后面的元素向前移动一位，最后一个元素赋值null，从而被GC回收

其之后lastRet赋值为-1，为什么赋值-1呢？这里抛出一个问题，**一次循环是否能调用两次remove？**

最后expectedModCount = modCount，因为调用了ArrayList.remove()，modCount必然改变，所以要重新复制，否则会抛出ConcurrentModificationException。**这也是为什么在迭代器不能调用list.remove的原因，因为list的remove不会修改迭代器的expectedModCount成员变量，会抛出ConcurrentModificationException，因此在单线程操作不当也会出现这个异常**

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209233558.png)

那么上面说一趟循环调用两次iterator.remove会发生什么？

因为第一次remove后lastRet为-1，所以会抛出一下异常。**而在next()方法中，又会更新lastRet的值，游标的前一个值，也就是要返回的值，因此remove方法往往是在next()方法之后调用**

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209234747.png)

### 4. 线程安全的Vector

Vector已经不再推荐使用了，由于逻辑和ArrayList非常相似，底层同样是数组，这里简单做下对比。从源码可知

* Vector的添加删除方法有synchronized修饰，因此达到线程安全的目的
* 其扩容方法，每次扩容至原来的两倍

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209145807.png)

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201209145843.png)

### 

