变量

```shell
控制台
A=3 //这种只在当前进程有效
export D
```

运算符

```shell
//计算（2+3）*4的几种方式
expr `expr 2 + 3` \* 4  
echo $[(2+3)*4]

```

工具

cut，切割文本(不会改变源文件)

```shell
文本
qwe qwe2
asd asd2
zxc zxc2
cut -d " " -f 1 cut.txt		//-d以什么分割，-f取第几列	cut -d " " -f 1,2 cut.txt
输出
qwe
asd
zxc

cat cut.txt| grep qwe2 | cut -d " " -f 2		输出//qwe2
echo $PATH | cut -d : -f 5-
```

sed

```shell
	sed "2a xxx xxx2" sed.txt	//添加xxx xxx2到第二行
	sed "/xxx/d" sed.txt			//删除包含xxx的行
	sed "s/qwe/ewq/g" sed.txt	//qwe替换为ewq，/g代表全局替换
	sed -e "2d" -e "s/qwe/ewq/g" sed.txt //删除第二行，再将qwe全局替换为ewq
```

awk

```shell
awk -F : '/^root/ {print $7}' passwd  //以:做分割，取以root开头的行的第七列
awk -F : '/^root/ {print $1","$7}' passwd //以:做分割，取以root开头的行的第一列，第七列，结果以逗号隔开
awk -F : -v i=1 '{print $3+i}' passwd  //第三列全部加1并打印
awk -F : '{print FILENAME "," NR "," NF}' passwd      //打印当前文件名，第几行，多少列
awk '/^$/ {print NR}' awk.txt //打印空行所在的行号
```

sort

```shell
//源文件
3:1
2:5
4:3
1:1
5:7
sort -t : -nrk 2 sort.txt		//-t以：分割，-n以数值排序，-r大小倒序，-k指定排序的列
5:7
2:5
4:3
3:1
1:1
```

