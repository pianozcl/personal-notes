### this

```js
    <script>
        //全局作用域中调用函数时，this 对象引用的就是 window，当用对象o调用，this引用对象o
        window.color = "red";
        var o = { color: "blue" };
        function sayColor() {
            alert(this.color);
        }
        sayColor();     //"red"
        o.sayColor = sayColor;
        o.sayColor();   //"blue"

    </script>
```



### caller

```js
    <script>   
        function outer() {
            inner();
        }

        function inner() {
            alert(inner.caller);//因为outer调用inner，所以弹出outer
        } 
        outer();
    </script>
```

