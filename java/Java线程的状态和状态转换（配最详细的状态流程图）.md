### Java线程的状态和状态转换（配最详细的状态转换流程图）

- **new**,
- **runnable**,
- **timed waiting**,
- **waiting**,
- **blocked**,
- **terminated**.

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200720171621.png)

**New** 代表创建但是未启动的线程

**runnable**又可分为ready和running两个子状态，由于单个cpu同一时间只可以执行单个线程，多线程的分配是通过cpu时间片来分配的，因此有一部分线程会在等待队列，也就是ready状态。CPU的Thread scheduling（线程调度）决定着线程什么时候可以实际运行

处于**runnable**状态的线程在JVM层面上来看是执行中的状态。但是在操作系统层面上，或许线程在等待一些资源

**Timed waiting**是线程指定了特定的时间，调用一下方法的现场会进入此状态

- Thread.sleep(sleeptime)
- Object.wait(timeout)
- Thread.join(timeout)
- LockSupport.parkNanos(timeout)
- LockSupport.parkUntil(timeout)

**waiting** 状态是由于线程调用了以下方法

- Object.wait()
- Thread.join()
- LockSupport.park()

**blocked** 是当前线程无法获取synchronized 锁或者是当前锁对象调用了Object.wait()方法，这时候会进入阻塞状态

线程执行完run()方法则会进入 **terminated** 状态.

