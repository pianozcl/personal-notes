### 利用C标准库函数实现IO操作

```c
#include <stdio.h>
main()
{
    int c;
    c=getchar();		//用于读取字符
    while (c!=EOF) {			//EOF，end of file
        putchar(c);		//写入字符
        c=getchar();
    }
}

```

执行结果如下

![](https://superzcl.oss-cn-shanghai.aliyuncs.com/PicGo/20200614141917.png)

