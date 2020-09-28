```java
import java.util.List;



public class Fib {
    public static void main(String[] args) {
        int n=40;
        long[] arr=new long[51];

        long t1 = System.currentTimeMillis();
        long fib1 = fib(arr, n);
        long t2 = System.currentTimeMillis();
        System.out.println("普通版"+fib1+"---"+(t2-t1));

        long t3 = System.currentTimeMillis();
        long fib2 = fib(n);
        long t4 = System.currentTimeMillis();
        System.out.println("优化版"+fib2+"---"+(t4-t3));

        System.out.println("*********************");
        System.out.println("动态规划版"+dpFib(n));
        System.out.println("动态规划优化"+dpFibOptimization(n));

    }


    /**
     * 时间复杂度O(n^2)
     * 因为子问题个数就是递归二叉树节点个数，存在重复计算子问题。
     * 由于想要求出f(5),需要先求f(4)和f(3),f(3)又要先求出f(2)(1)......也叫做自顶向下求解
     */
    public static long fib(int n){
        if(n==1||n==2){
            return 1;
        }
        return fib(n-1)+fib(n-2);
    }

    /**
     * 时间复杂度为O(n),空间复杂度O(n)
     * 通过数组记录子问题解,避免重复计算子问题。
     */
    public static long fib(long[] arr,int n){
        if(n==1||n==2){
            return 1;
        }
        if(arr[n]!=0){
            return arr[n];
        }
        arr[n]=fib(arr,n-1)+fib(arr,n-2);
        return arr[n];
    }

    /**
     * 时间复杂度为O(n),空间复杂度O(n)
     * 动态规划版，子问题个数n个，从f(1)....到f(n),也叫做自底向上求解
     */
    public static long dpFib(int n){
        long[] arr=new long[n+1];
        arr[1]=arr[2]=1;
        for(int i=3 ;i<=n;i++){
            arr[i]=arr[i-1]+arr[i-2];
        }
        return arr[n];
    }

    /**
     * 时间复杂度为O(n),通过复用变量,降低空间复杂度为O(1)
     */
    public static long dpFibOptimization(int n){
        if(n==1||n==2){
            return 1;
        }
        long a=1,b=1,c;
        for(int i=3;i<=n;i++){
            c=a+b;
            a=b;
            b=c;
        }
        return b;
    }

}


```

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200809005205.png)

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200809005930.png)

