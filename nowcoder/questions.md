## Servlet生命周期

Servlet的生命周期一般可以用三个方法来表示：

1. init()：仅执行一次，负责在装载Servlet时初始化Servlet对象
2. service() ：核心方法，一般HttpServlet中会有get,post两种处理方式。在调用doGet和doPost方法时会构造servletRequest和servletResponse请求和响应对象作为参数。
3. destory()：在停止并且卸载Servlet时执行，负责释放资源

初始化阶段：Servlet启动，会读取配置文件中的信息，构造指定的Servlet对象，创建ServletConfig对象，将ServletConfig作为参数来调用init()方法。所以选ACD。B是在调用service方法时才构造的

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201109165835.png)

***



## 面向对象五个基本原则：

单一职责原则（Single-Resposibility Principle）：一个类，最好只做一件事，只有一个引起它的变化。单一职责原则可以看做是低耦合、高内聚在面向对象原则上的引申，将职责定义为引起变化的原因，以提高内聚性来减少引起变化的原因。
开放封闭原则（Open-Closed principle）：软件实体应该是可扩展的，而不可修改的。也就是，对扩展开放，对修改封闭的。
Liskov替换原则（Liskov-Substituion Principle）：子类必须能够替换其基类。这一思想体现为对继承机制的约束规范，只有子类能够替换基类时，才能保证系统在运行期内识别子类，这是保证继承复用的基础。
依赖倒置原则（Dependecy-Inversion Principle）：依赖于抽象。具体而言就是高层模块不依赖于底层模块，二者都同依赖于抽象；抽象不依赖于具体，具体依赖于抽象。
接口隔离原则（Interface-Segregation Principle）：使用多个小的专门的接口，而不要使用一个大的总接口

***

## Try Catch

```java
public class Demo {
    public static String sRet = "";
    public static void func(int i)
    {
        try
        {
            if (i%2==0)
            {
                throw new Exception();
            }
        }
        catch (Exception e)
        {
            sRet += "0";
            return;
        }
        finally
        {
            sRet += "1";
        }
        sRet += "2";
    }
    public static void main(String[] args)
    {
        func(1);
        func(2);
        System.out.println(sRet); //1201
    }
}
```

***

## 异常

#### 分母为0 为运行时异常，jvm帮我们补货，无需代码里面显式捕获

Java的异常分为两种，一种是运行时异常（RuntimeException），一种是非运行异常也叫检查式异常（CheckedException）。

1、运行时异常不需要程序员去处理，当异常出现时，JVM会帮助处理。常见的运行时异常有：

ClassCastException(类转换异常)

ClassNotFoundException

IndexOutOfBoundsException(数组越界异常)

NullPointerException(空指针异常)

ArrayStoreException(数组存储异常，即数组存储类型不一致)

还有IO操作的BufferOverflowException异常

2、非运行异常需要程序员手动去捕获或者抛出异常进行显示的处理，因为Java认为Checked异常都是可以被修复的异常。常见的异常有：

IOException

SqlException

***

## static

可以用对象名来访问类中的静态方法(public权限)，但这样没什么意义

```java
public class Test{
    public static void print(){
        System.out.println("hehda");

    }
    public static void main(String[] args) {     
        Test test = new Test();
        test.print();
    }
}
```

***

## abstract

```java

 //抽象方法无法实例化，但是可以包含非抽象方法,抽象类的抽象方法，子类必须实现
public abstract class Abs {
    public void print(){
        System.out.println("heheda");
    }
    public abstract void print2();
}

public class Abse extends Abs {
    public static void main(String[] args) {
        Abse abse = new Abse();
        abse.print();
    }
    @Override
    public void print2() {	//必须实现父类抽象方法
    }
}


```

