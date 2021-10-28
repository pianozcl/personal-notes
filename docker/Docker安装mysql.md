宿主机端口：容器服务端口

指定字符集

```shell
docker run --name=mysql5.6-utf8 -it -p 3308:3306 -e MYSQL_ROOT_PASSWORD=123456 -d e05271ec102f --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

