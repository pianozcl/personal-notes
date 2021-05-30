#!/bin/bash


#特殊变量
# $0为当前脚本名字 $1 $2 $3.....为参数。例如 input:  bash parameter.sh p1 p2 p3 output: parameter.sh p1 p2 p3
echo "$0 $1 $2 $3"

#打印参数个数，例如bash parameter.sh p1 p2 p3 输出3
echo $#

echo $*

echo $@

# 判断上条命令是否正确执行，如果为0代表上条命令正确执行
echo $?
