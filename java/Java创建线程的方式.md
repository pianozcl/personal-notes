#### Java创建线程的方式

>##### 无论是什么方式，本质上都是实现Runnable接口的run方法，因为Thread也是实现了Runnable接口
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200718223414.png)

##### 示例一.启动一个线程观察其打印结果

>##### 可以看到，调用run方法是单个main线程顺序执行。调用start方法则是另外开启了一个线程
>
>```java
>import java.util.concurrent.TimeUnit;
>
>public class WhatIsThread {
>    private static class T1 extends Thread {
>        @Override
>        public void run() {
>           for(int i=0; i<10; i++) {
>               try {
>                   TimeUnit.MICROSECONDS.sleep(1);
>               } catch (InterruptedException e) {
>                   e.printStackTrace();
>               }
>               System.out.println("T1");
>           }
>        }
>    }
>
>    public static void main(String[] args) {
>//        new T1().run();
>        new T1().start();
>        for(int i=0; i<10; i++) {
>            try {
>                TimeUnit.MICROSECONDS.sleep(1);
>            } catch (InterruptedException e) {
>                e.printStackTrace();
>            }
>            System.out.println("main");
>        }
>
>    }
>}
>```
>
>##### 输出结果
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200718224224.png)
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200718224319.png)

***

#### 示例二.线程启动的三种方式

>```java
>public class HowToCreateThread {
>    static class MyThread extends Thread {
>        @Override
>        public void run() {
>            System.out.println("Hello MyThread!");
>        }
>    }
>
>    static class MyRun implements Runnable {
>        @Override
>        public void run() {
>            System.out.println("Hello MyRun!");
>        }
>    }
>
>    public static void main(String[] args) {
>        new MyThread().start();
>        new Thread(new MyRun()).start();
>        new Thread(()->{
>            System.out.println("Hello Lambda!");
>        }).start();
>    }
>}
>```
>
>##### 输出结果
>
>![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200718224606.png)

