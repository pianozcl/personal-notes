## 前言

* 本篇文章来介绍我们常用的集合类 HashMap，它通过散列函数将数据映射到表中的某个位置，以提升查询速度。其底层用于存放数据的数组也叫散列表

* 所谓散列函数，**简单来说就是将一个无限大的集合（在 HashMap 中，key值是一个无限大集合），经过 hash 运算取模，均匀的分布在一个有限的集合（我们定义的哈希表容量，比如长度 16 的数组）**
* 我们知道 Java 中的 HashMap 底层是一个数组，数组的每个元素是一个链表或者红黑树。我们也知道它的一些特性，比如允许key、value 可以为空、不保证键值对顺序、非线程安全。除了这些，HashMap源码还有很多细节值得分析，下面来了解一下
* 很多地方会将 hash 表数组元素比喻成桶，其实指的是用于存放元素的数组，每个数组元素其实就是一个 Node 类的链表引用或者 TreeNode 引用，而 TreeNode 为 Node 子类

基于 JDK1.8

***



## 正文

### 1. 成员变量和常量

```java
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4;	//默认初始化容量，大小为16
static final int MAXIMUM_CAPACITY = 1 << 30;	//最大容量
static final float DEFAULT_LOAD_FACTOR = 0.75f;	//默认加载因子
static final int TREEIFY_THRESHOLD = 8;		//链表长度超过8转红黑树
static final int UNTREEIFY_THRESHOLD = 6;	//链表长度小于6，红黑树转链表
static final int MIN_TREEIFY_CAPACITY = 64;	//如果容量小于64，会先进行扩容，而不会链表转红黑树

transient Node<K,V>[] table;		//哈希表数组，数组为Node类型元素，该类型为链表
transient Set<Map.Entry<K,V>> entrySet;	// key-value集合，可用于遍历Map
transient int size;	//元素数量
transient int modCount;  //插入删除元素，modCount++,用于记录改变次数
int threshold;	//当前能容纳的最大键值对，超过这个值需要扩容
final float loadFactor;	//加载因子，能够权衡时间复杂度和空间复杂度
```

***

### 2. 构造方法

一共有四个构造方法，这里我只列出来我们常用的两个

* 第一个是指定初始容量，也是我们比较推荐的做法，根据需要设置大小，避免后面resize扩容开销
* 第二个是默认构造方法，我们不指定默认大小为 16

```java
    public HashMap(int initialCapacity) {
        this(initialCapacity, DEFAULT_LOAD_FACTOR);
    }
    public HashMap() {
        this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted
    }
```

#### 2.1. 新创建空的HashMap的扩容阈值计算

**值得注意**的是指定 initialCapacity 的构造方法，在初始化一个新的Map时会调用以下方法

* 其中会先赋值默认加载因子 0.75，然后会调用 tableSizeFor 方法计算扩容阈值

```java
    public HashMap(int initialCapacity, float loadFactor) {
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal initial capacity: " +
                                               initialCapacity);
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        if (loadFactor <= 0 || Float.isNaN(loadFactor))
            throw new IllegalArgumentException("Illegal load factor: " +
                                               loadFactor);
        this.loadFactor = loadFactor;	//1
        this.threshold = tableSizeFor(initialCapacity); //2
    }
```

**tableSizeFor**  方法

* 该方法会计算大于当前容量的最小二次幂，例如传9，结果就是16，不能为其他非二次幂的数。这样说可能不太直观，下图我演示了一系列容量的计算结果，能够一目了然

```java
    static final int tableSizeFor(int cap) {
        int n = cap - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```

容量分别为 0 ～34 的计算结果

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20210110194631.png)

当通过**new**创建一个 HashMap ，此时容量为空，只有当put第一个元素时，才会对数组进行初始化

***

### 3. 插入过程

#### 3.1 对key值进行hash运算

* 这里h和h的**高16位**进行异或运算，目的是为了**增大离散性，因为对于容量小于16的HashMap，总是和低16位相关**

```java
    static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```

#### 3.2 putVal 插入方法

1. 插入首个元素，此时table size还是0，会通过**resize** 方法进行初始化。resize方法稍后说明

```java
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
      	//1
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
      	//这里拿计算出的hash值，进行 & （这里是取模）运算，n - 1 是数组对于的下标。
      	//得出相应下标，如果该下标直接插入元素为null，说明没有hash冲突，直接插入元素
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
          	//这里先创建一个新节点的引用 e, 根据条件语句赋值
            Node<K,V> e; K k;
          
          	//hash值相同，key相同，直接覆盖
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
          	//如果当前下标为红黑树类型节点，以红黑树方式插入
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
              	//遍历链表，插入元素
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                      	//如果链表长度等于8，将链表转红黑树
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                  	//判断链表有需要插入的元素，跳出循环
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                  	//更新p指向e，也就是指向链表中的最后一个，方便下p.next（）插入
                    p = e;
                }
            }
          	//返回旧值
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
      	//如果超过阈值，进行扩容
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```

由以上代码可知HashMap的插入逻辑如下

* 插入首个元素，按阈值初始化数组
* 判断是否有重复元素，重复的话替换
* 要插入的数组下标，元素类型如果为红黑树，则以红黑树方式插入
* 下标所在元素如果为链表，则以链表追加方式插入，如果链表长度等于8则转红黑树
* 最后判断哈希表大小是否超过阈值，如果超过则进行扩容

***

### 4. 查找过程

#### 4.1 查找方法

```java
    final Node<K,V> getNode(int hash, Object key) {
        Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (first = tab[(n - 1) & hash]) != null) {
          	//如果计算hash值和key值相同，直接返回
            if (first.hash == hash && // always check first node
                ((k = first.key) == key || (key != null && key.equals(k))))
                return first;
            if ((e = first.next) != null) {
              	//如果为红黑树节点，以红黑树方式查找
                if (first instanceof TreeNode)
                    return ((TreeNode<K,V>)first).getTreeNode(hash, key);
                do {
                  	//如果hash值相同，key不同，则遍历链表找到相同的key，返回
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        return e;
                } while ((e = e.next) != null);
            }
        }
        return null;
    }
```

***

### 5. 扩容

首先说一下阈值的计算

* 假如调用无参数构造方法，并插入第一个元素，这里阈值计算方式为 **默认容量 * 默认加载因子**
* 假如指定容量，并插入第一个元素，阈值会首先根据我上面说的 **tableSizeFor** 方法进行计算，继续插入元素，如果再发生扩容，容量同样为 **默认容量 * 默认加载因子**
* 所以假如加载因子为0.75，从第二次每次扩容，你会发现大小总是为 12，24，48，96......等这种

以上也体现了加载因子等作用，假如阈值为0.75，也就是每次到哈希表元素数量为12，24，48，96都会发生扩容， **假如我们把加载因子改成0.5呢？那么会在每次8，16，32等阈值进行扩容，这意味着，扩容频繁了。因此元素更加分散，出现长链表的概率会减小，查询速度会变大，但是频繁扩容会导致空间浪费。减小加载因子，则是相反的情况**

```java
final Node<K,V>[] resize() {
        Node<K,V>[] oldTab = table;
        int oldCap = (oldTab == null) ? 0 : oldTab.length;
        int oldThr = threshold;
        int newCap, newThr = 0;
        if (oldCap > 0) {
            if (oldCap >= MAXIMUM_CAPACITY) {
                threshold = Integer.MAX_VALUE;
                return oldTab;
            }
          	//新阈值为旧阈值两倍
            else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                     oldCap >= DEFAULT_INITIAL_CAPACITY)
                newThr = oldThr << 1; // double threshold
        }
        else if (oldThr > 0) // initial capacity was placed in threshold
          	//这里容量替换成阈值，回想上面的tableSizeFor方法。虽然默认阈值为0.75倍的
          	//容量，但是tableSizeFor取大于阈值的最小二次幂，还是能取到正确值
            newCap = oldThr;
        else {               // zero initial threshold signifies using defaults
          	//只有默认无参构造方法才会走到这个分支，阈值为默认算法，容量 * 0.75
            newCap = DEFAULT_INITIAL_CAPACITY;
            newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
        }
  			//newThr 为0时，阈值为容量 * 0.75
        if (newThr == 0) {
            float ft = (float)newCap * loadFactor;
            newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                      (int)ft : Integer.MAX_VALUE);
        }
        threshold = newThr;
        @SuppressWarnings({"rawtypes","unchecked"})
  					//进行扩容，首先要创建一个新的哈希表，其容量为上面计算出来的
            Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
        table = newTab;
        if (oldTab != null) {
          	//遍历旧哈希表数组
            for (int j = 0; j < oldCap; ++j) {
                Node<K,V> e;
                if ((e = oldTab[j]) != null) {
                    oldTab[j] = null;
                  	////重新计算哈希值并插入到新哈希表中
                    if (e.next == null)
                        newTab[e.hash & (newCap - 1)] = e;
                    else if (e instanceof TreeNode)
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                    else { // preserve order
                      	//如果是链表，采取不一样的方式。为了减少元素移动次数，会把原来一个
                      	//链表拆分为两个，其中一个放在原下标不懂，另外一个放到（原下标 + 旧的容量）的下标位置
                        Node<K,V> loHead = null, loTail = null;
                        Node<K,V> hiHead = null, hiTail = null;
                        Node<K,V> next;
                        do {
                            next = e.next;
                            if ((e.hash & oldCap) == 0) {
                                if (loTail == null)
                                    loHead = e;
                                else
                                    loTail.next = e;
                                loTail = e;
                            }
                            else {
                                if (hiTail == null)
                                    hiHead = e;
                                else
                                    hiTail.next = e;
                                hiTail = e;
                            }
                        } while ((e = next) != null);
                        if (loTail != null) {
                            loTail.next = null;
                            newTab[j] = loHead;
                        }
                        if (hiTail != null) {
                            hiTail.next = null;
                            newTab[j + oldCap] = hiHead;
                        }
                    }
                }
            }
        }
        return newTab;
    }
```

***

### 6. 查找元素

查找过程，类似插入过程的一部分，源代码如下。总体分为三种情况

* 当前hash表数组Node头节点key值与当前key相同，直接返回
* 如果当前节点为TreeNode节点，以红黑树方式查找
* 如果不是链表第一个节点，则循环遍历链表，直到查到对应的key相同

```java
    final Node<K,V> getNode(int hash, Object key) {
        Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (first = tab[(n - 1) & hash]) != null) {
          	//计算hash值，和key值，如果等于当前链表第一个元素，直接返回
            if (first.hash == hash && // always check first node
                ((k = first.key) == key || (key != null && key.equals(k))))
                return first;
            if ((e = first.next) != null) {
              	//如果为红黑树节点类型，进行红黑树查找
                if (first instanceof TreeNode)
                    return ((TreeNode<K,V>)first).getTreeNode(hash, key);
                do {
                  	//如果不是链表第一个节点，则循环遍历链表，直到查到对应的key相同，返回
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        return e;
                } while ((e = e.next) != null);
            }
        }
        return null;
    }
```

***

### 7. 删除元素

* 删除元素首先进行查找，找到需要删除的元素，创建指向它的引用。然后针对不同的节点类型，进行删除

```java
final Node<K,V> removeNode(int hash, Object key, Object value,
                               boolean matchValue, boolean movable) {
        Node<K,V>[] tab; Node<K,V> p; int n, index;
  			//查找元素并赋值给node引用
        if ((tab = table) != null && (n = tab.length) > 0 &&
            (p = tab[index = (n - 1) & hash]) != null) {
            Node<K,V> node = null, e; K k; V v;
          	//如果当前头数组下标头节点就是要查找的元素，赋值给node
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                node = p;
            else if ((e = p.next) != null) {
              	//红黑树的查找方式
                if (p instanceof TreeNode)
                    node = ((TreeNode<K,V>)p).getTreeNode(hash, key);
                else {
                  	//链表遍历查找方式
                    do {
                        if (e.hash == hash &&
                            ((k = e.key) == key ||
                             (key != null && key.equals(k)))) {
                            node = e;
                            break;
                        }
                        p = e;
                    } while ((e = e.next) != null);
                }
            }
          	//删除node
            if (node != null && (!matchValue || (v = node.value) == value ||
                                 (value != null && value.equals(v)))) {
              	//如果node为红黑树结点，采用红黑树删除方式
                if (node instanceof TreeNode)
                    ((TreeNode<K,V>)node).removeTreeNode(this, tab, movable);
              	//如果node为头结点，当前数组下标元素直接替换为next
                else if (node == p)
                    tab[index] = node.next;
                else
                  	//链表非头元素删除方式
                    p.next = node.next;
                ++modCount;
                --size;
                afterNodeRemoval(node);
                return node;
            }
        }
        return null;
    }
```

***

### 8. HashMap的迭代器

我们在用 foreach 遍历 Map 时候，其实会使用 HashMap 内部定义的迭代器。我们知道，遍历HashMap的顺序根插入顺序并不一样，但是每次遍历获取元素顺序又是一样的。因为对于 HashMap 迭代器的遍历方式为：

* 首先遍历数组，如果数组为null，数组index++
* 如果数组当前index不为null，调用next方法，其实调用的是 nextNode 依次遍历完链表

```java
abstract class HashIterator {
        Node<K,V> next;        // next entry to return
        Node<K,V> current;     // current entry
        int expectedModCount;  // for fast-fail
        int index;             // current slot

        HashIterator() {
            expectedModCount = modCount;
            Node<K,V>[] t = table;
            current = next = null;
            index = 0;
          	//跳过为null的数组下标
            if (t != null && size > 0) { // advance to first entry
                do {} while (index < t.length && (next = t[index++]) == null);
            }
        }

        public final boolean hasNext() {
            return next != null;
        }

  			//如果next不为空，将next赋值给e返回，next指向下一个next
        final Node<K,V> nextNode() {
            Node<K,V>[] t;
            Node<K,V> e = next;
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            if (e == null)
                throw new NoSuchElementException();
            if ((next = (current = e).next) == null && (t = table) != null) {
                do {} while (index < t.length && (next = t[index++]) == null);
            }
            return e;
        }

        public final void remove() {
            Node<K,V> p = current;
            if (p == null)
                throw new IllegalStateException();
            if (modCount != expectedModCount)
                throw new ConcurrentModificationException();
            current = null;
            K key = p.key;
            removeNode(hash(key), key, null, false, false);
            expectedModCount = modCount;
        }
```



## 总结

了解了HashMap的核心代码，对它的一些特点，以及使用作出如下总结

* HashMap底层是数组 + 链表/红黑树结构
* 在使用HashMap时，合适的指定容量，可以避免resize开销
* 对于加载因子，它可以调整哈希表对时间效率和空间的开销，但是不建议调整，默认的0.75我认为算是一个折中
* 当元素达到阈值，会进行扩容，哈希表总是以二次幂进行扩容
* 扩容的时候，会创建新的哈希表，并对元素重新进行hash计算。对于链表，计算方式为拆分链表为两个链表，其中一个保持原下标，另外一个原下标加旧容量长度
* 对于增删操作，同List一样有modCount记录操作次数，但是这只能发现多线程下的异常情况，并不能避免

