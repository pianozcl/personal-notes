#### LockSupport的使用

* LockSupport.park()可以停止线程并进入waiting状态
* LockSupport.unpark(t);使线程继续运行，可以叫醒指定的线程t。可以先于park之前调用

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200718233149.png)

```java
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.LockSupport;

public class TestLockSupport {
    public static void main(String[] args) {
        Thread t = new Thread(()->{
            for (int i = 0; i < 10; i++) {
                System.out.println(i);
                if(i == 5) {
                    //停止线程进入waiting
                    LockSupport.park();
                }
                try {
                    TimeUnit.SECONDS.sleep(1);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });

        t.start();
        
        //使线程继续运行，可以叫醒指定的线程t。可以先于park之前调用
        LockSupport.unpark(t);
    }
}

```

