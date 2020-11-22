## 前言

在阅读源码的时候，经常会碰到位运算，例如Java8中的HashMap部分源码。不同语言有各自的位运算方式，又大同小异。本篇文章带你一分钟彻底掌握Java中的位运算

```java
    /**
     * 这段代码是计算hashcode的，其中的位运算和异或运算是为了降低hash碰撞概率
     */
    static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```



## 正文

***

### 1. 整数的机器级表示

对于Java，int类型长度为32位。我这里为了方便说明，假设某种语言的整数类型位**4位**，那么能表示的的范围是多少？

* 如果是无符号类型，最大位二进制0～1111，也就是0～15
* 如果有符号，最高位符号位1代表负数，0代表正数，因此能表示的范围为二进制1000～0111，也就是-8～7

**为什么二进制1000等于-8？**

这就涉及到**补码编码**，以下是其定义

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201122170318.png)

也就是说，对于4位整数1000，最高位为1符号位，说明是一个负数。那么它的计算方式是：

* -1 * 2^3 + 0 * 2^2 + 0 * 2^1 + 0 * 2^0=-8+0+0+0=-8

再例如二进制的1111，按照这个计算方式结果是：

* -1 * 2^3 + 1 * 2^2 + 1 * 2^1 + 1 * 2^0=-8+4+2+1=-1



***

### 2. Java的位移运算

了解整数在机器中表示，就很容易能明白位移运算了。这里我拿Java中的int类型演示

int类型占32位，因此能表示的范围为**-2^31 ~ 2^31-1**，为了便于阅读，我这里把这个范围的十进制和二进制打印出来

可以看到

* int类型的十进制范围表示为：-2147483648～2147483647

* int类型的二进制表示范围为: 10000000 00000000 00000000 00000000 ～ 01111111 11111111 11111111 11111111

```java
public class BitShift {
    public static void main(String[] args) {
        System.out.println(Integer.MAX_VALUE);  //2147483647
        System.out.println(Integer.MIN_VALUE);  //-2147483648
        System.out.println(Integer.toBinaryString(Integer.MAX_VALUE));  // 01111111 11111111 11111111 11111111
        System.out.println(Integer.toBinaryString(Integer.MIN_VALUE));  // 10000000 00000000 00000000 00000000
    }
}
```



#### 左移<<

二进制数向左移动k位，**丢弃最高的k位**，并在有右边补k个0

* 01111111 11111111 11111111 11111111左移一位，符号位变成1，低位用0填充，所以结果位11111111 11111111 11111111 11111110，通过补码编码得出结果为-2
* 10000000 00000000 00000000 00000000左移一位，符号位变为0，代表正数，低位同样用0填充，结果位00000000 00000000 00000000 00000000，因此结果为0

```java
System.out.println(Integer.MAX_VALUE<<1);   //-2
System.out.println(Integer.toBinaryString(-2)); //11111111 11111111 11111111 11111110
------------------------------------------------
System.out.println(Integer.MIN_VALUE<<1);   //0
```



#### 算术右移>>

算术右移到方式比较微妙，二进制右移动k位，丢弃低k位，并在高k位补最高位的值。其目的是为了负数的运算

如下：算术右移动后，高位原本是几就用几补充

* 01111111 11111111 11111111 11111111算术右移1位为00111111 11111111 11111111 11111111
* 10000000 00000000 00000000 00000000算术右移1位为11000000 00000000 00000000 00000000

可以看到十进制无论是正还是负数，逻辑右移一位相当于除以二

```java
System.out.println(Integer.MAX_VALUE>>1);   //  1073741823
System.out.println(Integer.MIN_VALUE>>1);   //  -1073741824

System.out.println(Integer.toBinaryString(Integer.MAX_VALUE>>1));   //  00111111 11111111 11111111 11111111
System.out.println(Integer.toBinaryString(Integer.MIN_VALUE>>1));   //  11000000 00000000 00000000 00000000
```



#### 逻辑右移>>>

逻辑右移就很简单了，直接高k位补0，丢弃低k位

```java
System.out.println(Integer.MAX_VALUE>>>1);   //  1073741823
System.out.println(Integer.MIN_VALUE>>>1);   //  1073741824

System.out.println(Integer.toBinaryString(Integer.MAX_VALUE>>>1));   //  00111111 11111111 11111111 11111111
System.out.println(Integer.toBinaryString(Integer.MIN_VALUE>>>1));   //  01000000 00000000 00000000 00000000
```



### 3. C语言中的位运算

* 对于无符号整数，由移必须是逻辑的，也就是高位填充0

* 对于有符号整数，有些机器会进行算数右移，有些机器会逻辑右移动

以下为8位整数的位移情况

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20201122182217.png)



## 补充

一个数左移动或者右移动k位，**k非常大会是什么情况？**

可以看到，对于Java int类型，右移或者左移32位相当于没移动，位移33位相当于位移1位。这是因为位运算会先将k取模再进行位移。比如k=33%32=1

```java
System.out.println(Integer.MAX_VALUE);  //2147483647
System.out.println(Integer.MAX_VALUE>>32);  //2147483647

System.out.println(Integer.MAX_VALUE>>33);  //1073741823
System.out.println(Integer.MAX_VALUE>>1);   //1073741823

System.out.println(Integer.MAX_VALUE<<32);  //2147483647
System.out.println(Integer.MAX_VALUE>>>32); //2147483647
```

最后附上完整测试代码

```java
public class BitShift {
    public static void main(String[] args) {
        System.out.println(Integer.MAX_VALUE);  //2147483647
        System.out.println(Integer.MIN_VALUE);  //-2147483648
        System.out.println(Integer.toBinaryString(Integer.MAX_VALUE));  // 01111111 11111111 11111111 11111111
        System.out.println(Integer.toBinaryString(Integer.MIN_VALUE));  // 10000000 00000000 00000000 00000000

        System.out.println(Integer.MAX_VALUE<<1);   //-2
        System.out.println(Integer.MIN_VALUE<<1);   //0
        System.out.println(Integer.toBinaryString(-2)); //11111111 11111111 11111111 11111110

        System.out.println(Integer.MAX_VALUE>>1);   //  1073741823
        System.out.println(Integer.MIN_VALUE>>1);   //  -1073741824

        System.out.println(Integer.toBinaryString(Integer.MAX_VALUE>>1));   //  00111111 11111111 11111111 11111111
        System.out.println(Integer.toBinaryString(Integer.MIN_VALUE>>1));   //  11000000 00000000 00000000 00000000

        System.out.println(Integer.MAX_VALUE>>>1);   //  1073741823
        System.out.println(Integer.MIN_VALUE>>>1);   //  1073741824

        System.out.println(Integer.toBinaryString(Integer.MAX_VALUE>>>1));   //  00111111 11111111 11111111 11111111
        System.out.println(Integer.toBinaryString(Integer.MIN_VALUE>>>1));   //  01000000 00000000 00000000 00000000


        System.out.println(Integer.MAX_VALUE);  //2147483647
        System.out.println(Integer.MAX_VALUE>>32);  //2147483647

        System.out.println(Integer.MAX_VALUE>>33);  //1073741823
        System.out.println(Integer.MAX_VALUE>>1);   //1073741823

        System.out.println(Integer.MAX_VALUE<<32);  //2147483647
        System.out.println(Integer.MAX_VALUE>>>32); //2147483647
    }
}
```

