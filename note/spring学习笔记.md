## bean的scope

### 1.singleton

* 对象实例数量:在一个容器中只存在一个共享实例
* 对象存活时间:从容器启动，到bean的创建，直到容器销毁前，该bean会一直存在

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200904225237.png)

### 2.MVC模式

* Controller，以及Controller注入的service bean，默认都是单例，以提高性能
* 单例会有线程安全问题，比如Controller尽量避免定义成员变量，因为多线程同时访问可能会导致数据问题

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200904233257.png)

### 3.ThreadLocal在单例中的使用（解决单例对象成员变量共享问题）

* JDBC Connection对象是单例的，假如现有多个线程共用conn对象，假如A线程改变Conn对象的状态为开启，岂不是会影响到其他线程？
* 因此可以通过ThreadLocal，在每个线程的私有区域创建conn对象，多线程互不影响

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200904235123.png)

### 4.IOC容器BeanFacroty

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200905150231.png)

### 5.循环引用问题

假设有三个类A,B,C循环引用。Spring如何创建对应的bean？

* 单例模式：直接初始化对应的类的bean，可以创建成功
* prototype：先初始化A的引用b是否初始化，发现没有初始化准备初始化B，发现B中有引用c未初始化，便准备初始化C，C中又有a引用，如此造成循环倚赖，无法创建对应的bean

### 6.代理模式

开闭原则：对扩展进行开放,对修改进行关闭。也就是需求有变时，应该通过添加新模块，而不是修改原有代码满足需求

#### 静态代理

* 静态代理：代理类对象是静态的，接口如果有改动，或者代理类想要扩展新的实现类，都需要改动代理类，违反了开闭原则
* Proxy生成对象，InvocationHandler生成具有什么功能的对象

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200905202524.png)

#### 动态代理

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200906171439.png)