#!/bin/bash

# 可搭配$* 获取输入参数

for i in $*
do
	echo "hello $i"
done

# 作为整体打印
for i in "$*"
do
        echo "hello $i"
done

# $@无论是否加引号，都是单独输出
for i in "$@"
do 
	echo "hello $i"
done
