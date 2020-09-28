### 首先熟悉一下TCP头部

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200823134723.png)

***

### 抓包分析三次握手过程

#### 1.wireshark简单使用

>wireshark如何抓取指定IP的数据包？（这里的IP为我的服务器IP）
>
>* 可以通过过滤框通过表达式过滤：例如ip.src= =47.101.210.40 抓取源主机IP的数据包，ip.dst= =47.101.210.40代表目标主机的数据包
>* 因此抓取一个机器三次握手的数据包，可以用表达式ip.dst= =47.101.210.40 or ip.src= =47.101.210.40

#### 2.下层协议对传输层的支持，数据包是怎么找到目标机器的？（这里拿三次握手的第一个数据包来分析）

>1.TCP位于传输层，当接受到上层应用层请求的接口调用时，会生成一个Data长度为0的数据包

本案例我使用个人电脑（客户端），请求个人服务器，来分析三次握手（下图前三个数据包）

* 客户端发送一个SYNclient报文段，生成Seq（ISN初始化序列号）（**注意：这里的序列号0只是wireshark计算后的相对数字，真正的序列号是32位的36-61-df-71........**）

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200823124252.png)

* 服务器收到SYNclient数据包，也发送自己的SYN-server响应，包含初始化序列号Seq（ISN），并发送ACK（ACK=Seqclient+1）作为确认

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200823124601.png)

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200823124726.png)

* 最后客户端返回ACK（数值为服务器初始化序列号ISN+1）以确认服务端的SYN同步信号

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200823125004.png)

***

### TCP断开连接四次挥手过程

* 主动关闭者（这里是客户端）发送FIN段，和当前seq计为K，包含用于确认对方最后一次数据的ACK段计为L
* 服务器响应,ACK=k+1，seq=L
* 服务器发起主动关闭信号，向客户端发送FIN段，seq=L
* 客户端最后发送ACK用于确认服务器的FIN，如果FIN丢失，发送方会重传指导收到ACK响应

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200823134551.png)

