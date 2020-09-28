## 自动内存管理

### 内存区域

#### 运行时数据区域

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200912150130.png)

1.程序计数器

* 程序计数器是一块较小的内存空间，可以看作当前线程执行的字节码的行号指示器
* 线程私有，保证线程切换后恢复到正确的执行位置
* 如果执行的是Java方法，保存的是方法的地址。如果是native方法，计数器位空

2.Java虚拟机栈

* 每个方法执行，jvm会同步创建一个栈帧，方法的调用和返回就是压栈和出栈的过程
* 栈帧用于存放局部变量表，操作数栈，动态链接，方法出口等
* 局部变量表存放了基本数据类型和对象引用
* 栈帧中的空间以Slot（变量槽）来表示，long，double占两个slot，其余各一个

3.Java堆

* 虚拟机管理的最大一块内存区域，所有线程共享，用于存放对象实例
* 堆中也可以划分出线程私有的分配缓冲区TLAB（Thread Local Allocation Buffer），以提升对象分配效率
* Java堆可以在物理上处于不连续的内存空间
* 可以通过-Xmx -Xms设定堆大小，当堆没有足够的内存分配实例，会抛出OutOfMemoryError异常

4.方法区

* 线程共享的区域，用于存储已被加载的类型信息，常量，静态变量等，即时编译的缓存数据
* jdk8之前，hotspot虚拟机用永久代实现方法区，容易导致内存溢出问题
* jdk8和8之后，废弃的永久代概念，由本地内存实现的元空间来存放方法区的内容

5.运行时常量池

* Class文件的常量池表，用于存放编译期生成的各种字面量与符号引用，这部分内容在类加载后会放到常量池中

6.直接内存

* 通过调用native函数库直接分配堆外内存，并通过堆内的DirectByteBuffer对象作为这块内存的引用进行操作

#### Hotspot对象

1.对象的创建

* jvm遇到new指令，先检查常量池是否能定位到一个符号引用，并检查符号引用代表的类是否加载，解析，和初始化过，如果没有先执行类加载过程
* 类加载完成，进行内存分配过程（对象所需大小在类加载完成确定）

>内存分配的方式：
>
>1.指针碰撞（Bump the pointer）:假如内存规整，只是简单的移动指针来分配
>
>2.空闲列表（Free list）：内存不规整，jvm需要记录一个列表来记录内存块是否可用

* 分配空间线程安全问题：多线程同时操作指针分配内存，会导致线程安全问题

>解决方案：
>
>1.JVM采用CAS保证更新操作的原子性
>
>2.TLAB，在每个线程私有的堆内存缓冲区分配，直到缓冲区耗尽，同步锁定分配新的缓冲区

* JVM将内存空间（不包括对象头）初始化0值，保证在Java代码中不赋值也能使用
* 进行对象头的一些设置

2.对象的内存布局

* 对象头Header

>部分1：MarkWord，在32位和64位虚拟机中分别占用32bit和64bit
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200912201107.png)
>
>部分2：类型指针

* 实例数据Instant Data
* 对齐填充Padding：HotSpot虚拟机要求对象起始地址为8字节的整数倍，所以要用到padding

### 垃圾收集器与内存分配策略

#### 判断对象是否应该回收

1.引用计数法

* 每个对象添加一个引用计数器，该对象被引用时，计数器+1，引用失效，计数器-1
* 无法回收循环引用的对象

2.可达性分析算法

* 通过GC roots节点集合，通过引用关系向下搜索。当某些对象不可达，则说明该对象应该被回收

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200913005122.png)

3.引用类型

* 强引用（Strongly Reference）:普遍存在的引用赋值，比如Object   o=new Object();，只要强引用在，该对象就不会被回收
* 软引用（Soft Reference）：用于描述一些还有用，但是非必须的对象，在系统发生溢出之前，会对这些对象进行回收
* 弱引用（Weak Reference）：比软引用更弱一些，无论内存是否足够，当垃圾回收开始工作，都会被回收
* 虚引用（Phantom Reference）：最弱的引用，不会对对象的存活时间造成影响，仅仅是为了在对象回收时得到系统通知

4.一次对象自我拯救示例

* 不可达的对象并不会立即被回收，而是进行一次标记，被标记的对象如果覆盖了finalize()方法，会被放到队列中等代执行该方法。没有覆盖finalize()的对象，或者已经执行过finalize()的对象，会被垃圾回收器直接回收
* 任何一个对象的finalize()方法只会被系统调用一次

```java
package jvm;

/**
 * 此代码演示了两点：
 * 1.对象可以在被GC时自我拯救。
 * 2.这种自救的机会只有一次，因为一个对象的finalize()方法最多只会被系统自动调用一次
 *
 * @author zzm
 */
public class FinalizeEscapeGC {

    public static FinalizeEscapeGC SAVE_HOOK = null;

    public void isAlive() {
        System.out.println("yes, i am still alive :)");
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        System.out.println("finalize method executed!");
        FinalizeEscapeGC.SAVE_HOOK = this;
    }

    public static void main(String[] args) throws Throwable {
        SAVE_HOOK = new FinalizeEscapeGC();

        //对象第一次成功拯救自己
        SAVE_HOOK = null;
        System.gc();
        // 因为Finalizer方法优先级很低，暂停0.5秒，以等待它
        Thread.sleep(500);
        if (SAVE_HOOK != null) {
            SAVE_HOOK.isAlive();
        } else {
            System.out.println("no, i am dead :(");
        }

        // 下面这段代码与上面的完全相同，但是这次自救却失败了
        SAVE_HOOK = null;
        System.gc();
        // 因为Finalizer方法优先级很低，暂停0.5秒，以等待它
        Thread.sleep(500);
        if (SAVE_HOOK != null) {
            SAVE_HOOK.isAlive();
        } else {
            System.out.println("no, i am dead :(");
        }
    }
}

```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200913014318.png)

#### 垃圾收集算法

1.分代收集理论

* 弱分代假说：绝大多数对象是朝生夕灭的

* 强分代假说：熬过多次垃圾回收的对象越难以消亡

* 跨代引用假说：跨带引用只占极少数

  > 例如：新生代存在老年代引用，该引用会在GC时使新生代得以存活，进而会使该对象晋升到老年代，这时候跨带引用就被消除了

2.标记清除算法（Mark-Sweep）

* 对需要回收的对象进行标记，然后统一回收标记过的对象，或者对不需要回收的对象进行标记，然后统一回收未标记的

  >缺点：
  >
  >1.大量对象标记和清除导致效率降低
  >
  >2.存在空间碎片化问题

  ![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200913112954.png)

3.标记复制算法

* 把内存分为大小相等两块，当其中一块用完了，将存活对象复制到另外一块，然后再将第一块一次性清理掉
* 解决了碎片化问题，但是存在内存复制的开销，保留区域额外占用一半的内存空间

4.标记整理算法

* 将存活对象向空间一端移动，直接清理边界以外的内存

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200913122656.png)