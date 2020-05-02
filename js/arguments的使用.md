#### 每个函数内置arguments对象，里面存储所有传过来的实参

特性

> 1.具有length属性，可以根据length遍历
>
> 2.按照索引的方式存储
>
> 3.没有真正数组的一些方法pop() push()等

***

示例1

```js
    <script>
        function fn(){
            console.log(arguments);
        }

        fn(1,2,3);
        fn(2,3,4);
    </script>
```

输出如下

![](https://raw.githubusercontent.com/matrixZCL/personal-notes/master/img/20200501233820.png)

***

示例2

```js
    <script>
      //示例：找出最大参数
      function getMax() {
        var max = arguments[0];
        for (var i = 0; i < arguments.length; i++) {
          if (arguments[i] > max) {
            max = arguments[i];
          }
        }
        return max;
      }

      console.log(getMax(1, 5, 8, 3, 9)); //输出9
    </script>
```

