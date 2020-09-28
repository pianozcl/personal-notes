### Java线程Thread类方法sleep，yield，join

* #### Thread.sleep()是一个静态方法，作用是当前线程让出cpu占用并进入睡眠状态

* #### Thread.yield()也是静态方法，作用是使当前线程进入线程等待队列，相当于让出一下cpu的使用权

* #### join方法用于多个线程的协同工作，例如在线程t2中执行t1.join，则会等待线程t1执行完再执行t2

#### join方法示例代码

```java
public class TestJoin {
    public static void main(String[] args) {
        testJoin();
    }

    static void testJoin() {
        Thread t1 = new Thread(()->{
            for(int i=0; i<10; i++) {
                System.out.println("t1   " + i);
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        Thread t2 = new Thread(()->{

            for(int i=0; i<10; i++) {
                if(i==5){
                    try {
                        t1.join();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                System.out.println("t2   " + i);
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });
        t1.start();
        t2.start();
    }
}

```

#### 输出结果分析：i==5之前t1,t2交替执行。当i==5时执行t2.join()，直到t1执行完t2才继续执行

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200718231744.png)

