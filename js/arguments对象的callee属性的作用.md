arguments对象有一个 callee 的属性，该属性是一个指针，指向拥有这个 arguments 对象的函数

示例

```js
    <script>
        function factorial(num) {
            if (num <= 1) {
                return 1;
            } else {
                return num * arguments.callee(num - 1)
                // return factorial(num); 这种情况以下输出均为0，因为factorial指向了另一个函数
            }
        }

        var trueFn=factorial;
        factorial=function(){
            return 0;
        }

        console.log(trueFn(5));//120
        console.log(factorial(5));//0

    </script>
```

